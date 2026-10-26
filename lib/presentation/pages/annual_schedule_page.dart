import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';
import 'package:kakeibo/presentation/utils/annual_schedule_colors.dart';
import 'package:kakeibo/presentation/widgets/adaptive_page_title.dart';

enum _YearChange { discard, save }

class AnnualSchedulePage extends ConsumerStatefulWidget {
  const AnnualSchedulePage({super.key});

  @override
  ConsumerState<AnnualSchedulePage> createState() => _AnnualSchedulePageState();
}

class _AnnualSchedulePageState extends ConsumerState<AnnualSchedulePage> {
  final _budgetController = TextEditingController();
  DateTime? _startDate;
  int? _loadedYear;
  int _budget = 50000;
  int _startWeekday = DateTime.thursday;
  int _firstMonth = 9;
  int _secondMonth = 12;
  int _firstPeriodIndex = 7;
  int _secondPeriodIndex = 11;
  int _firstWeeks = 1;
  int _secondWeeks = 1;
  Set<int> _sixWeekPeriods = {};
  bool _advancedExpanded = false;
  bool _dirty = false;
  bool _saving = false;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _sync(AnnualSchedule schedule) {
    if (_loadedYear == schedule.year) return;
    _loadedYear = schedule.year;
    _advancedExpanded = false;
    _startDate = schedule.startDate;
    _startWeekday = schedule.startDate.weekday;
    _budget = schedule.periodBudget;
    _firstMonth = schedule.bonusMonths.first.month;
    _secondMonth = schedule.bonusMonths.last.month;
    _firstWeeks = schedule.bonusMonths.first.weeks;
    _secondWeeks = schedule.bonusMonths.last.weeks;
    _firstPeriodIndex = schedule.bonusMonths.first.weeks == 0
        ? 0
        : schedule.bonusMonths.first.periodIndex ??
            _indexForBonus(schedule, schedule.bonusMonths.first, {});
    _secondPeriodIndex = schedule.bonusMonths.last.weeks == 0
        ? 1
        : schedule.bonusMonths.last.periodIndex ??
            _indexForBonus(
                schedule, schedule.bonusMonths.last, {_firstPeriodIndex});
    _sixWeekPeriods = schedule.sixWeekPeriods.toSet();
    _dirty = false;
  }

  int _indexForBonus(
      AnnualSchedule schedule, BonusMonthSetting setting, Set<int> used) {
    final candidates = [
      for (final period in schedule.periods)
        if (period.days == setting.weeks * 7 && !used.contains(period.index))
          period,
    ];
    if (candidates.isEmpty) return 0;
    final target = DateTime(schedule.year, setting.month, 1);
    candidates.sort((a, b) => a.startDate
        .difference(target)
        .inDays
        .abs()
        .compareTo(b.startDate.difference(target).inDays.abs()));
    return candidates.first.index;
  }

  void _change(AnnualSchedule saved, void Function() change) {
    setState(() {
      change();
      _dirty = true;
      final count = AnnualScheduleGenerator.periodCount -
          ((1 - _firstWeeks) + (1 - _secondWeeks));
      if (_firstWeeks == 1 && _firstPeriodIndex >= count) {
        _firstPeriodIndex = count - 1;
      }
      if (_secondWeeks == 1 && _secondPeriodIndex >= count) {
        _secondPeriodIndex = count - 1;
      }
      if (_firstWeeks == 1 &&
          _secondWeeks == 1 &&
          _firstPeriodIndex == _secondPeriodIndex) {
        _secondPeriodIndex =
            (_secondPeriodIndex + 1) % AnnualScheduleGenerator.periodCount;
      }
      _reconcileSixWeekPeriods(saved);
      try {
        final configured = _configure(saved, _sixWeekPeriods, budget: 1);
        if (_firstWeeks == 1) {
          _firstMonth = configured.bonusMonths.first.month;
        }
        if (_secondWeeks == 1) {
          _secondMonth = configured.bonusMonths.last.month;
        }
      } on ScheduleConfigurationException {
        // Keep the draft selection until the user makes it valid.
      }
    });
  }

