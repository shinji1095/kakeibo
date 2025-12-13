import 'package:kakeibo/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<int> add(KakeiboTransaction tx);
  Future<void> delete(int id);
  Future<List<KakeiboTransaction>> getByMonth(DateTime monthFirstDay);
  Future<Map<int, int>> getMonthlyCategoryTotals(DateTime monthFirstDay, TransactionType type);

  /// Sum of amounts within [startInclusive, endExclusive) for given type.
  Future<int> getTotalByRange(DateTime startInclusive, DateTime endExclusive, TransactionType type);
}
