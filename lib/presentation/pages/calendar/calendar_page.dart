import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: month,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            locale: 'ja_JP',
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarFormat: CalendarFormat.month,
            onPageChanged: (d) => ref.read(monthProvider.notifier).state = DateTime(d.year, d.month),
          ),
          const Divider(),
          const Expanded(child: _MonthlyList()),
        ],
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 1),
    );
  }
}

class _MonthlyList extends ConsumerWidget {
  const _MonthlyList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(transactionsProvider);
    return listAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('今月の取引はありません'));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (c, i) {
            final tx = list[i];
            return ListTile(
              leading: Icon(tx.type == TransactionType.expense ? Icons.remove_circle : Icons.add_circle),
              title: Text('${tx.amount.value} 円'),
              subtitle: Text('${tx.date.year}/${tx.date.month}/${tx.date.day}  ${tx.memo}'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
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
            break;
          case 2:
            context.go('/report');
            break;
          case 3:
            context.go('/assets');
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
