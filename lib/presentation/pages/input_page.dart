import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';

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
  int _categoryId = 1; // default seed cat id

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

  Future<void> _submit(TransactionType type) async {
    final amount = int.tryParse(_amountCtrl.text) ?? 0;
    if (amount == 0) return;
    final tx = KakeiboTransaction(
      date: _date,
      amount: Money(amount),
      memo: _memoCtrl.text,
      categoryId: _categoryId,
      type: type,
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
      currentIndex: 1,
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
          DropdownButtonFormField<int>(
            value: _categoryId,
            items: const [
              DropdownMenuItem(value: 1, child: Text('食費/給料など(デモ)')),
              DropdownMenuItem(value: 2, child: Text('交通/臨時収入(デモ)')),
              DropdownMenuItem(value: 3, child: Text('光熱費(デモ)')),
            ],
            onChanged: (v) => setState(() => _categoryId = v ?? 1),
            decoration: const InputDecoration(labelText: 'カテゴリ'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _submit(type),
              icon: const Icon(Icons.save),
              label: Text(type == TransactionType.expense ? '支出を保存' : '収入を保存'),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          const Text('今月の一覧', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const _MonthlyList(),
        ],
      ),
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
        if (list.isEmpty) return const Text('まだデータがありません');
        return Column(
          children: list
              .map(
                (tx) => ListTile(
              leading: Icon(tx.type == TransactionType.expense ? Icons.remove_circle : Icons.add_circle),
              title: Text('${tx.amount.value} 円'),
              subtitle: Text('${tx.date.year}/${tx.date.month}/${tx.date.day}  ${tx.memo}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await ref.read(deleteTransactionProvider).call(tx.id!);
                  ref.invalidate(transactionsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('削除しました')));
                  }
                },
              ),
            ),
          )
              .toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Text('Error: $e'),
    );
  }
}
