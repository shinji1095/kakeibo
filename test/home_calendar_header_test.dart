import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/pages/home_page.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/utils/annual_schedule_colors.dart';

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
      year: now.year,
      startDate: startDate,
      weekStart: 0,
      periods: periods,
      bonusMonths: const [],
    );
  }

  Future<void> _pumpHomePage(WidgetTester tester, AnnualSchedule schedule) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => SettingsNotifier()),
          currentAnnualScheduleProvider.overrideWith((ref) async => schedule),
          homeCalendarSummaryProvider.overrideWith((ref) async => const HomeCalendarSummary(
                totalsByDay: <DateTime, ({int income, int expense})>{},
                remainingBudget: 0,
              )),
          bonusSummaryProvider.overrideWith((ref) async => const BonusSummary(
                isBonusMonth: false,
                bonusBalance: 0,
                bonusExpenseTotal: 0,
                bonusMonths: <int>[],
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

  testWidgets('home calendar shows labels, ranges, and matching colors', (WidgetTester tester) async {
    final now = DateTime.now();
    final schedule = _buildSchedule(now);
    await _pumpHomePage(tester, schedule);

    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));

    expect(find.text(l10n.homeDescription), findsNothing);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(find.text(l10n.bonusSummaryTitle), findsNothing);
    expect(find.text(l10n.bonusMonthInactive), findsNothing);

    final periodLabel = find.text(l10n.homePeriodLabel(1));
    expect(periodLabel, findsOneWidget);
    final periodText = tester.widget<Text>(periodLabel);
    expect(periodText.style?.color, equals(Colors.white));

    expect(find.text(l10n.homeIncomeLabel), findsOneWidget);
    expect(find.text(l10n.homeFixedSpecialLabel), findsOneWidget);
    expect(find.text(l10n.homeBudgetLabel), findsOneWidget);

    final prevStart = DateTime(now.year, now.month - 1, 1);
    final prevEnd = DateTime(now.year, now.month, 0);
    final currentStart = DateTime(now.year, now.month, 1);
    final currentEnd = DateTime(now.year, now.month + 1, 0);
    final incomeRange =
        '${l10n.formatShortDate(prevStart)}${l10n.rangeSeparator}${l10n.formatShortDate(prevEnd)}';
    final fixedRange =
        '${l10n.formatShortDate(currentStart)}${l10n.rangeSeparator}${l10n.formatShortDate(currentEnd)}';
    expect(find.text(incomeRange), findsOneWidget);
    expect(find.text(fixedRange), findsOneWidget);

    final expectedColor = buildAnnualScheduleColors(schedule.periods.length).first;
    final periodContainer = tester.widget<Container>(find.byKey(const Key('home-period-label')));
    final periodDecoration = periodContainer.decoration as BoxDecoration?;
    expect(periodDecoration?.color, expectedColor);
    final colorMatches = find.byWidgetPredicate((widget) {
      if (widget is Container) {
        final decoration = widget.decoration;
        return decoration is BoxDecoration && decoration.color == expectedColor;
      }
      return false;
    });
    expect(colorMatches, findsOneWidget);

    final todayCell = tester.widget<Container>(find.byKey(Key(_calendarKey(now))));
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
    expect(dayCells, findsNWidgets(35));

    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final currentWeekKey = Key(_calendarKey(weekStart));
    final nextWeekKey = Key(_calendarKey(weekStart.add(const Duration(days: 7))));
    final currentWeekTop = tester.getTopLeft(find.byKey(currentWeekKey)).dy;
    final nextWeekTop = tester.getTopLeft(find.byKey(nextWeekKey)).dy;
    expect(currentWeekTop, lessThan(nextWeekTop));
  });

  testWidgets('home calendar shows the current week and next 4 weeks', (WidgetTester tester) async {
    final now = DateTime.now();
    final schedule = _buildSchedule(now);
    await _pumpHomePage(tester, schedule);

    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final firstKey = Key(_calendarKey(weekStart));
    final lastKey = Key(_calendarKey(weekStart.add(const Duration(days: 34))));
    final beforeKey = Key(_calendarKey(weekStart.subtract(const Duration(days: 1))));
    final afterKey = Key(_calendarKey(weekStart.add(const Duration(days: 35))));

    expect(find.byKey(firstKey), findsOneWidget);
    expect(find.byKey(lastKey), findsOneWidget);
    expect(find.byKey(beforeKey), findsNothing);
    expect(find.byKey(afterKey), findsNothing);
  });
}

String _calendarKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return 'calendar-day-$y$m$d';
}
