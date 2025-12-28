import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/period_calendar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _formatDate(DateTime d) => '${d.year}年${d.month}月${d.day}日';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsProvider);
    final settings = ref.watch(settingsProvider);
    final calendarSummaryAsync = ref.watch(homeCalendarSummaryProvider);
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: calendarSummaryAsync.when(
                data: (summary) {
                  final remaining = summary.remainingBudget;
                  final remainingStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: remaining < 0 ? Colors.red : Colors.green,
                      );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('期間カレンダー', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('やりくり費 残額'),
                          Text('${remaining}円', style: remainingStyle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PeriodCalendar(
                        periodStart: stats.periodStart,
                        periodLengthDays: stats.periodLengthDays,
                        appStart: settings.kakeiboStartDate,
                        totalsByDay: summary.totalsByDay,
                      ),
                    ],
                  );
                },
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('期間カレンダー', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                    PeriodCalendar(
                      periodStart: stats.periodStart,
                      periodLengthDays: stats.periodLengthDays,
                      appStart: settings.kakeiboStartDate,
                      totalsByDay: <DateTime, ({int income, int expense})>{},
                    ),
                  ],
                ),
                error: (e, st) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('期間カレンダー', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Text('Error: $e'),
                  ],
                ),
              ),
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
