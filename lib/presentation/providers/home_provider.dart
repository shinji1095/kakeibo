import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_range.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class HomeStats {
  final DateTime periodStart;
  final DateTime periodEndExclusive;
  final int daysUntilPeriodEnd;
  final int periodLengthDays;

  const HomeStats({
    required this.periodStart,
    required this.periodEndExclusive,
    required this.daysUntilPeriodEnd,
    required this.periodLengthDays,
  });
}

final homeStatsProvider = Provider<HomeStats>((ref) {
  final settings = ref.watch(settingsProvider);
  final schedule = ref.watch(currentAnnualScheduleProvider).valueOrNull;
  if (schedule != null && schedule.periods.isNotEmpty) {
    final period = resolveSchedulePeriod(schedule.periods, DateTime.now());
    final start = period.startDate;
    final periodEndExclusive = period.endDate.add(const Duration(days: 1));
    final remaining = periodEndExclusive.difference(truncateDate(DateTime.now())).inDays;
    return HomeStats(
      periodStart: start,
      periodEndExclusive: periodEndExclusive,
      daysUntilPeriodEnd: remaining < 0 ? 0 : remaining,
      periodLengthDays: period.days,
    );
  }

  final length = settings.periodLengthDays <= 0 ? 35 : settings.periodLengthDays;
  final start = currentPeriodStart(settings.kakeiboStartDate, length, DateTime.now());
  final periodEndExclusive = start.add(Duration(days: length));
  final remaining = periodEndExclusive.difference(truncateDate(DateTime.now())).inDays;

  return HomeStats(
    periodStart: start,
    periodEndExclusive: periodEndExclusive,
    daysUntilPeriodEnd: remaining < 0 ? 0 : remaining,
    periodLengthDays: length,
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
  final bool isBonusMonth;
  final int bonusBalance;
  final int bonusExpenseTotal;
  final List<int> bonusMonths;

  const BonusSummary({
    required this.isBonusMonth,
    required this.bonusBalance,
    required this.bonusExpenseTotal,
    required this.bonusMonths,
  });
}

final bonusSummaryProvider = FutureProvider<BonusSummary>((ref) async {
  final schedule = await ref.watch(currentAnnualScheduleProvider.future);
  final settings = ref.watch(settingsProvider);
  if (schedule == null || schedule.periods.isEmpty || !sl.isRegistered<GetTransactionsByRange>()) {
    return const BonusSummary(
      isBonusMonth: false,
      bonusBalance: 0,
      bonusExpenseTotal: 0,
      bonusMonths: <int>[],
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
  final bonusMonths = schedule.bonusMonths;

  return BonusSummary(
    isBonusMonth: bonusMonths.contains(now.month),
    bonusBalance: bonusBalance,
    bonusExpenseTotal: bonusExpenseTotal,
    bonusMonths: bonusMonths,
  );
});
