import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';

void main() {
  test('generates periods with 35/42 day lengths and week-aligned total', () {
    final generator = AnnualScheduleGenerator();
    final year = 2026;
    final config = generator.generate(
      year: year,
      startDate: DateTime(year, 1, 1),
      weekStart: 0,
    );

    final total = config.periodDays.fold<int>(0, (sum, days) => sum + days);
    final yearDays = DateTime(year + 1, 1, 1).difference(DateTime(year, 1, 1)).inDays;
    final expected = yearDays - (yearDays % 7);

    expect(total, expected);
    expect(config.periodDays.every((d) => d == 35 || d == 42), isTrue);
  });

  test('bonus months are calculated from period starts', () {
    final generator = AnnualScheduleGenerator();
    final year = 2026;
    final config = generator.generate(
      year: year,
      startDate: DateTime(year, 1, 1),
      weekStart: 0,
    );
    final schedule = generator.buildSchedule(config);

    expect(schedule.bonusMonths.length, 2);
  });
}
