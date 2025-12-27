import 'package:drift/drift.dart' as d;
import 'package:kakeibo/data/datasources/local/drift_db.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase db;
  TransactionRepositoryImpl(this.db) {
    db.ensureSeeded();
  }

  @override
  Future<int> add(KakeiboTransaction tx) async {
    final id = await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        date: tx.date,
        amount: tx.amount.value,
        memo: d.Value(tx.memo),
        categoryId: tx.categoryId,
        type: tx.type == TransactionType.expense ? 0 : 1,
      ),
    );
    return id;
  }

  @override
  Future<void> update(KakeiboTransaction tx) async {
    if (tx.id == null) {
      throw ArgumentError('Transaction id is required for update');
    }
    await (db.update(db.transactions)..where((tbl) => tbl.id.equals(tx.id!))).write(
      TransactionsCompanion(
        date: d.Value(tx.date),
        amount: d.Value(tx.amount.value),
        memo: d.Value(tx.memo),
        categoryId: d.Value(tx.categoryId),
        type: d.Value(tx.type == TransactionType.expense ? 0 : 1),
      ),
    );
  }

  @override
  Future<void> delete(int id) {
    return (db.delete(db.transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<List<KakeiboTransaction>> getByMonth(DateTime monthFirstDay) async {
    final month = DateTime(monthFirstDay.year, monthFirstDay.month);
    final next = DateTime(month.year, month.month + 1);
    return getByRange(month, next);
  }

  @override
  Future<List<KakeiboTransaction>> getByRange(DateTime startInclusive, DateTime endExclusive) async {
    final rows = await (db.select(db.transactions)
          ..where((t) => t.date.isBiggerOrEqualValue(startInclusive) & t.date.isSmallerThanValue(endExclusive))
          ..orderBy([(t) => d.OrderingTerm.asc(t.date)]))
        .get();

    return rows
        .map((r) => KakeiboTransaction(
              id: r.id,
              date: r.date,
              amount: Money(r.amount),
              memo: r.memo,
              categoryId: r.categoryId,
              type: r.type == 0 ? TransactionType.expense : TransactionType.income,
            ))
        .toList();
  }

  @override
  Future<Map<int, int>> getMonthlyCategoryTotals(DateTime monthFirstDay, TransactionType type) async {
    final month = DateTime(monthFirstDay.year, monthFirstDay.month);
    final next = DateTime(month.year, month.month + 1);
    final t = db.transactions;
    final q = db.customSelect(
      'SELECT category_id, SUM(amount) AS total FROM transactions '
      'WHERE date >= ? AND date < ? AND type = ? GROUP BY category_id',
      variables: [
        d.Variable<DateTime>(month),
        d.Variable<DateTime>(next),
        d.Variable<int>(type == TransactionType.expense ? 0 : 1),
      ],
      readsFrom: {t},
    );

    final rows = await q.get();
    final map = <int, int>{};
    for (final r in rows) {
      final raw = r.data['total'];
      final total = _toInt(raw);
      map[r.data['category_id'] as int] = total;
    }
    return map;
  }

  @override
  Future<int> getTotalByRange(DateTime startInclusive, DateTime endExclusive, TransactionType type) async {
    final t = db.transactions;
    final q = db.customSelect(
      'SELECT SUM(amount) AS total FROM transactions '
      'WHERE date >= ? AND date < ? AND type = ?',
      variables: [
        d.Variable<DateTime>(startInclusive),
        d.Variable<DateTime>(endExclusive),
        d.Variable<int>(type == TransactionType.expense ? 0 : 1),
      ],
      readsFrom: {t},
    );

    final rows = await q.get();
    if (rows.isEmpty) return 0;
    return _toInt(rows.first.data['total']);
  }

  int _toInt(Object? v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is BigInt) return v.toInt();
    if (v is num) return v.toInt();
    return 0;
  }
}