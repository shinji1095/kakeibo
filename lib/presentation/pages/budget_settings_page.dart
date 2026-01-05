import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class BudgetSettingsPage extends ConsumerStatefulWidget {
  const BudgetSettingsPage({super.key});

  @override
  ConsumerState<BudgetSettingsPage> createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends ConsumerState<BudgetSettingsPage> {
  late final TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final l10n = AppLocalizations.of(context);
    final value = int.tryParse(_budgetController.text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationEnterAmount)),
      );
      return;
    }
    ref.read(settingsProvider.notifier).setPeriodBudget(value);
    final countStatus = ref.read(currentAnnualScheduleCountStatusProvider);
    if (countStatus != null && !countStatus.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.annualScheduleCountMismatchWarning)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.budgetSavedMessage)),
    );
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final budgetText = settings.periodBudget.toString();
    if (_budgetController.text != budgetText) {
      _budgetController.text = budgetText;
      _budgetController.selection = TextSelection.collapsed(offset: budgetText.length);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.budgetSettingsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bonusBudgetTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  key: const Key('budget-settings-input'),
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.bonusBudgetLabel,
                    hintText: l10n.bonusBudgetHint,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(l10n.bonusBudgetNote),
            const SizedBox(height: 4),
            Text(l10n.bonusBudgetApplyNote),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('budget-settings-back'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(l10n.budgetBackButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    key: const Key('budget-settings-save'),
                    onPressed: _saveBudget,
                    child: Text(l10n.budgetSaveButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
