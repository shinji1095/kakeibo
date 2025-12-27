import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/add_transaction.dart';
import 'package:kakeibo/domain/usecases/delete_transaction.dart';
import 'package:kakeibo/domain/usecases/get_category_totals_by_range.dart';
import 'package:kakeibo/domain/usecases/get_monthly_summary.dart';
import 'package:kakeibo/domain/usecases/get_total_by_range.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_range.dart';
import 'package:kakeibo/domain/usecases/update_transaction.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

final monthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final periodOffsetProvider = StateProvider<int>((ref) => 0);

final expenseAttributeFilterProvider = StateProvider<Set<ExpenseAttribute>>(
  (ref) => ExpenseAttribute.values.toSet(),
);

final periodRangeProvider = Provider<({DateTime start, DateTime end})>((ref) {
  final settings = ref.watch(settingsProvider);
  final offset = ref.watch(periodOffsetProvider);
  final length = settings.periodLengthDays <= 0 ? 35 : settings.periodLengthDays;
  final baseStart = currentPeriodStart(settings.kakeiboStartDate, length, DateTime.now());
  final start = baseStart.add(Duration(days: length * offset));
  final end = start.add(Duration(days: length));
  return (start: start, end: end);
});

final transactionsProvider = FutureProvider<List<KakeiboTransaction>>((ref) async {
  final range = ref.watch(periodRangeProvider);
  final use = sl<GetTransactionsByRange>();
  return use(range.start, range.end);
});

final addTransactionProvider = Provider<AddTransaction>((ref) => sl<AddTransaction>());
final updateTransactionProvider = Provider<UpdateTransaction>((ref) => sl<UpdateTransaction>());
final deleteTransactionProvider = Provider<DeleteTransaction>((ref) => sl<DeleteTransaction>());

final monthlySummaryProvider = FutureProvider.family<Map<int, int>, ({DateTime month, TransactionType type})>((ref, arg) async {
  final use = sl<GetMonthlySummary>();
  return use(arg.month, arg.type);
});

final periodCategoryTotalsProvider = FutureProvider.family<Map<int, int>, TransactionType>((ref, type) async {
  final range = ref.watch(periodRangeProvider);
  final filters = ref.watch(expenseAttributeFilterProvider);
  final use = sl<GetCategoryTotalsByRange>();
  return use(range.start, range.end, type, expenseAttributes: filters);
});

final trendCountProvider = StateProvider<int>((ref) => 3);

final periodTotalsProvider = FutureProvider<List<({DateTime start, DateTime end, int income, int expense})>>((ref) async {
  final range = ref.watch(periodRangeProvider);
  final count = ref.watch(trendCountProvider);
  final length = range.end.difference(range.start).inDays;
  final ranges = buildPeriodRanges(range.start, length, count);
  final use = sl<GetTotalByRange>();
  final filters = ref.watch(expenseAttributeFilterProvider);

  final results = <({DateTime start, DateTime end, int income, int expense})>[];
  for (final r in ranges) {
    final income = await use(r.start, r.end, TransactionType.income);
    final expense = await use(
      r.start,
      r.end,
      TransactionType.expense,
      expenseAttributes: filters,
    );
    results.add((start: r.start, end: r.end, income: income, expense: expense));
  }

  return results;
});
