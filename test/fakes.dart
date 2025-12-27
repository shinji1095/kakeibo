import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class FakeTransactionRepository implements TransactionRepository {
  KakeiboTransaction? added;
  KakeiboTransaction? updated;
  int? deletedId;
  List<KakeiboTransaction> rangeItems = <KakeiboTransaction>[];
  int _nextId = 1;

  @override
  Future<int> add(KakeiboTransaction tx) async {
    added = tx;
    return _nextId++;
  }

  @override
  Future<void> update(KakeiboTransaction tx) async {
    updated = tx;
  }

  @override
  Future<void> delete(int id) async {
    deletedId = id;
  }

  @override
  Future<List<KakeiboTransaction>> getByMonth(DateTime monthFirstDay) async {
    return const [];
  }

  @override
  Future<List<KakeiboTransaction>> getByRange(DateTime startInclusive, DateTime endExclusive) async {
    return rangeItems;
  }

  @override
  Future<Map<int, int>> getMonthlyCategoryTotals(DateTime monthFirstDay, TransactionType type) async {
    return const {};
  }

  @override
  Future<int> getTotalByRange(DateTime startInclusive, DateTime endExclusive, TransactionType type) async {
    return 0;
  }
}
