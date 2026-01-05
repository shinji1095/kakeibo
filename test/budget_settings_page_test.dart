import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/pages/budget_settings_page.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

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

  Future<void> _pumpBudgetSettingsPage(
    WidgetTester tester, {
    required SettingsNotifier notifier,
    required AnnualScheduleCountStatus? countStatus,
  }) async {
    final router = GoRouter(
      initialLocation: '/settings/budget',
      routes: [
        GoRoute(
          path: '/',
          builder: (ctx, st) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/settings/budget',
          builder: (ctx, st) => const BudgetSettingsPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => notifier),
          currentAnnualScheduleCountStatusProvider.overrideWith((ref) => countStatus),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('ja', 'JP'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(BudgetSettingsPage), findsOneWidget);
  }

  testWidgets('budget save navigates home when counts are valid', (WidgetTester tester) async {
    final notifier = SettingsNotifier();
    final status = AnnualScheduleCountStatus(
      count35: 8,
      count42: 2,
      expected35: 8,
      expected42: 2,
    );

    await _pumpBudgetSettingsPage(tester, notifier: notifier, countStatus: status);

    final input = find.byKey(const Key('budget-settings-input'));
    expect(input, findsOneWidget);
    expect(find.byKey(const Key('budget-settings-back')), findsOneWidget);
    expect(find.byKey(const Key('budget-settings-save')), findsOneWidget);

    await tester.enterText(input, '65000');
    await tester.tap(find.byKey(const Key('budget-settings-save')));
    await tester.pumpAndSettle();
    expect(notifier.state.periodBudget, 65000);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('budget save stays when counts are invalid', (WidgetTester tester) async {
    final notifier = SettingsNotifier();
    final status = AnnualScheduleCountStatus(
      count35: 7,
      count42: 2,
      expected35: 8,
      expected42: 2,
    );

    await _pumpBudgetSettingsPage(tester, notifier: notifier, countStatus: status);

    final l10n = AppLocalizations.of(tester.element(find.byType(BudgetSettingsPage)));
    final input = find.byKey(const Key('budget-settings-input'));

    await tester.enterText(input, '65000');
    await tester.tap(find.byKey(const Key('budget-settings-save')));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetSettingsPage), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text(l10n.annualScheduleCountMismatchWarning), findsOneWidget);
  });

  testWidgets('budget settings page shows description', (WidgetTester tester) async {
    final notifier = SettingsNotifier();
    await _pumpBudgetSettingsPage(tester, notifier: notifier, countStatus: null);

    final l10n = AppLocalizations.of(tester.element(find.byType(BudgetSettingsPage)));
    final note = find.text(l10n.bonusBudgetNote);
    final applyNote = find.text(l10n.bonusBudgetApplyNote);
    expect(note, findsOneWidget);
    expect(applyNote, findsOneWidget);

    final input = find.byKey(const Key('budget-settings-input'));
    final inputBottom = tester.getBottomLeft(input).dy;
    final noteTop = tester.getTopLeft(note).dy;
    expect(noteTop, greaterThan(inputBottom));
  });
}
