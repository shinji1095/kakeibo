import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/theme/app_theme.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/pages/breakdown_page.dart';
import 'package:kakeibo/presentation/pages/bonus_settings_page.dart';
import 'package:kakeibo/presentation/pages/category_manage_page.dart';
import 'package:kakeibo/presentation/pages/csv_export_page.dart';
import 'package:kakeibo/presentation/pages/home_page.dart';
import 'package:kakeibo/presentation/pages/input_page.dart';
import 'package:kakeibo/presentation/pages/reminder_manage_page.dart';
import 'package:kakeibo/presentation/pages/settings_page.dart';
import 'package:kakeibo/presentation/pages/trend_page.dart';
import 'package:kakeibo/presentation/pages/transaction_edit_page.dart';
import 'package:kakeibo/presentation/pages/transaction_list_page.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class KakeiboApp extends ConsumerWidget {
  const KakeiboApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final baseLight = AppTheme.themeFor(settings.colorTheme, Brightness.light);
    final baseDark = AppTheme.themeFor(settings.colorTheme, Brightness.dark);

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
    GoRoute(path: '/list', builder: (ctx, st) => const TransactionListPage(), name: 'list'),
    GoRoute(path: '/input', builder: (ctx, st) => const InputPage(), name: 'input'),
    GoRoute(path: '/breakdown', builder: (ctx, st) => const BreakdownPage(), name: 'breakdown'),
    GoRoute(path: '/trend', builder: (ctx, st) => const TrendPage(), name: 'trend'),
    GoRoute(path: '/settings', builder: (ctx, st) => const SettingsPage(), name: 'settings'),
    GoRoute(path: '/settings/csv', builder: (ctx, st) => const CsvExportPage(), name: 'csv_export'),
    GoRoute(path: '/settings/categories', builder: (ctx, st) => const CategoryManagePage(), name: 'category_manage'),
    GoRoute(path: '/settings/bonus', builder: (ctx, st) => const BonusSettingsPage(), name: 'bonus_settings'),
    GoRoute(path: '/settings/reminder', builder: (ctx, st) => const ReminderManagePage(), name: 'reminder_manage'),
    GoRoute(
      path: '/edit',
      name: 'edit',
      builder: (ctx, st) {
        final tx = st.extra as KakeiboTransaction;
        return TransactionEditPage(transaction: tx);
      },
    ),
  ],
);
