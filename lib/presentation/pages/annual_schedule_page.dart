import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/utils/annual_schedule_colors.dart';

class AnnualSchedulePage extends ConsumerStatefulWidget {
  const AnnualSchedulePage({super.key});

  @override
  ConsumerState<AnnualSchedulePage> createState() => _AnnualSchedulePageState();
}

class _AnnualSchedulePageState extends ConsumerState<AnnualSchedulePage> {
  int? _bonusPeriod1Index;
  int? _bonusPeriod2Index;
  int? _selectedBonusYear;
  bool _selectionDirty = false;

  void _shiftYear(int delta) {
    ref.read(annualSchedulePageYearProvider.notifier).state += delta;
  }

  bool get _canApply {
    if (_bonusPeriod1Index == null || _bonusPeriod2Index == null) return false;
    return _bonusPeriod1Index != _bonusPeriod2Index;
  }

  Future<void> _applyBonusPeriods() async {
    if (!_canApply) return;
    final usecase = ref.read(setAnnualScheduleBonusPeriodsProvider);
    await usecase(
      year: ref.read(annualSchedulePageYearProvider),
      bonusPeriodIndices: <int>[_bonusPeriod1Index!, _bonusPeriod2Index!],
    );
    if (!mounted) return;
    setState(() => _selectionDirty = false);
    final year = ref.read(annualSchedulePageYearProvider);
    ref.invalidate(annualScheduleForYearProvider(year));
  }

  void _syncBonusSelection(AnnualSchedule schedule, int year) {
    final bonusPeriods = [...schedule.bonusPeriods]..sort();
    final shouldSync = _selectedBonusYear != year || !_selectionDirty;
    if (!shouldSync) return;
    _bonusPeriod1Index = bonusPeriods.isNotEmpty ? bonusPeriods[0] : null;
    _bonusPeriod2Index = bonusPeriods.length > 1 ? bonusPeriods[1] : null;
    _selectedBonusYear = year;
    _selectionDirty = false;
  }

  void _setBonusPeriod1(int? index) {
    setState(() {
      _selectionDirty = true;
      _bonusPeriod1Index = index;
    });
  }

  void _setBonusPeriod2(int? index) {
    setState(() {
      _selectionDirty = true;
      _bonusPeriod2Index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final year = ref.watch(annualSchedulePageYearProvider);
    final scheduleAsync = ref.watch(annualScheduleForYearProvider(year));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.annualScheduleTitle)),
      body: scheduleAsync.when(
        data: (schedule) {
          if (schedule == null || schedule.periods.isEmpty) {
            return Center(child: Text(l10n.annualScheduleMissing));
          }
          _syncBonusSelection(schedule, year);
          final periodColors = buildAnnualScheduleColors(schedule.periods.length);
          final monthColors = buildAnnualScheduleColors(12);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(
                title: l10n.annualScheduleYear(year),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _shiftYear(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: () => _shiftYear(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: _AnnualScheduleChart(
                          schedule: schedule,
                          periodColors: periodColors,
                          monthColors: monthColors,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.bonusMonthSwapTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              key: const Key('bonus-period-1'),
                              value: _bonusPeriod1Index,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.bonusMonthPrimary,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: [
                                for (var i = 0; i < schedule.periods.length; i++)
                                  DropdownMenuItem<int>(
                                    value: i,
                                    key: ValueKey('bonus-period-1-$i'),
                                    child: Text(l10n.annualSchedulePeriodIndex(i + 1)),
                                  ),
                              ],
                              onChanged: _setBonusPeriod1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              key: const Key('bonus-period-2'),
                              value: _bonusPeriod2Index,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.bonusMonthSecondary,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: [
                                for (var i = 0; i < schedule.periods.length; i++)
                                  DropdownMenuItem<int>(
                                    value: i,
                                    key: ValueKey('bonus-period-2-$i'),
                                    child: Text(l10n.annualSchedulePeriodIndex(i + 1)),
                                  ),
                              ],
                              onChanged: _setBonusPeriod2,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _canApply ? _applyBonusPeriods : null,
                          child: Text(l10n.dialogApply),
                        ),
                      ),
                    ],
                  ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget trailing;

  const _SectionHeader({
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }
}

class _AnnualScheduleChart extends StatelessWidget {
  final AnnualSchedule schedule;
  final List<Color> periodColors;
  final List<Color> monthColors;

  const _AnnualScheduleChart({
    required this.schedule,
    required this.periodColors,
    required this.monthColors,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, 640.0);
        const outerInset = 60.0;
        final outerRadius = max(0.0, size / 2 - outerInset);
        final innerRadius = outerRadius * 0.82;
        final innerSectionRadius = max(0.0, innerRadius - 6);

        return Center(
          child: SizedBox(
            key: const Key('annual-schedule-chart'),
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: _buildPeriodSections(context, outerRadius),
                    centerSpaceRadius: innerRadius,
                    sectionsSpace: 1,
                    startDegreeOffset: -90,
                  ),
                ),
                IgnorePointer(
                  child: PieChart(
                    PieChartData(
                      sections: _buildMonthSections(context, innerSectionRadius),
                      centerSpaceRadius: 0,
                      sectionsSpace: 1,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPeriodSections(BuildContext context, double radius) {
    final l10n = AppLocalizations.of(context);
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < schedule.periods.length; i++) {
      final period = schedule.periods[i];
      final color = periodColors[i % periodColors.length];
      sections.add(PieChartSectionData(
        value: period.days.toDouble(),
        color: color,
        radius: radius,
        title: l10n.annualSchedulePeriodIndex(i + 1),
        titlePositionPercentageOffset: 0.86,
        titleStyle: TextStyle(
          color: _labelColor(color),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ));
    }
    return sections;
  }

  List<PieChartSectionData> _buildMonthSections(BuildContext context, double radius) {
    final l10n = AppLocalizations.of(context);
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < 12; i++) {
      final month = i + 1;
      final days = _daysInMonth(schedule.year, month);
      final color = monthColors[i % monthColors.length];
      sections.add(PieChartSectionData(
        value: days.toDouble(),
        color: color,
        radius: radius,
        title: l10n.formatMonth(month),
        titlePositionPercentageOffset: 0.62,
        titleStyle: TextStyle(
          color: _labelColor(color),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ));
    }
    return sections;
  }

  int _daysInMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return end.difference(start).inDays;
  }

  Color _labelColor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
