import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/presentation/utils/annual_schedule_colors.dart';

class PeriodCalendar extends StatelessWidget {
  static const rowCount = 6;

  final Map<DateTime, ({int income, int expense})> totalsByDay;
  final ValueChanged<DateTime>? onDateTap;
  final DateTime displayedMonth;
  final AnnualSchedulePeriod? displayedPeriod;
  final String? periodLabel;
  final DateTime? selectedDate;
  final VoidCallback? onTodayTap;
  final List<AnnualSchedule> annualSchedules;
  final bool showPeriodColors;

  const PeriodCalendar({
    super.key,
    required this.totalsByDay,
    required this.displayedMonth,
    this.displayedPeriod,
    this.periodLabel,
    this.selectedDate,
    this.onDateTap,
    this.onTodayTap,
    this.annualSchedules = const [],
    this.showPeriodColors = true,
  });

  static int rowCountForPeriod(AnnualSchedulePeriod period) {
    return math.max(1, (period.days + 6) ~/ 7);
  }

  static double heightForWidth(BuildContext context, double width,
      {int rows = rowCount}) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cellAspectRatio = (1.0 / textScale).clamp(0.5, 1.1);
    final cellWidth = (width - 6 * 4) / 7;
    final gridHeight = rows * cellWidth / cellAspectRatio + (rows - 1) * 4;
    return math.max(48, 24 * textScale) +
        math.max(24, 16 * textScale) +
        8 +
        gridHeight +
        2;
  }

  @override
  Widget build(BuildContext context) {
    final now = truncateDate(DateTime.now());
    final firstDay = displayedPeriod?.startDate ??
        DateTime(displayedMonth.year, displayedMonth.month, 1);
    final gridStart = displayedPeriod == null
        ? DateTime(
            firstDay.year, firstDay.month, firstDay.day - firstDay.weekday % 7)
        : firstDay;
    final rows = displayedPeriod == null
        ? rowCount
        : rowCountForPeriod(displayedPeriod!);
    final allWeekdayLabels = MaterialLocalizations.of(context).narrowWeekdays;
    final firstWeekdayIndex = gridStart.weekday % 7;
    final weekdayLabels = [
      ...allWeekdayLabels.skip(firstWeekdayIndex),
      ...allWeekdayLabels.take(firstWeekdayIndex),
    ];
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cellAspectRatio = (1.0 / textScale).clamp(0.5, 1.1);
    final monthColors = showPeriodColors && displayedPeriod != null
        ? buildAnnualScheduleColors(12)
        : const <Color>[];

    Widget buildDateCell(DateTime date) {
      final totals = totalsByDay[truncateDate(date)];
      final income = totals?.income ?? 0;
      final expense = totals?.expense ?? 0;
      final isToday = date == now;
      final isSelected =
          selectedDate != null && date == truncateDate(selectedDate!);
      final isCurrentMonth = displayedPeriod != null ||
          (date.month == displayedMonth.month &&
              date.year == displayedMonth.year);
      final periodColor = !showPeriodColors
          ? null
          : displayedPeriod == null
              ? colorForScheduleDate(annualSchedules, date)
              : monthColors[date.month - 1];

      return GestureDetector(
        onTap: onDateTap == null ? null : () => onDateTap!(truncateDate(date)),
        child: Container(
          key: Key(_calendarKey(date)),
          decoration: BoxDecoration(
            color: periodColor == null
                ? scheme.surface
                : Color.alphaBlend(periodColor.withAlpha(110), scheme.surface),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? scheme.primary
                  : isToday
                      ? scheme.primary
                      : periodColor ?? scheme.outlineVariant,
              width: isSelected ? 3 : (isToday ? 2 : 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isToday || isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrentMonth ? null : scheme.onSurfaceVariant,
                      ),
                ),
                if (income > 0 || expense > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        if (expense > 0)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: scheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (income > 0) ...[
                          if (expense > 0) const SizedBox(width: 3),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  displayedPeriod != null
                      ? periodLabel ?? ''
                      : l10n.locale.languageCode == 'ja'
                          ? '${displayedMonth.year}年${displayedMonth.month}月'
                          : '${displayedMonth.year}/${displayedMonth.month}',
                  key: const Key('home-displayed-month'),
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              key: const Key('home-calendar-today'),
              icon: const Icon(Icons.today_outlined),
              tooltip: l10n.homeGoToToday,
              onPressed: onTodayTap,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdayLabels
              .map((label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: cellAspectRatio,
          ),
          itemCount: rows * 7,
          itemBuilder: (context, index) => buildDateCell(DateTime(
            gridStart.year,
            gridStart.month,
            gridStart.day + index,
          )),
        ),
      ],
    );
  }
}

String _calendarKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return 'calendar-day-$y$m$d';
}
