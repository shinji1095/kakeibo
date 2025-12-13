import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _fixedAmountCtrl;
  final FocusNode _fixedAmountFocus = FocusNode();

  String _formatDate(DateTime d) => '${d.year}年${d.month}月${d.day}日';

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _fixedAmountCtrl = TextEditingController(text: s.fixedExpenseAmount.toString());

    _fixedAmountFocus.addListener(() {
      if (!_fixedAmountFocus.hasFocus) {
        final v = int.tryParse(_fixedAmountCtrl.text) ?? 0;
        ref.read(settingsProvider.notifier).setFixedExpenseAmount(v);
      }
    });
  }

  @override
  void dispose() {
    _fixedAmountCtrl.dispose();
    _fixedAmountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    // Keep controller in sync when updated externally (and not editing)
    if (!_fixedAmountFocus.hasFocus) {
      final want = settings.fixedExpenseAmount.toString();
      if (_fixedAmountCtrl.text != want) {
        _fixedAmountCtrl.text = want;
      }
    }

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
                  DropdownButtonFormField<ThemeMode>(
                    value: settings.themeMode,
                    decoration: const InputDecoration(labelText: 'カラーテーマ'),
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
                    value: settings.salaryDay,
                    decoration: const InputDecoration(labelText: '給料日（毎月）'),
                    items: List.generate(
                      31,
                          (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}日')),
                    ),
                    onChanged: (v) {
                      if (v == null) return;
                      notifier.setSalaryDay(v);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('固定支出', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<int?>(
                    value: settings.fixedExpenseDay,
                    decoration: const InputDecoration(labelText: '固定支出の日（毎月）'),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('未設定')),
                      ...List.generate(
                        31,
                            (i) => DropdownMenuItem<int?>(value: i + 1, child: Text('${i + 1}日')),
                      ),
                    ],
                    onChanged: (v) => notifier.setFixedExpenseDay(v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fixedAmountCtrl,
                    focusNode: _fixedAmountFocus,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '固定支出の金額（円）',
                      hintText: '例：80000',
                    ),
                    onChanged: (s) {
                      final v = int.tryParse(s);
                      if (v == null) return;
                      notifier.setFixedExpenseAmount(v);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
