import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_filter_chips.dart';

class BreakdownPage extends ConsumerWidget {
  const BreakdownPage({super.key});

  void _shiftPeriod(WidgetRef ref, int delta) {
    ref.read(periodOffsetProvider.notifier).state += delta;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(periodRangeProvider);
    final endInclusive = range.end.subtract(const Duration(days: 1));
    return AppScaffold(
      title: '内訳',
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
                '${_formatDate(range.start)} 〜 ${_formatDate(endInclusive)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shiftPeriod(ref, 1),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('支出属性'),
          const SizedBox(height: 4),
          const ExpenseAttributeFilterChips(),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('支出カテゴリ内訳'),
                  SizedBox(height: 8),
                  _Pie(type: TransactionType.expense),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('収入カテゴリ内訳'),
                  SizedBox(height: 8),
                  _Pie(type: TransactionType.income),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';
}

class _Pie extends ConsumerWidget {
  final TransactionType type;
  const _Pie({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(periodCategoryTotalsProvider(type));
    final categoriesAsync = ref.watch(categoriesProvider);

    return dataAsync.when(
        data: (map) {
          if (map.isEmpty) return const Center(child: Text('データがありません'));
          final categories = {
            for (final c in categoriesAsync.value ?? const <Category>[])
              if (c.id != null) c.id!: c,
          };

          final entries = map.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final sum = map.values.fold<int>(0, (a, b) => a + b);
          final sections = <PieChartSectionData>[];
          for (final entry in entries) {
            final cat = categories[entry.key];
            final color = cat != null
                ? Color(cat.color)
                : _seededColor(entry.key);
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
                final name = cat?.name ?? 'カテゴリ${entry.key}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(name)),
                      Text('${entry.value} 円'),
                    ],
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      );
  }

  Color _seededColor(int seed) {
    final rnd = Random(seed);
    return Color((rnd.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }
}
