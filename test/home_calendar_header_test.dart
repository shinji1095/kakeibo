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
    expect(find.text(l10n.homeCalendarTitle), findsOneWidget);
    expect(find.text(l10n.homeBudgetTitle), findsOneWidget);
    expect(find.text(l10n.homePeriodLabel(1)), findsOneWidget);
    expect(find.text('${now.year}'), findsOneWidget);
    expect(find.text(l10n.homeMonthlyIncomeLabel), findsOneWidget);
    expect(find.text(l10n.homeVariableTotalLabel), findsOneWidget);
    expect(find.text(l10n.homeFixedExpensesLabel), findsOneWidget);
    expect(find.text(l10n.homeSpecialExpensesLabel), findsOneWidget);
    expect(find.text(l10n.homePeriodRemaining(50000)), findsOneWidget);

    final expectedColor =
        buildAnnualScheduleColors(schedule.periods.length).first;
    final periodContainer = tester.widget<Container>(find.descendant(
      of: find.byKey(Key('home-period-${now.year}-0')),
      matching: find.byType(Container),
    ));
    final periodDecoration = periodContainer.decoration as BoxDecoration?;
    expect(periodDecoration?.color, expectedColor);

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
    expect(dayCells, findsNWidgets(42));

    expect(find.text('${now.year}年${now.month}月'), findsOneWidget);
    expect(find.byKey(Key(_calendarKey(firstDay))), findsOneWidget);
    expect(find.byKey(Key(_calendarKey(lastDay))), findsOneWidget);
  });

  testWidgets('home calendar shows the whole current month',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final schedule = _buildSchedule(now);
    await _pumpHomePage(tester, schedule);

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
  });

  testWidgets('month navigation crosses the year boundary',
      (WidgetTester tester) async {
    var month = DateTime(2026, 12);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ja', 'JP'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => PeriodCalendar(
            displayedMonth: month,
            totalsByDay: const {},
            onMonthChanged: (offset) => setState(() {
              month = DateTime(month.year, month.month + offset);
            }),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home-next-month')));
    await tester.pumpAndSettle();
    expect(find.text('2027年1月'), findsOneWidget);
    expect(
        find.byKey(Key(_calendarKey(DateTime(2027, 1, 31)))), findsOneWidget);
  });
}

String _calendarKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return 'calendar-day-$y$m$d';
}
