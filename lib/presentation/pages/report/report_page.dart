import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('レポート')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${month.year}年${month.month}月', style: Theme.of(context).textTheme.titleLarge),
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
      bottomNavigationBar: const _BottomNav(currentIndex: 2),
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
              // random color for demo (in real app, load from category table)
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

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/calendar');
            break;
          case 2:
            break;
          case 3:
            context.go('/assets');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.edit), label: '入力'),
        NavigationDestination(icon: Icon(Icons.calendar_month), label: 'カレンダー'),
        NavigationDestination(icon: Icon(Icons.pie_chart), label: 'レポート'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: '資産'),
      ],
    );
  }
}
