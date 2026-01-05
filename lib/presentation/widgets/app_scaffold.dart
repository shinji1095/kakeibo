import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';

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
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(Icons.account_balance_wallet_outlined),
        ),
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
    final l10n = AppLocalizations.of(context);

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
        NavigationDestination(icon: const Icon(Icons.home), label: l10n.navHome),
        NavigationDestination(icon: const Icon(Icons.list), label: l10n.navList),
        NavigationDestination(
          icon: buildAddIcon(),
          selectedIcon: buildAddIcon(),
          label: l10n.navInput,
        ),
        NavigationDestination(icon: const Icon(Icons.pie_chart), label: l10n.navBreakdown),
        NavigationDestination(icon: const Icon(Icons.show_chart), label: l10n.navTrend),
      ],
    );
  }
}
