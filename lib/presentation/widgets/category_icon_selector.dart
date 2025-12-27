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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selectable.map((category) {
          final color = Color(category.color);
          final iconColor = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : Colors.black;

          return ChoiceChip(
            label: Text(category.name),
            avatar: CircleAvatar(
              backgroundColor: color,
              child: Icon(
                categoryIconFor(category),
                size: 16,
                color: iconColor,
              ),
            ),
            selected: category.id == selectedId,
            onSelected: (_) => onSelected(category.id!),
          );
        }).toList(),
      ),
    );
  }
}
