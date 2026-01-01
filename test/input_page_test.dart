import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/add_transaction.dart';
import 'package:kakeibo/presentation/pages/input_page.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart' as tx_providers;
import 'fakes.dart';

void main() {
  List<Category> _categories() {
    return [
      const Category(id: 1, name: '食費', color: 0xFF000000, type: TransactionType.expense),
      const Category(id: 2, name: '給料', color: 0xFF000000, type: TransactionType.income),
    ];
  }

  ProviderScope _wrap(Widget child, FakeTransactionRepository fakeRepo) {
    final categories = _categories();
    return ProviderScope(
      overrides: [
        categoriesProvider.overrideWith((ref) async => categories),
        categoriesByTypeProvider.overrideWith((ref, type) async {
          return categories.where((c) => c.type == type).toList();
        }),
        tx_providers.transactionsProvider.overrideWith((ref) async => const <KakeiboTransaction>[]),
        tx_providers.addTransactionProvider.overrideWithValue(AddTransaction(fakeRepo)),
      ],
      child: MaterialApp(
        locale: const Locale('ja', 'JP'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }

  testWidgets('shows validation error when amount is empty', (WidgetTester tester) async {
    final fakeRepo = FakeTransactionRepository();
    await tester.pumpWidget(_wrap(const InputPage(), fakeRepo));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('支出を保存'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('支出を保存'));
    await tester.pumpAndSettle();

    expect(find.text('金額を入力してください'), findsOneWidget);
    expect(fakeRepo.added, isNull);
  });

  testWidgets('submits expense with selected category', (WidgetTester tester) async {
    final fakeRepo = FakeTransactionRepository();
    await tester.pumpWidget(_wrap(const InputPage(), fakeRepo));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, '金額（円）'),
      '1200',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'メモ'),
      'ランチ',
    );

    await tester.ensureVisible(find.text('支出を保存'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('支出を保存'));
    await tester.pumpAndSettle();

    expect(fakeRepo.added, isNotNull);
    expect(fakeRepo.added!.amount.value, 1200);
    expect(fakeRepo.added!.type, TransactionType.expense);
    expect(fakeRepo.added!.categoryId, 1);
    expect(fakeRepo.added!.memo, 'ランチ');
    expect(fakeRepo.added!.expenseAttribute, ExpenseAttribute.variable);
  });
}
