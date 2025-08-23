import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple placeholder: show sum of expenses/income will be implemented by joining DB in future.
    return Scaffold(
      appBar: AppBar(title: const Text('資産（デモ）')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              title: Text('現金残高 (デモ)'), 
              subtitle: Text('後で口座/財布を実装して正確に計算します'),
              trailing: Text('¥ 0'),
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text('負債 (デモ)'),
              trailing: Text('¥ 0'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 3),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/calendar');
            break;
          case 2:
            context.go('/report');
            break;
          case 3:
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.edit), label: '入力'),
        NavigationDestination(icon: Icon(Icons.calendar_month), label: 'カレンダー'),
        NavigationDestination(icon: Icon(Icons.pie_chart), label: 'レポート'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: '資産'),
      ],
    );
  }
}
