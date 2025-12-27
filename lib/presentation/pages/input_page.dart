import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/category_icon_selector.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_icon_selector.dart';

class InputPage extends ConsumerStatefulWidget {
  const InputPage({super.key});

  @override
  ConsumerState<InputPage> createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<InputPage> with SingleTickerProviderStateMixin {
  late TabController _tab;

  final _amountCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  int? _expenseCategoryId;
  int? _incomeCategoryId;
  ExpenseAttribute _expenseAttribute = kDefaultExpenseAttribute;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _amountCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  void _ensureCategorySelected(TransactionType type, List<Category> categories) {
    if (categories.isEmpty) return;
    final current = type == TransactionType.expense ? _expenseCategoryId : _incomeCategoryId;
    final exists = categories.any((c) => c.id == current);
    if (current == null || !exists) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          if (type == TransactionType.expense) {
            _expenseCategoryId = categories.first.id;
          } else {
            _incomeCategoryId = categories.first.id;
          }
        });
      });
    }
  }

  Future<void> _submit(TransactionType type) async {
    final amount = int.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('金額を入力してください')));
      }
      return;
    }

    final categoryId = type == TransactionType.expense ? _expenseCategoryId : _incomeCategoryId;
    if (categoryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('カテゴリを選択してください')));
      }
      return;
    }

    final tx = KakeiboTransaction(
      date: _date,
      amount: Money(amount),
      memo: _memoCtrl.text,
      categoryId: categoryId,
      type: type,
      expenseAttribute: type == TransactionType.expense ? _expenseAttribute : null,
    );
    await ref.read(addTransactionProvider).call(tx);
    _amountCtrl.clear();
    _memoCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(type == TransactionType.expense ? '支出を保存しました' : '収入を保存しました')),
      );
    }
    ref.invalidate(transactionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '入力',
      currentIndex: 2,
      body: Column(
        children: [
          TabBar(
            controller: _tab,
            tabs: const [Tab(text: '支出'), Tab(text: '収入')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildForm(TransactionType.expense),
                _buildForm(TransactionType.income),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(TransactionType type) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(type));

    return categoriesAsync.when(
      data: (categories) {
        final selectable = categories.where((c) => c.id != null).toList();
        _ensureCategorySelected(type, selectable);
        final selectedId = type == TransactionType.expense ? _expenseCategoryId : _incomeCategoryId;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '金額（円）'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
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
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoCtrl,
                decoration: const InputDecoration(labelText: 'メモ'),
              ),
              const SizedBox(height: 12),
              CategoryIconSelector(
                label: 'カテゴリ',
                categories: selectable,
                selectedId: selectedId,
                onSelected: (id) {
                  setState(() {
                    if (type == TransactionType.expense) {
                      _expenseCategoryId = id;
                    } else {
                      _incomeCategoryId = id;
                    }
                  });
                },
              ),
              if (type == TransactionType.expense) ...[
                const SizedBox(height: 12),
                ExpenseAttributeIconSelector(
                  selected: _expenseAttribute,
                  onSelected: (value) => setState(() => _expenseAttribute = value),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _submit(type),
                  icon: const Icon(Icons.save),
                  label: Text(type == TransactionType.expense ? '支出を保存' : '収入を保存'),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
