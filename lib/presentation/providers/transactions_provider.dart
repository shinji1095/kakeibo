import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/add_transaction.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_month.dart';
import 'package:kakeibo/domain/usecases/delete_transaction.dart';
import 'package:kakeibo/domain/usecases/get_monthly_summary.dart';

final monthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final transactionsProvider = FutureProvider<List<KakeiboTransaction>>((ref) async {
  final month = ref.watch(monthProvider);
  final use = sl<GetTransactionsByMonth>();
  return use(month);
});

final addTransactionProvider = Provider<AddTransaction>((ref) => sl<AddTransaction>());
final deleteTransactionProvider = Provider<DeleteTransaction>((ref) => sl<DeleteTransaction>());
final monthlySummaryProvider = FutureProvider.family<Map<int, int>, ({DateTime month, TransactionType type})>((ref, arg) async {
  final use = sl<GetMonthlySummary>();
  return use(arg.month, arg.type);
});
