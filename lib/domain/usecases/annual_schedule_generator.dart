import 'package:kakeibo/domain/entities/annual_schedule.dart';

class ScheduleConfigurationException implements Exception {
  final String message;
  const ScheduleConfigurationException(this.message);

  @override
  String toString() => message;
}

class AnnualScheduleGenerator {
  static const int periodCount = 12;
  static const int regularDays = 35;
  static const int bonusDays = 7;

  static DateTime defaultStartDate(int year) =>
      startDateForWeekday(year, DateTime.monday);

  static int daysInYear(int year) =>
      DateTime(year + 1, 1, 1).difference(DateTime(year, 1, 1)).inDays;

  static int baseWeeks(int days) {
    if (days == 7) return 1;
    if (days >= 28 && days <= 30) return 4;
    if (days >= 35 && days <= 37) return 5;
    if (days >= 42 && days <= 44) return 6;
    throw ArgumentError.value(days, 'days');
  }

  static List<int> periodMonthLabels(List<BonusMonthSetting> bonuses) {
    final zeroMonths = bonuses
        .where((bonus) => bonus.weeks == 0)
        .map((bonus) => bonus.month)
        .toSet();
    return [
      for (var month = 1; month <= 12; month++)
        if (!zeroMonths.contains(month)) month
    ];
  }

  /// The chosen weekday's first occurrence from January 1 through January 7.
  static DateTime startDateForWeekday(int year, int weekday) {
    if (weekday < DateTime.monday || weekday > DateTime.sunday) {
      throw ArgumentError.value(weekday, 'weekday');
    }
    final first = DateTime(year, 1, 1);
    final offset = (weekday - first.weekday + 7) % 7;
    return DateTime(year, 1, 1 + offset);
  }

  /// Basic settings: the selected weekday starts within January 1–7,
  /// August and December have zero-week bonuses. The nominal September,
  /// October periods are 42 days. November uses 35 days plus the remaining
  /// one or two days of the year as the start of its sixth week.
  AnnualScheduleConfig configureBasic({
    required int year,
    required int weekday,
    required int weekStart,
    required int periodBudget,
  }) {
    return configure(
      year: year,
      startDate: startDateForWeekday(year, weekday),
      weekStart: weekStart,
      bonusMonths: const [
        BonusMonthSetting(month: 8, weeks: 0),
        BonusMonthSetting(month: 12, weeks: 0),
      ],
      sixWeekPeriods: const [7, 8, 9],
      periodBudget: periodBudget,
    );
  }

  AnnualScheduleConfig generate({
    required int year,
    required DateTime startDate,
    required int weekStart,
  }) {
    return configure(
      year: year,
      startDate: startDate,
      weekStart: weekStart,
      bonusMonths: const [
        BonusMonthSetting(month: 8, weeks: 0),
        BonusMonthSetting(month: 12, weeks: 0),
      ],
      sixWeekPeriods: const [7, 8, 9],
      periodBudget: 50000,
    );
  }

