import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/presentation/pages/home_page.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/utils/annual_schedule_colors.dart';
import 'package:kakeibo/presentation/widgets/period_calendar.dart';

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

  AnnualSchedule _buildSchedule(DateTime now) {
    final startDate = DateTime(now.year, now.month, 1);
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
      year: now.year,
      startDate: startDate,
      weekStart: 0,
      periods: periods,
      bonusPeriods: const [7, 11],
    );
  }

  Future<void> _pumpHomePage(
      WidgetTester tester, AnnualSchedule schedule) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => SettingsNotifier()),
          annualScheduleForYearProvider.overrideWith(
              (ref, year) async => year == schedule.year ? schedule : null),
          currentAnnualScheduleProvider.overrideWith((ref) async => schedule),
          bonusSummaryProvider.overrideWith((ref) async => const BonusSummary(
                isBonusPeriod: false,
                bonusBalance: 0,
                bonusExpenseTotal: 0,
                bonusPeriods: <int>[],
              )),
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
          home: const HomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  }

  testWidgets('home shows period, calendar, and budget sections',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final schedule = _buildSchedule(now);
    await _pumpHomePage(tester, schedule);

    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));

    expect(find.text(l10n.homeDescription), findsNothing);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(find.text(l10n.bonusSummaryTitle), findsNothing);
    expect(find.text(l10n.bonusMonthInactive), findsNothing);

    expect(find.text(l10n.homePeriodsTitle), findsOneWidget);
    expect(find.byKey(const Key('home-display-mode-toggle')), findsOneWidget);
    expect(find.byKey(const Key('home-period-date-table')), findsNothing);
    expect(find.text(l10n.homeMonthColorsLabel), findsOneWidget);
    expect(find.text(l10n.homeCalendarTitle), findsOneWidget);
    expect(find.text(l10n.homeBudgetTitle), findsOneWidget);
    expect(find.byKey(const Key('home-period-calendar')), findsOneWidget);
    expect(find.byKey(Key('home-month-choice-${now.year}-${now.month}')),
        findsOneWidget);
    expect(find.text('${now.year}'), findsOneWidget);
    expect(find.text(l10n.homeMonthlyIncomeLabel), findsOneWidget);
    expect(find.text(l10n.homeVariableTotalLabel), findsOneWidget);
    expect(find.text(l10n.homeFixedExpensesLabel), findsOneWidget);
    expect(find.text(l10n.homeSpecialExpensesLabel), findsOneWidget);
    expect(find.byKey(const Key('home-budget-days-remaining')), findsOneWidget);
    expect(find.text(l10n.formatYenAmount(50000)), findsOneWidget);
    expect(find.text(l10n.homeRemainingLabel), findsNWidgets(2));
    expect(find.text(' / ${l10n.homeBudgetUnitWeek}'), findsOneWidget);
    expect(find.text(' / ${l10n.homeBudgetUnitMonth}'), findsOneWidget);
    expect(find.textContaining('この期間は残り'), findsNothing);

    final expectedColor = buildAnnualScheduleColors(12)[now.month - 1];
    final monthContainer = tester.widget<Container>(find.descendant(
      of: find.byKey(Key('home-month-choice-${now.year}-${now.month}')),
      matching: find.byType(Container),
    ));
    final monthDecoration = monthContainer.decoration as BoxDecoration?;
    expect(monthDecoration?.color, expectedColor);

    final todayCell =
        tester.widget<Container>(find.byKey(Key(_calendarKey(now))));
    final todayDecoration = todayCell.decoration as BoxDecoration?;
    final todayBorder = todayDecoration?.border as Border?;
    expect(todayBorder?.top.width, greaterThan(0));

    final dayCells = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.key is Key) {
        final value = (widget.key as Key).toString();
        return value.contains('calendar-day-');
      }
      return false;
    });
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    expect(dayCells, findsNWidgets(35));
    final surface =
        Theme.of(tester.element(find.byType(HomePage))).colorScheme.surface;
    expect(todayDecoration?.color,
        Color.alphaBlend(expectedColor.withAlpha(110), surface));

    expect(find.text(l10n.formatLongDate(now)), findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const Key('home-budget-period-range')))
            .data,
        '${l10n.formatMonthDay(schedule.periods[0].startDate)} - ${l10n.formatMonthDay(schedule.periods[0].endDate)}');
    expect(find.byKey(const Key('home-budget-link')), findsNothing);
    expect(find.byKey(const Key('home-selected-day-total')), findsNothing);
    expect(
        find.byKey(const Key('home-weekly-target-progress')), findsOneWidget);
    await tester.tap(find.text(l10n.homeModeMonth));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-period-timeline')), findsOneWidget);
    expect(find.text(l10n.homePeriodColorsLabel), findsOneWidget);
    expect(find.text('${now.year}年${now.month}月'), findsOneWidget);
    expect(find.byKey(Key(_calendarKey(firstDay))), findsOneWidget);
    expect(find.byKey(Key(_calendarKey(lastDay))), findsOneWidget);

    final periodColor =
        buildAnnualScheduleColors(schedule.periods.length).first;
    final periodCircle = tester.widget<Container>(find.descendant(
      of: find.byKey(Key('home-period-${now.year}-0')),
      matching: find.byType(Container),
    ));
    expect((periodCircle.decoration as BoxDecoration).color, periodColor);
    final firstDayCell =
        tester.widget<Container>(find.byKey(Key(_calendarKey(firstDay))));
    expect((firstDayCell.decoration as BoxDecoration).color,
        Color.alphaBlend(periodColor.withAlpha(110), surface));
  });

  testWidgets('home calendar shows the whole current month',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final schedule = _buildSchedule(now);
    await _pumpHomePage(tester, schedule);
    await tester.tap(find.text('暦月'));
    await tester.pumpAndSettle();

    final firstDay = DateTime(now.year, now.month, 1);
    final gridStart = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    final gridEnd =
        DateTime(gridStart.year, gridStart.month, gridStart.day + 41);

    expect(find.byKey(Key(_calendarKey(gridStart))), findsOneWidget);
    expect(find.byKey(Key(_calendarKey(gridEnd))), findsOneWidget);
    expect(
        find.byKey(
            Key(_calendarKey(gridStart.subtract(const Duration(days: 1))))),
        findsNothing);
    expect(find.byKey(Key(_calendarKey(gridEnd.add(const Duration(days: 1))))),
        findsNothing);
  });

  testWidgets('horizontal swipes move between months in both directions',
      (WidgetTester tester) async {
    final now = DateTime.now();
    await _pumpHomePage(tester, _buildSchedule(now));
    await tester.tap(find.text('暦月'));
    await tester.pumpAndSettle();

    final nextMonth = DateTime(now.year, now.month + 1, 1);
    await tester.fling(find.byKey(const Key('home-month-calendar')),
        const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('${nextMonth.year}年${nextMonth.month}月'), findsOneWidget);
    expect(
        find.byKey(
            Key(_calendarKey(DateTime(nextMonth.year, nextMonth.month, 1)))),
        findsOneWidget);

    await tester.fling(find.byKey(const Key('home-month-calendar')),
        const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('${now.year}年${now.month}月'), findsOneWidget);

    await tester.fling(find.byKey(const Key('home-month-calendar')),
        const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-calendar-today')));
    await tester.pumpAndSettle();
    expect(find.text('${now.year}年${now.month}月'), findsOneWidget);
  });

  testWidgets('period calendar moves by swiping', (WidgetTester tester) async {
    final now = DateTime.now();
    final schedule = _buildSchedule(now);
    await _pumpHomePage(tester, schedule);
    await tester.fling(find.byKey(const Key('home-period-calendar')),
        const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
    expect(find.byKey(const Key('home-period-date-table')), findsNothing);
    expect(find.text('${schedule.year} · ${l10n.homePeriodLabel(2)}'),
        findsOneWidget);
    expect(find.byKey(const Key('home-calendar-today')), findsOneWidget);
    expect(find.byKey(const Key('home-previous-month')), findsNothing);
    expect(find.byKey(const Key('home-next-month')), findsNothing);
    expect(
        tester
            .widget<Text>(find.byKey(const Key('home-budget-days-remaining')))
            .data,
        l10n.homeCountdownDays(schedule.periods[1].days - 1));
  });

  testWidgets('tapping a day selects it after swiping away from today',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final schedule = _buildSchedule(now);
    await _pumpHomePage(tester, schedule);

    await tester.fling(find.byKey(const Key('home-period-calendar')),
        const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();

    final date = schedule.periods[1].startDate.add(const Duration(days: 10));
    final dateCell = find.byKey(Key(_calendarKey(date)));
    expect(dateCell, findsOneWidget);
    await tester.tap(dateCell);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
    expect(
        tester.widget<Text>(find.byKey(const Key('home-selected-date'))).data,
        l10n.formatLongDate(date));
    expect(
        tester
            .widget<Text>(find.byKey(const Key('home-budget-days-remaining')))
            .data,
        l10n.homeCountdownDays(schedule.periods[1].days - 11));
    final decoration =
        tester.widget<Container>(dateCell).decoration as BoxDecoration;
    expect((decoration.border as Border).top.width, 3);
  });

  test('period calendar uses only the weeks in each period', () {
    AnnualSchedulePeriod periodWithDays(int days) => AnnualSchedulePeriod(
          index: 0,
          days: days,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, days),
        );

    expect(PeriodCalendar.rowCountForPeriod(periodWithDays(7)), 1);
    expect(PeriodCalendar.rowCountForPeriod(periodWithDays(35)), 5);
    expect(PeriodCalendar.rowCountForPeriod(periodWithDays(36)), 6);
    expect(PeriodCalendar.rowCountForPeriod(periodWithDays(42)), 6);
  });
}

String _calendarKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return 'calendar-day-$y$m$d';
}
