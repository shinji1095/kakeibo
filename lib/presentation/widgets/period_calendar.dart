import 'package:flutter/material.dart';
import 'package:kakeibo/core/utils/period_utils.dart';

class PeriodCalendar extends StatelessWidget {
  final DateTime periodStart;
  final int periodLengthDays;
  final DateTime appStart;

  const PeriodCalendar({
    super.key,
    required this.periodStart,
    required this.periodLengthDays,
    required this.appStart,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _weekdayLabels
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
            childAspectRatio: 1.1,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            if (index < offset) {
              return const SizedBox.shrink();
            }
            final date = days[index - offset];
            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

const List<String> _weekdayLabels = ['日', '月', '火', '水', '木', '金', '土'];

const List<Color> _periodColors = [
  Color(0xFFE3F2FD),
  Color(0xFFFFF3E0),
  Color(0xFFE8F5E9),
  Color(0xFFF3E5F5),
];
