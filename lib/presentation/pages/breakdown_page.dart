import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/utils/category_icons.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_filter_chips.dart';

class BreakdownPage extends ConsumerWidget {
  const BreakdownPage({super.key});

  void _shiftPeriod(WidgetRef ref, int delta) {
    ref.read(periodOffsetProvider.notifier).state += delta;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(periodRangeProvider);
    final endInclusive = range.end.subtract(const Duration(days: 1));
    return AppScaffold(
      title: l10n.breakdownTitle,
      currentIndex: 3,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shiftPeriod(ref, -1),
              ),
              Text(
                '${l10n.formatDate(range.start)}${l10n.rangeSeparator}${l10n.formatDate(endInclusive)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shiftPeriod(ref, 1),
              ),
            ],
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
