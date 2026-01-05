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
  void _shiftYear(int delta) {
    ref.read(annualSchedulePageYearProvider.notifier).state += delta;
  }

  Future<void> _updatePeriod(AnnualSchedulePeriod period, int days) async {
    final usecase = ref.read(updateAnnualSchedulePeriodProvider);
    await usecase(
      year: ref.read(annualSchedulePageYearProvider),
      periodIndex: period.index,
      days: days,
    );
    final year = ref.read(annualSchedulePageYearProvider);
    ref.invalidate(annualScheduleForYearProvider(year));
  }

  Future<void> _toggleBonusMonth(int month, bool currentValue) async {
    final l10n = AppLocalizations.of(context);
    final selection = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.bonusMonthToggleTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.bonusMonthToggleOn),
              trailing: currentValue ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(true),
            ),
            ListTile(
              title: Text(l10n.bonusMonthToggleOff),
              trailing: !currentValue ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogCancel),
          ),
        ],
      ),
    );
    if (selection == null) return;

    final usecase = ref.read(setBonusMonthOverrideProvider);
    await usecase(
      year: ref.read(annualSchedulePageYearProvider),
      month: month,
      isBonus: selection,
    );
    final year = ref.read(annualSchedulePageYearProvider);
    ref.invalidate(annualScheduleForYearProvider(year));
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
          if (schedule == null) {
            return Center(child: Text(l10n.annualScheduleMissing));
          }
          final totalDays = schedule.periods.fold<int>(0, (sum, p) => sum + p.days);
          final bonusMonths = schedule.bonusMonths;
          final periodColors = buildAnnualScheduleColors(schedule.periods.length);
          final monthSegments = _buildMonthSegments(schedule.periods, periodColors);
          final countStatus = AnnualScheduleCountStatus.fromSchedule(schedule);

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
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.annualScheduleStartDate(l10n.formatLongDate(schedule.startDate))),
                      Text(l10n.annualSchedulePeriodCount(schedule.periods.length)),
                      Text(l10n.annualScheduleTotalDays(totalDays)),
                      const SizedBox(height: 8),
                      Text(l10n.annualSchedulePeriodSelectionCount(
                        35,
                        countStatus.count35,
                        countStatus.expected35,
                      )),
                      Text(l10n.annualSchedulePeriodSelectionCount(
                        42,
                        countStatus.count42,
                        countStatus.expected42,
                      )),
                      if (!countStatus.isValid) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.annualScheduleCountMismatchWarning,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.bonusMonthTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  const columns = 4;
                  const spacing = 12.0;
                  final baseWidth =
                      (constraints.maxWidth - spacing * (columns - 1)) / columns;
                  final normalizedBase = baseWidth > 0 ? baseWidth : constraints.maxWidth / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      for (var month = 1; month <= 12; month++)
                        _BonusMonthChip(
                          containerKey: Key('bonus-month-chip-$month'),
                          month: month,
                          baseWidth: normalizedBase,
                          label: l10n.formatMonth(month),
                          isBonus: bonusMonths.contains(month),
                          segments: monthSegments[month] ?? const <_MonthSegment>[],
                          onTap: () => _toggleBonusMonth(month, bonusMonths.contains(month)),
                        ),
                    ],
                  );
                },
              ),
              if (bonusMonths.isEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.noBonusMonths),
              ],
              const SizedBox(height: 16),
              Text(l10n.annualScheduleListTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schedule.periods.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final period = schedule.periods[index];
                    final label = '${l10n.formatDate(period.startDate)}'
                        '${l10n.rangeSeparator}${l10n.formatDate(period.endDate)}';
                    return ListTile(
                      leading: Container(
                        key: Key('annual-period-color-$index'),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: periodColors[index],
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(l10n.annualSchedulePeriodLabel(period.index + 1, label)),
                      subtitle: Text(l10n.annualSchedulePeriodDays(period.days)),
                      trailing: DropdownButton<int>(
                        value: period.days,
                        items: [
                          DropdownMenuItem(value: 35, child: Text(l10n.periodLength35)),
                          DropdownMenuItem(value: 42, child: Text(l10n.periodLength42)),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          _updatePeriod(period, value);
                        },
                      ),
                    );
                  },
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing,
      ],
    );
  }
}

class _BonusMonthChip extends StatelessWidget {
  final Key? containerKey;
  final int month;
  final double baseWidth;
  final String label;
  final bool isBonus;
  final List<_MonthSegment> segments;
  final VoidCallback onTap;

  const _BonusMonthChip({
    this.containerKey,
    required this.month,
    required this.baseWidth,
    required this.label,
    required this.isBonus,
    required this.segments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gradient = _buildSegmentGradient(segments);
    final background = segments.isNotEmpty ? segments.first.color : scheme.surfaceVariant;
    final textColor = scheme.onSurface;
    final borderColor = scheme.outlineVariant;
    const borderWidth = 1.0;
    final width = baseWidth;
    final starIcon = _buildStarIcon(textColor);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Container(
          key: containerKey,
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gradient == null ? background : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: starIcon == null
              ? Text(label, style: TextStyle(color: textColor))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    starIcon,
                    const SizedBox(width: 4),
                    Text(label, style: TextStyle(color: textColor)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget? _buildStarIcon(Color textColor) {
    if (isBonus) {
      return const Icon(Icons.star, size: 16, color: Colors.amber);
    }
    if (month == 1 || month == 2) {
      return Icon(Icons.star_border, size: 16, color: textColor);
    }
    return null;
  }
}

class _MonthSegment {
  final Color color;
  final double ratio;

  const _MonthSegment({
    required this.color,
    required this.ratio,
  });
}

Map<int, List<_MonthSegment>> _buildMonthSegments(
  List<AnnualSchedulePeriod> periods,
  List<Color> colors,
) {
  final daysByMonth = <int, Map<int, int>>{};

  for (final period in periods) {
    var cursor = period.startDate;
    while (!cursor.isAfter(period.endDate)) {
      final monthEnd = DateTime(cursor.year, cursor.month + 1, 0);
      final segmentEnd = period.endDate.isBefore(monthEnd) ? period.endDate : monthEnd;
      final days = segmentEnd.difference(cursor).inDays + 1;
      final month = cursor.month;
      final map = daysByMonth.putIfAbsent(month, () => <int, int>{});
      map[period.index] = (map[period.index] ?? 0) + days;
      cursor = segmentEnd.add(const Duration(days: 1));
    }
  }

  final result = <int, List<_MonthSegment>>{};
  for (final entry in daysByMonth.entries) {
    final total = entry.value.values.fold<int>(0, (sum, days) => sum + days);
    if (total <= 0) continue;
    final segments = entry.value.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    result[entry.key] = [
      for (final segment in segments)
        _MonthSegment(
          color: colors[segment.key % colors.length],
          ratio: segment.value / total,
        ),
    ];
  }
  return result;
}

LinearGradient? _buildSegmentGradient(List<_MonthSegment> segments) {
  if (segments.length <= 1) return null;

  final colors = <Color>[];
  final stops = <double>[];
  var cursor = 0.0;
  for (final segment in segments) {
    final ratio = segment.ratio;
    colors.add(segment.color);
    stops.add(cursor.clamp(0.0, 1.0));
    cursor = (cursor + ratio).clamp(0.0, 1.0);
    colors.add(segment.color);
    stops.add(cursor);
  }

  return LinearGradient(colors: colors, stops: stops);
}
