import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';
import 'package:kakeibo/presentation/utils/annual_schedule_colors.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/period_calendar.dart';

typedef _PeriodId = ({int year, int index});

enum _HomeDisplayMode { period, month }

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  static const _initialPage = 12000;
  static const _yearMarkerWidth = 52.0;
  static const _periodTileWidth = 72.0;

  late final DateTime _initialMonth;
  late PageController _calendarPageController;
  late final PageController _periodPageController;
  final ScrollController _periodScrollController = ScrollController();
  final ScrollController _monthScrollController = ScrollController();
  Timer? _dayChangeTimer;
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  _HomeDisplayMode _displayMode = _HomeDisplayMode.period;
  var _currentPage = _initialPage;
  _PeriodId? _selectedPeriod;
  _PeriodId? _lastCenteredPeriod;
  String? _lastTimelineSignature;
  int? _lastCenteredMonthPage;
  String? _lastMonthTimelineSignature;
  _PeriodId? _pendingPeriod;
  int? _pendingPage;
  DateTime? _pendingDate;
  bool _resettingPeriodPage = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _initialMonth = DateTime(now.year, now.month, 1);
    _displayedMonth = _initialMonth;
    _selectedDate = DateTime(now.year, now.month, now.day);
    _calendarPageController = PageController(initialPage: _initialPage);
    _periodPageController = PageController(initialPage: 1);
    WidgetsBinding.instance.addObserver(this);
    _scheduleDayChange();
  }

  @override
  void dispose() {
    _dayChangeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _calendarPageController.dispose();
    _periodPageController.dispose();
    _periodScrollController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }

  void _scheduleDayChange() {
    _dayChangeTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _dayChangeTimer = Timer(nextDay.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleDayChange();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    setState(() {});
    _scheduleDayChange();
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
    for (final schedule in schedules.reversed) {
      for (final period in schedule.periods) {
        if (!date.isBefore(period.startDate) && !date.isAfter(period.endDate)) {
          return (year: schedule.year, index: period.index);
        }
      }
    }
    return null;
  }

  void _jumpToToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetPage = _pageForMonth(today);
    setState(() {
      _selectedDate = today;
      _selectedPeriod = null;
      _displayedMonth = DateTime(today.year, today.month);
      _currentPage = targetPage;
      _pendingPage = _displayMode == _HomeDisplayMode.month ? targetPage : null;
      _pendingDate = _displayMode == _HomeDisplayMode.month ? today : null;
      _pendingPeriod = null;
    });
    if (_displayMode == _HomeDisplayMode.month &&
        _calendarPageController.hasClients) {
      _calendarPageController.jumpToPage(targetPage);
    }
    if (_displayMode == _HomeDisplayMode.period &&
        _periodPageController.hasClients) {
      _periodPageController.jumpToPage(1);
    }
  }

  void _selectPeriod(AnnualSchedule schedule, AnnualSchedulePeriod period) {
    if (period.days == 0) return;
    final selected = (year: schedule.year, index: period.index);
    if (_displayMode == _HomeDisplayMode.period) {
      setState(() {
        _selectedPeriod = selected;
        _selectedDate = period.startDate;
        _displayedMonth =
            DateTime(period.startDate.year, period.startDate.month);
        _currentPage = _pageForMonth(_displayedMonth);
      });
      return;
    }
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
    if (_displayMode == _HomeDisplayMode.period) {
      setState(() {
        _selectedDate = date;
        _selectedPeriod = selected;
      });
      return;
    }
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

  void _setDisplayMode(_HomeDisplayMode mode) {
    if (mode == _displayMode) return;
    final targetPage = _pageForMonth(_selectedDate);
    final calendarWasVisible = _calendarPageController.hasClients;
    if (mode == _HomeDisplayMode.month) {
      if (!calendarWasVisible) {
        _calendarPageController.dispose();
        _calendarPageController = PageController(initialPage: targetPage);
      }
    }
    setState(() {
      _displayMode = mode;
      if (mode == _HomeDisplayMode.month) {
        _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
        _currentPage = targetPage;
        _pendingPage = _currentPage;
        _pendingDate = _selectedDate;
        _pendingPeriod = _selectedPeriod;
      }
    });
    if (mode == _HomeDisplayMode.month && calendarWasVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _calendarPageController.hasClients) {
          _calendarPageController.jumpToPage(targetPage);
        }
      });
    }
  }

  void _selectMonth(int year, int month) {
    final target = DateTime(year, month);
    final page = _pageForMonth(target);
    if (_displayMode == _HomeDisplayMode.period) {
      setState(() {
        _selectedDate = _defaultDateForMonth(target);
        _selectedPeriod = null;
        _displayedMonth = target;
        _currentPage = page;
      });
      return;
    }
    if (page == _currentPage) {
      setState(() {
        _selectedDate = _defaultDateForMonth(target);
        _selectedPeriod = null;
      });
    } else if (_calendarPageController.hasClients) {
      _calendarPageController.jumpToPage(page);
    }
  }

  void _shiftPeriod(
      List<AnnualSchedule> schedules, _PeriodId? selected, int offset) {
    if (selected == null) return;
    final periods = [
      for (final schedule in schedules)
        for (final period in schedule.periods)
          if (period.days > 0) (schedule: schedule, period: period),
    ];
    final index = periods.indexWhere((entry) =>
        entry.schedule.year == selected.year &&
        entry.period.index == selected.index);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= periods.length) return;
    _selectPeriod(periods[target].schedule, periods[target].period);
  }

  _PeriodId? _periodForDisplayedMonth(List<AnnualSchedule> schedules) {
    final selected = _selectedPeriod;
    if (selected != null &&
        schedules.any((schedule) =>
            schedule.year == selected.year &&
            schedule.periods.any((period) =>
                period.index == selected.index && period.days > 0))) {
      return selected;
    }

    final anchor = _selectedDate;
    for (final schedule in schedules.reversed) {
      for (final period
          in schedule.periods.where((period) => period.days > 0)) {
        if (!anchor.isBefore(period.startDate) &&
            !anchor.isAfter(period.endDate)) {
          return (year: schedule.year, index: period.index);
        }
      }
    }
    _PeriodId? previous;
    for (final schedule in schedules) {
      for (final period
          in schedule.periods.where((period) => period.days > 0)) {
        if (!period.startDate.isAfter(anchor)) {
          previous = (year: schedule.year, index: period.index);
        }
      }
    }
    return previous;
  }

  Widget _timelineTile(
    BuildContext context, {
    required Key key,
    required String label,
    required String tooltip,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: _periodTileWidth,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Semantics(
            selected: selected,
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
                      color: color,
                      border: Border.all(
                        color: selected ? scheme.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
          for (final period
              in schedule.periods.where((period) => period.days > 0)) {
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
              for (final period
                  in schedule.periods.where((period) => period.days > 0))
                _timelineTile(
                  context,
                  key: Key('home-period-${schedule.year}-${period.index}'),
                  label: l10n.homePeriodLabel(period.index + 1),
                  tooltip:
                      '${l10n.formatDate(period.startDate)}${l10n.rangeSeparator}${l10n.formatDate(period.endDate)}',
                  color: colorsByYear[schedule.year]![period.index],
                  selected:
                      selected == (year: schedule.year, index: period.index),
                  onTap: () => _selectPeriod(schedule, period),
                ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildMonthTimeline(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final monthColors = buildAnnualScheduleColors(12);
    final selectedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    final years = [
      selectedMonth.year - 1,
      selectedMonth.year,
      selectedMonth.year + 1,
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final selectedPage = _pageForMonth(selectedMonth);
      final signature = years.join(',');
      if (_lastCenteredMonthPage != selectedPage ||
          _lastMonthTimelineSignature != signature) {
        _lastCenteredMonthPage = selectedPage;
        _lastMonthTimelineSignature = signature;
        final selectedIndex = 12 + selectedMonth.month - 1;
        final selectedCenter = (selectedIndex ~/ 12 + 1) * _yearMarkerWidth +
            selectedIndex * _periodTileWidth +
            _periodTileWidth / 2;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_monthScrollController.hasClients) return;
          _monthScrollController.animateTo(
            (selectedCenter - constraints.maxWidth / 2).clamp(
              0.0,
              _monthScrollController.position.maxScrollExtent,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        });
      }
      return SingleChildScrollView(
        key: const Key('home-month-timeline'),
        controller: _monthScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final year in years) ...[
            SizedBox(
              width: _yearMarkerWidth,
              child: Text(
                '$year',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
            for (var month = 1; month <= 12; month++)
              _timelineTile(
                context,
                key: Key('home-month-choice-$year-$month'),
                label: l10n.formatMonth(month),
                tooltip: l10n.locale.languageCode == 'ja'
                    ? '$year年$month月'
                    : '$year/${month.toString().padLeft(2, '0')}',
                color: monthColors[month - 1],
                selected:
                    selectedMonth.year == year && selectedMonth.month == month,
                onTap: () => _selectMonth(year, month),
              ),
          ],
        ]),
      );
    });
  }

  Widget _buildSelectedPeriodCalendar(
      BuildContext context,
      WidgetRef pageRef,
      AnnualSchedulePeriod period,
      _PeriodId id,
      List<AnnualSchedule> schedules,
      bool showPeriodColors) {
    final totals = <DateTime, ({int income, int expense})>{};
    var month = DateTime(period.startDate.year, period.startDate.month);
    final calendarEnd = DateTime(
      period.startDate.year,
      period.startDate.month,
      period.startDate.day + PeriodCalendar.rowCountForPeriod(period) * 7 - 1,
    );
    final lastMonth = DateTime(calendarEnd.year, calendarEnd.month);
    while (!month.isAfter(lastMonth)) {
      final summary =
          pageRef.watch(homeMonthSummaryProvider(month)).valueOrNull;
      if (summary != null) totals.addAll(summary.totalsByDay);
      month = DateTime(month.year, month.month + 1);
    }
    final l10n = AppLocalizations.of(context);
    final label = '${id.year} · ${l10n.homePeriodLabel(id.index + 1)}';
    return PeriodCalendar(
      displayedMonth: _displayedMonth,
      displayedPeriod: period,
      periodLabel: label,
      selectedDate: _selectedDate,
      totalsByDay: totals,
      annualSchedules: schedules,
      showPeriodColors: showPeriodColors,
      onTodayTap: _jumpToToday,
      onDateTap: (date) => _selectDate(date, schedules),
    );
  }

  Widget _buildPeriodCalendarPages(BuildContext context,
      List<AnnualSchedule> schedules, _PeriodId selected, bool showColors) {
    final entries = [
      for (final schedule in schedules)
        for (final period in schedule.periods)
          if (period.days > 0) (schedule: schedule, period: period),
    ];
    final index = entries.indexWhere((entry) =>
        entry.schedule.year == selected.year &&
        entry.period.index == selected.index);
    if (index < 0) return const SizedBox.shrink();
    final pages = [
      entries[index > 0 ? index - 1 : index],
      entries[index],
      entries[index + 1 < entries.length ? index + 1 : index],
    ];
    final rows = PeriodCalendar.rowCountForPeriod(pages[1].period);
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedSize(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: PeriodCalendar.heightForWidth(context, constraints.maxWidth,
              rows: rows),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              if (_resettingPeriodPage ||
                  notification.metrics.axis != Axis.horizontal) {
                return false;
              }
              final page = _periodPageController.page?.round();
              if (page == null || page == 1) return false;
              _resettingPeriodPage = true;
              try {
                _periodPageController.jumpToPage(1);
              } finally {
                _resettingPeriodPage = false;
              }
              if ((page == 0 && index == 0) ||
                  (page == 2 && index == entries.length - 1)) {
                return false;
              }
              _shiftPeriod(schedules, selected, page - 1);
              return false;
            },
            child: PageView.builder(
              key: const Key('home-period-calendar'),
              controller: _periodPageController,
              itemCount: pages.length,
              itemBuilder: (context, page) {
                final entry = pages[page];
                return Consumer(builder: (context, pageRef, _) {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: _buildSelectedPeriodCalendar(
                      context,
                      pageRef,
                      entry.period,
                      (year: entry.schedule.year, index: entry.period.index),
                      schedules,
                      showColors,
                    ),
                  );
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider);
    final monthSummaryAsync = ref.watch(homeMonthSummaryProvider(
        DateTime(_selectedDate.year, _selectedDate.month)));
    final showPeriodColors = ref.watch(homePeriodColorsEnabledProvider);
    final fallbackBudget = ref.watch(settingsProvider).periodBudget;

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
    final periodBudget = selectedPeriod == null
        ? currentSchedule?.periodBudget ?? fallbackBudget
        : schedulesByYear[selectedPeriod.year]?.periodBudget ?? fallbackBudget;
    AnnualSchedulePeriod? selectedSchedulePeriod;
    if (selectedPeriod != null) {
      for (final schedule in schedules) {
        if (schedule.year != selectedPeriod.year) continue;
        for (final period
            in schedule.periods.where((period) => period.days > 0)) {
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
    final selectedWeek = selectedSchedulePeriod == null ||
            _selectedDate.isBefore(selectedSchedulePeriod.startDate) ||
            _selectedDate.isAfter(selectedSchedulePeriod.endDate)
        ? null
        : weekWithinSchedulePeriod(selectedSchedulePeriod, _selectedDate);
    final weekTotalAsync = selectedWeek == null
        ? null
        : ref.watch(homePeriodVariableTotalProvider(selectedWeek));
    final weeklyTarget = selectedWeek == null || selectedSchedulePeriod == null
        ? null
        : targetForScheduleWeek(
            periodBudget,
            selectedSchedulePeriod,
            selectedWeek.start,
            selectedWeek.endExclusive,
          );
    final spentThisPeriod = periodTotalAsync.valueOrNull;
    final remainingBudget =
        spentThisPeriod == null ? null : periodBudget - spentThisPeriod;
    final endDate = selectedSchedulePeriod?.endDate;
    final daysToPeriodEnd = endDate == null
        ? null
        : DateTime.utc(endDate.year, endDate.month, endDate.day)
            .difference(DateTime.utc(
                _selectedDate.year, _selectedDate.month, _selectedDate.day))
            .inDays;
    final remainingDays = daysToPeriodEnd == null
        ? null
        : daysToPeriodEnd < 0
            ? 0
            : daysToPeriodEnd;
    final progress = spentThisPeriod == null
        ? null
        : periodBudget == 0
            ? (spentThisPeriod > 0 ? 1.0 : 0.0)
            : (spentThisPeriod / periodBudget).clamp(0.0, 1.0);

    return AppScaffold(
      currentIndex: 0,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HomeSection(
            title: l10n.homePeriodsTitle,
            trailing: ToggleButtons(
              key: const Key('home-display-mode-toggle'),
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
              isSelected: [
                _displayMode == _HomeDisplayMode.period,
                _displayMode == _HomeDisplayMode.month,
              ],
              onPressed: (index) => _setDisplayMode(index == 0
                  ? _HomeDisplayMode.period
                  : _HomeDisplayMode.month),
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.homeModePeriod)),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.homeModeMonth)),
              ],
            ),
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
                else if (_displayMode == _HomeDisplayMode.period)
                  _buildMonthTimeline(context),
                if (schedules.isNotEmpty &&
                    _displayMode == _HomeDisplayMode.month)
                  _buildPeriodTimeline(context, schedules, selectedPeriod),
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
              message: _displayMode == _HomeDisplayMode.month
                  ? showPeriodColors
                      ? l10n.homePeriodColorsOn
                      : l10n.homePeriodColorsOff
                  : showPeriodColors
                      ? l10n.homeMonthColorsOn
                      : l10n.homeMonthColorsOff,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_displayMode == _HomeDisplayMode.month
                      ? l10n.homePeriodColorsLabel
                      : l10n.homeMonthColorsLabel),
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
                if (_displayMode == _HomeDisplayMode.period &&
                    selectedSchedulePeriod != null &&
                    selectedPeriod != null)
                  _buildPeriodCalendarPages(
                    context,
                    schedules,
                    selectedPeriod,
                    showPeriodColors,
                  )
                else
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
                                .watch(annualScheduleForYearProvider(
                                    month.year - 1))
                                .valueOrNull;
                            final schedule = ref
                                .watch(
                                    annualScheduleForYearProvider(month.year))
                                .valueOrNull;
                            final nextSchedule = ref
                                .watch(annualScheduleForYearProvider(
                                    month.year + 1))
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
                                  const <DateTime,
                                      ({int income, int expense})>{},
                              annualSchedules: pageSchedules,
                              showPeriodColors:
                                  ref.watch(homePeriodColorsEnabledProvider),
                              onTodayTap: _jumpToToday,
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
                _SelectedDaySummary(
                  date: _selectedDate,
                  weeklyExpense: weekTotalAsync?.valueOrNull,
                  weeklyTarget: weeklyTarget,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _HomeSection(
            title: l10n.homeBudgetTitle,
            titleSuffix: selectedSchedulePeriod == null
                ? null
                : Text(
                    '${l10n.formatMonthDay(selectedSchedulePeriod.startDate)} - ${l10n.formatMonthDay(selectedSchedulePeriod.endDate)}',
                    key: const Key('home-budget-period-range'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (remainingDays != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.homeCountdownPrefix,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 4),
                        Text(
                          l10n.homeCountdownDays(remainingDays),
                          key: const Key('home-budget-days-remaining'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                _ProgressAmountLabels(
                  spent: spentThisPeriod,
                  remaining: remainingBudget,
                  unit: l10n.homeBudgetUnitMonth,
                ),
                const SizedBox(height: 6),
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
  final Widget? titleSuffix;
  final Widget? trailing;
  final Widget child;

  const _HomeSection({
    required this.title,
    this.titleSuffix,
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (titleSuffix != null) ...[
                  const SizedBox(width: 4),
                  Flexible(child: titleSuffix!),
                ],
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
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

class _SelectedDaySummary extends StatelessWidget {
  final DateTime date;
  final int? weeklyExpense;
  final int? weeklyTarget;

  const _SelectedDaySummary({
    required this.date,
    required this.weeklyExpense,
    required this.weeklyTarget,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isOverTarget = weeklyExpense != null &&
        weeklyTarget != null &&
        weeklyExpense! > weeklyTarget!;
    final progress = weeklyExpense == null || weeklyTarget == null
        ? 0.0
        : weeklyTarget == 0
            ? (weeklyExpense! > 0 ? 1.0 : 0.0)
            : (weeklyExpense! / weeklyTarget!).clamp(0.0, 1.0);

    return Container(
      key: const Key('home-selected-day-summary'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.formatLongDate(date),
            key: const Key('home-selected-date'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _ProgressAmountLabels(
            spent: weeklyExpense,
            remaining: weeklyExpense == null || weeklyTarget == null
                ? null
                : weeklyTarget! - weeklyExpense!,
            unit: l10n.homeBudgetUnitWeek,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              key: const Key('home-weekly-target-progress'),
              value: progress,
              minHeight: 12,
              color: isOverTarget ? scheme.error : scheme.primary,
            ),
          ),
          if (isOverTarget) ...[
            const SizedBox(height: 6),
            Text(
              l10n.homeWeeklyBudgetOver(weeklyExpense! - weeklyTarget!),
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

class _ProgressAmountLabels extends StatelessWidget {
  final int? spent;
  final int? remaining;
  final String unit;

  const _ProgressAmountLabels({
    required this.spent,
    required this.remaining,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.labelSmall;
    return Row(children: [
      Expanded(
        child: Text(
          l10n.homeProgressSpent(spent),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(l10n.homeRemainingLabel, style: style),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                l10n.formatYenAmount(remaining),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: remaining != null && remaining! < 0
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
              ),
            ),
            Text(' / $unit', style: style),
          ],
        ),
      ),
    ]);
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
