import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _formatDate(DateTime d) => '${d.year}年${d.month}月${d.day}日';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsProvider);
    final endInclusive = stats.periodEndExclusive.subtract(const Duration(days: 1));

    return AppScaffold(
      title: 'ホーム',
      currentIndex: 0,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('現在の期間', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('開始日: ${_formatDate(stats.periodStart)}'),
                  Text('終了日: ${_formatDate(endInclusive)}'),
                  Text('期間長: ${stats.periodLengthDays}日'),
                  const SizedBox(height: 8),
                  Text('終了まであと${stats.daysUntilPeriodEnd}日'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('期間カレンダー/収支/残額表示は未実装です（プレースホルダー）'),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('ボーナス表示は未実装です（プレースホルダー）'),
            ),
          ),
        ],
      ),
    );
  }
}