import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final int currentIndex;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: AppBottomNav(currentIndex: currentIndex),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        if (i == currentIndex) return;
        switch (i) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/input');
            break;
          case 2:
            context.go('/calendar');
            break;
          case 3:
            context.go('/report');
            break;
          case 4:
            context.go('/assets');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
        NavigationDestination(icon: Icon(Icons.edit), label: '入力'),
        NavigationDestination(icon: Icon(Icons.calendar_month), label: 'カレンダー'),
        NavigationDestination(icon: Icon(Icons.pie_chart), label: 'レポート'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: '資産'),
      ],
    );
  }
}
