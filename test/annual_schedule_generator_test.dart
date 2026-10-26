import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';
import 'package:kakeibo/core/utils/period_utils.dart';

void main() {
  final generator = AnnualScheduleGenerator();
  final start = DateTime(2026, 1, 1);

  test('basic weekday maps to January 1 through 7', () {
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final date = AnnualScheduleGenerator.startDateForWeekday(2026, weekday);
      expect(date.month, 1);
      expect(date.day, inInclusiveRange(1, 7));
      expect(date.weekday, weekday);
    }
  });

  test('every new year defaults to its first Monday', () {
    for (var year = 2024; year <= 2031; year++) {
      final date = AnnualScheduleGenerator.defaultStartDate(year);
      expect(date.weekday, DateTime.monday);
      expect(date.day, inInclusiveRange(1, 7));
    }
  });

  test('default schedule covers the calendar year in continuous periods', () {
    final config =
        generator.generate(year: 2026, startDate: start, weekStart: 0);
    final schedule = generator.buildSchedule(config);
    expect(config.periodDays, hasLength(10));
    expect(config.periodDays.where((days) => days == 7), isEmpty);
    expect(config.periodDays.reduce((a, b) => a + b), 365);
    expect(schedule.bonusMonths.map((b) => b.month), [8, 12]);
    for (var i = 1; i < schedule.periods.length; i++) {
      expect(schedule.periods[i].startDate,
          schedule.periods[i - 1].endDate.add(const Duration(days: 1)));
    }
  });

  test('zero-week bonus adds no period and extends one regular period', () {
    final config = generator.configure(
      year: 2026,
      startDate: start,
      weekStart: 0,
      bonusMonths: const [
        BonusMonthSetting(month: 9, weeks: 0),
        BonusMonthSetting(month: 12, weeks: 1, periodIndex: 10),
      ],
      sixWeekPeriods: const [0],
      periodBudget: 65000,
    );
    final schedule = generator.buildSchedule(config);
    expect(config.periodDays[0], 42);
    expect(config.periodDays, hasLength(11));
    expect(config.periodDays, isNot(contains(0)));
    expect(config.periodDays.reduce((a, b) => a + b), 365);
    expect(schedule.periodBudget, 65000);
    expect(schedule.bonusPeriods, [10]);
  });

  test('one-week bonus selects a period rather than a calendar month', () {
    final config = generator.configure(
      year: 2026,
      startDate: start,
      weekStart: 0,
      bonusMonths: const [
        BonusMonthSetting(month: 8, weeks: 1, periodIndex: 1),
        BonusMonthSetting(month: 12, weeks: 1, periodIndex: 11),
      ],
      sixWeekPeriods: const [],
      periodBudget: 50000,
    );
    expect(config.periodDays[1], 7);
    expect(config.periodDays[11], 7);
    expect(config.bonusMonths.first.periodIndex, 1);
    expect(config.bonusMonths.first.month, 2);
    expect(config.bonusMonths.last.periodIndex, 11);
  });

  test('legacy two six-week periods remain valid with zero-week bonuses', () {
    final config = generator.configure(
      year: 2026,
      startDate: start,
      weekStart: 0,
      bonusMonths: const [
        BonusMonthSetting(month: 9, weeks: 0),
        BonusMonthSetting(month: 12, weeks: 0),
      ],
      sixWeekPeriods: const [0, 1],
      periodBudget: 50000,
    );
    expect(config.periodDays.where((days) => days == 42), hasLength(2));
    expect(config.periodDays, hasLength(10));
    expect(config.periodDays, isNot(contains(0)));
    expect(config.periodDays.reduce((a, b) => a + b), 365);
  });

  test('basic settings cover 365 or 366 days for every starting weekday', () {
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final config = generator.configureBasic(
          year: 2026, weekday: weekday, weekStart: 0, periodBudget: 50000);
      final schedule = generator.buildSchedule(config);
      expect(config.startDate,
          AnnualScheduleGenerator.startDateForWeekday(2026, weekday));
      expect(config.bonusMonths.map((bonus) => bonus.month), [8, 12]);
      expect(config.bonusMonths.every((bonus) => bonus.weeks == 0), isTrue);
      expect(schedule.periods, hasLength(10));
      expect(config.periodDays.reduce((a, b) => a + b), 365);
      expect(config.sixWeekPeriods, [7, 8, 9]);
      expect(config.periodDays.sublist(0, 7), everyElement(35));
      expect(config.periodDays.sublist(7, 9), [42, 42]);
      expect(config.periodDays[9], 36);
      expect(
          config.sixWeekPeriods.map((index) =>
              AnnualScheduleGenerator.periodMonthLabels(
                  config.bonusMonths)[index]),
          [9, 10, 11]);
    }
  });

  test('leap year adds two days to the last regular period', () {
    final config = generator.configureBasic(
        year: 2024,
        weekday: DateTime.monday,
        weekStart: 0,
        periodBudget: 50000);
    expect(config.periodDays.reduce((a, b) => a + b), 366);
    expect(config.periodDays.last, 37);
  });

  test('old four-week adjustment is converted to a partial sixth week', () {
    final old = AnnualScheduleConfig(
      year: 2026,
      startDate: start,
      weekStart: 0,
      periodDays: const [35, 35, 35, 35, 35, 35, 28, 42, 42, 43],
      bonusMonths: const [
        BonusMonthSetting(month: 8, weeks: 0),
        BonusMonthSetting(month: 12, weeks: 0),
      ],
      sixWeekPeriods: const [7, 8, 9],
      periodBudget: 65000,
    );
    final migrated = generator.normalizeConfig(old);
    expect(migrated.periodDays, [35, 35, 35, 35, 35, 35, 35, 42, 42, 36]);
    expect(migrated.periodBudget, 65000);
  });

  test('legacy zero-day slots are removed without shifting dated periods', () {
    final oldDays = List<int>.filled(12, 35)
      ..[0] = 42
      ..[7] = 0
      ..[11] = 7;
    final migrated = generator.normalizeConfig(AnnualScheduleConfig(
      year: 2026,
      startDate: start,
      weekStart: 0,
      periodDays: oldDays,
      bonusMonths: const [
        BonusMonthSetting(month: 9, weeks: 0),
        BonusMonthSetting(month: 12, weeks: 1, periodIndex: 11),
      ],
      sixWeekPeriods: const [0],
    ));
    expect(migrated.periodDays, hasLength(11));
    expect(migrated.periodDays, isNot(contains(0)));
    expect(migrated.bonusMonths.last.periodIndex, 10);
    expect(migrated.sixWeekPeriods, [0]);
    expect(migrated.periodDays.reduce((a, b) => a + b), 365);
  });

  test('old generated year is recreated from its first Monday', () {
    final oldStart = DateTime(2026, 1, 1).add(const Duration(days: 364));
    final oldDays = List<int>.filled(12, 35)
      ..[7] = 7
      ..[11] = 7;
    final migrated = generator.normalizeConfig(AnnualScheduleConfig(
      year: 2027,
      startDate: oldStart,
      weekStart: 0,
      periodDays: oldDays,
    ));
    expect(migrated.startDate, DateTime(2027, 1, 4));
    expect(migrated.periodDays, hasLength(10));
    expect(migrated.periodDays.reduce((a, b) => a + b), 365);
  });

  test('a partial final week receives the remaining target', () {
    final config = generator.configureBasic(
        year: 2026,
        weekday: DateTime.monday,
        weekStart: 0,
        periodBudget: 50000);
    final period = generator.buildSchedule(config).periods.last;
    var totalTarget = 0;
    for (var day = period.startDate;
        !day.isAfter(period.endDate);
        day = day.add(const Duration(days: 7))) {
      final week = weekWithinSchedulePeriod(period, day);
      totalTarget +=
          targetForScheduleWeek(50000, period, week.start, week.endExclusive);
      if (week.endExclusive == period.endDate.add(const Duration(days: 1))) {
        expect(week.endExclusive.difference(week.start).inDays, 1);
      }
    }
    expect(totalTarget, 50000);
  });

  test('invalid month boundary and six-week count are rejected', () {
    expect(
        () => generator.configure(
              year: 2026,
              startDate: start,
              weekStart: 0,
              bonusMonths: const [
                BonusMonthSetting(month: 9, weeks: 0),
                BonusMonthSetting(month: 12, weeks: 1, periodIndex: 11),
              ],
              sixWeekPeriods: const [],
              periodBudget: 50000,
            ),
        throwsA(isA<ScheduleConfigurationException>()));
    expect(
        () => generator.configure(
              year: 2026,
              startDate: start,
              weekStart: 0,
              bonusMonths: const [
                BonusMonthSetting(month: 2, weeks: 1, periodIndex: 1),
                BonusMonthSetting(month: 12, weeks: 1, periodIndex: 1),
              ],
              sixWeekPeriods: const [],
              periodBudget: 50000,
            ),
        throwsA(isA<ScheduleConfigurationException>()));
  });
}
