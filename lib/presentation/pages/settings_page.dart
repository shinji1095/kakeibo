import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/core/theme/app_theme.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  String _formatDate(DateTime d) => '${d.year}年${d.month}月${d.day}日';

  void _showPlaceholder(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label は未実装です')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('表示', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('文字サイズ')),
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
                    decoration: const InputDecoration(labelText: 'カラーテーマ'),
                    items: [
                      for (final theme in AppColorTheme.values)
                        DropdownMenuItem(
                          value: theme,
                          child: Text(theme.label),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      notifier.setColorTheme(v);
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ThemeMode>(
                    value: settings.themeMode,
                    decoration: const InputDecoration(labelText: '表示モード'),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('システム')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('ライト')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('ダーク')),
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

          Text('家計簿', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('家計簿の開始日'),
                  subtitle: Text(_formatDate(settings.kakeiboStartDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: settings.kakeiboStartDate,
                      locale: const Locale('ja', 'JP'),
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
                    decoration: const InputDecoration(labelText: '期間の長さ（35/42日）'),
                    items: const [
                      DropdownMenuItem(value: 35, child: Text('35日')),
                      DropdownMenuItem(value: 42, child: Text('42日')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      notifier.setPeriodLengthDays(v);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('設定変更は以後の期間から適用されます'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('アカウント', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('プロフィール設定'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPlaceholder(context, 'プロフィール設定'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('データ共有設定'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPlaceholder(context, 'データ共有設定'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('言語設定'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPlaceholder(context, '言語設定'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('管理', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('CSVエクスポート'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/csv'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('カテゴリ管理'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/categories'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('ボーナス設定'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/bonus'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('リマインダー管理'),
                  subtitle: const Text('初期リリース対象外'),
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
