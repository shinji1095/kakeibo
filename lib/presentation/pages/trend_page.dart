import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_filter_chips.dart';

class TrendPage extends ConsumerWidget {
  const TrendPage({super.key});

  int _valueFor(
    ({DateTime start, DateTime end, int income, int expense}) item,
    TrendMetric metric,
  ) {
    switch (metric) {
      case TrendMetric.income:
        return item.income;
      case TrendMetric.expense:
        return item.expense;
      case TrendMetric.balance:
        return item.income - item.expense;
    }
  }

  Color _colorFor(TrendMetric metric, int value) {
    switch (metric) {
      case TrendMetric.income:
        return Colors.blue;
      case TrendMetric.expense:
        return Colors.red;
      case TrendMetric.balance:
        return value >= 0 ? Colors.green : Colors.red;
    }
  }

  double _axisInterval(double minY, double maxY) {
    final range = (maxY - minY).abs();
    if (range == 0) return 1;
    return range / 4;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(periodRangeProvider);
    final endInclusive = range.end.subtract(const Duration(days: 1));
    final count = ref.watch(trendCountProvider);
    final rangeType = ref.watch(trendRangeTypeProvider);
    final metric = ref.watch(trendMetricProvider);
    final totalsAsync = rangeType == TrendRangeType.period
        ? ref.watch(periodTotalsProvider)
        : ref.watch(weeklyTotalsProvider);

    return AppScaffold(
      title: l10n.trendTitle,
      currentIndex: 4,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.trendTargetPeriod(
              l10n.formatDate(range.start),
              l10n.formatDate(endInclusive),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.rangeTypePeriod),
                selected: rangeType == TrendRangeType.period,
                onSelected: (_) {
                  ref.read(trendRangeTypeProvider.notifier).state = TrendRangeType.period;
                },
              ),
              ChoiceChip(
                label: Text(l10n.rangeTypeWeek),
                selected: rangeType == TrendRangeType.week,
                onSelected: (_) {
                  ref.read(trendRangeTypeProvider.notifier).state = TrendRangeType.week;
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.metricBalance),
                selected: metric == TrendMetric.balance,
                onSelected: (_) {
                  ref.read(trendMetricProvider.notifier).state = TrendMetric.balance;
                },
              ),
              ChoiceChip(
                label: Text(l10n.metricIncome),
                selected: metric == TrendMetric.income,
                onSelected: (_) {
                  ref.read(trendMetricProvider.notifier).state = TrendMetric.income;
                },
              ),
              ChoiceChip(
                label: Text(l10n.metricExpense),
                selected: metric == TrendMetric.expense,
                onSelected: (_) {
                  ref.read(trendMetricProvider.notifier).state = TrendMetric.expense;
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.trendCountLabel(count), style: Theme.of(context).textTheme.bodyMedium),
          Slider(
            value: count.toDouble(),
            min: 3,
            max: 12,
            divisions: 9,
            label: count.toString(),
            onChanged: (v) => ref.read(trendCountProvider.notifier).state = v.round().clamp(3, 12),
          ),
          const SizedBox(height: 8),
          Text(l10n.expenseAttribute),
          const SizedBox(height: 4),
          const ExpenseAttributeFilterChips(),
          const SizedBox(height: 12),
          totalsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return Center(child: Text(l10n.noData));
              }

              final values = list.map((item) => _valueFor(item, metric)).toList();
              final minValue = values.reduce(min);
              final maxValue = values.reduce(max);
              var minY = minValue.toDouble();
              var maxY = maxValue.toDouble();
              if (minY == maxY) {
                if (minY == 0) {
                  minY = -1;
                  maxY = 1;
                } else {
                  minY *= 0.9;
                  maxY *= 1.1;
                }
              } else {
                final padding = (maxY - minY) * 0.1;
                minY -= padding;
                maxY += padding;
              }
              if (metric != TrendMetric.balance) {
                minY = min(0, minY);
              }
              final interval = _axisInterval(minY, maxY);
              final labels = list.map((item) => l10n.formatShortDate(item.start)).toList();

              final barGroups = List.generate(list.length, (i) {
                final value = values[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: value.toDouble(),
                      width: 12,
                      borderRadius: BorderRadius.circular(2),
                      color: _colorFor(metric, value),
                    ),
                  ],
                );
              });

              return Column(
                children: [
                  SizedBox(
                    height: 240,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        minY: minY,
                        maxY: maxY,
                        barGroups: barGroups,
                        gridData: FlGridData(show: true, horizontalInterval: interval),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: interval,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    labels[index],
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                l10n.formatCurrency(rod.toY.toInt()),
                                Theme.of(context).textTheme.labelMedium ??
                                    const TextStyle(color: Colors.black),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(l10n.errorMessage(e))),
          ),
        ],
      ),
    );
  }
}
