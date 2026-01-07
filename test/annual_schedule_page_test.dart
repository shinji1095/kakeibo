import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/set_annual_schedule_bonus_periods.dart';
import 'package:kakeibo/presentation/pages/annual_schedule_page.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

AnnualSchedule _buildSchedule(int year) {
  final startDate = DateTime(year, 1, 1);
  final periodDays = List<int>.filled(12, 35);
  periodDays[7] = 7;
  periodDays[11] = 7;
  final periods = <AnnualSchedulePeriod>[];
  var cursor = startDate;
  for (var i = 0; i < periodDays.length; i++) {
    final days = periodDays[i];
    final start = cursor;
    final end = cursor.add(Duration(days: days - 1));
    periods.add(AnnualSchedulePeriod(
      index: i,
      days: days,
      startDate: start,
      endDate: end,
    ));
    cursor = cursor.add(Duration(days: days));
  }
  return AnnualSchedule(
    year: year,
    startDate: startDate,
    weekStart: 0,
    periods: periods,
    bonusPeriods: const [7, 11],
  );
}

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

  Future<void> _pumpAnnualSchedulePage(
    WidgetTester tester, {
    SettingsNotifier? settings,
    SetAnnualScheduleBonusPeriods? setUsecase,
  }) async {
    final notifier = settings ?? SettingsNotifier();
    const year = 2023;
    final setter = setUsecase ?? _NoopSetBonusPeriods(_buildSchedule(year));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => notifier),
          annualSchedulePageYearProvider.overrideWith((ref) => year),
          annualScheduleForYearProvider.overrideWith((ref, _) async => _buildSchedule(year)),
          categoriesProvider.overrideWith((ref) async => <Category>[]),
          setAnnualScheduleBonusPeriodsProvider.overrideWith((ref) => setter),
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

  testWidgets('annual schedule chart stays within the screen', (WidgetTester tester) async {
    const size = Size(320, 640);
    binding.window.physicalSizeTestValue = size;
    await _pumpAnnualSchedulePage(tester);

    final chartFinder = find.byKey(const Key('annual-schedule-chart'));
    await tester.ensureVisible(chartFinder);
    final rect = tester.getRect(chartFinder);

    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(size.width));
    expect(rect.bottom, lessThanOrEqualTo(size.height));
  });

  testWidgets('annual schedule page shows chart labels and bonus selection controls',
      (WidgetTester tester) async {
    final setUsecase = _FakeSetBonusPeriods(_buildSchedule(2023));
    await _pumpAnnualSchedulePage(tester, setUsecase: setUsecase);

    final l10n = AppLocalizations.of(tester.element(find.byType(AnnualSchedulePage)));

    expect(find.text(l10n.annualScheduleListTitle), findsNothing);
    expect(find.text(l10n.bonusMonthTitle), findsNothing);

    expect(find.text(l10n.bonusMonthSwapTitle), findsOneWidget);
    expect(find.text(l10n.bonusMonthPrimary), findsOneWidget);
    expect(find.text(l10n.bonusMonthSecondary), findsOneWidget);

    final chartFinder = find.byKey(const Key('annual-schedule-chart'));
    expect(chartFinder, findsOneWidget);
    expect(find.byKey(const Key('bonus-period-1')), findsOneWidget);
    expect(find.byKey(const Key('bonus-period-2')), findsOneWidget);

    final applyButtonFinder = find.widgetWithText(ElevatedButton, l10n.dialogApply);
    expect(applyButtonFinder, findsOneWidget);
    final applyButton = tester.widget<ElevatedButton>(applyButtonFinder);
    expect(applyButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('bonus-period-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bonus-period-1-11')));
    await tester.pumpAndSettle();
    final disabledButton = tester.widget<ElevatedButton>(applyButtonFinder);
    expect(disabledButton.onPressed, isNull);

    await tester.tap(find.byKey(const Key('bonus-period-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bonus-period-2-0')));
    await tester.pumpAndSettle();
    final enabledButton = tester.widget<ElevatedButton>(applyButtonFinder);
    expect(enabledButton.onPressed, isNotNull);

    await tester.tap(applyButtonFinder);
    await tester.pumpAndSettle();
    expect(setUsecase.bonusPeriodIndices, [0, 11]);
  });

  testWidgets('annual schedule page hides bonus expense registration', (WidgetTester tester) async {
    await _pumpAnnualSchedulePage(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(AnnualSchedulePage)));
    expect(find.text(l10n.bonusExpenseTitle), findsNothing);
  });
}

class _NoopSetBonusPeriods implements SetAnnualScheduleBonusPeriods {
  final AnnualSchedule schedule;

  _NoopSetBonusPeriods(this.schedule);

  @override
  Future<AnnualSchedule> call({
    required int year,
    required List<int> bonusPeriodIndices,
  }) async {
    return schedule;
  }
}

class _FakeSetBonusPeriods implements SetAnnualScheduleBonusPeriods {
  final AnnualSchedule schedule;
  List<int>? bonusPeriodIndices;

  _FakeSetBonusPeriods(this.schedule);

  @override
  Future<AnnualSchedule> call({
    required int year,
    required List<int> bonusPeriodIndices,
  }) async {
    final sorted = [...bonusPeriodIndices]..sort();
    this.bonusPeriodIndices = sorted;
    return schedule;
  }
}
