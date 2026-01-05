import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/pages/annual_schedule_page.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
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

  AnnualSchedule _buildSchedule(int year) {
    final startDate = DateTime(year, 1, 1);
    final periods = [
      AnnualSchedulePeriod(
        index: 0,
        days: 35,
        startDate: startDate,
        endDate: startDate.add(const Duration(days: 34)),
      ),
      AnnualSchedulePeriod(
        index: 1,
        days: 42,
        startDate: startDate.add(const Duration(days: 35)),
        endDate: startDate.add(const Duration(days: 76)),
      ),
    ];
    return AnnualSchedule(
      year: year,
      startDate: startDate,
      weekStart: 0,
      periods: periods,
      bonusMonths: const [2],
    );
  }

  Future<void> _pumpAnnualSchedulePage(
    WidgetTester tester, {
    SettingsNotifier? settings,
  }) async {
    final notifier = settings ?? SettingsNotifier();
    const year = 2023;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => notifier),
          annualSchedulePageYearProvider.overrideWith((ref) => year),
          annualScheduleForYearProvider.overrideWith((ref, _) async => _buildSchedule(year)),
          categoriesProvider.overrideWith((ref) async => <Category>[]),
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
          home: const AnnualSchedulePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(AnnualSchedulePage), findsOneWidget);
  }

  testWidgets('annual schedule page shows counts and bonus toggle popup', (WidgetTester tester) async {
    await _pumpAnnualSchedulePage(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(AnnualSchedulePage)));

    expect(find.text(l10n.annualScheduleRegenerate), findsNothing);
    expect(find.text(l10n.annualSchedulePeriodSelectionCount(35, 1, 8)), findsOneWidget);
    expect(find.text(l10n.annualSchedulePeriodSelectionCount(42, 1, 2)), findsOneWidget);

    expect(find.byKey(const Key('annual-period-color-0')), findsOneWidget);
    expect(find.byKey(const Key('annual-period-color-1')), findsOneWidget);

    final month1Chip = find.byKey(const Key('bonus-month-chip-1'));
    expect(month1Chip, findsOneWidget);
    final period0Indicator = tester.widget<Container>(find.byKey(const Key('annual-period-color-0')));
    final period0Decoration = period0Indicator.decoration as BoxDecoration?;
    final month1Widget = tester.widget<Container>(month1Chip);
    final month1Decoration = month1Widget.decoration as BoxDecoration?;
    expect(month1Decoration?.color, period0Decoration?.color);

    final month1Star = find.descendant(of: month1Chip, matching: find.byIcon(Icons.star_border));
    expect(month1Star, findsOneWidget);

    final bonusChip = find.byKey(const Key('bonus-month-chip-2'));
    expect(bonusChip, findsOneWidget);
    final chipWidget = tester.widget<Container>(bonusChip);
    final decoration = chipWidget.decoration as BoxDecoration?;
    expect(decoration?.gradient, isNotNull);
    final bonusBorder = decoration?.border as Border?;
    final month1Border = month1Decoration?.border as Border?;
    expect(bonusBorder?.top.width, equals(month1Border?.top.width));

    final bonusStar = find.descendant(of: bonusChip, matching: find.byIcon(Icons.star));
    expect(bonusStar, findsOneWidget);
    final bonusIcon = tester.widget<Icon>(bonusStar);
    expect(bonusIcon.color, equals(Colors.amber));

    await tester.tap(bonusChip);
    await tester.pumpAndSettle();
    expect(find.text(l10n.bonusMonthToggleTitle), findsOneWidget);
    expect(find.text(l10n.bonusMonthToggleOn), findsOneWidget);
    expect(find.text(l10n.bonusMonthToggleOff), findsOneWidget);
  });

  testWidgets('annual schedule page hides bonus expense registration', (WidgetTester tester) async {
    await _pumpAnnualSchedulePage(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(AnnualSchedulePage)));
    expect(find.text(l10n.bonusExpenseTitle), findsNothing);
  });
}
