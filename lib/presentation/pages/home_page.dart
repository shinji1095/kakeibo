import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/period_calendar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider);
    final settings = ref.watch(settingsProvider);
    final calendarSummaryAsync = ref.watch(homeCalendarSummaryProvider);
    final bonusSummaryAsync = ref.watch(bonusSummaryProvider);
    final endInclusive = stats.periodEndExclusive.subtract(const Duration(days: 1));

    return AppScaffold(
      title: l10n.homeTitle,
      currentIndex: 0,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.homeCurrentPeriod, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.homeStartDate}: ${l10n.formatLongDate(stats.periodStart)}'),
                  Text('${l10n.homeEndDate}: ${l10n.formatLongDate(endInclusive)}'),
                  Text(l10n.homePeriodLengthLabel(stats.periodLengthDays)),
                  const SizedBox(height: 8),
                  Text(l10n.homeDaysRemaining(stats.daysUntilPeriodEnd)),
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
                      Text(l10n.homeCalendarTitle, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.homeBudgetRemainingLabel),
                          Text(l10n.formatCurrency(remaining), style: remainingStyle),
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
                    Text(l10n.homeCalendarTitle, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                    PeriodCalendar(
                      periodStart: stats.periodStart,
                      periodLengthDays: stats.periodLengthDays,
                      appStart: settings.kakeiboStartDate,
                      totalsByDay: const <DateTime, ({int income, int expense})>{},
                    ),
                  ],
                ),
                error: (e, st) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.homeCalendarTitle, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Text(l10n.errorMessage(e)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: bonusSummaryAsync.when(
                data: (summary) {
                  if (!summary.isBonusMonth) {
                    return Text(l10n.bonusMonthInactive);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.bonusSummaryTitle, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.bonusBalanceLabel),
                          Text(l10n.formatCurrency(summary.bonusBalance)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.bonusExpenseTotalLabel),
                          Text(l10n.formatCurrency(summary.bonusExpenseTotal)),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text(l10n.errorMessage(e)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
