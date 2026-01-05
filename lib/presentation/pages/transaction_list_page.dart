import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/utils/category_icons.dart';
import 'package:kakeibo/presentation/utils/period_header_utils.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_filter_chips.dart';
import 'package:kakeibo/presentation/widgets/period_header.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  Set<TransactionType> _filterTypes = {
    TransactionType.expense,
    TransactionType.income,
  };

  void _shiftPeriod(int delta) {
    ref.read(periodOffsetProvider.notifier).state += delta;
  }

  Future<void> _showRangeBasisDialog() async {
    final l10n = AppLocalizations.of(context);
    var selection = ref.read(rangeBasisProvider);
    final result = await showDialog<RangeBasis>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rangeBasisTitle),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<RangeBasis>(
                title: Text(l10n.rangeBasisPeriod),
                value: RangeBasis.period,
                groupValue: selection,
                onChanged: (value) => setState(() => selection = value ?? selection),
              ),
              RadioListTile<RangeBasis>(
                title: Text(l10n.rangeBasisMonth),
                value: RangeBasis.month,
                groupValue: selection,
                onChanged: (value) => setState(() => selection = value ?? selection),
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
            onPressed: () => Navigator.of(ctx).pop(selection),
            child: Text(l10n.dialogOk),
          ),
        ],
      ),
    );
    if (result != null) {
      ref.read(rangeBasisProvider.notifier).state = result;
    }
  }

  void _toggleType(TransactionType type) {
    setState(() {
      if (_filterTypes.length == 2) {
        _filterTypes = {type};
        return;
      }
      if (_filterTypes.contains(type)) {
        _filterTypes = {TransactionType.expense, TransactionType.income};
      } else {
        _filterTypes = {type};
      }
    });
  }

  Future<void> _confirmDelete(KakeiboTransaction tx) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.deleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteOk),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(deleteTransactionProvider).call(tx.id!);
      ref.invalidate(transactionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deletedMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(periodRangeProvider);
    final basis = ref.watch(rangeBasisProvider);
    final scheduleMap = ref.watch(annualSchedulesAroundNowProvider);
    final schedule = scheduleMap[range.start.year];
    final listAsync = ref.watch(transactionsProvider);
    final expenseFilters = ref.watch(expenseAttributeFilterProvider);
    final effectiveExpenseFilters =
        expenseFilters.isEmpty ? ExpenseAttribute.values.toSet() : expenseFilters;
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryMap = <int, Category>{
      for (final c in categoriesAsync.value ?? <Category>[]) if (c.id != null) c.id!: c,
    };
    final effectiveTypes = _filterTypes.isEmpty
        ? {TransactionType.expense, TransactionType.income}
        : _filterTypes;

    final endInclusive = range.end.subtract(const Duration(days: 1));
    final headerTitle = buildPeriodHeaderTitle(
      l10n: l10n,
      basis: basis,
      rangeStart: range.start,
      rangeEndExclusive: range.end,
      schedule: schedule,
    );
    final headerSubtitle = buildPeriodHeaderSubtitle(
      l10n: l10n,
      rangeStart: range.start,
      rangeEndInclusive: endInclusive,
    );

    return AppScaffold(
      title: l10n.listTitle,
      currentIndex: 1,
      body: Column(
        children: [
          PeriodHeader(
            title: headerTitle,
            subtitle: headerSubtitle,
            onPrev: () => _shiftPeriod(-1),
            onNext: () => _shiftPeriod(1),
            onRangeTap: _showRangeBasisDialog,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(l10n.filterExpense),
                selected: effectiveTypes.contains(TransactionType.expense),
                onSelected: (_) => _toggleType(TransactionType.expense),
              ),
              FilterChip(
                label: Text(l10n.filterIncome),
                selected: effectiveTypes.contains(TransactionType.income),
                onSelected: (_) => _toggleType(TransactionType.income),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.expenseAttribute),
          const SizedBox(height: 4),
          const ExpenseAttributeFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: listAsync.when(
              data: (list) {
                final filtered = list.where((tx) {
                  if (!effectiveTypes.contains(tx.type)) return false;
                  if (tx.type == TransactionType.expense) {
                    final attr = tx.expenseAttribute ?? kDefaultExpenseAttribute;
                    if (!effectiveExpenseFilters.contains(attr)) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noTransactions));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = filtered[index];
                    final cat = categoryMap[tx.categoryId];
                    final catLabel = cat?.name ?? l10n.categoryFallback(tx.categoryId);
                    final catColor = cat != null ? Color(cat.color) : Theme.of(context).colorScheme.primary;
                    final iconColor = ThemeData.estimateBrightnessForColor(catColor) == Brightness.dark
                        ? Colors.white
                        : Colors.black;
                    final typeLabel = tx.type == TransactionType.expense ? l10n.typeExpense : l10n.typeIncome;
                    final attrLabel = tx.type == TransactionType.expense
                        ? l10n.expenseAttributeLabel(tx.expenseAttribute ?? kDefaultExpenseAttribute)
                        : null;
                    final memo = tx.memo.trim();
                    final subtitle = '${l10n.formatDate(tx.date)}  $typeLabel / $catLabel'
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
                      title: Text(l10n.formatCurrency(tx.amount.value)),
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
              error: (e, st) => Center(child: Text(l10n.errorMessage(e))),
            ),
          ),
        ],
      ),
    );
  }
}
