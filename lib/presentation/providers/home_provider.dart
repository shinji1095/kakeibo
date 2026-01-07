import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_range.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';
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

  final length = 35;
  final startBase = DateTime(now.year, 1, 1);
  final start = currentPeriodStart(startBase, length, now);
  final periodEndExclusive = start.add(Duration(days: length));
  final remaining = periodEndExclusive.difference(truncateDate(now)).inDays;
  final diffDays = truncateDate(now).difference(startBase).inDays;
  final periodIndex = diffDays < 0 ? 0 : diffDays ~/ length;
  final fallbackColors = buildAnnualScheduleColors(1);
  final periodColor = fallbackColors.isNotEmpty ? fallbackColors.first : Colors.transparent;

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

class HomeCalendarSummary {
  final Map<DateTime, ({int income, int expense})> totalsByDay;
  final int remainingBudget;

  const HomeCalendarSummary({
    required this.totalsByDay,
    required this.remainingBudget,
  });
}

final homeCalendarSummaryProvider = FutureProvider<HomeCalendarSummary>((ref) async {
  final stats = ref.watch(homeStatsProvider);
  final settings = ref.watch(settingsProvider);

  if (!sl.isRegistered<GetTransactionsByRange>()) {
    return HomeCalendarSummary(
      totalsByDay: <DateTime, ({int income, int expense})>{},
      remainingBudget: settings.periodBudget,
    );
  }

  final use = sl<GetTransactionsByRange>();
  final list = await use(stats.periodStart, stats.periodEndExclusive);
  final totalsByDay = <DateTime, ({int income, int expense})>{};
  var usedBudget = 0;

  for (final tx in list) {
    final day = truncateDate(tx.date);
    final current = totalsByDay[day] ?? (income: 0, expense: 0);
    if (tx.type == TransactionType.income) {
      totalsByDay[day] = (
        income: current.income + tx.amount.value,
        expense: current.expense,
      );
    } else {
      totalsByDay[day] = (
        income: current.income,
        expense: current.expense + tx.amount.value,
      );
      final attr = tx.expenseAttribute ?? kDefaultExpenseAttribute;
      if (attr == ExpenseAttribute.variable) {
        usedBudget += tx.amount.value;
      }
    }
  }

  final remaining = settings.periodBudget - usedBudget;
  return HomeCalendarSummary(
    totalsByDay: totalsByDay,
    remainingBudget: remaining,
  );
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
  final settings = ref.watch(settingsProvider);
  if (schedule == null || schedule.periods.isEmpty || !sl.isRegistered<GetTransactionsByRange>()) {
    return const BonusSummary(
      isBonusPeriod: false,
      bonusBalance: 0,
      bonusExpenseTotal: 0,
      bonusPeriods: <int>[],
    );
  }

  final now = DateTime.now();
  final yearStart = DateTime(schedule.year, 1, 1);
  final yearEnd = DateTime(schedule.year + 1, 1, 1);
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

  final periodBudgetTotal = settings.periodBudget * schedule.periods.length;
  final bonusBalance = periodBudgetTotal - variableTotal - bonusExpenseTotal;
  final bonusPeriods = schedule.bonusPeriods;
  final currentPeriod = resolveSchedulePeriod(schedule.periods, now);

  return BonusSummary(
    isBonusPeriod: currentPeriod.days == 7,
    bonusBalance: bonusBalance,
    bonusExpenseTotal: bonusExpenseTotal,
    bonusPeriods: bonusPeriods,
  );
});
