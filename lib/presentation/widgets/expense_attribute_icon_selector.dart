import 'package:flutter/material.dart';
import 'package:kakeibo/domain/entities/transaction.dart';

class ExpenseAttributeIconSelector extends StatelessWidget {
  final ExpenseAttribute selected;
  final ValueChanged<ExpenseAttribute> onSelected;

  const ExpenseAttributeIconSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(labelText: '支出属性'),
      child: Wrap(
        spacing: 8,
        children: ExpenseAttribute.values.map((attr) {
          return ChoiceChip(
            label: Text(attr.label),
            avatar: Icon(_iconFor(attr), size: 18),
            selected: attr == selected,
            onSelected: (_) => onSelected(attr),
          );
        }).toList(),
      ),
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