  AnnualScheduleConfig _configure(
    AnnualSchedule saved,
    Set<int> six, {
    int? budget,
    int? firstPeriodIndex,
    int? secondPeriodIndex,
  }) =>
      ref.read(annualScheduleGeneratorProvider).configure(
            year: saved.year,
            startDate: _startDate ?? saved.startDate,
            weekStart: saved.weekStart,
            bonusMonths: [
              BonusMonthSetting(
                month: _firstMonth,
                weeks: _firstWeeks,
                periodIndex: _firstWeeks == 1
                    ? firstPeriodIndex ?? _firstPeriodIndex
                    : null,
              ),
              BonusMonthSetting(
                month: _secondMonth,
                weeks: _secondWeeks,
                periodIndex: _secondWeeks == 1
                    ? secondPeriodIndex ?? _secondPeriodIndex
                    : null,
              ),
            ],
            sixWeekPeriods: six.toList(),
            periodBudget: budget ?? _budget,
          );

  ({Set<int> indices, AnnualSchedule schedule})? _validSixWeeks(
      AnnualSchedule saved,
      {int? requiredIndex,
      int? firstPeriodIndex,
      int? secondPeriodIndex}) {
    final options = _allValidSixWeeks(saved,
        requiredIndex: requiredIndex,
        firstPeriodIndex: firstPeriodIndex,
        secondPeriodIndex: secondPeriodIndex,
        firstOnly: true);
    return options.isEmpty ? null : options.first;
  }

  List<({Set<int> indices, AnnualSchedule schedule})> _allValidSixWeeks(
      AnnualSchedule saved,
      {int? requiredIndex,
      int? firstPeriodIndex,
      int? secondPeriodIndex,
      bool firstOnly = false}) {
    final zeroCount = (1 - _firstWeeks) + (1 - _secondWeeks);
    final periodCount = AnnualScheduleGenerator.periodCount - zeroCount;
    final sixCount = zeroCount == 2 ? 3 : zeroCount;
    if (zeroCount == 0 && requiredIndex != null) return [];
    final options = <Set<int>>[];
    if (sixCount == 0) {
      options.add({});
    } else if (sixCount == 1) {
      for (var i = 0; i < periodCount; i++) {
        if (requiredIndex == null || requiredIndex == i) options.add({i});
      }
    } else if (sixCount == 2) {
      for (var i = 0; i < periodCount - 1; i++) {
        for (var j = i + 1; j < periodCount; j++) {
          if (requiredIndex == null ||
              requiredIndex == i ||
              requiredIndex == j) {
            options.add({i, j});
          }
        }
      }
    } else {
      for (var i = 0; i < periodCount - 2; i++) {
        for (var j = i + 1; j < periodCount - 1; j++) {
          for (var k = j + 1; k < periodCount; k++) {
            if (requiredIndex == null ||
                requiredIndex == i ||
                requiredIndex == j ||
                requiredIndex == k) {
              options.add({i, j, k});
            }
          }
        }
      }
    }
    options.sort((a, b) => b
        .intersection(_sixWeekPeriods)
        .length
        .compareTo(a.intersection(_sixWeekPeriods).length));
    final valid = <({Set<int> indices, AnnualSchedule schedule})>[];
    for (final indices in options) {
      try {
        final config = _configure(
          saved,
          indices,
          budget: 1,
          firstPeriodIndex: firstPeriodIndex,
          secondPeriodIndex: secondPeriodIndex,
        );
        valid.add((
          indices: indices,
          schedule:
              ref.read(annualScheduleGeneratorProvider).buildSchedule(config)
        ));
        if (firstOnly) break;
      } on ScheduleConfigurationException {
        // A different period may place both bonus boundaries correctly.
      }
    }
    return valid;
  }

