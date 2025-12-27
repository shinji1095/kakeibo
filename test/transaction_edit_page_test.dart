import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/update_transaction.dart';
import 'package:kakeibo/presentation/pages/transaction_edit_page.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart' as tx_providers;
import 'fakes.dart';

void main() {
  Future<GoRouter> _pumpEditPage(
    WidgetTester tester,
    FakeTransactionRepository repo,
    KakeiboTransaction tx,
  ) async {
    final categories = [
      const Category(id: 10, name: '食費', color: 0xFF000000, type: TransactionType.expense),
      const Category(id: 11, name: '給料', color: 0xFF000000, type: TransactionType.income),
    ];

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (ctx, st) => const SizedBox.shrink()),
        GoRoute(path: '/edit', builder: (ctx, st) => TransactionEditPage(transaction: tx)),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesByTypeProvider.overrideWith((ref, type) async {
            return categories.where((c) => c.type == type).toList();
          }),
          tx_providers.updateTransactionProvider.overrideWithValue(UpdateTransaction(repo)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.push('/edit');
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('updates a transaction', (WidgetTester tester) async {
    final repo = FakeTransactionRepository();
    final tx = KakeiboTransaction(
      id: 1,
      date: DateTime(2024, 1, 2),
      amount: const Money(100),
      memo: 'old',
      categoryId: 10,
      type: TransactionType.expense,
      expenseAttribute: ExpenseAttribute.variable,
    );
    await _pumpEditPage(tester, repo, tx);

    await tester.enterText(find.widgetWithText(TextFormField, '金額（円）'), '150');
    await tester.enterText(find.widgetWithText(TextFormField, 'メモ'), 'updated');

    await tester.tap(find.text('更新'));
    await tester.pumpAndSettle();

    expect(repo.updated, isNotNull);
    expect(repo.updated!.id, 1);
    expect(repo.updated!.amount.value, 150);
    expect(repo.updated!.memo, 'updated');
    expect(repo.updated!.categoryId, 10);
    expect(repo.updated!.expenseAttribute, ExpenseAttribute.variable);
  });

  testWidgets('shows validation error when amount is empty', (WidgetTester tester) async {
    final repo = FakeTransactionRepository();
    final tx = KakeiboTransaction(
      id: 2,
      date: DateTime(2024, 1, 2),
      amount: const Money(100),
      memo: 'old',
      categoryId: 10,
      type: TransactionType.expense,
      expenseAttribute: ExpenseAttribute.variable,
    );

    await _pumpEditPage(tester, repo, tx);

    await tester.enterText(find.widgetWithText(TextFormField, '金額（円）'), '');
    await tester.tap(find.text('更新'));
    await tester.pumpAndSettle();

    expect(find.text('金額を入力してください'), findsOneWidget);
    expect(repo.updated, isNull);
  });

  testWidgets('does not update when navigating back', (WidgetTester tester) async {
    final repo = FakeTransactionRepository();
    final tx = KakeiboTransaction(
      id: 3,
      date: DateTime(2024, 1, 2),
      amount: const Money(100),
      memo: 'old',
      categoryId: 10,
      type: TransactionType.expense,
      expenseAttribute: ExpenseAttribute.variable,
    );

    await _pumpEditPage(tester, repo, tx);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(repo.updated, isNull);
  });
}
