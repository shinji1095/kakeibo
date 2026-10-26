import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_range.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/utils/annual_schedule_colors.dart';

class HomeStats {
  final int periodIndex;
  final DateTime periodStart;
  final DateTime periodEndExclusive;
  final int daysUntilPeriodEnd;
  final int periodLengthDays;
  final DateTime calendarStart;
  final Color periodColor;

  const HomeStats({
    required this.periodIndex,
    required this.periodStart,
    required this.periodEndExclusive,
    required this.daysUntilPeriodEnd,
    required this.periodLengthDays,
    required this.calendarStart,
    required this.periodColor,
  });
}

final homePeriodColorsEnabledProvider = StateProvider<bool>((ref) => true);

final homeStatsProvider = Provider<HomeStats>((ref) {
  final now = DateTime.now();
  final schedule = ref.watch(currentAnnualScheduleProvider).valueOrNull;
  if (schedule != null && schedule.periods.isNotEmpty) {
    final period = resolveSchedulePeriod(schedule.periods, now);
    final start = period.startDate;
    final periodEndExclusive = period.endDate.add(const Duration(days: 1));
    final remaining = periodEndExclusive.difference(truncateDate(now)).inDays;
    final colors = buildAnnualScheduleColors(schedule.periods.length);
    final periodColor = colors.isNotEmpty
        ? colors[period.index % colors.length]
        : Colors.transparent;
    return HomeStats(
      periodIndex: period.index,
      periodStart: start,
      periodEndExclusive: periodEndExclusive,
      daysUntilPeriodEnd: remaining < 0 ? 0 : remaining,
      periodLengthDays: period.days,
      calendarStart: schedule.startDate,
      periodColor: periodColor,
    );
  }

  const length = 35;
  final startBase = DateTime(now.year, 1, 1);
  final start = currentPeriodStart(startBase, length, now);
  final periodEndExclusive = start.add(const Duration(days: length));
  final remaining = periodEndExclusive.difference(truncateDate(now)).inDays;
  final diffDays = truncateDate(now).difference(startBase).inDays;
  final periodIndex = diffDays < 0 ? 0 : diffDays ~/ length;
  final fallbackColors = buildAnnualScheduleColors(1);
  final periodColor =
      fallbackColors.isNotEmpty ? fallbackColors.first : Colors.transparent;

  return HomeStats(
    periodIndex: periodIndex,
    periodStart: start,
    periodEndExclusive: periodEndExclusive,
    daysUntilPeriodEnd: remaining < 0 ? 0 : remaining,
    periodLengthDays: length,
    calendarStart: startBase,
    periodColor: periodColor,
  );
});

class HomeMonthSummary {
  final Map<DateTime, ({int income, int expense})> totalsByDay;
  final int income;
  final int fixedExpenses;
  final int specialExpenses;

  const HomeMonthSummary({
    required this.totalsByDay,
    required this.income,
    required this.fixedExpenses,
    required this.specialExpenses,
  });
}

final homeMonthSummaryProvider =
    FutureProvider.family<HomeMonthSummary, DateTime>((ref, month) async {
  if (!sl.isRegistered<GetTransactionsByRange>()) {
    return const HomeMonthSummary(
      totalsByDay: <DateTime, ({int income, int expense})>{},
      income: 0,
      fixedExpenses: 0,
      specialExpenses: 0,
    );
  }

  final firstDay = DateTime(month.year, month.month, 1);
  final gridStart =
      DateTime(firstDay.year, firstDay.month, 1 - firstDay.weekday % 7);
  final gridEndExclusive =
      DateTime(gridStart.year, gridStart.month, gridStart.day + 42);
  final transactions =
      await sl<GetTransactionsByRange>()(gridStart, gridEndExclusive);
  final totalsByDay = <DateTime, ({int income, int expense})>{};
  var income = 0;
  var fixedExpenses = 0;
  var specialExpenses = 0;

  for (final tx in transactions) {
    final day = truncateDate(tx.date);
    final current = totalsByDay[day] ?? (income: 0, expense: 0);
    final isIncome = tx.type == TransactionType.income;
    totalsByDay[day] = isIncome
        ? (income: current.income + tx.amount.value, expense: current.expense)
        : (income: current.income, expense: current.expense + tx.amount.value);

    if (day.year != month.year || day.month != month.month) continue;
    if (isIncome) {
      income += tx.amount.value;
      continue;
    }
    switch (tx.expenseAttribute ?? kDefaultExpenseAttribute) {
      case ExpenseAttribute.variable:
        break;
      case ExpenseAttribute.fixed:
        fixedExpenses += tx.amount.value;
        break;
      case ExpenseAttribute.bonus:
        specialExpenses += tx.amount.value;
        break;
    }
  }

  return HomeMonthSummary(
    totalsByDay: totalsByDay,
    income: income,
    fixedExpenses: fixedExpenses,
    specialExpenses: specialExpenses,
  );
});

