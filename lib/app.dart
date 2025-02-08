import 'package:flutter/material.dart';
import 'package:kakeibo/presentation/pages/input/input_page.dart';
import 'package:kakeibo/presentation/pages/calendar/calendar_page.dart';
import 'package:kakeibo/presentation/pages/report/report_page.dart';
import 'package:kakeibo/presentation/pages/assets/assets_page.dart';
import 'package:kakeibo/core/thema/app_thema.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '35家計簿~フトコロ~', // アプリのタイトル
      debugShowCheckedModeBanner: false, // デバッグバナーを非表示
      theme: AppTheme.lightTheme, // ライトテーマを適用
      darkTheme: AppTheme.darkTheme, // ダークテーマを適用
      themeMode: ThemeMode.system, // システム設定に応じてテーマを切り替え
      initialRoute: '/', // アプリ起動時の初期画面
      routes: {
        '/': (context) => const InputPage(), // 初期画面：入力ページ
        '/calendar': (context) => const CalendarPage(), // カレンダーページ
        '/report': (context) => const ReportPage(), // レポートページ
        '/assets': (context) => const AssetsPage(), // 資産ページ
      },
    );
  }
}
