import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';

class BreakdownPage extends ConsumerWidget {
  const BreakdownPage({super.key});

  void _shiftMonth(WidgetRef ref, DateTime month, int delta) {
    ref.read(monthProvider.notifier).state = DateTime(month.year, month.month + delta);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthProvider);
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
                onPressed: () => _shiftMonth(ref, month, -1),
              ),
              Text('${month.year}年${month.month}月', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shiftMonth(ref, month, 1),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('期間/属性フィルタは未実装（プレースホルダー）'),
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
}

class _Pie extends ConsumerWidget {
  final TransactionType type;
  const _Pie({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthProvider);
    final dataAsync = ref.watch(monthlySummaryProvider((month: month, type: type)));
    return SizedBox(
      height: 220,
      child: dataAsync.when(
        data: (map) {
          if (map.isEmpty) return const Center(child: Text('データがありません'));
          final sum = map.values.fold<int>(0, (a, b) => a + b);
          final sections = <PieChartSectionData>[];
          final rnd = Random(42);
          map.forEach((catId, total) {
            sections.add(PieChartSectionData(
              value: total.toDouble(),
              title: '${(total / (sum == 0 ? 1 : sum) * 100).toStringAsFixed(0)}%',
              radius: 70,
              color: Color((rnd.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
            ));
          });
          return PieChart(PieChartData(sections: sections));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}