import 'package:flutter/material.dart';
import 'package:kakeibo/presentation/pages/input/input_page.dart';
import 'package:kakeibo/presentation/pages/calendar/calendar_page.dart';
import 'package:kakeibo/presentation/pages/report/report_page.dart';
import 'package:kakeibo/presentation/pages/assets/assets_page.dart';

class BasePage extends StatelessWidget {
  final Widget child; // 各ページの内容を受け取る
  final int currentIndex; // 現在の選択ページ

  const BasePage({Key? key, required this.child, required this.currentIndex})
      : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // 既に選択中なら何もしない

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const InputPage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const CalendarPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const ReportPage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const AssetsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // 各ページの内容をここに表示
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),

        // `app_theme.dart` で設定したテーマを適用
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '入力'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'レポート'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: '資産'),
        ],
      ),
    );
  }
}
