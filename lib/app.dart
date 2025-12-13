import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/theme/app_theme.dart';
import 'package:kakeibo/presentation/pages/assets_page.dart';
import 'package:kakeibo/presentation/pages/calendar_page.dart';
import 'package:kakeibo/presentation/pages/home_page.dart';
import 'package:kakeibo/presentation/pages/input_page.dart';
import 'package:kakeibo/presentation/pages/report_page.dart';
import 'package:kakeibo/presentation/pages/settings_page.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class KakeiboApp extends ConsumerWidget {
  const KakeiboApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final baseLight = AppTheme.lightTheme;
    final baseDark = AppTheme.darkTheme;

    final ThemeData lightTheme = baseLight.copyWith(
      textTheme: baseLight.textTheme.apply(fontSizeFactor: settings.fontScale),
    );

    final ThemeData darkTheme = baseDark.copyWith(
      textTheme: baseDark.textTheme.apply(fontSizeFactor: settings.fontScale),
    );

    return MaterialApp.router(
      title: '35家計簿 ~フトコロ~',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      routerConfig: _router,
      locale: const Locale('ja', 'JP'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
      ],
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const HomePage(), name: 'home'),
    GoRoute(path: '/input', builder: (ctx, st) => const InputPage(), name: 'input'),
    GoRoute(path: '/calendar', builder: (ctx, st) => const CalendarPage(), name: 'calendar'),
    GoRoute(path: '/report', builder: (ctx, st) => const ReportPage(), name: 'report'),
    GoRoute(path: '/assets', builder: (ctx, st) => const AssetsPage(), name: 'assets'),
    GoRoute(path: '/settings', builder: (ctx, st) => const SettingsPage(), name: 'settings'),
  ],
);
