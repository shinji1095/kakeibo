class BonusMonthSetting {
  final int month;
  final int weeks;

  /// Selected seven-day slot for a one-week bonus. Zero-week bonuses use
  /// [month] instead.
  final int? periodIndex;

  const BonusMonthSetting({
    required this.month,
    required this.weeks,
    this.periodIndex,
  });
}

class AnnualScheduleConfig {
  final int year;
  final DateTime startDate;
  final int weekStart;
  final List<int> periodDays;
  final List<BonusMonthSetting> bonusMonths;
  final List<int> sixWeekPeriods;
  final int periodBudget;

  const AnnualScheduleConfig({
    required this.year,
    required this.startDate,
    required this.weekStart,
    required this.periodDays,
    this.bonusMonths = const [],
    this.sixWeekPeriods = const [],
    this.periodBudget = 50000,
  });
}

class AnnualSchedulePeriod {
  final int index;
  final int days;
  final DateTime startDate;
  final DateTime endDate;

  const AnnualSchedulePeriod({
    required this.index,
    required this.days,
    required this.startDate,
    required this.endDate,
  });
}

class AnnualSchedule {
  final int year;
  final DateTime startDate;
  final int weekStart;
  final List<AnnualSchedulePeriod> periods;
  final List<int> bonusPeriods;
  final List<BonusMonthSetting> bonusMonths;
  final List<int> sixWeekPeriods;
  final int periodBudget;

  const AnnualSchedule({
    required this.year,
    required this.startDate,
    required this.weekStart,
    required this.periods,
    required this.bonusPeriods,
    this.bonusMonths = const [],
    this.sixWeekPeriods = const [],
    this.periodBudget = 50000,
  });
}
