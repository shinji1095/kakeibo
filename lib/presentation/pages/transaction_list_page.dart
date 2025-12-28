import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/utils/category_icons.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_filter_chips.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  TransactionType? _filterType;

  void _shiftPeriod(int delta) {
    ref.read(periodOffsetProvider.notifier).state += delta;
  }

  String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  Future<void> _confirmDelete(KakeiboTransaction tx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この取引を削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('削除')),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(deleteTransactionProvider).call(tx.id!);
      ref.invalidate(transactionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('削除しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = ref.watch(periodRangeProvider);
    final listAsync = ref.watch(transactionsProvider);
    final expenseFilters = ref.watch(expenseAttributeFilterProvider);
    final effectiveExpenseFilters =
        expenseFilters.isEmpty ? ExpenseAttribute.values.toSet() : expenseFilters;
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryMap = <int, Category>{
      for (final c in categoriesAsync.value ?? <Category>[]) if (c.id != null) c.id!: c,
    };

    final endInclusive = range.end.subtract(const Duration(days: 1));

    return AppScaffold(
      title: '一覧',
      currentIndex: 1,
      body: Column(
        children: [
          _PeriodHeader(
            rangeLabel: '${_formatDate(range.start)} ～ ${_formatDate(endInclusive)}',
            onPrev: () => _shiftPeriod(-1),
            onNext: () => _shiftPeriod(1),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('すべて'),
                selected: _filterType == null,
                onSelected: (_) => setState(() => _filterType = null),
              ),
              ChoiceChip(
                label: const Text('支出'),
                selected: _filterType == TransactionType.expense,
                onSelected: (_) => setState(() => _filterType = TransactionType.expense),
              ),
              ChoiceChip(
                label: const Text('収入'),
                selected: _filterType == TransactionType.income,
                onSelected: (_) => setState(() => _filterType = TransactionType.income),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('支出属性'),
          const SizedBox(height: 4),
          const ExpenseAttributeFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: listAsync.when(
              data: (list) {
                final filtered = list.where((tx) {
                  if (_filterType != null && tx.type != _filterType) return false;
                  if (tx.type == TransactionType.expense) {
                    final attr = tx.expenseAttribute ?? kDefaultExpenseAttribute;
                    if (!effectiveExpenseFilters.contains(attr)) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('取引がありません'));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = filtered[index];
                    final cat = categoryMap[tx.categoryId];
                    final catLabel = cat?.name ?? 'カテゴリ${tx.categoryId}';
                    final catColor = cat != null ? Color(cat.color) : Theme.of(context).colorScheme.primary;
                    final iconColor = ThemeData.estimateBrightnessForColor(catColor) == Brightness.dark
                        ? Colors.white
                        : Colors.black;
                    final typeLabel = tx.type == TransactionType.expense ? '支出' : '収入';
                    final attrLabel = tx.type == TransactionType.expense
                        ? (tx.expenseAttribute ?? kDefaultExpenseAttribute).label
                        : null;
                    final memo = tx.memo.trim();
                    final subtitle = '${_formatDate(tx.date)}  $typeLabel / $catLabel'
                        '${attrLabel == null ? '' : ' / $attrLabel'}'
                        '${memo.isEmpty ? '' : ' / $memo'}';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: catColor,
                        child: Icon(
                          cat == null ? Icons.category : categoryIconFor(cat),
                          color: iconColor,
                        ),
                      ),
                      title: Text('${tx.amount.value} 円'),
                      subtitle: Text(subtitle),
                      onTap: () => context.push('/edit', extra: tx),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(tx),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodHeader extends StatelessWidget {
  final String rangeLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PeriodHeader({
    required this.rangeLabel,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
          Text(rangeLabel, style: Theme.of(context).textTheme.titleMedium),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}
