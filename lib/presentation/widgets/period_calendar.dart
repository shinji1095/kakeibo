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
  final ValueChanged<int>? onMonthChanged;
  final List<AnnualSchedule> annualSchedules;
  final bool showPeriodColors;

  const PeriodCalendar({
    super.key,
    required this.totalsByDay,
    required this.displayedMonth,
    this.onDateTap,
    this.onMonthChanged,
    this.annualSchedules = const [],
    this.showPeriodColors = true,
  });

  static double heightForWidth(BuildContext context, double width) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cellAspectRatio = (0.8 / textScale).clamp(0.5, 0.9);
    final cellWidth = (width - 6 * 4) / 7;
    final gridHeight =
        rowCount * cellWidth / cellAspectRatio + (rowCount - 1) * 4;
    return math.max(48, 24 * textScale) +
        math.max(24, 16 * textScale) +
        8 +
        gridHeight +
        2;
  }

  @override
  Widget build(BuildContext context) {
    final now = truncateDate(DateTime.now());
    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final gridStart =
        DateTime(firstDay.year, firstDay.month, 1 - firstDay.weekday % 7);
    final weekdayLabels = MaterialLocalizations.of(context).narrowWeekdays;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    // Keep room for 3 text lines at larger text scales to avoid overflow.
    final cellAspectRatio = (0.8 / textScale).clamp(0.5, 0.9);
    final periodRanges = <({DateTime start, DateTime end, Color color})>[];
    if (showPeriodColors) {
      for (final schedule in annualSchedules) {
        final colors = buildAnnualScheduleColors(schedule.periods.length);
        for (final period in schedule.periods) {
          periodRanges.add((
            start: period.startDate,
            end: period.endDate,
            color: colors[period.index % colors.length],
          ));
        }
      }
    }

    Widget buildDateCell(DateTime date) {
      final totals = totalsByDay[truncateDate(date)];
      final income = totals?.income ?? 0;
      final expense = totals?.expense ?? 0;
      final isToday = date == now;
      final isCurrentMonth = date.month == displayedMonth.month &&
          date.year == displayedMonth.year;
      Color? periodColor;
      for (final range in periodRanges) {
        if (!date.isBefore(range.start) && !date.isAfter(range.end)) {
          periodColor = range.color;
          break;
        }
      }

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
              color: isToday
                  ? scheme.primary
                  : periodColor ?? scheme.outlineVariant,
              width: isToday ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentMonth ? null : scheme.onSurfaceVariant,
                      ),
                ),
                if (income > 0)
                  Text(
                    '+$income',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.blue,
                          height: 1.0,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (expense > 0)
                  Text(
                    '-$expense',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.red,
                          height: 1.0,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              key: const Key('home-previous-month'),
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onMonthChanged?.call(-1),
            ),
            Text(
              l10n.locale.languageCode == 'ja'
                  ? '${displayedMonth.year}年${displayedMonth.month}月'
                  : '${displayedMonth.year}/${displayedMonth.month}',
              key: const Key('home-displayed-month'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              key: const Key('home-next-month'),
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onMonthChanged?.call(1),
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
          itemCount: rowCount * 7,
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
