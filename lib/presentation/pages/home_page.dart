import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/period_calendar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(preloadAnnualSchedulesProvider);
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider);
    final calendarSummaryAsync = ref.watch(homeCalendarSummaryProvider);
    final now = DateTime.now();
    final incomeRange = _formatRange(
      l10n,
      DateTime(now.year, now.month - 1, 1),
      DateTime(now.year, now.month, 0),
    );
    final fixedRange = _formatRange(
      l10n,
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    );
    final periodLabel = l10n.homePeriodLabel(stats.periodIndex + 1);

    return AppScaffold(
      title: l10n.homeTitle,
      currentIndex: 0,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
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
                      _CalendarHeader(
                        periodLabel: periodLabel,
                        periodColor: stats.periodColor,
                        incomeRange: incomeRange,
                        fixedRange: fixedRange,
                        budgetLabel: l10n.homeBudgetLabel,
                        budgetValue: l10n.formatCurrency(remaining),
                        budgetValueStyle: remainingStyle,
                        onBudgetTap: () => context.push('/settings/budget'),
                      ),
                      const SizedBox(height: 12),
                      PeriodCalendar(
                        totalsByDay: summary.totalsByDay,
                        onDateTap: (date) => context.go('/input', extra: date),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/settings/annual'),
                          icon: const Icon(Icons.calendar_month),
                          label: Text(l10n.annualSchedule),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CalendarHeader(
                      periodLabel: periodLabel,
                      periodColor: stats.periodColor,
                      incomeRange: incomeRange,
                      fixedRange: fixedRange,
                      budgetLabel: l10n.homeBudgetLabel,
                      budgetValue: l10n.formatCurrency(0),
                      budgetValueStyle: Theme.of(context).textTheme.titleMedium,
                      onBudgetTap: () => context.push('/settings/budget'),
                    ),
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                    PeriodCalendar(
                      totalsByDay: const <DateTime, ({int income, int expense})>{},
                      onDateTap: (date) => context.go('/input', extra: date),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/settings/annual'),
                        icon: const Icon(Icons.calendar_month),
                        label: Text(l10n.annualSchedule),
                      ),
                    ),
                  ],
                ),
                error: (e, st) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CalendarHeader(
                      periodLabel: periodLabel,
                      periodColor: stats.periodColor,
                      incomeRange: incomeRange,
                      fixedRange: fixedRange,
                      budgetLabel: l10n.homeBudgetLabel,
                      budgetValue: l10n.formatCurrency(0),
                      budgetValueStyle: Theme.of(context).textTheme.titleMedium,
                      onBudgetTap: () => context.push('/settings/budget'),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.errorMessage(e)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final String periodLabel;
  final Color periodColor;
  final String incomeRange;
  final String fixedRange;
  final String budgetLabel;
  final String budgetValue;
  final TextStyle? budgetValueStyle;
  final VoidCallback onBudgetTap;

  const _CalendarHeader({
    required this.periodLabel,
    required this.periodColor,
    required this.incomeRange,
    required this.fixedRange,
    required this.budgetLabel,
    required this.budgetValue,
    required this.budgetValueStyle,
    required this.onBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: const Key('home-period-label'),
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: periodColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            periodLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _PeriodRangeRow(label: AppLocalizations.of(context).homeIncomeLabel, range: incomeRange),
              const SizedBox(height: 6),
              _PeriodRangeRow(label: AppLocalizations.of(context).homeFixedSpecialLabel, range: fixedRange),
              const SizedBox(height: 6),
              InkWell(
                key: const Key('home-budget-link'),
                borderRadius: BorderRadius.circular(6),
                onTap: onBudgetTap,
                child: _PeriodRangeRow(
                  label: budgetLabel,
                  range: budgetValue,
                  rangeStyle: budgetValueStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeriodRangeRow extends StatelessWidget {
  final String label;
  final String range;
  final TextStyle? rangeStyle;

  const _PeriodRangeRow({
    required this.label,
    required this.range,
    this.rangeStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(range, style: rangeStyle),
      ],
    );
  }
}

String _formatRange(AppLocalizations l10n, DateTime start, DateTime end) {
  return '${l10n.formatShortDate(start)}${l10n.rangeSeparator}${l10n.formatShortDate(end)}';
}
