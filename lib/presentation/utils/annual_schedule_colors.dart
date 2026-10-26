import 'package:flutter/material.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';

List<Color> buildAnnualScheduleColors(int count) {
  if (count <= 0) return const [];
  return List.generate(count, (index) {
    final hue = (360.0 / count) * index;
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.75).toColor();
  });
}

Color? colorForScheduleDate(List<AnnualSchedule> schedules, DateTime date) {
  for (final schedule in schedules.reversed) {
    for (final period in schedule.periods) {
      if (period.days > 0 &&
          !date.isBefore(period.startDate) &&
          !date.isAfter(period.endDate)) {
        final colors = buildAnnualScheduleColors(schedule.periods.length);
        return colors[period.index % colors.length];
      }
    }
  }
  return null;
}