  /// Zero-week bonuses are calendar-month settings and do not create periods.
  /// One-week bonuses select seven-day periods by index.
  AnnualScheduleConfig configure({
    required int year,
    required DateTime startDate,
    required int weekStart,
    required List<BonusMonthSetting> bonusMonths,
    required List<int> sixWeekPeriods,
    required int periodBudget,
  }) {
    if (bonusMonths.length != 2 ||
        bonusMonths.any((b) =>
            b.month < 1 ||
            b.month > 12 ||
            b.weeks < 0 ||
            b.weeks > 1 ||
            (b.weeks == 1 &&
                b.periodIndex != null &&
                (b.periodIndex! < 0 || b.periodIndex! >= periodCount))) ||
        bonusMonths
                .where((b) => b.weeks == 0)
                .map((b) => b.month)
                .toSet()
                .length !=
            bonusMonths.where((b) => b.weeks == 0).length ||
        bonusMonths
                .where((b) => b.weeks == 1 && b.periodIndex != null)
                .map((b) => b.periodIndex)
                .toSet()
                .length !=
            bonusMonths
                .where((b) => b.weeks == 1 && b.periodIndex != null)
                .length) {
      throw const ScheduleConfigurationException(
          'ボーナス設定を2つ選び、0週は異なる暦月、1週は異なる期を指定してください。');
    }
    if (periodBudget <= 0) {
      throw const ScheduleConfigurationException('やりくり費は1円以上にしてください。');
    }
    final zeroCount = bonusMonths.where((b) => b.weeks == 0).length;
    final count = periodCount - zeroCount;
    if (bonusMonths.any((b) =>
        b.weeks == 1 && b.periodIndex != null && b.periodIndex! >= count)) {
      throw ScheduleConfigurationException('1週にする期は1期〜$count期から選んでください。');
    }
    final six = sixWeekPeriods.toSet();
    if (!(six.length == zeroCount || (zeroCount == 2 && six.length == 3)) ||
        six.any((index) => index < 0 || index >= count)) {
      throw ScheduleConfigurationException(
          '6週にする通常期を${zeroCount == 2 ? '2期または3期' : '$zeroCount期'}選んでください。');
    }

    final start = _date(startDate);
    final oneWeekSettings = bonusMonths.where((b) => b.weeks == 1).toList();
    List<int>? matchingDays;
    List<int>? matchingIndices;
    for (var first = 0;
        first < (oneWeekSettings.isEmpty ? 1 : count);
        first++) {
      if (oneWeekSettings.isNotEmpty &&
          oneWeekSettings[0].periodIndex != null &&
          oneWeekSettings[0].periodIndex != first) {
        continue;
      }
      for (var second = 0;
          second < (oneWeekSettings.length < 2 ? 1 : count);
          second++) {
        if (oneWeekSettings.length == 2 &&
            (first == second ||
                (oneWeekSettings[1].periodIndex != null &&
                    oneWeekSettings[1].periodIndex != second))) {
          continue;
        }
        final indices = [
          if (oneWeekSettings.isNotEmpty) first,
          if (oneWeekSettings.length == 2) second,
        ];
        if (indices.any(six.contains)) continue;
        final days = List<int>.generate(
          count,
          (i) => indices.contains(i)
              ? bonusDays
              : six.contains(i)
                  ? 42
                  : regularDays,
        );
        // When both bonuses are zero-week months, the third selected period
        // starts a sixth week with only the remaining one or two days.
        final partialSixIndex =
            six.length == 3 ? six.reduce((a, b) => a > b ? a : b) : null;
        if (partialSixIndex != null) days[partialSixIndex] = regularDays;
        final regularIndices = [
          for (var i = 0; i < count; i++)
            if (!indices.contains(i)) i,
        ];
        days[partialSixIndex ?? regularIndices.last] += daysInYear(year) - 364;
        if (_matchesSelections(start, days, indices, oneWeekSettings, year)) {
          matchingDays = days;
          matchingIndices = indices;
          break;
        }
      }
      if (matchingDays != null) break;
    }
    if (matchingDays == null) {
      throw const ScheduleConfigurationException(
        '選んだ期にボーナス期間を置けません。開始日、ボーナス設定、または6週にする期を変更してください。',
      );
    }
    final indices = matchingIndices!;
    final boundaries = _boundaries(start, matchingDays);
    var oneIndex = 0;
    final settings = <BonusMonthSetting>[];
    for (final setting in bonusMonths) {
      if (setting.weeks == 0) {
        settings.add(BonusMonthSetting(month: setting.month, weeks: 0));
      } else {
        final index = indices[oneIndex++];
        settings.add(BonusMonthSetting(
            month: boundaries[index].month, weeks: 1, periodIndex: index));
      }
    }
    return AnnualScheduleConfig(
      year: year,
      startDate: start,
      weekStart: weekStart,
      periodDays: matchingDays,
      bonusMonths: settings,
      sixWeekPeriods: six.toList()..sort(),
      periodBudget: periodBudget,
    );
  }

