import 'package:flutter/material.dart';
import 'package:kakeibo/core/utils/period_utils.dart';

class PeriodCalendar extends StatelessWidget {
  final DateTime periodStart;
  final int periodLengthDays;
  final DateTime appStart;
  final Map<DateTime, ({int income, int expense})> totalsByDay;

  const PeriodCalendar({
    super.key,
    required this.periodStart,
    required this.periodLengthDays,
    required this.appStart,
    required this.totalsByDay,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStart = truncateDate(periodStart);
    final normalizedAppStart = truncateDate(appStart);
    final length = periodLengthDays <= 0 ? 35 : periodLengthDays;
    final days = List.generate(length, (i) => normalizedStart.add(Duration(days: i)));
    final offset = normalizedStart.weekday % 7; // Sunday = 0
    final totalCells = offset + length;
    final periodIndex = normalizedStart.difference(normalizedAppStart).inDays ~/ length;
    final color = _periodColors[periodIndex % _periodColors.length];
    final weekdayLabels = MaterialLocalizations.of(context).narrowWeekdays;

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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 0.9,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            if (index < offset) {
              return const SizedBox.shrink();
            }
            final date = days[index - offset];
            final totals = totalsByDay[truncateDate(date)];
            final income = totals?.income ?? 0;
            final expense = totals?.expense ?? 0;
            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (income > 0)
                      Text(
                        '+$income',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.blue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (expense > 0)
                      Text(
                        '-$expense',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.red),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

const List<Color> _periodColors = [
  Color(0xFFE3F2FD),
  Color(0xFFFFF3E0),
  Color(0xFFE8F5E9),
  Color(0xFFF3E5F5),
];
