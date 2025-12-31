import 'package:flutter/material.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.expenseAttribute,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ExpenseAttribute.values.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final attr = ExpenseAttribute.values[index];
          final isSelected = attr == selected;
          final theme = Theme.of(context);
          final borderColor = isSelected ? theme.colorScheme.primary : theme.dividerColor;
          final backgroundColor = isSelected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : theme.colorScheme.surface;
          final iconColor = isSelected ? theme.colorScheme.primary : theme.iconTheme.color;

          return Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelected(attr),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_iconFor(attr), size: 20, color: iconColor),
                    const SizedBox(height: 4),
                    Text(
                      l10n.expenseAttributeLabel(attr),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
