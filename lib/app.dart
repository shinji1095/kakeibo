import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/core/theme/app_theme.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/pages/breakdown_page.dart';
import 'package:kakeibo/presentation/pages/annual_schedule_page.dart';
import 'package:kakeibo/presentation/pages/budget_settings_page.dart';
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
    final ThemeData lightTheme = AppTheme.themeFor(settings.colorTheme, Brightness.light);

    return MaterialApp.router(
      title: AppLocalizations(settings.language.locale).appTitle,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
      locale: settings.language.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const HomePage(), name: 'home'),
    GoRoute(path: '/list', builder: (ctx, st) => const TransactionListPage(), name: 'list'),
    GoRoute(
      path: '/input',
      builder: (ctx, st) {
        final date = st.extra is DateTime ? st.extra as DateTime : null;
        return InputPage(initialDate: date);
      },
      name: 'input',
    ),
    GoRoute(path: '/breakdown', builder: (ctx, st) => const BreakdownPage(), name: 'breakdown'),
    GoRoute(path: '/trend', builder: (ctx, st) => const TrendPage(), name: 'trend'),
    GoRoute(path: '/settings', builder: (ctx, st) => const SettingsPage(), name: 'settings'),
    GoRoute(path: '/settings/csv', builder: (ctx, st) => const CsvExportPage(), name: 'csv_export'),
    GoRoute(path: '/settings/categories', builder: (ctx, st) => const CategoryManagePage(), name: 'category_manage'),
    GoRoute(path: '/settings/budget', builder: (ctx, st) => const BudgetSettingsPage(), name: 'budget_settings'),
    GoRoute(path: '/settings/annual', builder: (ctx, st) => const AnnualSchedulePage(), name: 'annual_schedule'),
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