  bool _matchesSelections(
    DateTime start,
    List<int> days,
    List<int> bonusIndices,
    List<BonusMonthSetting> bonusMonths,
    int year,
  ) {
    if (days.fold<int>(0, (sum, d) => sum + d) != daysInYear(year)) {
      return false;
    }
    final boundaries = _boundaries(start, days);
    for (var i = 0; i < bonusMonths.length; i++) {
      final index = bonusIndices[i];
      final boundary = boundaries[index];
      final selection = bonusMonths[i];
      if (selection.weeks == 1 && selection.periodIndex == null) {
        if (boundary.month != selection.month) return false;
        if (boundaries.take(index).any((earlier) =>
            earlier.year == boundary.year && earlier.month == boundary.month)) {
          return false;
        }
      }
    }
    return true;
  }

  List<DateTime> _boundaries(DateTime start, List<int> days) {
    final boundaries = <DateTime>[];
    var cursor = start;
    for (final length in days) {
      boundaries.add(cursor);
      cursor = cursor.add(Duration(days: length));
    }
    return boundaries;
  }

  AnnualScheduleConfig normalizeConfig(AnnualScheduleConfig config) {
    if (_isLegacyGeneratedSchedule(config)) {
      return configureBasic(
        year: config.year,
        weekday: DateTime.monday,
        weekStart: config.weekStart,
        periodBudget: config.periodBudget,
      );
    }
    if (_isPreviousJanuaryDefault(config)) {
      return configureBasic(
        year: config.year,
        weekday: DateTime.monday,
        weekStart: config.weekStart,
        periodBudget: config.periodBudget,
      );
    }
    // Earlier basic schedules shortened a regular period to four weeks and
    // made all three selected periods 42 days. Preserve the selections while
    // moving that week back to the regular period.
    if (config.bonusMonths.length == 2 &&
        config.bonusMonths.every((bonus) => bonus.weeks == 0) &&
        config.sixWeekPeriods.length == 3 &&
        config.periodDays.length == 10 &&
        config.periodDays.any((days) => days >= 28 && days <= 30)) {
      return configure(
        year: config.year,
        startDate: config.startDate,
        weekStart: config.weekStart,
        bonusMonths: config.bonusMonths,
        sixWeekPeriods: config.sixWeekPeriods,
        periodBudget: config.periodBudget,
      );
    }
    if (config.periodDays.contains(0)) {
      final days = config.periodDays.where((days) => days > 0).toList();
      if (days.length >= 10 &&
          days.length <= periodCount &&
          days.fold<int>(0, (sum, d) => sum + d) == 364) {
        final originalSettings = config.bonusMonths.length == 2
            ? config.bonusMonths
            : _monthsFromDays(_date(config.startDate), config.periodDays);
        final settings = <BonusMonthSetting>[];
        for (final setting in originalSettings) {
          if (setting.weeks == 0) {
            settings.add(BonusMonthSetting(month: setting.month, weeks: 0));
          } else {
            final oldIndex = setting.periodIndex ??
                _indexForLegacyBonus(
                    config.startDate, config.periodDays, setting);
            final newIndex = oldIndex -
                config.periodDays
                    .take(oldIndex)
                    .where((days) => days == 0)
                    .length;
            settings.add(BonusMonthSetting(
                month: setting.month, weeks: 1, periodIndex: newIndex));
          }
        }
        return normalizeConfig(AnnualScheduleConfig(
          year: config.year,
          startDate: config.startDate,
          weekStart: config.weekStart,
          periodDays: days,
          bonusMonths: settings,
          sixWeekPeriods: [
            for (var i = 0; i < days.length; i++)
              if (days[i] == 42) i,
          ],
          periodBudget: config.periodBudget,
        ));
      }
    }
    if (config.periodDays.fold<int>(0, (sum, d) => sum + d) == 364 &&
        config.periodDays.length >= 10 &&
        config.periodDays.length <= periodCount &&
        config.periodDays.any((days) => days >= 28)) {
      final days = config.periodDays.toList();
      final lastRegular = days.lastIndexWhere((days) => days >= 28);
      days[lastRegular] += daysInYear(config.year) - 364;
      return normalizeConfig(AnnualScheduleConfig(
        year: config.year,
        startDate: config.startDate,
        weekStart: config.weekStart,
        periodDays: days,
        bonusMonths: config.bonusMonths,
        sixWeekPeriods: config.sixWeekPeriods,
        periodBudget: config.periodBudget,
      ));
    }
    if (_isValidDays(config.periodDays, config.year)) {
      if (config.bonusMonths.length == 2 &&
          config.bonusMonths
              .every((b) => b.weeks == 0 || b.periodIndex != null)) {
        return config;
      }
      final legacyStart = _date(config.startDate);
      final isLegacySchedule = config.bonusMonths.length != 2;
      final start =
          isLegacySchedule && legacyStart == DateTime(config.year, 1, 1)
              ? defaultStartDate(config.year)
              : legacyStart;
      return AnnualScheduleConfig(
        year: config.year,
        startDate: start,
        weekStart: config.weekStart,
        periodDays: config.periodDays,
        bonusMonths: config.bonusMonths.length == 2
            ? _resolveLegacySettings(
                start, config.periodDays, config.bonusMonths)
            : _monthsFromDays(start, config.periodDays),
        sixWeekPeriods: [
          for (var i = 0; i < config.periodDays.length; i++)
            if (baseWeeks(config.periodDays[i]) == 6) i,
        ],
        periodBudget: config.periodBudget,
      );
    }
    return generate(
      year: config.year,
      startDate: config.startDate,
      weekStart: config.weekStart,
    );
  }

