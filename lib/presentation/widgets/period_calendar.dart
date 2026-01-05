import 'package:flutter/material.dart';
import 'package:kakeibo/core/utils/period_utils.dart';

class PeriodCalendar extends StatelessWidget {
  final Map<DateTime, ({int income, int expense})> totalsByDay;
  final ValueChanged<DateTime>? onDateTap;

  const PeriodCalendar({
    super.key,
    required this.totalsByDay,
    this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = truncateDate(DateTime.now());
    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final weeks = List.generate(5, (i) => weekStart.add(Duration(days: 7 * i)));
    final days = [
      for (final start in weeks) ...List.generate(7, (i) => start.add(Duration(days: i))),
    ];
    const totalCells = 35;
    final weekdayLabels = MaterialLocalizations.of(context).narrowWeekdays;
    final scheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    // Keep room for 3 text lines at larger text scales to avoid overflow.
    final cellAspectRatio = (0.8 / textScale).clamp(0.5, 0.9) as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final date = days[index];
            final totals = totalsByDay[truncateDate(date)];
            final income = totals?.income ?? 0;
            final expense = totals?.expense ?? 0;
            final isToday = date == now;
            final key = Key(_calendarKey(date));
            return GestureDetector(
              onTap: onDateTap == null ? null : () => onDateTap!(truncateDate(date)),
              child: Container(
                key: key,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isToday ? scheme.primary : scheme.outlineVariant,
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
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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
          },
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
