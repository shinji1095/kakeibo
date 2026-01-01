import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/update_transaction.dart';
import 'package:kakeibo/presentation/pages/transaction_edit_page.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart' as tx_providers;

import 'fakes.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.window.physicalSizeTestValue = const Size(1200, 2000);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  Future<GlobalKey<NavigatorState>> _pumpEditPage(
    WidgetTester tester,
    FakeTransactionRepository repo,
    KakeiboTransaction tx,
  ) async {
    final categories = [
      const Category(id: 10, name: 'Food', color: 0xFF000000, type: TransactionType.expense),
      const Category(id: 11, name: 'Salary', color: 0xFF000000, type: TransactionType.income),
    ];

    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesByTypeProvider.overrideWith((ref, type) async {
            return categories.where((c) => c.type == type).toList();
          }),
          tx_providers.updateTransactionProvider.overrideWithValue(UpdateTransaction(repo)),
        ],
        child: MaterialApp(
          navigatorKey: navKey,
          locale: const Locale('ja', 'JP'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/edit',
          routes: {
            '/': (_) => const SizedBox.shrink(),
            '/edit': (_) => TransactionEditPage(transaction: tx),
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(TransactionEditPage), findsOneWidget);
    return navKey;
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

    await tester.enterText(find.byKey(const Key('transaction-edit-amount')), '150');
    await tester.enterText(find.byKey(const Key('transaction-edit-memo')), 'updated');
    await tester.pumpAndSettle();

    final updateButton = find.byKey(const Key('transaction-edit-update'));
    expect(updateButton, findsOneWidget);
    await tester.tap(updateButton);
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

    await tester.enterText(find.byKey(const Key('transaction-edit-amount')), '');
    await tester.pumpAndSettle();

    final updateButton = find.byKey(const Key('transaction-edit-update'));
    expect(updateButton, findsOneWidget);
    await tester.tap(updateButton);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(TransactionEditPage)));
    expect(find.text(l10n.validationEnterAmount), findsOneWidget);
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

    final navKey = await _pumpEditPage(tester, repo, tx);

    navKey.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(repo.updated, isNull);
  });
}
