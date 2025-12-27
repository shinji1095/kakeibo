import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/get_category_totals_by_range.dart';
import 'fakes.dart';

void main() {
  test('aggregates totals by category within range', () async {
    final repo = FakeTransactionRepository();
    repo.rangeItems = [
      KakeiboTransaction(
        id: 1,
        date: DateTime(2024, 1, 5),
        amount: const Money(100),
        memo: 'coffee',
        categoryId: 10,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.variable,
      ),
      KakeiboTransaction(
        id: 2,
        date: DateTime(2024, 1, 6),
        amount: const Money(50),
        memo: 'snack',
        categoryId: 10,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.fixed,
      ),
      KakeiboTransaction(
        id: 3,
        date: DateTime(2024, 1, 7),
        amount: const Money(30),
        memo: 'book',
        categoryId: 11,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.variable,
      ),
      KakeiboTransaction(
        id: 4,
        date: DateTime(2024, 1, 8),
        amount: const Money(200),
        memo: 'salary',
        categoryId: 12,
        type: TransactionType.income,
      ),
    ];

    final usecase = GetCategoryTotalsByRange(repo);
    final totals = await usecase(
      DateTime(2024, 1, 1),
      DateTime(2024, 2, 1),
      TransactionType.expense,
    );

    expect(totals[10], 150);
    expect(totals[11], 30);
    expect(totals.containsKey(12), isFalse);
  });
}