  bool _isLegacyGeneratedSchedule(AnnualScheduleConfig config) {
    final oldStart =
        DateTime(2026, 1, 1).add(Duration(days: 364 * (config.year - 2026)));
    if (_date(config.startDate) != oldStart ||
        config.periodDays.length != periodCount) {
      return false;
    }
    for (var i = 0; i < periodCount; i++) {
      if (config.periodDays[i] != (i == 7 || i == 11 ? 7 : regularDays)) {
        return false;
      }
    }
    if (config.bonusMonths.isEmpty) return true;
    final expected = _monthsFromDays(oldStart, config.periodDays);
    return config.bonusMonths.length == 2 &&
        List.generate(2, (i) => i).every((i) =>
            config.bonusMonths[i].month == expected[i].month &&
            config.bonusMonths[i].weeks == 1 &&
            (config.bonusMonths[i].periodIndex == null ||
                config.bonusMonths[i].periodIndex == expected[i].periodIndex));
  }

  bool _isPreviousJanuaryDefault(AnnualScheduleConfig config) {
    if (DateTime(config.year, 1, 1).weekday == DateTime.monday ||
        _date(config.startDate) != DateTime(config.year, 1, 1) ||
        config.bonusMonths.length != 2 ||
        config.bonusMonths[0].month != 8 ||
        config.bonusMonths[0].weeks != 0 ||
        config.bonusMonths[1].month != 12 ||
        config.bonusMonths[1].weeks != 0 ||
        config.sixWeekPeriods.length != 3 ||
        !config.sixWeekPeriods.toSet().containsAll({7, 8, 9})) {
      return false;
    }
    final extra = daysInYear(config.year) - 364;
    final expected = [
      ...List<int>.filled(7, 35),
      42,
      42,
      35 + extra,
    ];
    final previous = [
      ...List<int>.filled(6, 35),
      28,
      42,
      42,
      42 + extra,
    ];
    bool sameDays(List<int> values) =>
        config.periodDays.length == values.length &&
        List.generate(values.length, (i) => i)
            .every((i) => config.periodDays[i] == values[i]);
    return sameDays(expected) || sameDays(previous);
  }

