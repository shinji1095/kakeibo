import 'dart:math';
import 'package:kakeibo/domain/entities/annual_schedule.dart';

class AnnualScheduleGenerator {
  AnnualScheduleConfig generate({
    required int year,
    required DateTime startDate,
    required int weekStart,
  }) {
    final normalizedStart = _truncateDate(startDate);
    final targetDays = _targetDays(year);
    final candidates = _buildCandidates(targetDays);

    AnnualScheduleConfig? best;
    var bestScore = 1 << 30;
    var bestMaxRun = 1 << 30;

    for (final candidate in candidates) {
      final total = candidate.n35 + candidate.n42;
      for (var shift = 0; shift < total; shift++) {
        final periods = _distributePeriods(candidate.n35, candidate.n42, shift);
        final bonusMonths = _bonusMonthsFor(year, normalizedStart, periods);
        final score = _scoreCandidate(bonusMonths.length, candidate.n42, total);
        final maxRun = _maxConsecutive(periods, 35);
        if (score < bestScore || (score == bestScore && maxRun < bestMaxRun)) {
          bestScore = score;
          bestMaxRun = maxRun;
          best = AnnualScheduleConfig(
            year: year,
            startDate: normalizedStart,
            weekStart: weekStart,
            periodDays: periods,
          );
        }
      }
    }

    if (best != null) {
      return best;
    }

    final fallbackCount = max(1, targetDays ~/ 35);
    return AnnualScheduleConfig(
      year: year,
      startDate: normalizedStart,
      weekStart: weekStart,
      periodDays: List.filled(fallbackCount, 35),
    );
  }

  AnnualSchedule buildSchedule(AnnualScheduleConfig config) {
    final periods = <AnnualSchedulePeriod>[];
    var cursor = _truncateDate(config.startDate);
    for (var i = 0; i < config.periodDays.length; i++) {
      final days = config.periodDays[i];
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

    final bonusMonths = _bonusMonthsFor(config.year, config.startDate, config.periodDays);
    final appliedBonusMonths = _applyBonusOverrides(bonusMonths, config.bonusMonthOverrides);
    return AnnualSchedule(
      year: config.year,
      startDate: config.startDate,
      weekStart: config.weekStart,
      periods: periods,
      bonusMonths: appliedBonusMonths,
    );
  }

  AnnualScheduleConfig updatePeriodLength({
    required AnnualScheduleConfig config,
    required int periodIndex,
    required int days,
  }) {
    if (periodIndex < 0 || periodIndex >= config.periodDays.length) {
      return config;
    }
    final normalized = days == 42 ? 42 : 35;
    final updated = [...config.periodDays];
    if (updated[periodIndex] == normalized) {
      return config;
    }
    updated[periodIndex] = normalized;

    final targetDays = _targetDays(config.year);
    var delta = updated.reduce((a, b) => a + b) - targetDays;
    if (delta == 0) {
      return config.copyWithDays(updated);
    }

    final indices = List<int>.generate(updated.length, (i) => i)
      ..remove(periodIndex)
      ..sort((a, b) => (b - periodIndex).abs().compareTo((a - periodIndex).abs()));

    for (final i in indices) {
      if (delta > 0 && updated[i] == 42) {
        updated[i] = 35;
        delta -= 7;
      } else if (delta < 0 && updated[i] == 35) {
        updated[i] = 42;
        delta += 7;
      }
      if (delta == 0) {
        break;
      }
    }

    if (delta != 0) {
      return config;
    }

    return config.copyWithDays(updated);
  }

  List<int> _bonusMonthsFor(int year, DateTime startDate, List<int> periods) {
    final startMonths = <int>{};
    var cursor = _truncateDate(startDate);
    for (final days in periods) {
      if (cursor.year == year) {
        startMonths.add(cursor.month);
      }
      cursor = cursor.add(Duration(days: days));
    }
    return [
      for (var month = 1; month <= 12; month++)
        if (!startMonths.contains(month)) month,
    ];
  }

  List<int> _applyBonusOverrides(List<int> baseMonths, Map<int, bool> overrides) {
    if (overrides.isEmpty) return baseMonths;
    final updated = {...baseMonths};
    overrides.forEach((month, isBonus) {
      if (isBonus) {
        updated.add(month);
      } else {
        updated.remove(month);
      }
    });
    final list = updated.toList()..sort();
    return list;
  }

  List<_Candidate> _buildCandidates(int targetDays) {
    final candidates = <_Candidate>[];
    for (var n42 = 0; n42 <= 60; n42++) {
      for (var n35 = 0; n35 <= 60; n35++) {
        if (42 * n42 + 35 * n35 == targetDays) {
          candidates.add(_Candidate(n35: n35, n42: n42));
        }
      }
    }
    candidates.sort((a, b) {
      final scoreA = _scoreCandidate(2, a.n42, a.n35 + a.n42);
      final scoreB = _scoreCandidate(2, b.n42, b.n35 + b.n42);
      return scoreA.compareTo(scoreB);
    });
    return candidates;
  }

  List<int> _distributePeriods(int n35, int n42, int shift) {
    final total = n35 + n42;
    final periods = List<int>.filled(total, 35);
    if (n42 == 0) return periods;

    final used = <int>{};
    for (var i = 0; i < n42; i++) {
      var pos = ((i * total) / n42).floor();
      pos = (pos + shift) % total;
      while (used.contains(pos)) {
        pos = (pos + 1) % total;
      }
      used.add(pos);
      periods[pos] = 42;
    }
    return periods;
  }

  int _maxConsecutive(List<int> periods, int value) {
    var maxRun = 0;
    var current = 0;
    for (final days in periods) {
      if (days == value) {
        current++;
        if (current > maxRun) maxRun = current;
      } else {
        current = 0;
      }
    }
    return maxRun;
  }

  int _scoreCandidate(int bonusCount, int n42, int total) {
    return 1000 * (bonusCount - 2).abs() + 10 * n42 + total;
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

class _Candidate {
  final int n35;
  final int n42;
  const _Candidate({required this.n35, required this.n42});
}

extension on AnnualScheduleConfig {
  AnnualScheduleConfig copyWithDays(List<int> periodDays) {
    return AnnualScheduleConfig(
      year: year,
      startDate: startDate,
      weekStart: weekStart,
      periodDays: periodDays,
      bonusMonthOverrides: bonusMonthOverrides,
    );
  }
}
