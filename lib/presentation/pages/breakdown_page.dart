import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/utils/category_icons.dart';
import 'package:kakeibo/presentation/utils/period_header_utils.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_filter_chips.dart';
import 'package:kakeibo/presentation/widgets/period_header.dart';

class BreakdownPage extends ConsumerWidget {
  const BreakdownPage({super.key});

  void _shiftPeriod(WidgetRef ref, int delta) {
    ref.read(periodOffsetProvider.notifier).state += delta;
  }

  Future<void> _showRangeBasisDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    var selection = ref.read(rangeBasisProvider);
    final result = await showDialog<RangeBasis>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rangeBasisTitle),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<RangeBasis>(
                title: Text(l10n.rangeBasisPeriod),
                value: RangeBasis.period,
                groupValue: selection,
                onChanged: (value) => setState(() => selection = value ?? selection),
              ),
              RadioListTile<RangeBasis>(
                title: Text(l10n.rangeBasisMonth),
                value: RangeBasis.month,
                groupValue: selection,
                onChanged: (value) => setState(() => selection = value ?? selection),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(selection),
            child: Text(l10n.dialogOk),
          ),
        ],
      ),
    );
    if (result != null) {
      ref.read(rangeBasisProvider.notifier).state = result;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(periodRangeProvider);
    final basis = ref.watch(rangeBasisProvider);
    final scheduleMap = ref.watch(annualSchedulesAroundNowProvider);
    final schedule = scheduleMap[range.start.year];
    final endInclusive = range.end.subtract(const Duration(days: 1));
    final headerTitle = buildPeriodHeaderTitle(
      l10n: l10n,
      basis: basis,
      rangeStart: range.start,
      rangeEndExclusive: range.end,
      schedule: schedule,
    );
    final headerSubtitle = buildPeriodHeaderSubtitle(
      l10n: l10n,
      rangeStart: range.start,
      rangeEndInclusive: endInclusive,
    );
    return AppScaffold(
      title: l10n.breakdownTitle,
      currentIndex: 3,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PeriodHeader(
            title: headerTitle,
            subtitle: headerSubtitle,
            onPrev: () => _shiftPeriod(ref, -1),
            onNext: () => _shiftPeriod(ref, 1),
            onRangeTap: () => _showRangeBasisDialog(context, ref),
          ),
          const SizedBox(height: 4),
          Text(l10n.expenseAttribute),
          const SizedBox(height: 4),
          const ExpenseAttributeFilterChips(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.breakdownExpenseCategory),
                  const SizedBox(height: 8),
                  const _Pie(type: TransactionType.expense),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.breakdownIncomeCategory),
                  const SizedBox(height: 8),
                  const _Pie(type: TransactionType.income),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pie extends ConsumerWidget {
  final TransactionType type;
  const _Pie({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(periodCategoryTotalsProvider(type));
    final categoriesAsync = ref.watch(categoriesProvider);

    return dataAsync.when(
      data: (map) {
        if (map.isEmpty) return Center(child: Text(l10n.noData));
        final categories = {
          for (final c in categoriesAsync.value ?? const <Category>[])
            if (c.id != null) c.id!: c,
        };

        final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        final sum = map.values.fold<int>(0, (a, b) => a + b);
        final sections = <PieChartSectionData>[];
        for (final entry in entries) {
          final cat = categories[entry.key];
          final color = cat != null ? Color(cat.color) : _seededColor(entry.key);
          sections.add(PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${(entry.value / (sum == 0 ? 1 : sum) * 100).toStringAsFixed(0)}%',
            radius: 70,
            color: color,
          ));
        }

        return Column(
          children: [
            SizedBox(
              height: 220,
              child: PieChart(PieChartData(sections: sections)),
            ),
            const SizedBox(height: 8),
            ...entries.map((entry) {
              final cat = categories[entry.key];
              final name = cat?.name ?? l10n.categoryFallback(entry.key);
              final color = cat != null ? Color(cat.color) : Theme.of(context).colorScheme.primary;
              final iconColor = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                  ? Colors.white
                  : Colors.black;
              final iconData = cat != null ? categoryIconFor(cat) : Icons.category;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: color,
                            child: Icon(iconData, size: 14, color: iconColor),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(l10n.formatCurrency(entry.value)),
                  ],
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(l10n.errorMessage(e))),
    );
  }

  Color _seededColor(int seed) {
    final rnd = Random(seed);
    return Color((rnd.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }
}
