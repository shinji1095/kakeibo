class AnnualScheduleConfig {
  final int year;
  final DateTime startDate;
  final int weekStart;
  final List<int> periodDays;

  const AnnualScheduleConfig({
    required this.year,
    required this.startDate,
    required this.weekStart,
    required this.periodDays,
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

  const AnnualSchedule({
    required this.year,
    required this.startDate,
    required this.weekStart,
    required this.periods,
    required this.bonusPeriods,
  });
}
