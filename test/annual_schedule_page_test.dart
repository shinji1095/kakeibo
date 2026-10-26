import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/repositories/annual_schedule_repository.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';
import 'package:kakeibo/domain/usecases/save_annual_schedule.dart';
import 'package:kakeibo/presentation/pages/annual_schedule_page.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';

class _MemoryScheduleRepository implements AnnualScheduleRepository {
  AnnualScheduleConfig config;
  _MemoryScheduleRepository(this.config);
  @override
  Future<AnnualScheduleConfig?> getConfig(int year) async => config;
  @override
  Future<void> saveConfig(AnnualScheduleConfig config) async =>
      this.config = config;
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final generator = AnnualScheduleGenerator();
  late _MemoryScheduleRepository repo;

  setUp(() {
    binding.window.physicalSizeTestValue = const Size(1200, 2000);
    binding.window.devicePixelRatioTestValue = 1;
    repo = _MemoryScheduleRepository(generator.generate(
        year: 2026, startDate: DateTime(2026, 1, 1), weekStart: 0));
  });
  tearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    final router = GoRouter(initialLocation: '/annual', routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) =>
            const Scaffold(key: Key('test-home'), body: Text('Home')),
      ),
      GoRoute(
        path: '/annual',
        builder: (context, state) => const AnnualSchedulePage(),
      ),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        annualSchedulePageYearProvider.overrideWith((ref) => 2026),
        annualScheduleForYearProvider.overrideWith(
            (ref, year) async => generator.buildSchedule(repo.config)),
        annualScheduleGeneratorProvider.overrideWith((ref) => generator),
        saveAnnualScheduleProvider
            .overrideWith((ref) => SaveAnnualSchedule(repo, generator)),
      ],
      child: MaterialApp.router(
        locale: const Locale('ja', 'JP'),
        routerConfig: router,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows editable settings and a preview', (tester) async {
    binding.window.physicalSizeTestValue = const Size(320, 640);
    await pumpPage(tester);
    expect(find.byKey(const Key('annual-budget')), findsOneWidget);
    expect(find.byKey(const Key('annual-start-date')), findsNothing);
    await tester.tap(find.text('詳細設定'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('annual-start-date')), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('bonus-month-0-8')), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('bonus-month-0-8')), findsOneWidget);
    expect(find.byKey(const Key('bonus-weeks-2026-0')), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('annual-timeline')), 300,
        scrollable: find.byType(Scrollable).first);
    final rect = tester.getRect(find.byKey(const Key('annual-timeline')));
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(320));
  });

  testWidgets('basic settings save two zero-week months and ten periods',
      (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('annual-budget')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('annual-budget-input')), '65000');
    await tester.tap(find.text('設定').last);
    await tester.pumpAndSettle();
    final save = find.byKey(const Key('annual-save'));
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repo.config.periodBudget, 65000);
    expect(repo.config.bonusMonths.map((bonus) => bonus.month), [8, 12]);
    expect(repo.config.bonusMonths.every((bonus) => bonus.weeks == 0), isTrue);
    expect(repo.config.periodDays, hasLength(10));
    expect(repo.config.periodDays, isNot(contains(0)));
    expect(repo.config.sixWeekPeriods, [7, 8, 9]);
    expect(repo.config.periodDays[6], 35);
    expect(repo.config.periodDays[9], 36);
    expect(find.byKey(const Key('test-home')), findsOneWidget);
  });

  testWidgets('one-week bonus is selected by period number', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('詳細設定'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(const Key('bonus-weeks-2026-0')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('1週').first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(const Key('bonus-period-select-0')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('bonus-period-select-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bonus-period-option-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annual-save')));
    await tester.pumpAndSettle();
    expect(repo.config.bonusMonths.first.periodIndex, 1);
    expect(repo.config.periodDays[1], 7);
    expect(repo.config.periodDays, hasLength(11));
    expect(find.byKey(const Key('test-home')), findsOneWidget);
  });
}
