import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';
import 'package:kakeibo/presentation/utils/period_header_utils.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';
import 'package:kakeibo/presentation/widgets/expense_attribute_filter_chips.dart';
import 'package:kakeibo/presentation/widgets/period_header.dart';

class TrendPage extends ConsumerStatefulWidget {
  const TrendPage({super.key});

  @override
  ConsumerState<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends ConsumerState<TrendPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  ({double barWidth, double groupSpace}) _barLayoutForCount(int count) {
    if (count <= 3) {
      return (barWidth: 44, groupSpace: 24);
    }
    if (count <= 6) {
      return (barWidth: 32, groupSpace: 20);
    }
    if (count <= 9) {
      return (barWidth: 24, groupSpace: 16);
    }
    return (barWidth: 18, groupSpace: 14);
  }

  double _contentWidth(int count, double barWidth, double groupSpace) {
    if (count <= 0) return 0;
    if (count == 1) return barWidth;
    return barWidth * count + groupSpace * (count - 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(periodRangeProvider);
    final basis = ref.watch(rangeBasisProvider);
    final scheduleMap = ref.watch(annualSchedulesAroundNowProvider);
    final schedule = scheduleMap[range.start.year];
    final count = ref.watch(trendCountProvider);
    final metric = ref.watch(trendMetricProvider);
    final showAmounts = ref.watch(trendShowAmountsProvider);
    final totalsAsync = ref.watch(periodTotalsProvider);
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
      title: l10n.trendTitle,
      currentIndex: 4,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PeriodHeader(
            title: headerTitle,
            subtitle: headerSubtitle,
            onPrev: () => _shiftPeriod(-1),
            onNext: () => _shiftPeriod(1),
            onRangeTap: _showRangeBasisDialog,
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
              final labels = list
                  .map((item) => buildRangeLegendLabel(
                        l10n: l10n,
                        basis: basis,
                        rangeStart: item.start,
                        rangeEndExclusive: item.end,
                        schedule: scheduleMap[item.start.year],
                      ))
                  .toList();

              return Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 240,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final layout = _barLayoutForCount(list.length);
                            final contentWidth =
                                _contentWidth(list.length, layout.barWidth, layout.groupSpace);
                            final scrollEnabled =
                                contentWidth > constraints.maxWidth && list.length > 1;
                            final alignment = scrollEnabled
                                ? BarChartAlignment.start
                                : (list.length <= 1
                                    ? BarChartAlignment.center
                                    : BarChartAlignment.spaceBetween);
                            final barGroups = List.generate(list.length, (i) {
                              final value = values[i];
                              return BarChartGroupData(
                                x: i,
                                showingTooltipIndicators: showAmounts ? [0] : const [],
                                barRods: [
                                  BarChartRodData(
                                    toY: value.toDouble(),
                                    width: layout.barWidth,
                                    borderRadius: BorderRadius.circular(2),
                                    color: _colorFor(metric, value),
                                  ),
                                ],
                              );
                            });
                            return Scrollbar(
                              controller: _scrollController,
                              thumbVisibility: scrollEnabled,
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                physics: scrollEnabled
                                    ? const BouncingScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                                child: SizedBox(
                                  width: max(constraints.maxWidth, contentWidth),
                                  child: BarChart(
                                    BarChartData(
                                      alignment: alignment,
                                      groupsSpace: layout.groupSpace,
                                      minY: minY,
                                      maxY: maxY,
                                      barGroups: barGroups,
                                      gridData:
                                          FlGridData(show: true, horizontalInterval: interval),
                                      borderData: FlBorderData(show: false),
                                      titlesData: FlTitlesData(
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        leftTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false, reservedSize: 0),
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
                                        enabled: false,
                                        touchTooltipData: BarTouchTooltipData(
                                          tooltipPadding: EdgeInsets.zero,
                                          tooltipMargin: 6,
                                          getTooltipColor: (_) => Colors.transparent,
                                          fitInsideHorizontally: true,
                                          fitInsideVertically: true,
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            if (!showAmounts) return null;
                                            return BarTooltipItem(
                                              l10n.formatCurrency(rod.toY.toInt()),
                                              Theme.of(context).textTheme.labelSmall ??
                                                  const TextStyle(color: Colors.black),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.trendCountLabel(count),
                      style: Theme.of(context).textTheme.bodyMedium),
                  Slider(
                    value: count.toDouble(),
                    min: 3,
                    max: 12,
                    divisions: 9,
                    label: count.toString(),
                    onChanged: (v) =>
                        ref.read(trendCountProvider.notifier).state = v.round().clamp(3, 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.trendShowAmounts),
                      Switch.adaptive(
                        value: showAmounts,
                        onChanged: (value) =>
                            ref.read(trendShowAmountsProvider.notifier).state = value,
                      ),
                    ],
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