  void _reconcileSixWeekPeriods(AnnualSchedule saved) {
    final zeroCount = (1 - _firstWeeks) + (1 - _secondWeeks);
    final count = zeroCount == 2 ? 3 : zeroCount;
    if (count == 0) {
      _sixWeekPeriods = {};
      return;
    }
    if (_sixWeekPeriods.length == count) {
      try {
        _configure(saved, _sixWeekPeriods, budget: 1);
        return;
      } on ScheduleConfigurationException {
        // The changed month or date needs a different six-week period.
      }
    }
    _sixWeekPeriods = _validSixWeeks(saved)?.indices ?? {};
  }

  Future<void> _pickStartDate(AnnualSchedule saved) async {
    final firstDate = DateTime(saved.year, 1, 1);
    final lastDate = DateTime(saved.year, 12, 31);
    final current = _startDate ?? saved.startDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(firstDate) || current.isAfter(lastDate)
          ? firstDate
          : current,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null && mounted) {
      _change(saved, () {
        _startDate = picked;
        _startWeekday = picked.weekday;
      });
    }
  }

  void _chooseStartWeekday(AnnualSchedule saved, int weekday) {
    _applyBasicPreset(saved, weekday: weekday);
  }

  void _applyBasicPreset(AnnualSchedule saved, {int? weekday, int? budget}) {
    final config = ref.read(annualScheduleGeneratorProvider).configureBasic(
          year: saved.year,
          weekday: weekday ?? _startWeekday,
          weekStart: saved.weekStart,
          periodBudget: budget ?? _budget,
        );
    setState(() {
      _startDate = config.startDate;
      _startWeekday = config.startDate.weekday;
      _budget = config.periodBudget;
      _firstMonth = 8;
      _secondMonth = 12;
      _firstWeeks = 0;
      _secondWeeks = 0;
      _firstPeriodIndex = 0;
      _secondPeriodIndex = 1;
      _sixWeekPeriods = config.sixWeekPeriods.toSet();
      _dirty = true;
    });
  }

  bool _isBasicPreset(AnnualSchedule? schedule) {
    if (schedule == null ||
        _startDate !=
            AnnualScheduleGenerator.startDateForWeekday(
                schedule.year, _startWeekday) ||
        _firstWeeks != 0 ||
        _secondWeeks != 0 ||
        _firstMonth != 8 ||
        _secondMonth != 12 ||
        _sixWeekPeriods.length != 3) {
      return false;
    }
    final labels =
        AnnualScheduleGenerator.periodMonthLabels(schedule.bonusMonths);
    return _sixWeekPeriods
            .map((index) => labels[index])
            .toSet()
            .containsAll({9, 10, 11}) &&
        schedule.periods[6].days == 35 &&
        schedule.periods[9].days ==
            35 + AnnualScheduleGenerator.daysInYear(schedule.year) - 364;
  }

  Future<void> _editBudget(AnnualSchedule saved) async {
    final l10n = AppLocalizations.of(context);
    _budgetController.text = _budget.toString();
    var invalid = false;
    final amount = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.viewInsetsOf(sheetContext).bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.bonusBudgetLabel,
                style: Theme.of(sheetContext).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              key: const Key('annual-budget-input'),
              controller: _budgetController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.bonusBudgetLabel,
                suffixText: l10n.annualBudgetUnit,
                helperText: invalid ? null : l10n.annualBudgetHelp,
                errorText: invalid ? l10n.annualBudgetError : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (invalid) setSheetState(() => invalid = false);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final value = int.tryParse(_budgetController.text);
                  if (value == null || value <= 0) {
                    setSheetState(() => invalid = true);
                    return;
                  }
                  Navigator.pop(sheetContext, value);
                },
                child: Text(l10n.dialogApply),
              ),
            ),
          ]),
        ),
      ),
    );
    if (amount != null && amount != _budget && mounted) {
      _applyBasicPreset(saved, budget: amount);
    }
  }

  void _selectMonth(AnnualSchedule saved, int entry, int month) {
    if ((entry == 0 && month == _firstMonth) ||
        (entry == 1 && month == _secondMonth)) {
      return;
    }
    _change(saved, () {
      if (entry == 0) {
        _firstMonth = month;
      } else {
        _secondMonth = month;
      }
    });
  }

  Future<void> _selectPeriod(AnnualSchedule saved, int entry) async {
    final l10n = AppLocalizations.of(context);
    final selected = entry == 0 ? _firstPeriodIndex : _secondPeriodIndex;
    final periodCount = AnnualScheduleGenerator.periodCount -
        ((1 - _firstWeeks) + (1 - _secondWeeks));
    final options = [
      for (var i = 0; i < periodCount; i++)
        _validSixWeeks(
          saved,
          firstPeriodIndex: entry == 0 ? i : null,
          secondPeriodIndex: entry == 1 ? i : null,
        ),
    ];
    final chosen = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.75,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l10n.annualChoosePeriod,
                  style: Theme.of(sheetContext).textTheme.titleLarge),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final period = options[index]?.schedule.periods[index];
                  return ListTile(
                    key: Key('bonus-period-option-$index'),
                    enabled: period != null,
                    selected: index == selected,
                    title: Text(l10n.annualSchedulePeriodIndex(index + 1)),
                    subtitle: Text(period == null
                        ? l10n.annualPeriodUnavailable
                        : '${l10n.formatShortDate(period.startDate)}${l10n.rangeSeparator}${l10n.formatShortDate(period.endDate)}'),
                    trailing:
                        index == selected ? const Icon(Icons.check) : null,
                    onTap: period == null
                        ? null
                        : () => Navigator.pop(sheetContext, index),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    final option = options[chosen]!;
    _change(saved, () {
      _sixWeekPeriods = option.indices.toSet();
      if (entry == 0) {
        _firstPeriodIndex = chosen;
        _firstMonth = option.schedule.periods[chosen].startDate.month;
      } else {
        _secondPeriodIndex = chosen;
        _secondMonth = option.schedule.periods[chosen].startDate.month;
      }
    });
  }

  Future<bool> _save(AnnualScheduleConfig draft) async {
    setState(() => _saving = true);
    try {
      await ref.read(saveAnnualScheduleProvider)(draft);
      if (!mounted) return false;
      setState(() => _dirty = false);
      ref.invalidate(annualScheduleForYearProvider(draft.year));
      ref.invalidate(currentAnnualScheduleProvider);
      ref.read(settingsProvider.notifier).setPeriodBudget(draft.periodBudget);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).annualScheduleSaved)),
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeYear(int target, AnnualScheduleConfig? draft) async {
    if (!_dirty) {
      ref.read(annualSchedulePageYearProvider.notifier).state = target;
      return;
    }
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<_YearChange>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.annualUnsavedTitle),
        content: Text(l10n.annualUnsavedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, _YearChange.discard),
            child: Text(l10n.annualDiscard),
          ),
          FilledButton(
            onPressed: draft == null
                ? null
                : () => Navigator.pop(dialogContext, _YearChange.save),
            child: Text(l10n.annualSaveAndContinue),
          ),
        ],
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == _YearChange.save && (draft == null || !await _save(draft))) {
      return;
    }
    setState(() {
      _dirty = false;
      _loadedYear = null;
    });
    ref.read(annualSchedulePageYearProvider.notifier).state = target;
  }

  Future<void> _pickYear(int year, AnnualScheduleConfig? draft) async {
    final l10n = AppLocalizations.of(context);
    final currentYear = DateTime.now().year;
    final firstYear = (year < currentYear ? year : currentYear) - 100;
    final lastYear = (year > currentYear ? year : currentYear) + 100;
    const rowHeight = 56.0;
    final scrollController = ScrollController(
      initialScrollOffset: (currentYear - firstYear) * rowHeight,
    );
    try {
      final selected = await showDialog<int>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.annualSelectYear),
          content: SizedBox(
            width: 280,
            height: 320,
            child: ListView.builder(
              controller: scrollController,
              itemExtent: rowHeight,
              itemCount: lastYear - firstYear + 1,
              itemBuilder: (context, index) {
                final option = firstYear + index;
                return ListTile(
                  key: Key('annual-year-option-$option'),
                  title: Text(l10n.locale.languageCode == 'ja'
                      ? '$option年'
                      : '$option'),
                  selected: option == year,
                  trailing: option == year ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(dialogContext, option),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.dialogCancel),
            ),
          ],
        ),
      );
      if (mounted && selected != null && selected != year) {
        await _changeYear(selected, draft);
      }
    } finally {
      scrollController.dispose();
    }
  }

  double get _sectionSpacing =>
      (MediaQuery.sizeOf(context).width * 0.035).clamp(10.0, 18.0).toDouble();

  double get _settingsSpacing =>
      (MediaQuery.sizeOf(context).height * 0.025).clamp(16.0, 28.0).toDouble();

  Future<void> _showAdvancedHelp() => showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final l10n = AppLocalizations.of(dialogContext);
          return AlertDialog(
            title: Text(l10n.annualAdvancedTitle),
            content: Text(l10n.annualAdvancedHelp),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.annualClose),
              ),
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final year = ref.watch(annualSchedulePageYearProvider);
    final scheduleAsync = ref.watch(annualScheduleForYearProvider(year));
    final saved = scheduleAsync.valueOrNull;
    if (saved != null) _sync(saved);

    AnnualScheduleConfig? draft;
    AnnualSchedule? preview;
    if (saved != null) {
      try {
        draft = _configure(saved, _sixWeekPeriods);
        preview =
            ref.read(annualScheduleGeneratorProvider).buildSchedule(draft);
      } on ScheduleConfigurationException {
        // The relevant editor displays the validation message.
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              fit: FlexFit.loose,
              child: AdaptivePageTitle(
                l10n.annualScheduleYear(year),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              key: const Key('annual-year-edit'),
              tooltip: l10n.annualSelectYear,
              onPressed: () => _pickYear(year, draft),
              icon: const Icon(Icons.edit_outlined),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: saved == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('annual-save'),
                  onPressed: draft == null || !_dirty || _saving
                      ? null
                      : () async {
                          if (await _save(draft!) && context.mounted) {
                            context.goNamed('home');
                          }
                        },
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: Text(l10n.annualSaveThis),
                ),
              ),
            ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (loadError, _) =>
            Center(child: Text(l10n.errorMessage(loadError))),
        data: (schedule) {
          if (schedule == null) {
            return Center(child: Text(l10n.annualScheduleMissing));
          }
          final shown = preview ?? schedule;
          final zeroCount = (1 - _firstWeeks) + (1 - _secondWeeks);
          final sixCount = zeroCount == 2 ? 3 : zeroCount;
          final previous =
              ref.watch(annualScheduleForYearProvider(year - 1)).valueOrNull;
          final next =
              ref.watch(annualScheduleForYearProvider(year + 1)).valueOrNull;
          final hasNeighborGap = (previous != null &&
                  previous.periods.last.endDate.add(const Duration(days: 1)) !=
                      shown.startDate) ||
              (next != null &&
                  shown.periods.last.endDate.add(const Duration(days: 1)) !=
                      next.startDate);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (_dirty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(l10n.annualUnsavedBadge,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ),
                SizedBox(height: _sectionSpacing),
              ],
              Card(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(16, 16, 16, _sectionSpacing),
                        child: Text(l10n.annualScheduleBasics,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                        child: DropdownButtonFormField<int>(
                          key: ValueKey('annual-weekday-$year-$_startWeekday'),
                          initialValue: _startWeekday,
                          decoration: InputDecoration(
                            labelText: l10n.annualStartWeekday,
                            helperText: l10n.annualBasicStartHelp(
                                l10n.formatLongDate(
                                    AnnualScheduleGenerator.startDateForWeekday(
                                        year, _startWeekday))),
                          ),
                          items: [
                            for (var weekday = DateTime.monday;
                                weekday <= DateTime.sunday;
                                weekday++)
                              DropdownMenuItem(
                                value: weekday,
                                child: Text(l10n.formatWeekday(weekday)),
                              ),
                          ],
                          onChanged: (weekday) {
                            if (weekday != null) {
                              _chooseStartWeekday(schedule, weekday);
                            }
                          },
                        ),
                      ),
                      ListTile(
                        key: const Key('annual-budget'),
                        leading: const Icon(Icons.payments_outlined),
                        title: Text(l10n.bonusBudgetLabel),
                        subtitle: Text(
                          '${NumberFormat.decimalPattern().format(_budget)} ${l10n.annualBudgetUnit}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: const Icon(Icons.edit_outlined, size: 20),
                        onTap: () => _editBudget(schedule),
                      ),
                      if (!_isBasicPreset(preview)) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                          child: Text(l10n.annualBasicCustomActive,
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: OutlinedButton.icon(
                            key: const Key('annual-basic-reset'),
                            onPressed: () => _applyBasicPreset(schedule),
                            icon: const Icon(Icons.restart_alt),
                            label: Text(l10n.annualBasicReset),
                          ),
                        ),
                      ],
                      if (_isBasicPreset(preview))
                        SizedBox(height: _sectionSpacing),
                    ]),
              ),
              SizedBox(height: _settingsSpacing),
              Card(
                child: ExpansionTile(
                  key: ValueKey('annual-advanced-$year'),
                  title: Text(l10n.annualAdvancedTitle,
                      style: Theme.of(context).textTheme.titleMedium),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      key: const Key('annual-advanced-help'),
                      tooltip: l10n.annualAdvancedHelpTooltip,
                      onPressed: _showAdvancedHelp,
                      icon: const Icon(Icons.help_outline),
                    ),
                    Icon(_advancedExpanded
                        ? Icons.expand_less
                        : Icons.expand_more),
                  ]),
                  initiallyExpanded: false,
                  onExpansionChanged: (expanded) =>
                      setState(() => _advancedExpanded = expanded),
                  childrenPadding:
                      EdgeInsets.fromLTRB(8, _sectionSpacing, 8, 12),
                  children: _advancedExpanded
                      ? [
                          ListTile(
                            key: const Key('annual-start-date'),
                            leading: const Icon(Icons.event_outlined),
                            title: Text(l10n.startDate),
                            subtitle: Text(l10n.formatLongDate(
                                _startDate ?? schedule.startDate)),
                            trailing: const Icon(Icons.edit_outlined),
                            onTap: () => _pickStartDate(schedule),
                          ),
                          _bonusCard(l10n, schedule, preview),
                          if (sixCount > 0)
                            _sixWeekCard(l10n, schedule, preview, sixCount),
                        ]
                      : const [],
                ),
              ),
              if (draft == null) ...[
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.annualBoundaryInvalid),
                  ),
                ),
              ],
              if (hasNeighborGap) ...[
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.annualNeighborWarning),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _timelineCard(l10n, shown, preview == null),
            ],
          );
        },
      ),
    );
  }

  Widget _dateColumns(AppLocalizations l10n, DateTime start, DateTime end) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final dateStyle = Theme.of(context).textTheme.bodyMedium;
    Widget cell(String label, DateTime date) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              Text(l10n.formatDate(date), style: dateStyle),
            ],
          ),
        );
    return Row(children: [
      cell(l10n.annualStartDateColumn, start),
      cell(l10n.annualEndDateColumn, end),
    ]);
  }

  Widget _bonusCard(
      AppLocalizations l10n, AnnualSchedule saved, AnnualSchedule? preview) {
    final boundaryError = preview == null && _validSixWeeks(saved) == null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.annualChooseBonus,
              style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: _sectionSpacing),
          Text(l10n.annualBonusHelp,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          _bonusWeekEditor(l10n, saved, preview, 0),
          const Divider(height: 32),
          _bonusWeekEditor(l10n, saved, preview, 1),
          if (boundaryError) _inlineError(l10n.annualBoundaryInvalid),
        ]),
      ),
    );
  }

  Widget _monthButton(
      AppLocalizations l10n, AnnualSchedule saved, int entry, int month) {
    final selected = month == (entry == 0 ? _firstMonth : _secondMonth);
    final otherZeroMonth = entry == 0 && _secondWeeks == 0
        ? _secondMonth
        : entry == 1 && _firstWeeks == 0
            ? _firstMonth
            : null;
    return selected
        ? FilledButton.tonal(
            key: Key('bonus-month-$entry-$month'),
            onPressed: null,
            style: FilledButton.styleFrom(
                disabledBackgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                disabledForegroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 2)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check, size: 15),
              const SizedBox(width: 2),
              Text(l10n.locale.languageCode == 'ja'
                  ? l10n.formatMonth(month)
                  : month.toString()),
            ]),
          )
        : OutlinedButton(
            key: Key('bonus-month-$entry-$month'),
            onPressed: month == otherZeroMonth
                ? null
                : () => _selectMonth(saved, entry, month),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 2)),
            child: Text(l10n.locale.languageCode == 'ja'
                ? l10n.formatMonth(month)
                : month.toString()),
          );
  }

  Widget _bonusWeekEditor(AppLocalizations l10n, AnnualSchedule saved,
      AnnualSchedule? preview, int index) {
    final weeks = index == 0 ? _firstWeeks : _secondWeeks;
    final month = index == 0 ? _firstMonth : _secondMonth;
    final periodIndex = index == 0 ? _firstPeriodIndex : _secondPeriodIndex;
    AnnualSchedulePeriod? period;
    if (preview != null && weeks == 1) {
      for (final candidate in preview.periods) {
        if (candidate.days == 7 && candidate.index == periodIndex) {
          period = candidate;
          break;
        }
      }
    }
    final week = period == null ? null : ((period.startDate.day - 1) ~/ 7) + 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(index == 0 ? l10n.bonusMonthPrimary : l10n.bonusMonthSecondary,
          style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 6),
      SegmentedButton<int>(
        key: Key('bonus-weeks-${saved.year}-$index'),
        segments: [
          ButtonSegment(value: 0, label: Text(l10n.annualWeeks(0))),
          ButtonSegment(value: 1, label: Text(l10n.annualWeeks(1))),
        ],
        selected: {weeks},
        onSelectionChanged: (selection) => _change(saved, () {
          if (index == 0) {
            _firstWeeks = selection.first;
          } else {
            _secondWeeks = selection.first;
          }
        }),
      ),
      const SizedBox(height: 12),
      if (weeks == 0) ...[
        Text(l10n.annualZeroMonthHelp),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, constraints) {
          final width = (constraints.maxWidth - 24) / 4;
          return Wrap(spacing: 8, runSpacing: 8, children: [
            for (var selectedMonth = 1; selectedMonth <= 12; selectedMonth++)
              SizedBox(
                  width: width,
                  child: _monthButton(l10n, saved, index, selectedMonth)),
          ]);
        }),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(l10n.annualZeroMonthSummary(l10n.formatMonth(month))),
        ),
      ] else ...[
        Text(l10n.annualOnePeriodHelp),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: Key('bonus-period-select-$index'),
          onPressed: () => _selectPeriod(saved, index),
          icon: const Icon(Icons.calendar_view_week_outlined),
          label: Text(l10n.annualSchedulePeriodIndex(periodIndex + 1)),
        ),
      ],
      if (period != null && weeks == 1)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(l10n.annualOnePeriodDate(
              l10n.formatShortDate(period.startDate),
              l10n.formatShortDate(period.endDate),
              week!)),
        ),
    ]);
  }

  Widget _sixWeekCard(AppLocalizations l10n, AnnualSchedule saved,
      AnnualSchedule? preview, int count) {
    final options = _allValidSixWeeks(saved);
    final candidates = <int, ({Set<int> indices, AnnualSchedule schedule})>{};
    final labels = AnnualScheduleGenerator.periodMonthLabels([
      BonusMonthSetting(month: _firstMonth, weeks: _firstWeeks),
      BonusMonthSetting(month: _secondMonth, weeks: _secondWeeks),
    ]);
    for (final option in options) {
      for (final index in option.indices) {
        candidates.putIfAbsent(labels[index], () => option);
      }
    }
    final selectedMonths = {
      if (preview != null)
        for (final index in _sixWeekPeriods) labels[index],
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.annualSixWeekTitle,
              style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: _sectionSpacing),
          Text(l10n.annualSixWeekHelp(count),
              style: Theme.of(context).textTheme.bodySmall),
          if (_sixWeekPeriods.length != count)
            _inlineError(l10n.annualSixWeekRequired(count)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var month = 1; month <= 12; month++)
              FilterChip(
                key: Key('six-week-month-$month'),
                label: Text(l10n.formatMonth(month)),
                selected: selectedMonths.contains(month),
                onSelected: candidates[month] == null
                    ? null
                    : (_) => _change(saved, () {
                          _sixWeekPeriods = candidates[month]!.indices.toSet();
                        }),
              ),
          ]),
          if (preview != null) ...[
            const SizedBox(height: 12),
            for (final index in _sixWeekPeriods.toList()..sort())
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${l10n.formatMonth(labels[index])} · ${l10n.annualSchedulePeriodIndex(index + 1)} · ${l10n.annualSixCandidate(l10n.formatShortDate(preview.periods[index].startDate), l10n.formatShortDate(preview.periods[index].endDate))}',
                ),
              ),
          ],
        ]),
      ),
    );
  }

  Widget _timelineCard(
      AppLocalizations l10n, AnnualSchedule schedule, bool showingSaved) {
    final periodColors = buildAnnualScheduleColors(schedule.periods.length);
    return Card(
      key: const Key('annual-timeline'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.annualPreviewTitle,
              style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: _sectionSpacing),
          Text(l10n.annualTimelineSummary(schedule.periods.length),
              style: Theme.of(context).textTheme.bodySmall),
          if (showingSaved)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.annualPreviewSaved,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          for (final period in schedule.periods)
            _timelineRow(l10n, schedule, period,
                periodColors[period.index % periodColors.length]),
        ]),
      ),
    );
  }

  Widget _timelineRow(AppLocalizations l10n, AnnualSchedule schedule,
      AnnualSchedulePeriod period, Color color) {
    final colors = Theme.of(context).colorScheme;
    final isBonus = schedule.bonusPeriods.contains(period.index);
    final isSix = schedule.sixWeekPeriods.contains(period.index);
    final weeks = AnnualScheduleGenerator.baseWeeks(period.days);
    final extra = period.days - weeks * 7;
    final type = isBonus
        ? l10n.annualBonusTag
        : isSix && period.days < 42
            ? l10n.annualPartialSixWeeks(extra, period.days)
            : extra == 0
                ? l10n.annualWeeks(weeks)
                : l10n.annualWeeksExtra(weeks, extra);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: color, width: 2),
            ),
          ),
          if (period.index < schedule.periods.length - 1)
            Container(width: 2, height: 58, color: colors.outlineVariant),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${l10n.annualSchedulePeriodIndex(period.index + 1)}  $type',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            _dateColumns(l10n, period.startDate, period.endDate),
          ]),
        ),
      ]),
    );
  }

  Widget _inlineError(String message) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(message,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      );
}
