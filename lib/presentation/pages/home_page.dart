import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/period_calendar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _initialPage = 12000;

  late final DateTime _initialMonth;
  late final PageController _calendarPageController;
  late DateTime _displayedMonth;
  var _currentPage = _initialPage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _initialMonth = DateTime(now.year, now.month, 1);
    _displayedMonth = _initialMonth;
    _calendarPageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _calendarPageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) => DateTime(
      _initialMonth.year, _initialMonth.month + page - _initialPage, 1);

  void _shiftMonth(int offset) {
    _calendarPageController.animateToPage(
      _currentPage + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(preloadAnnualSchedulesProvider);
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider);
    final calendarSummaryAsync = ref.watch(homeCalendarSummaryProvider);
    final monthTotalsAsync =
        ref.watch(homeMonthTotalsProvider(_displayedMonth));
    final showPeriodColors = ref.watch(homePeriodColorsEnabledProvider);
    final remainingBudget = calendarSummaryAsync.valueOrNull?.remainingBudget;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CalendarHeader(
                    periodLabel: periodLabel,
                    periodColor: stats.periodColor,
                    incomeRange: incomeRange,
                    fixedRange: fixedRange,
                    budgetLabel: l10n.homeBudgetLabel,
                    budgetValue: l10n.formatCurrency(remainingBudget ?? 0),
                    budgetValueStyle:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: remainingBudget == null
                                  ? null
                                  : remainingBudget < 0
                                      ? Colors.red
                                      : Colors.green,
                            ),
                    onBudgetTap: () => context.push('/settings/budget'),
                  ),
                  if (calendarSummaryAsync.isLoading ||
                      monthTotalsAsync.isLoading) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                  if (calendarSummaryAsync.hasError) ...[
                    const SizedBox(height: 12),
                    Text(l10n.errorMessage(calendarSummaryAsync.error!)),
                  ],
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) => SizedBox(
                      height: PeriodCalendar.heightForWidth(
                          context, constraints.maxWidth),
                      child: PageView.builder(
                        key: const Key('home-month-calendar'),
                        controller: _calendarPageController,
                        onPageChanged: (page) {
                          setState(() {
                            _currentPage = page;
                            _displayedMonth = _monthForPage(page);
                          });
                        },
                        itemBuilder: (context, page) {
                          final month = _monthForPage(page);
                          return Consumer(builder: (context, ref, _) {
                            final totals =
                                ref.watch(homeMonthTotalsProvider(month));
                            final previousSchedule = ref
                                .watch(
                                  annualScheduleForYearProvider(month.year - 1),
                                )
                                .valueOrNull;
                            final currentSchedule = ref
                                .watch(
                                  annualScheduleForYearProvider(month.year),
                                )
                                .valueOrNull;
                            final nextSchedule = ref
                                .watch(
                                  annualScheduleForYearProvider(month.year + 1),
                                )
                                .valueOrNull;
                            return PeriodCalendar(
                              displayedMonth: month,
                              totalsByDay: totals.valueOrNull ??
                                  const <DateTime,
                                      ({int income, int expense})>{},
                              annualSchedules: [
                                if (previousSchedule != null) previousSchedule,
                                if (currentSchedule != null) currentSchedule,
                                if (nextSchedule != null) nextSchedule,
                              ],
                              showPeriodColors:
                                  ref.watch(homePeriodColorsEnabledProvider),
                              onMonthChanged: _shiftMonth,
                              onDateTap: (date) =>
                                  context.go('/input', extra: date),
                            );
                          });
                        },
                      ),
                    ),
                  ),
                  if (monthTotalsAsync.hasError) ...[
                    const SizedBox(height: 12),
                    Text(l10n.errorMessage(monthTotalsAsync.error!)),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('home-period-colors-toggle'),
                      onPressed: () {
                        final notifier =
                            ref.read(homePeriodColorsEnabledProvider.notifier);
                        notifier.state = !notifier.state;
                      },
                      icon: Icon(showPeriodColors
                          ? Icons.palette
                          : Icons.palette_outlined),
                      label: Text(showPeriodColors
                          ? l10n.homePeriodColorsOn
                          : l10n.homePeriodColorsOff),
                    ),
                  ),
                  const SizedBox(height: 8),
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
              _PeriodRangeRow(
                  label: AppLocalizations.of(context).homeIncomeLabel,
                  range: incomeRange),
              const SizedBox(height: 6),
              _PeriodRangeRow(
                  label: AppLocalizations.of(context).homeFixedSpecialLabel,
                  range: fixedRange),
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
