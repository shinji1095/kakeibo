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
    Widget buildAddIcon() {
      final scheme = Theme.of(context).colorScheme;
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          color: scheme.onPrimary,
        ),
      );
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        if (i == currentIndex) return;
        switch (i) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/list');
            break;
          case 2:
            context.go('/input');
            break;
          case 3:
            context.go('/breakdown');
            break;
          case 4:
            context.go('/trend');
            break;
        }
      },
      destinations: [
        const NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
        const NavigationDestination(icon: Icon(Icons.list), label: '一覧'),
        NavigationDestination(
          icon: buildAddIcon(),
          selectedIcon: buildAddIcon(),
          label: '入力',
        ),
        const NavigationDestination(icon: Icon(Icons.pie_chart), label: '内訳'),
        const NavigationDestination(icon: Icon(Icons.show_chart), label: '推移'),
      ],
    );
  }
}
