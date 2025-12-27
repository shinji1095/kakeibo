import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_filter_chips.dart';

class TrendPage extends ConsumerWidget {
  const TrendPage({super.key});

  String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(periodRangeProvider);
    final endInclusive = range.end.subtract(const Duration(days: 1));
    final count = ref.watch(trendCountProvider);
    final totalsAsync = ref.watch(periodTotalsProvider);

    return AppScaffold(
      title: '推移',
      currentIndex: 4,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '基準期間: ${_formatDate(range.start)} 〜 ${_formatDate(endInclusive)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text('表示期間数: $count', style: Theme.of(context).textTheme.bodyMedium),
          Slider(
            value: count.toDouble(),
            min: 3,
            max: 12,
            divisions: 9,
            label: count.toString(),
            onChanged: (v) => ref.read(trendCountProvider.notifier).state = v.round().clamp(3, 12),
          ),
          const SizedBox(height: 8),
          const Text('支出属性'),
          const SizedBox(height: 4),
          const ExpenseAttributeFilterChips(),
          const SizedBox(height: 8),
          const Text('棒グラフは未実装です（プレースホルダー）'),
          const SizedBox(height: 12),
          totalsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const Center(child: Text('データがありません'));
              }

              return Column(
                children: list.map((item) {
                  final end = item.end.subtract(const Duration(days: 1));
                  final diff = item.income - item.expense;
                  return Card(
                    child: ListTile(
                      title: Text('${_formatDate(item.start)} 〜 ${_formatDate(end)}'),
                      subtitle: Text('収入 ${item.income}円 / 支出 ${item.expense}円'),
                      trailing: Text('差額 ${diff}円'),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}
