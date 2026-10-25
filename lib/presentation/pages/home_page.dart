import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
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
  var _currentPage = _initialPage;
  _PeriodId? _selectedPeriod;
  _PeriodId? _lastCenteredPeriod;
  String? _lastTimelineSignature;
  _PeriodId? _pendingPeriod;
  int? _pendingPage;

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
      setState(() => _selectedPeriod = selected);
      return;
    }
    _pendingPeriod = selected;
    _pendingPage = page;
    _calendarPageController.jumpToPage(page);
  }

  void _onCalendarPageChanged(int page) {
    final selected = page == _pendingPage ? _pendingPeriod : null;
    _pendingPeriod = null;
    _pendingPage = null;
    setState(() {
      _currentPage = page;
      _displayedMonth = _monthForPage(page);
      _selectedPeriod = selected;
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

    final now = DateTime.now();
    final isCurrentMonth =
        now.year == _displayedMonth.year && now.month == _displayedMonth.month;
    final anchor = isCurrentMonth
        ? DateTime(now.year, now.month, now.day)
        : DateTime(_displayedMonth.year, _displayedMonth.month, 15);
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
                                l10n.homePeriodLabel(period.index + 1),
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
                          return PeriodCalendar(
                            displayedMonth: month,
                            totalsByDay: summary.valueOrNull?.totalsByDay ??
                                const <DateTime, ({int income, int expense})>{},
                            annualSchedules: [
                              if (previousSchedule != null) previousSchedule,
                              if (schedule != null) schedule,
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
                if (monthSummaryAsync.hasError) ...[
                  const SizedBox(height: 12),
                  Text(l10n.errorMessage(monthSummaryAsync.error!)),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.homeSelectedPeriod),
                    if (spentThisPeriod != null)
                      Expanded(
                        child: Text(
                          '${l10n.formatCurrency(spentThisPeriod)} / ${l10n.formatCurrency(periodBudget)}',
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                ),
                _AmountRow(
                  label: l10n.homeVariableTotalLabel,
                  amount: spentThisPeriod,
                ),
                _AmountRow(
                  label: l10n.homeFixedExpensesLabel,
                  amount: monthSummaryAsync.valueOrNull?.fixedExpenses,
                ),
                _AmountRow(
                  label: l10n.homeSpecialExpensesLabel,
                  amount: monthSummaryAsync.valueOrNull?.specialExpenses,
                ),
                const Divider(height: 24),
                InkWell(
                  key: const Key('home-budget-link'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.push('/settings/budget'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            remainingBudget == null
                                ? l10n.homeBudgetRemainingLabel
                                : isCurrentPeriod
                                    ? l10n.homePeriodRemaining(remainingBudget)
                                    : l10n.homeSelectedPeriodRemaining(
                                        remainingBudget),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: remainingBudget != null &&
                                          remainingBudget < 0
                                      ? Theme.of(context).colorScheme.error
                                      : null,
                                ),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
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
  final Widget child;

  const _HomeSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final int? amount;

  const _AmountRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(amount == null ? '—' : l10n.formatCurrency(amount!)),
        ],
      ),
    );
  }
}
