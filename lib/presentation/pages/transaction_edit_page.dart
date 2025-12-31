import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/widgets/category_icon_selector.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_icon_selector.dart';

class TransactionEditPage extends ConsumerStatefulWidget {
  final KakeiboTransaction transaction;

  const TransactionEditPage({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<TransactionEditPage> createState() => _TransactionEditPageState();
}

class _TransactionEditPageState extends ConsumerState<TransactionEditPage> {
  late TransactionType _type;
  late DateTime _date;
  late TextEditingController _amountCtrl;
  late TextEditingController _memoCtrl;
  int? _categoryId;
  ExpenseAttribute? _expenseAttribute;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction.type;
    _date = widget.transaction.date;
    _categoryId = widget.transaction.categoryId;
    _expenseAttribute = widget.transaction.type == TransactionType.expense
        ? (widget.transaction.expenseAttribute ?? kDefaultExpenseAttribute)
        : null;
    _amountCtrl = TextEditingController(text: widget.transaction.amount.value.toString());
    _memoCtrl = TextEditingController(text: widget.transaction.memo);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  void _ensureCategorySelected(List<Category> categories) {
    if (categories.isEmpty) return;
    final exists = categories.any((c) => c.id == _categoryId);
    if (_categoryId == null || !exists) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _categoryId = categories.first.id);
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final amount = int.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.validationEnterAmount)));
      }
      return;
    }
    if (_type == TransactionType.expense && _expenseAttribute == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.validationSelectExpenseAttribute)));
      }
      return;
    }
    if (_categoryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.validationSelectCategory)));
      }
      return;
    }

    final updated = widget.transaction.copyWith(
      date: _date,
      amount: Money(amount),
      memo: _memoCtrl.text,
      categoryId: _categoryId,
      type: _type,
      expenseAttribute: _type == TransactionType.expense ? _expenseAttribute : null,
    );

    await ref.read(updateTransactionProvider).call(updated);
    ref.invalidate(transactionsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.updatedMessage)));
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_type));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editTitle)),
      body: categoriesAsync.when(
        data: (categories) {
          final selectable = categories.where((c) => c.id != null).toList();
          _ensureCategorySelected(selectable);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<TransactionType>(
                value: _type,
                decoration: InputDecoration(labelText: l10n.typeLabel),
                items: [
                  DropdownMenuItem(value: TransactionType.expense, child: Text(l10n.expenseTab)),
                  DropdownMenuItem(value: TransactionType.income, child: Text(l10n.incomeTab)),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _type = v;
                    _categoryId = null;
                    _expenseAttribute = v == TransactionType.expense ? kDefaultExpenseAttribute : null;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.amountLabel),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: _date,
                    locale: l10n.locale,
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(labelText: l10n.dateLabel),
                  child: Text(l10n.formatLongDate(_date)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoCtrl,
                decoration: InputDecoration(labelText: l10n.memoLabel),
              ),
              const SizedBox(height: 12),
              CategoryIconSelector(
                label: l10n.categoryLabel,
                categories: selectable,
                selectedId: _categoryId,
                onSelected: (id) => setState(() => _categoryId = id),
              ),
              if (_type == TransactionType.expense) ...[
                const SizedBox(height: 12),
                ExpenseAttributeIconSelector(
                  selected: _expenseAttribute ?? kDefaultExpenseAttribute,
                  onSelected: (value) => setState(() => _expenseAttribute = value),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('transaction-edit-update'),
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.updateButton),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorMessage(e))),
      ),
    );
  }
}