  AnnualSchedule buildSchedule(AnnualScheduleConfig config) {
    final normalized = normalizeConfig(config);
    final periods = <AnnualSchedulePeriod>[];
    var cursor = _date(normalized.startDate);
    for (var i = 0; i < normalized.periodDays.length; i++) {
      final days = normalized.periodDays[i];
      periods.add(AnnualSchedulePeriod(
        index: i,
        days: days,
        startDate: cursor,
        endDate: cursor.add(Duration(days: days - 1)),
      ));
      cursor = cursor.add(Duration(days: days));
    }
    return AnnualSchedule(
      year: normalized.year,
      startDate: normalized.startDate,
      weekStart: normalized.weekStart,
      periods: periods,
      bonusPeriods: [
        for (var i = 0; i < periods.length; i++)
          if (periods[i].days == 7) i,
      ],
      bonusMonths: normalized.bonusMonths,
      sixWeekPeriods: normalized.sixWeekPeriods,
      periodBudget: normalized.periodBudget,
    );
  }

  bool _isValidDays(List<int> days, int year) {
    if (days.length < 10 ||
        days.length > periodCount ||
        days.where((days) => days == 7).length != days.length - 10 ||
        days.fold<int>(0, (sum, d) => sum + d) != daysInYear(year)) {
      return false;
    }
    var baseTotal = 0;
    var fourCount = 0;
    var sixCount = 0;
    for (final daysInPeriod in days) {
      try {
        final weeks = baseWeeks(daysInPeriod);
        baseTotal += weeks * 7;
        if (weeks == 4) fourCount++;
        if (weeks == 6) sixCount++;
      } on ArgumentError {
        return false;
      }
    }
    final zeroCount = 12 - days.length;
    return baseTotal == 364 &&
        fourCount <= 1 &&
        sixCount == zeroCount + fourCount;
  }

  int _indexForLegacyBonus(
      DateTime start, List<int> days, BonusMonthSetting setting) {
    final boundaries = _boundaries(_date(start), days);
    for (var index = 0; index < days.length; index++) {
      if (days[index] == 7 && boundaries[index].month == setting.month) {
        return index;
      }
    }
    return days.indexOf(7);
  }

  List<BonusMonthSetting> _monthsFromDays(DateTime start, List<int> days) {
    final months = <BonusMonthSetting>[];
    var cursor = _date(start);
    for (var index = 0; index < days.length; index++) {
      final length = days[index];
      if (length == 0 || length == 7) {
        months.add(BonusMonthSetting(
          month: cursor.month,
          weeks: length ~/ 7,
          periodIndex: length == 7 ? index : null,
        ));
      }
      cursor = cursor.add(Duration(days: length));
    }
    return months;
  }

  List<BonusMonthSetting> _resolveLegacySettings(
      DateTime start, List<int> days, List<BonusMonthSetting> settings) {
    final boundaries = _boundaries(start, days);
    final used = <int>{};
    final resolved = <BonusMonthSetting>[];
    for (final setting in settings) {
      final candidates = [
        for (var i = 0; i < days.length; i++)
          if (days[i] == setting.weeks * 7 && !used.contains(i)) i,
      ];
      if (candidates.isEmpty) return _monthsFromDays(start, days);
      final index = candidates.firstWhere(
        (i) => boundaries[i].month == setting.month,
        orElse: () => candidates.first,
      );
      used.add(index);
      resolved.add(BonusMonthSetting(
        month: boundaries[index].month,
        weeks: setting.weeks,
        periodIndex: setting.weeks == 1 ? index : null,
      ));
    }
    return resolved;
  }

  DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);
}
