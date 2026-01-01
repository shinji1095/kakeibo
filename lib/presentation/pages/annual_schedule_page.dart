import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';

class AnnualSchedulePage extends ConsumerStatefulWidget {
  const AnnualSchedulePage({super.key});

  @override
  ConsumerState<AnnualSchedulePage> createState() => _AnnualSchedulePageState();
}

class _AnnualSchedulePageState extends ConsumerState<AnnualSchedulePage> {
  final _bonusAmountCtrl = TextEditingController();
  final _bonusMemoCtrl = TextEditingController();
  DateTime _bonusDate = DateTime.now();

  @override
  void dispose() {
    _bonusAmountCtrl.dispose();
    _bonusMemoCtrl.dispose();
    super.dispose();
  }

  void _shiftYear(int delta) {
    ref.read(annualSchedulePageYearProvider.notifier).state += delta;
  }

  Future<void> _regenerate(AnnualSchedule schedule) async {
    final usecase = ref.read(regenerateAnnualScheduleProvider);
    await usecase(
      year: schedule.year,
      startDate: schedule.startDate,
      weekStart: schedule.weekStart,
    );
    final year = ref.read(annualSchedulePageYearProvider);
    ref.invalidate(annualScheduleForYearProvider(year));
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

  Future<void> _saveBonusExpense(Category bonusCategory) async {
    final l10n = AppLocalizations.of(context);
    final amount = int.tryParse(_bonusAmountCtrl.text);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.validationEnterAmount)));
      }
      return;
    }

    await ref.read(addTransactionProvider).call(
          KakeiboTransaction(
            date: _bonusDate,
            amount: Money(amount),
            memo: _bonusMemoCtrl.text,
            categoryId: bonusCategory.id!,
            type: TransactionType.expense,
            expenseAttribute: ExpenseAttribute.bonus,
          ),
        );

    _bonusAmountCtrl.clear();
    _bonusMemoCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bonusExpenseSaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final year = ref.watch(annualSchedulePageYearProvider);
    final scheduleAsync = ref.watch(annualScheduleForYearProvider(year));
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.annualScheduleTitle)),
      body: scheduleAsync.when(
        data: (schedule) {
          if (schedule == null) {
            return Center(child: Text(l10n.annualScheduleMissing));
          }
          final totalDays = schedule.periods.fold<int>(0, (sum, p) => sum + p.days);
          final bonusMonths = schedule.bonusMonths;
          final bonusCategory = (categoriesAsync.value ?? const <Category>[])
              .where((c) => c.type == TransactionType.expense)
              .firstWhere(
                (c) => c.name == l10n.bonusExpenseCategoryName,
                orElse: () => const Category(id: null, name: '', color: 0, type: TransactionType.expense),
              );

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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _regenerate(schedule),
                          icon: const Icon(Icons.autorenew),
                          label: Text(l10n.annualScheduleRegenerate),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.bonusMonthTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (var month = 1; month <= 12; month++)
                    Chip(
                      label: Text(l10n.formatMonth(month)),
                      backgroundColor: bonusMonths.contains(month)
                          ? Theme.of(context).colorScheme.tertiaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                    ),
                ],
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
              const SizedBox(height: 24),
              Text(l10n.bonusExpenseTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bonusCategory.id == null)
                        Text(l10n.bonusExpenseMissingCategory)
                      else ...[
                        TextFormField(
                          controller: _bonusAmountCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(labelText: l10n.bonusExpenseAmountLabel),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: _bonusDate,
                              locale: l10n.locale,
                            );
                            if (picked != null) {
                              setState(() => _bonusDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: l10n.dateLabel),
                            child: Text(l10n.formatLongDate(_bonusDate)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bonusMemoCtrl,
                          decoration: InputDecoration(labelText: l10n.memoLabel),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _saveBonusExpense(bonusCategory),
                            icon: const Icon(Icons.save),
                            label: Text(l10n.bonusExpenseSave),
                          ),
                        ),
                      ],
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing,
      ],
    );
  }
}
