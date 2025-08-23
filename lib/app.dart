import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/theme/app_theme.dart';
import 'package:kakeibo/presentation/pages/input/input_page.dart';
import 'package:kakeibo/presentation/pages/calendar/calendar_page.dart';
import 'package:kakeibo/presentation/pages/report/report_page.dart';
import 'package:kakeibo/presentation/pages/assets/assets_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class KakeiboApp extends StatelessWidget {
  const KakeiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = _router;

    return ProviderScope(
      child: MaterialApp.router(
        title: '35家計簿 ~フトコロ~',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
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
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const InputPage(), name: 'input'),
    GoRoute(path: '/calendar', builder: (ctx, st) => const CalendarPage(), name: 'calendar'),
    GoRoute(path: '/report', builder: (ctx, st) => const ReportPage(), name: 'report'),
    GoRoute(path: '/assets', builder: (ctx, st) => const AssetsPage(), name: 'assets'),
  ],
);
