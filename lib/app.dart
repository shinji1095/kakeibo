import 'package:flutter/material.dart';
import 'package:kakeibo/presentation/pages/input/input_page.dart';
import 'package:kakeibo/presentation/pages/calendar/calendar_page.dart';
import 'package:kakeibo/presentation/pages/report/report_page.dart';
import 'package:kakeibo/presentation/pages/assets/assets_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '家計簿アプリ', // アプリのタイトル
      debugShowCheckedModeBanner: false, // デバッグバナーを非表示
      theme: ThemeData(
        primarySwatch: Colors.orange, // アプリ全体のテーマカラー
        brightness: Brightness.dark, // ダークモード
      ),
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
