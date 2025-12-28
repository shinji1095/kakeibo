import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_range.dart';
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
