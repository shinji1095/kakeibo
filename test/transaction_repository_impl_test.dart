import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/datasources/local/drift_db.dart';
import 'package:kakeibo/data/repositories/category_repository_impl.dart';
import 'package:kakeibo/data/repositories/transaction_repository_impl.dart';
import 'package:kakeibo/domain/entities/transaction.dart';

void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl repo;
  late CategoryRepositoryImpl categoryRepo;
  late int expenseCatId;
  late int expenseCatId2;
  late int incomeCatId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureSeeded();
    repo = TransactionRepositoryImpl(db);
    categoryRepo = CategoryRepositoryImpl(db);

    final rows = await db.select(db.categories).get();
    final expenseCats = rows.where((c) => c.type == 0).toList();
    final incomeCats = rows.where((c) => c.type == 1).toList();

    expenseCatId = expenseCats.first.id;
    expenseCatId2 = expenseCats.length > 1 ? expenseCats[1].id : expenseCats.first.id;
    incomeCatId = incomeCats.first.id;
  });

  tearDown(() async {
    await db.close();
  });

  test('category repository returns seeded categories', () async {
    final categories = await categoryRepo.getAll();
    expect(categories, isNotEmpty);
    expect(categories.any((c) => c.type == TransactionType.expense), isTrue);
    expect(categories.any((c) => c.type == TransactionType.income), isTrue);
  });

  test('add/update/delete and range queries work', () async {
    final id1 = await repo.add(
      KakeiboTransaction(
        date: DateTime(2024, 1, 5),
        amount: const Money(100),
        memo: 'coffee',
        categoryId: expenseCatId,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.variable,
      ),
    );

    final id2 = await repo.add(
      KakeiboTransaction(
        date: DateTime(2024, 1, 10),
        amount: const Money(200),
        memo: 'lunch',
        categoryId: expenseCatId,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.variable,
      ),
    );

    final id3 = await repo.add(
      KakeiboTransaction(
        date: DateTime(2024, 1, 15),
        amount: const Money(300),
        memo: 'rent',
        categoryId: expenseCatId2,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.fixed,
      ),
    );

    final id4 = await repo.add(
      KakeiboTransaction(
        date: DateTime(2024, 1, 8),
        amount: const Money(500),
        memo: 'salary',
        categoryId: incomeCatId,
        type: TransactionType.income,
      ),
    );

    await repo.add(
      KakeiboTransaction(
        date: DateTime(2024, 2, 1),
        amount: const Money(999),
        memo: 'outside',
        categoryId: expenseCatId,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.bonus,
      ),
    );

    final rangeList = await repo.getByRange(
      DateTime(2024, 1, 1),
      DateTime(2024, 2, 1),
    );

    expect(rangeList.length, 4);
    expect(rangeList.first.date, DateTime(2024, 1, 5));
    expect(
      rangeList.firstWhere((t) => t.id == id1).expenseAttribute,
      ExpenseAttribute.variable,
    );

    final updated = rangeList.firstWhere((t) => t.id == id1).copyWith(
          amount: const Money(150),
          memo: 'updated',
        );
    await repo.update(updated);

    final afterUpdate = await repo.getByRange(
      DateTime(2024, 1, 1),
      DateTime(2024, 2, 1),
    );
    final updatedRow = afterUpdate.firstWhere((t) => t.id == id1);
    expect(updatedRow.amount.value, 150);
    expect(updatedRow.memo, 'updated');

    await repo.delete(id4);
    final afterDelete = await repo.getByRange(
      DateTime(2024, 1, 1),
      DateTime(2024, 2, 1),
    );
    expect(afterDelete.any((t) => t.id == id4), isFalse);

    final expenseTotal = await repo.getTotalByRange(
      DateTime(2024, 1, 1),
      DateTime(2024, 2, 1),
      TransactionType.expense,
    );
    expect(expenseTotal, 150 + 200 + 300);

    final incomeTotal = await repo.getTotalByRange(
      DateTime(2024, 1, 1),
      DateTime(2024, 2, 1),
      TransactionType.income,
    );
    expect(incomeTotal, 0);

    final monthlyTotals = await repo.getMonthlyCategoryTotals(
      DateTime(2024, 1, 1),
      TransactionType.expense,
    );

    final expectedPrimary = expenseCatId == expenseCatId2 ? 150 + 200 + 300 : 150 + 200;
    expect(monthlyTotals[expenseCatId], expectedPrimary);
    if (expenseCatId2 != expenseCatId) {
      expect(monthlyTotals[expenseCatId2], 300);
    }

    expect(afterDelete.map((t) => t.id), contains(id2));
    expect(afterDelete.map((t) => t.id), contains(id3));
  });
}
