import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class BonusSettingsPage extends ConsumerStatefulWidget {
  const BonusSettingsPage({super.key});

  @override
  ConsumerState<BonusSettingsPage> createState() => _BonusSettingsPageState();
}

class _BonusSettingsPageState extends ConsumerState<BonusSettingsPage> {
  late final TextEditingController _budgetController;
  late final FocusNode _budgetFocus;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController();
    _budgetFocus = FocusNode();
    _budgetFocus.addListener(() {
      if (!_budgetFocus.hasFocus) {
        _commitBudget();
      }
    });
  }

  @override
  void dispose() {
    _budgetFocus.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _commitBudget() {
    final value = int.tryParse(_budgetController.text);
    if (value == null) return;
    ref.read(settingsProvider.notifier).setPeriodBudget(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final budgetText = settings.periodBudget.toString();
    if (_budgetController.text != budgetText) {
      _budgetController.text = budgetText;
      _budgetController.selection = TextSelection.collapsed(offset: budgetText.length);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bonusSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.bonusBudgetTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _budgetController,
                    focusNode: _budgetFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l10n.bonusBudgetLabel,
                      hintText: l10n.bonusBudgetHint,
                    ),
                    onFieldSubmitted: (_) => _commitBudget(),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.bonusBudgetNote),
                  const SizedBox(height: 4),
                  Text(l10n.bonusBudgetApplyNote),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.bonusMonthTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<int>(
                value: settings.bonusMonth,
                decoration: InputDecoration(labelText: l10n.bonusMonthLabel),
                items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(l10n.formatMonth(i + 1)),
                  ),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  notifier.setBonusMonth(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
