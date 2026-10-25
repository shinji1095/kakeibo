import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';
import 'package:kakeibo/presentation/utils/annual_schedule_colors.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/period_calendar.dart';

typedef _PeriodId = ({int year, int index});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _initialPage = 12000;
  static const _yearMarkerWidth = 52.0;
  static const _periodTileWidth = 72.0;

  late final DateTime _initialMonth;
  late final PageController _calendarPageController;
  final ScrollController _periodScrollController = ScrollController();
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  var _currentPage = _initialPage;
  _PeriodId? _selectedPeriod;
  _PeriodId? _lastCenteredPeriod;
  String? _lastTimelineSignature;
  _PeriodId? _pendingPeriod;
  int? _pendingPage;
  DateTime? _pendingDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _initialMonth = DateTime(now.year, now.month, 1);
    _displayedMonth = _initialMonth;
    _selectedDate = DateTime(now.year, now.month, now.day);
    _calendarPageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _calendarPageController.dispose();
    _periodScrollController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) => DateTime(
      _initialMonth.year, _initialMonth.month + page - _initialPage, 1);

  int _pageForMonth(DateTime month) =>
      _initialPage +
      (month.year - _initialMonth.year) * 12 +
      month.month -
      _initialMonth.month;

  DateTime _defaultDateForMonth(DateTime month) {
    final now = DateTime.now();
    return now.year == month.year && now.month == month.month
        ? DateTime(now.year, now.month, now.day)
        : DateTime(month.year, month.month, 1);
  }

  _PeriodId? _periodIdForDate(List<AnnualSchedule> schedules, DateTime date) {
    for (final schedule in schedules) {
      for (final period in schedule.periods) {
        if (!date.isBefore(period.startDate) && !date.isAfter(period.endDate)) {
          return (year: schedule.year, index: period.index);
        }
      }
    }
    return null;
  }

  void _shiftMonth(int offset) {
    _calendarPageController.animateToPage(
      _currentPage + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectPeriod(AnnualSchedule schedule, AnnualSchedulePeriod period) {
    final selected = (year: schedule.year, index: period.index);
    final page = _pageForMonth(period.startDate);
    if (page == _currentPage) {
      setState(() {
        _selectedPeriod = selected;
        _selectedDate = period.startDate;
      });
      return;
    }
    _pendingPeriod = selected;
    _pendingPage = page;
    _pendingDate = period.startDate;
    _calendarPageController.jumpToPage(page);
  }

  void _selectDate(DateTime date, List<AnnualSchedule> schedules) {
    final selected = _periodIdForDate(schedules, date);
    final page = _pageForMonth(date);
    if (page == _currentPage) {
      setState(() {
        _selectedDate = date;
        _selectedPeriod = selected;
      });
      return;
    }
    _pendingPeriod = selected;
    _pendingPage = page;
    _pendingDate = date;
    _calendarPageController.jumpToPage(page);
  }

  void _onCalendarPageChanged(int page) {
    final selected = page == _pendingPage ? _pendingPeriod : null;
    final selectedDate = page == _pendingPage ? _pendingDate : null;
    _pendingPeriod = null;
    _pendingPage = null;
    _pendingDate = null;
    setState(() {
      _currentPage = page;
      _displayedMonth = _monthForPage(page);
      _selectedPeriod = selected;
      _selectedDate = selectedDate ?? _defaultDateForMonth(_displayedMonth);
    });
  }

  _PeriodId? _periodForDisplayedMonth(List<AnnualSchedule> schedules) {
    final selected = _selectedPeriod;
    if (selected != null &&
        schedules.any((schedule) =>
            schedule.year == selected.year &&
            schedule.periods.any((period) => period.index == selected.index))) {
      return selected;
    }

    final anchor = _selectedDate;
    _PeriodId? previous;
    for (final schedule in schedules) {
      for (final period in schedule.periods) {
        if (!anchor.isBefore(period.startDate) &&
            !anchor.isAfter(period.endDate)) {
          return (year: schedule.year, index: period.index);
        }
        if (!period.startDate.isAfter(anchor)) {
          previous = (year: schedule.year, index: period.index);
        }
      }
    }
    return previous;
  }

  Widget _buildPeriodTimeline(
    BuildContext context,
    List<AnnualSchedule> schedules,
    _PeriodId? selected,
  ) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colorsByYear = {
      for (final schedule in schedules)
        schedule.year: buildAnnualScheduleColors(schedule.periods.length),
    };
    return LayoutBuilder(builder: (context, constraints) {
      final signature = schedules
          .map((schedule) => '${schedule.year}:${schedule.periods.length}')
          .join(',');
      if (selected != null &&
          (selected != _lastCenteredPeriod ||
              signature != _lastTimelineSignature)) {
        _lastCenteredPeriod = selected;
        _lastTimelineSignature = signature;
        var itemStart = 0.0;
        double? selectedCenter;
        for (final schedule in schedules) {
          itemStart += _yearMarkerWidth;
          for (final period in schedule.periods) {
            if (schedule.year == selected.year &&
                period.index == selected.index) {
              selectedCenter = itemStart + _periodTileWidth / 2;
            }
            itemStart += _periodTileWidth;
          }
        }
        if (selectedCenter != null) {
          final target = selectedCenter - constraints.maxWidth / 2;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_periodScrollController.hasClients) return;
            _periodScrollController.animateTo(
              target.clamp(
                  0.0, _periodScrollController.position.maxScrollExtent),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          });
        }
      }

      return SingleChildScrollView(
        key: const Key('home-period-timeline'),
        controller: _periodScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final schedule in schedules) ...[
              SizedBox(
                width: _yearMarkerWidth,
                child: Text(
                  '${schedule.year}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              for (final period in schedule.periods)
                SizedBox(
                  width: _periodTileWidth,
                  child: Tooltip(
                    message:
                        '${l10n.formatDate(period.startDate)}${l10n.rangeSeparator}${l10n.formatDate(period.endDate)}',
                    child: InkWell(
                      key: Key('home-period-${schedule.year}-${period.index}'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _selectPeriod(schedule, period),
                      child: Semantics(
                        selected: selected ==
                            (year: schedule.year, index: period.index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorsByYear[schedule.year]![
                                      period.index],
                                  border: Border.all(
                                    color: selected ==
                                            (
                                              year: schedule.year,
                                              index: period.index
                                            )
                                        ? scheme.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.homeTimelinePeriodLabel(period.index + 1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontWeight: selected ==
                                              (
                                                year: schedule.year,
                                                index: period.index
                                              )
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider);
    final monthSummaryAsync =
        ref.watch(homeMonthSummaryProvider(_displayedMonth));
    final showPeriodColors = ref.watch(homePeriodColorsEnabledProvider);
    final periodBudget = ref.watch(settingsProvider).periodBudget;

    final schedulesByYear = <int, AnnualSchedule>{};
    var schedulesLoading = false;
    for (var year = _displayedMonth.year - 1;
        year <= _displayedMonth.year + 1;
        year++) {
      final scheduleAsync = ref.watch(annualScheduleForYearProvider(year));
      schedulesLoading |= scheduleAsync.isLoading;
      final schedule = scheduleAsync.valueOrNull;
      if (schedule != null) schedulesByYear[year] = schedule;
    }
    final currentScheduleAsync = ref.watch(currentAnnualScheduleProvider);
    schedulesLoading |= currentScheduleAsync.isLoading;
    final currentSchedule = currentScheduleAsync.valueOrNull;
    if (currentSchedule != null &&
        currentSchedule.year >= _displayedMonth.year - 1 &&
        currentSchedule.year <= _displayedMonth.year + 1) {
      schedulesByYear.putIfAbsent(currentSchedule.year, () => currentSchedule);
    }
    final schedules = schedulesByYear.values.toList()
      ..sort((a, b) => a.year.compareTo(b.year));
    final selectedPeriod = _periodForDisplayedMonth(schedules);
    AnnualSchedulePeriod? selectedSchedulePeriod;
    if (selectedPeriod != null) {
      for (final schedule in schedules) {
        if (schedule.year != selectedPeriod.year) continue;
        for (final period in schedule.periods) {
          if (period.index == selectedPeriod.index) {
            selectedSchedulePeriod = period;
            break;
          }
        }
      }
    }
    final periodRange = (
      start: selectedSchedulePeriod?.startDate ?? stats.periodStart,
      endExclusive:
          selectedSchedulePeriod?.endDate.add(const Duration(days: 1)) ??
              stats.periodEndExclusive,
    );
    final periodTotalAsync =
        ref.watch(homePeriodVariableTotalProvider(periodRange));
    final dailyPeriod = selectedSchedulePeriod != null &&
            !_selectedDate.isBefore(selectedSchedulePeriod.startDate) &&
            !_selectedDate.isAfter(selectedSchedulePeriod.endDate)
        ? selectedSchedulePeriod
        : null;
    final monthSummary = monthSummaryAsync.valueOrNull;
    final dailyIncome = monthSummary == null
        ? null
        : monthSummary.totalsByDay[_selectedDate]?.income ?? 0;
    final dailyExpenses = monthSummary == null
        ? null
        : monthSummary.totalsByDay[_selectedDate]?.expense ?? 0;
    final dailyVariableExpenses = monthSummary == null
        ? null
        : monthSummary.variableExpensesByDay[_selectedDate] ?? 0;
    final dailyTarget = dailyPeriod == null || dailyPeriod.days <= 0
        ? null
        : (periodBudget / dailyPeriod.days).ceil();
    final spentThisPeriod = periodTotalAsync.valueOrNull;
    final remainingBudget =
        spentThisPeriod == null ? null : periodBudget - spentThisPeriod;
    final now = DateTime.now();
    final isCurrentPeriod = !now.isBefore(periodRange.start) &&
        now.isBefore(periodRange.endExclusive);
    final progress = spentThisPeriod == null
        ? null
        : periodBudget == 0
            ? (spentThisPeriod > 0 ? 1.0 : 0.0)
            : (spentThisPeriod / periodBudget).clamp(0.0, 1.0);

    return AppScaffold(
      title: l10n.homeTitle,
      currentIndex: 0,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HomeSection(
            title: l10n.homePeriodsTitle,
            child: Column(
              children: [
                if (schedules.isEmpty && schedulesLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(),
                  )
                else if (schedules.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(l10n.annualScheduleMissing),
                  )
                else
                  _buildPeriodTimeline(context, schedules, selectedPeriod),
                if (selectedSchedulePeriod != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${l10n.formatDate(selectedSchedulePeriod.startDate)}${l10n.rangeSeparator}${l10n.formatDate(selectedSchedulePeriod.endDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context.push('/settings/annual'),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(l10n.annualSchedule),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _HomeSection(
            title: l10n.homeCalendarTitle,
            trailing: Tooltip(
              message: showPeriodColors
                  ? l10n.homePeriodColorsOn
                  : l10n.homePeriodColorsOff,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.homePeriodColorsLabel),
                  Switch.adaptive(
                    key: const Key('home-period-colors-toggle'),
                    value: showPeriodColors,
                    onChanged: (value) => ref
                        .read(homePeriodColorsEnabledProvider.notifier)
                        .state = value,
                  ),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => SizedBox(
                    height: PeriodCalendar.heightForWidth(
                        context, constraints.maxWidth),
                    child: PageView.builder(
                      key: const Key('home-month-calendar'),
                      controller: _calendarPageController,
                      onPageChanged: _onCalendarPageChanged,
                      itemBuilder: (context, page) {
                        final month = _monthForPage(page);
                        return Consumer(builder: (context, ref, _) {
                          final summary =
                              ref.watch(homeMonthSummaryProvider(month));
                          final previousSchedule = ref
                              .watch(
                                  annualScheduleForYearProvider(month.year - 1))
                              .valueOrNull;
                          final schedule = ref
                              .watch(annualScheduleForYearProvider(month.year))
                              .valueOrNull;
                          final nextSchedule = ref
                              .watch(
                                  annualScheduleForYearProvider(month.year + 1))
                              .valueOrNull;
                          final pageSchedules = [
                            if (previousSchedule != null) previousSchedule,
                            if (schedule != null) schedule,
                            if (nextSchedule != null) nextSchedule,
                          ];
                          return PeriodCalendar(
                            displayedMonth: month,
                            selectedDate: _selectedDate,
                            totalsByDay: summary.valueOrNull?.totalsByDay ??
                                const <DateTime, ({int income, int expense})>{},
                            annualSchedules: pageSchedules,
                            showPeriodColors:
                                ref.watch(homePeriodColorsEnabledProvider),
                            onMonthChanged: _shiftMonth,
                            onDateTap: (date) =>
                                _selectDate(date, pageSchedules),
                          );
                        });
                      },
                    ),
                  ),
                ),
                if (monthSummaryAsync.hasError) ...[
                  const SizedBox(height: 12),
                  Text(l10n.errorMessage(monthSummaryAsync.error!)),
                ],
                const SizedBox(height: 12),
                _DailyExpenseSummary(
                  date: _selectedDate,
                  income: dailyIncome,
                  expenseTotal: dailyExpenses,
                  variableExpense: dailyVariableExpenses,
                  dailyTarget: dailyTarget,
                  onInput: () => context.go('/input', extra: _selectedDate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _HomeSection(
            title: l10n.homeBudgetTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.formatCurrencyRatio(spentThisPeriod, periodBudget),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      key: const Key('home-budget-link'),
                      tooltip: l10n.budgetSettingsTitle,
                      onPressed: () => context.push('/settings/budget'),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    key: const Key('home-budget-progress'),
                    value: progress,
                    minHeight: 10,
                    color: remainingBudget != null && remainingBudget < 0
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _AmountRow(
                  label: l10n.homeMonthlyIncomeLabel,
                  amount: monthSummaryAsync.valueOrNull?.income,
                  onTap: () =>
                      context.go('/input?type=income', extra: _selectedDate),
                ),
                _AmountRow(
                  label: l10n.homeVariableTotalLabel,
                  amount: spentThisPeriod,
                  onTap: () => context.go(
                    '/input?attribute=${ExpenseAttribute.variable.name}',
                    extra: _selectedDate,
                  ),
                ),
                _AmountRow(
                  label: l10n.homeFixedExpensesLabel,
                  amount: monthSummaryAsync.valueOrNull?.fixedExpenses,
                  onTap: () => context.go(
                    '/input?attribute=${ExpenseAttribute.fixed.name}',
                    extra: _selectedDate,
                  ),
                ),
                _AmountRow(
                  label: l10n.homeSpecialExpensesLabel,
                  amount: monthSummaryAsync.valueOrNull?.specialExpenses,
                  onTap: () => context.go(
                    '/input?attribute=${ExpenseAttribute.bonus.name}',
                    extra: _selectedDate,
                  ),
                ),
                const Divider(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    remainingBudget == null
                        ? l10n.homeBudgetRemainingLabel
                        : isCurrentPeriod
                            ? l10n.homePeriodRemaining(remainingBudget)
                            : l10n.homeSelectedPeriodRemaining(remainingBudget),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: remainingBudget != null && remainingBudget < 0
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                  ),
                ),
                if (periodTotalAsync.hasError) ...[
                  const SizedBox(height: 8),
                  Text(l10n.errorMessage(periodTotalAsync.error!)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _HomeSection({
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _DailyExpenseSummary extends StatelessWidget {
  final DateTime date;
  final int? income;
  final int? expenseTotal;
  final int? variableExpense;
  final int? dailyTarget;
  final VoidCallback onInput;

  const _DailyExpenseSummary({
    required this.date,
    required this.income,
    required this.expenseTotal,
    required this.variableExpense,
    required this.dailyTarget,
    required this.onInput,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isOverTarget = variableExpense != null &&
        dailyTarget != null &&
        variableExpense! > dailyTarget!;
    final progress = variableExpense == null || dailyTarget == null
        ? 0.0
        : dailyTarget == 0
            ? (variableExpense! > 0 ? 1.0 : 0.0)
            : (variableExpense! / dailyTarget!).clamp(0.0, 1.0);

    return Container(
      key: const Key('home-daily-expense-summary'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.formatDate(date),
                  key: const Key('home-selected-date'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                onPressed: onInput,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.homeDailyInput),
              ),
            ],
          ),
          Text(
            l10n.homeDailyExpenseTotal,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            expenseTotal == null ? '—' : l10n.formatCurrency(expenseTotal!),
            key: const Key('home-selected-day-total'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (income != null && income! > 0)
            _AmountRow(
              label: l10n.homeDailyIncome,
              amount: income,
            ),
          const SizedBox(height: 8),
          Text(
            l10n.homeDailyBudgetRatioLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            l10n.formatCurrencyRatio(variableExpense, dailyTarget),
            key: const Key('home-daily-budget-ratio'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              key: const Key('home-daily-target-progress'),
              value: progress,
              minHeight: 12,
              color: isOverTarget ? scheme.error : scheme.primary,
            ),
          ),
          if (isOverTarget) ...[
            const SizedBox(height: 6),
            Text(
              l10n.homeDailyBudgetOver(variableExpense! - dailyTarget!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final int? amount;
  final VoidCallback? onTap;

  const _AmountRow({required this.label, required this.amount, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(amount == null ? '—' : l10n.formatCurrency(amount!)),
          if (onTap != null) const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}
