import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/delete_transaction.dart';
import 'package:kakeibo/presentation/pages/transaction_list_page.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart' as tx_providers;
import 'fakes.dart';

void main() {
  final categories = [
    const Category(id: 1, name: '食費', color: 0xFF000000, type: TransactionType.expense),
    const Category(id: 2, name: '給料', color: 0xFF000000, type: TransactionType.income),
  ];

  List<KakeiboTransaction> _transactions() {
    return [
      KakeiboTransaction(
        id: 10,
        date: DateTime(2024, 1, 2),
        amount: const Money(100),
        memo: 'コーヒー',
        categoryId: 1,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.variable,
      ),
      KakeiboTransaction(
        id: 11,
        date: DateTime(2024, 1, 3),
        amount: const Money(200),
        memo: '給料',
        categoryId: 2,
        type: TransactionType.income,
      ),
    ];
  }

  ProviderScope _wrap(Widget child, FakeTransactionRepository fakeRepo, List<KakeiboTransaction> list) {
    return ProviderScope(
      overrides: [
        categoriesProvider.overrideWith((ref) async => categories),
        categoriesByTypeProvider.overrideWith((ref, type) async {
          return categories.where((c) => c.type == type).toList();
        }),
        tx_providers.transactionsProvider.overrideWith((ref) async => list),
        tx_providers.deleteTransactionProvider.overrideWithValue(DeleteTransaction(fakeRepo)),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('filters by transaction type', (WidgetTester tester) async {
    final fakeRepo = FakeTransactionRepository();
    await tester.pumpWidget(_wrap(const TransactionListPage(), fakeRepo, _transactions()));
    await tester.pumpAndSettle();

    expect(find.text('100 円'), findsOneWidget);
    expect(find.text('200 円'), findsOneWidget);

    await tester.tap(find.text('支出'));
    await tester.pumpAndSettle();

    expect(find.text('100 円'), findsOneWidget);
    expect(find.text('200 円'), findsNothing);
  });

  testWidgets('deletes a transaction after confirmation', (WidgetTester tester) async {
    final fakeRepo = FakeTransactionRepository();
    await tester.pumpWidget(_wrap(const TransactionListPage(), fakeRepo, _transactions()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    expect(find.text('削除確認'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '削除'));
    await tester.pumpAndSettle();

    expect(fakeRepo.deletedId, 10);
  });

  testWidgets('filters expenses by attribute', (WidgetTester tester) async {
    final fakeRepo = FakeTransactionRepository();
    final list = [
      KakeiboTransaction(
        id: 10,
        date: DateTime(2024, 1, 2),
        amount: const Money(100),
        memo: 'fixed',
        categoryId: 1,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.fixed,
      ),
      KakeiboTransaction(
        id: 12,
        date: DateTime(2024, 1, 3),
        amount: const Money(150),
        memo: 'variable',
        categoryId: 1,
        type: TransactionType.expense,
        expenseAttribute: ExpenseAttribute.variable,
      ),
      KakeiboTransaction(
        id: 11,
        date: DateTime(2024, 1, 4),
        amount: const Money(200),
        memo: 'income',
        categoryId: 2,
        type: TransactionType.income,
      ),
    ];

    await tester.pumpWidget(_wrap(const TransactionListPage(), fakeRepo, list));
    await tester.pumpAndSettle();

    expect(find.text('100 円'), findsOneWidget);
    expect(find.text('150 円'), findsOneWidget);
    expect(find.text('200 円'), findsOneWidget);

    await tester.tap(find.text('やりくり費'));
    await tester.pumpAndSettle();

    expect(find.text('100 円'), findsOneWidget);
    expect(find.text('150 円'), findsNothing);
    expect(find.text('200 円'), findsOneWidget);
  });
}