final homePeriodVariableTotalProvider =
    FutureProvider.family<int, ({DateTime start, DateTime endExclusive})>(
        (ref, period) async {
  if (!sl.isRegistered<GetTransactionsByRange>()) return 0;
  final transactions = await sl<GetTransactionsByRange>()(
    period.start,
    period.endExclusive,
  );
  var total = 0;
  for (final tx in transactions) {
    if (tx.type == TransactionType.expense &&
        (tx.expenseAttribute ?? kDefaultExpenseAttribute) ==
            ExpenseAttribute.variable) {
      total += tx.amount.value;
    }
  }
  return total;
});

class BonusSummary {
  final bool isBonusPeriod;
  final int bonusBalance;
  final int bonusExpenseTotal;
  final List<int> bonusPeriods;

  const BonusSummary({
    required this.isBonusPeriod,
    required this.bonusBalance,
    required this.bonusExpenseTotal,
    required this.bonusPeriods,
  });
}

final bonusSummaryProvider = FutureProvider<BonusSummary>((ref) async {
  final schedule = await ref.watch(currentAnnualScheduleProvider.future);
  if (schedule == null ||
      schedule.periods.isEmpty ||
      !sl.isRegistered<GetTransactionsByRange>()) {
    return const BonusSummary(
      isBonusPeriod: false,
      bonusBalance: 0,
      bonusExpenseTotal: 0,
      bonusPeriods: <int>[],
    );
  }

  final now = DateTime.now();
  final yearStart = schedule.startDate;
  final yearEnd = schedule.periods.last.endDate.add(const Duration(days: 1));
  final use = sl<GetTransactionsByRange>();
  final list = await use(yearStart, yearEnd);

  var variableTotal = 0;
  var bonusExpenseTotal = 0;
  for (final tx in list) {
    if (tx.type != TransactionType.expense) continue;
    final attr = tx.expenseAttribute ?? kDefaultExpenseAttribute;
    if (attr == ExpenseAttribute.variable) {
      variableTotal += tx.amount.value;
    } else if (attr == ExpenseAttribute.bonus) {
      bonusExpenseTotal += tx.amount.value;
    }
  }

  final periodBudgetTotal = schedule.periodBudget *
      schedule.periods.where((period) => period.days > 0).length;
  final bonusBalance = periodBudgetTotal - variableTotal - bonusExpenseTotal;
  final bonusPeriods = schedule.bonusPeriods;
  final currentPeriod = resolveSchedulePeriod(schedule.periods, now);
  final isZeroWeekBonusMonth = schedule.bonusMonths.any((bonus) =>
      bonus.weeks == 0 &&
      bonus.month == now.month &&
      schedule.year == now.year);

  return BonusSummary(
    isBonusPeriod:
        isZeroWeekBonusMonth || bonusPeriods.contains(currentPeriod.index),
    bonusBalance: bonusBalance,
    bonusExpenseTotal: bonusExpenseTotal,
    bonusPeriods: bonusPeriods,
  );
});
