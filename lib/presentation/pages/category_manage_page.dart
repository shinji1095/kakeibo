import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';

class CategoryManagePage extends ConsumerStatefulWidget {
  const CategoryManagePage({super.key});

  @override
  ConsumerState<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends ConsumerState<CategoryManagePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  static const _palette = <Color>[
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF5C6BC0),
    Color(0xFF29B6F6),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFFFFCA28),
    Color(0xFFFFA726),
    Color(0xFF8D6E63),
    Color(0xFF78909C),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  bool _isProtectedName(String name) {
    return name == '未分類' || name == 'ボーナス支出';
  }

  Future<void> _showCategoryDialog({
    required TransactionType type,
    Category? category,
  }) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: category?.name ?? '');
    var selectedColor = category != null ? Color(category.color) : _palette.first;

    final result = await showDialog<_CategoryDialogResult>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(category == null ? l10n.categoryAddTitle : l10n.categoryEditTitle),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: l10n.categoryNameLabel),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.categoryColorLabel),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final color in _palette)
                        GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: CircleAvatar(
                            backgroundColor: color,
                            child: selectedColor == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.dialogCancel),
              ),
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.categoryNameRequired)),
                    );
                    return;
                  }
                  Navigator.of(ctx).pop(_CategoryDialogResult(name, selectedColor.value));
                },
                child: Text(l10n.dialogSave),
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    if (category == null) {
      await ref.read(addCategoryProvider).call(
            Category(
              name: result.name,
              color: result.color,
              type: type,
            ),
          );
    } else {
      await ref.read(updateCategoryProvider).call(
            category.copyWith(name: result.name, color: result.color),
          );
    }

    ref.invalidate(categoriesProvider);
  }

  Future<void> _confirmDelete(Category category) async {
    final l10n = AppLocalizations.of(context);
    if (_isProtectedName(category.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categoryDeleteProtected)),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.categoryDeleteTitle),
        content: Text(l10n.categoryDeleteBody(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteOk),
          ),
        ],
      ),
    );

    if (ok == true) {
      if (category.id == null) return;
      await ref.read(deleteCategoryProvider).call(category.id!);
      ref.invalidate(categoriesProvider);
      ref.invalidate(transactionsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoryManageTitle),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: l10n.categoryTabExpense),
            Tab(text: l10n.categoryTabIncome),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _CategoryList(type: TransactionType.expense, onEdit: _showCategoryDialog, onDelete: _confirmDelete),
          _CategoryList(type: TransactionType.income, onEdit: _showCategoryDialog, onDelete: _confirmDelete),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final type = _tab.index == 0 ? TransactionType.expense : TransactionType.income;
          _showCategoryDialog(type: type);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final TransactionType type;
  final Future<void> Function({required TransactionType type, Category? category}) onEdit;
  final Future<void> Function(Category category) onDelete;

  const _CategoryList({
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  bool _isProtectedName(String name) {
    return name == '未分類' || name == 'ボーナス支出';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoriesByTypeProvider(type));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(child: Text(l10n.noCategories));
        }
        return ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isProtected = _isProtectedName(category.name);
            return ListTile(
              leading: CircleAvatar(backgroundColor: Color(category.color)),
              title: Text(category.name),
              subtitle: isProtected ? Text(l10n.categoryProtectedLabel) : null,
              onTap: isProtected ? null : () => onEdit(type: type, category: category),
              trailing: isProtected
                  ? const Icon(Icons.lock)
                  : IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => onDelete(category),
                    ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(l10n.errorMessage(e))),
    );
  }
}

class _CategoryDialogResult {
  final String name;
  final int color;
  const _CategoryDialogResult(this.name, this.color);
}
