import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';

class ExpenseAttributeFilterChips extends ConsumerWidget {
  const ExpenseAttributeFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(expenseAttributeFilterProvider);
    final allAttributes = ExpenseAttribute.values;
    final allSelected = selected.length == allAttributes.length;

    void setAll() {
      ref.read(expenseAttributeFilterProvider.notifier).state = allAttributes.toSet();
    }

    void toggleAttribute(ExpenseAttribute attr, bool isSelected) {
      final next = {...selected};
      if (isSelected) {
        next.add(attr);
      } else {
        next.remove(attr);
        if (next.isEmpty) {
          next.addAll(allAttributes);
        }
      }
      ref.read(expenseAttributeFilterProvider.notifier).state = next;
    }

    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('すべて'),
          selected: allSelected,
          onSelected: (_) => setAll(),
        ),
        ...allAttributes.map(
          (attr) => FilterChip(
            label: Text(attr.label),
            avatar: Icon(_iconFor(attr), size: 18),
            selected: selected.contains(attr),
            onSelected: (value) => toggleAttribute(attr, value),
          ),
        ),
      ],
    );
  }
}

IconData _iconFor(ExpenseAttribute attr) {
  switch (attr) {
    case ExpenseAttribute.fixed:
      return Icons.lock;
    case ExpenseAttribute.variable:
      return Icons.account_balance_wallet;
    case ExpenseAttribute.bonus:
      return Icons.card_giftcard;
  }
}
