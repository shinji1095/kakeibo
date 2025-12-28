import 'package:flutter/material.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/utils/category_icons.dart';

class CategoryIconSelector extends StatelessWidget {
  final String label;
  final List<Category> categories;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  const CategoryIconSelector({
    super.key,
    required this.label,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectable = categories.where((c) => c.id != null).toList();
    if (selectable.isEmpty) {
      return const Text('カテゴリがありません');
    }

    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: selectable.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (context, index) {
          final category = selectable[index];
          final isSelected = category.id == selectedId;
          final theme = Theme.of(context);
          final borderColor = isSelected ? theme.colorScheme.primary : theme.dividerColor;
          final backgroundColor = isSelected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : theme.colorScheme.surface;
          final iconColor = Color(category.color);

          return Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelected(category.id!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(categoryIconFor(category), size: 20, color: iconColor),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
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
