import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/core/theme/app_theme.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _showPlaceholder(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.notImplemented(label))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.displaySection, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(l10n.fontSize)),
                      Text('${settings.fontScale.toStringAsFixed(2)}x'),
                    ],
                  ),
                  Slider(
                    value: settings.fontScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    label: settings.fontScale.toStringAsFixed(2),
                    onChanged: notifier.setFontScale,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AppColorTheme>(
                    value: settings.colorTheme,
                    decoration: InputDecoration(labelText: l10n.colorTheme),
                    items: [
                      for (final theme in AppColorTheme.values)
                        DropdownMenuItem(
                          value: theme,
                          child: Text(l10n.colorThemeLabel(theme)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      notifier.setColorTheme(v);
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AppLanguage>(
                    value: settings.language,
                    decoration: InputDecoration(labelText: l10n.language),
                    items: [
                      for (final language in AppLanguage.values)
                        DropdownMenuItem(
                          value: language,
                          child: Text(l10n.languageLabel(language)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      notifier.setLanguage(v);
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ThemeMode>(
                    value: settings.themeMode,
                    decoration: InputDecoration(labelText: l10n.displayMode),
                    items: [
                      DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.themeSystem)),
                      DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.themeLight)),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.themeDark)),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      notifier.setThemeMode(v);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(l10n.kakeiboSection, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.startDate),
                  subtitle: Text(l10n.formatLongDate(settings.kakeiboStartDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: settings.kakeiboStartDate,
                      locale: l10n.locale,
                    );
                    if (picked != null) {
                      notifier.setKakeiboStartDate(picked);
                    }
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<int>(
                    value: settings.periodLengthDays,
                    decoration: InputDecoration(labelText: l10n.periodLength),
                    items: [
                      DropdownMenuItem(value: 35, child: Text(l10n.periodLength35)),
                      DropdownMenuItem(value: 42, child: Text(l10n.periodLength42)),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      notifier.setPeriodLengthDays(v);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.periodChangeNote),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(l10n.accountSection, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.profileSetting),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPlaceholder(context, l10n.profileSetting),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.dataSharingSetting),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPlaceholder(context, l10n.dataSharingSetting),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(l10n.managementSection, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.csvExport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/csv'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.categoryManage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/categories'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.bonusSettings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/bonus'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.annualSchedule),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/annual'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.reminderManage),
                  subtitle: Text(l10n.reminderOutOfScope),
                  enabled: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
