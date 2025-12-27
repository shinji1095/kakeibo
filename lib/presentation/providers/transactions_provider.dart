import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/add_transaction.dart';
import 'package:kakeibo/domain/usecases/delete_transaction.dart';
import 'package:kakeibo/domain/usecases/get_monthly_summary.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_range.dart';
import 'package:kakeibo/domain/usecases/update_transaction.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

final monthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final periodOffsetProvider = StateProvider<int>((ref) => 0);

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