import 'package:flutter/material.dart';
import 'package:kakeibo/presentation/widgets/base_page.dart';

class AssetsPage extends StatelessWidget {
  const AssetsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ダミーデータ（資産と負債）
    final assets = 100924;
    final liabilities = 217164;
    final total = assets - liabilities;

    // リストデータ
    final items = [
      {'category': '現金', 'amount': 217164, 'type': '負債'},
      {'category': '銀行', 'amount': 100924, 'type': '資産'},
      {'category': 'カード', 'amount': 0, 'type': '決済予定金額'},
    ];

    return BasePage(
      currentIndex: 3, // 「資産」タブのインデックス
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('資産'),
        ),
        body: Column(
          children: [
            // 資産・負債・合計の表示部分
            _buildSummaryRow(context, assets, liabilities, total),

            // カテゴリごとのリスト
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: theme.dividerColor,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildListItem(context, item['category'] as String,
                      item['amount'] as int, item['type'] as String);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 資産・負債・合計の表示部分
  Widget _buildSummaryRow(BuildContext context, int assets, int liabilities, int total) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryColumn(context, '資産', assets, theme.colorScheme.primary),
          _buildSummaryColumn(context, '負債', liabilities, theme.colorScheme.error),
          _buildSummaryColumn(context, '合計', total,
              total >= 0 ? theme.colorScheme.secondary : theme.colorScheme.error),
        ],
      ),
    );
  }

  // 資産・負債・合計の1列
  Widget _buildSummaryColumn(BuildContext context, String label, int amount, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          '¥ ${amount.toString()}',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // リストアイテム
  Widget _buildListItem(BuildContext context, String category, int amount, String type) {
    final theme = Theme.of(context);
    final isAsset = type == '資産';
    return ListTile(
      title: Text(
        category,
        style: theme.textTheme.bodyLarge,
      ),
      trailing: Text(
        '¥ ${amount.toString()}',
        style: TextStyle(
          color: isAsset ? theme.colorScheme.primary : theme.colorScheme.error,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        type,
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
      ),
      tileColor: theme.cardColor,
    );
  }
}
