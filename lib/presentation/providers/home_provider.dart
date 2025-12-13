import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class HomeStats {
  final DateTime monthStart;
  final DateTime monthEndExclusive;

  final int daysUntilMonthEnd;

  final int thisMonthExpensePlanned;
  final int lastMonthIncome;
  final int diff;

  final bool isBonusMonth;
  final int daysUntilNextBonusMonthStart;

  const HomeStats({
    required this.monthStart,
    required this.monthEndExclusive,
    required this.daysUntilMonthEnd,
    required this.thisMonthExpensePlanned,
    required this.lastMonthIncome,
    required this.diff,
    required this.isBonusMonth,
    required this.daysUntilNextBonusMonthStart,
  });
}

DateTime _dateInMonthClamped(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  final d = day > lastDay ? lastDay : day;
  return DateTime(year, month, d);
}

DateTime _occurrenceOnOrBefore(DateTime today, int dayOfMonth) {
  final candidate = _dateInMonthClamped(today.year, today.month, dayOfMonth);
  if (!candidate.isAfter(today)) return candidate;

  // previous month
  final prevMonth = DateTime(today.year, today.month - 1, 1);
  return _dateInMonthClamped(prevMonth.year, prevMonth.month, dayOfMonth);
}

DateTime _nextOccurrence(DateTime occurrence, int dayOfMonth) {
  final nextMonth = DateTime(occurrence.year, occurrence.month + 1, 1);
  return _dateInMonthClamped(nextMonth.year, nextMonth.month, dayOfMonth);
}

DateTime _prevOccurrence(DateTime occurrence, int dayOfMonth) {
  final prevMonth = DateTime(occurrence.year, occurrence.month - 1, 1);
  return _dateInMonthClamped(prevMonth.year, prevMonth.month, dayOfMonth);
}

int _ceilWeeks(int days) {
  // ceil(days/7)
  return (days + 6) ~/ 7;
}

bool _isBonusMonth(DateTime start, DateTime endExclusive) {
  final days = endExclusive.difference(start).inDays;
  return _ceilWeeks(days) < 5;
}

int _daysUntilNextBonusMonthStart(DateTime today, int fixedDay) {
  // If current period is bonus => 0
  var start = _occurrenceOnOrBefore(today, fixedDay);
  var end = _nextOccurrence(start, fixedDay);

  if (_isBonusMonth(start, end)) return 0;

  // Search forward (up to 36 periods) for next bonus month
  var nextStart = end;
  for (var i = 0; i < 36; i++) {
    final nextEnd = _nextOccurrence(nextStart, fixedDay);
    if (_isBonusMonth(nextStart, nextEnd)) {
      final d = nextStart.difference(today).inDays;
      return d < 0 ? 0 : d;
    }
    nextStart = nextEnd;
  }

  // If not found (unlikely), treat as not available
  return 0;
}

final homeStatsProvider = FutureProvider<HomeStats?>((ref) async {
  final settings = ref.watch(settingsProvider);
  final fixedDay = settings.fixedExpenseDay;
  if (fixedDay == null) return null;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final monthStart = _occurrenceOnOrBefore(today, fixedDay);
  final monthEndExclusive = _nextOccurrence(monthStart, fixedDay);
  final prevStart = _prevOccurrence(monthStart, fixedDay);

  final repo = sl<TransactionRepository>();

  final thisExpenseActual = await repo.getTotalByRange(
    monthStart,
    monthEndExclusive,
    TransactionType.expense,
  );

  final lastIncome = await repo.getTotalByRange(
    prevStart,
    monthStart,
    TransactionType.income,
  );

  // planned = actual + fixedExpenseAmount (固定支出は月1回必ずある、を反映)
  final thisExpensePlanned = thisExpenseActual + settings.fixedExpenseAmount;
  final diff = lastIncome - thisExpensePlanned;

  final daysUntilEnd = monthEndExclusive.difference(today).inDays;
  final isBonus = _isBonusMonth(monthStart, monthEndExclusive);
  final daysUntilBonus = _daysUntilNextBonusMonthStart(today, fixedDay);

  return HomeStats(
    monthStart: monthStart,
    monthEndExclusive: monthEndExclusive,
    daysUntilMonthEnd: daysUntilEnd < 0 ? 0 : daysUntilEnd,
    thisMonthExpensePlanned: thisExpensePlanned,
    lastMonthIncome: lastIncome,
    diff: diff,
    isBonusMonth: isBonus,
    daysUntilNextBonusMonthStart: daysUntilBonus,
  );
});
