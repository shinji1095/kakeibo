import 'package:flutter/material.dart';

class AssetsPage extends StatelessWidget {
  const AssetsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('資産'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              // TODO: グラフページへ遷移する処理
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: その他オプションメニュー
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 資産・負債・合計の表示部分
          _buildSummaryRow(assets, liabilities, total),

          // カテゴリごとのリスト
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildListItem(item['category'] as String,
                    item['amount'] as int, item['type'] as String);
              },
            ),
          ),
        ],
      ),

      // ボトムナビゲーションバー
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // 資産タブを選択中
        onTap: (index) {
          // TODO: 画面遷移処理
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '家計簿'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '統計'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: '資産'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'もっと見る'),
        ],
      ),
    );
  }

  // 資産・負債・合計の表示部分
  Widget _buildSummaryRow(int assets, int liabilities, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryColumn('資産', assets, Colors.blue),
          _buildSummaryColumn('負債', liabilities, Colors.red),
          _buildSummaryColumn('合計', total, total >= 0 ? Colors.green : Colors.orange),
        ],
      ),
    );
  }

  // 資産・負債・合計の1列
  Widget _buildSummaryColumn(String label, int amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          '¥ ${amount.toString()}',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // リストアイテム
  Widget _buildListItem(String category, int amount, String type) {
    final isAsset = type == '資産';
    return ListTile(
      title: Text(
        category,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: Text(
        '¥ ${amount.toString()}',
        style: TextStyle(
          color: isAsset ? Colors.blue : Colors.red,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        type,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      tileColor: Colors.grey.shade800,
    );
  }
}
