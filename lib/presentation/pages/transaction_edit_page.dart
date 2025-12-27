import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _type = widget.transaction.type;
    _date = widget.transaction.date;
    _categoryId = widget.transaction.categoryId;
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
    final amount = int.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('金額を入力してください')));
      }
      return;
    }
    if (_categoryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('カテゴリを選択してください')));
      }
      return;
    }

    final updated = widget.transaction.copyWith(
      date: _date,
      amount: Money(amount),
      memo: _memoCtrl.text,
      categoryId: _categoryId,
      type: _type,
    );

    await ref.read(updateTransactionProvider).call(updated);
    ref.invalidate(transactionsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新しました')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_type));

    return Scaffold(
      appBar: AppBar(title: const Text('取引の編集')),
      body: categoriesAsync.when(
        data: (categories) {
          _ensureCategorySelected(categories);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<TransactionType>(
                value: _type,
                decoration: const InputDecoration(labelText: '種別'),
                items: const [
                  DropdownMenuItem(value: TransactionType.expense, child: Text('支出')),
                  DropdownMenuItem(value: TransactionType.income, child: Text('収入')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _type = v;
                    _categoryId = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '金額（円）'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: _date,
                    locale: const Locale('ja', 'JP'),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: '日付'),
                  child: Text('${_date.year}年${_date.month}月${_date.day}日'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoCtrl,
                decoration: const InputDecoration(labelText: 'メモ'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _categoryId,
                items: categories
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
                decoration: const InputDecoration(labelText: 'カテゴリ'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('更新'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}