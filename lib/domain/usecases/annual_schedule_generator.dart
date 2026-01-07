import 'package:kakeibo/domain/entities/annual_schedule.dart';

class AnnualScheduleGenerator {
  static const int periodCount = 12;
  static const int regularDays = 35;
  static const int bonusDays = 7;
  static const List<int> defaultBonusPeriods = [7, 11];

  AnnualScheduleConfig generate({
    required int year,
    required DateTime startDate,
    required int weekStart,
  }) {
    final normalizedStart = _truncateDate(startDate);
    final periodDays = List<int>.filled(periodCount, regularDays);
    for (final index in defaultBonusPeriods) {
      if (index >= 0 && index < periodDays.length) {
        periodDays[index] = bonusDays;
      }
    }
    return AnnualScheduleConfig(
      year: year,
      startDate: normalizedStart,
      weekStart: weekStart,
      periodDays: periodDays,
    );
  }

  AnnualScheduleConfig normalizeConfig(AnnualScheduleConfig config) {
    if (_isValidConfig(config)) return config;
    return generate(
      year: config.year,
      startDate: config.startDate,
      weekStart: config.weekStart,
    );
  }

  AnnualSchedule buildSchedule(AnnualScheduleConfig config) {
    final normalized = normalizeConfig(config);
    final periods = <AnnualSchedulePeriod>[];
    var cursor = _truncateDate(normalized.startDate);
    for (var i = 0; i < normalized.periodDays.length; i++) {
      final days = _normalizeDays(normalized.periodDays[i]);
      final start = cursor;
      final end = cursor.add(Duration(days: days - 1));
      periods.add(AnnualSchedulePeriod(
        index: i,
        days: days,
        startDate: start,
        endDate: end,
      ));
      cursor = cursor.add(Duration(days: days));
    }

    final bonusPeriods = <int>[
      for (final period in periods)
        if (period.days == bonusDays) period.index,
    ];
    return AnnualSchedule(
      year: normalized.year,
      startDate: normalized.startDate,
      weekStart: normalized.weekStart,
      periods: periods,
      bonusPeriods: bonusPeriods,
    );
  }

  AnnualScheduleConfig setBonusPeriods({
    required AnnualScheduleConfig config,
    required List<int> bonusPeriodIndices,
  }) {
    final selected = bonusPeriodIndices.toSet().where((index) {
      return index >= 0 && index < periodCount;
    }).toList();
    if (selected.length != defaultBonusPeriods.length) {
      return config;
    }

    final updated = List<int>.filled(periodCount, regularDays);
    for (final index in selected) {
      updated[index] = bonusDays;
    }
    if (_sameDays(updated, config.periodDays)) {
      return config;
    }
    return config.copyWithDays(updated);
  }

  bool _isValidConfig(AnnualScheduleConfig config) {
    if (config.periodDays.length != periodCount) return false;
    var total = 0;
    var bonusCount = 0;
    for (final days in config.periodDays) {
      if (days != regularDays && days != bonusDays) return false;
      if (days == bonusDays) bonusCount++;
      total += days;
    }
    if (bonusCount != defaultBonusPeriods.length) return false;
    return total == _targetDays(config.year);
  }

  int _normalizeDays(int days) => days == bonusDays ? bonusDays : regularDays;

  bool _sameDays(List<int> next, List<int> current) {
    if (next.length != current.length) return false;
    for (var i = 0; i < next.length; i++) {
      if (next[i] != current[i]) return false;
    }
    return true;
  }

  int _targetDays(int year) {
    final totalDays = _daysInYear(year);
    return totalDays - (totalDays % 7);
  }

  int _daysInYear(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    return end.difference(start).inDays;
  }

  DateTime _truncateDate(DateTime date) => DateTime(date.year, date.month, date.day);
}

extension on AnnualScheduleConfig {
  AnnualScheduleConfig copyWithDays(List<int> periodDays) {
    return AnnualScheduleConfig(
      year: year,
      startDate: startDate,
      weekStart: weekStart,
      periodDays: periodDays,
    );
  }
}
