import 'package:flutter/material.dart';
import 'package:kakeibo/presentation/widgets/bottom_navigation.dart';
import 'package:kakeibo/presentation/widgets/category_button.dart';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 支出・収入の2タブ
    _tabController.addListener(() {
      setState(() {}); // タブ切り替え時に画面を再描画
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ボタンのラベルをタブによって変える例
  String get submitButtonLabel {
    return _tabController.index == 0 ? '支出を入力する' : '収入を入力する';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('35家計簿フトコロ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '支出'),
            Tab(text: '収入'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExpenseInputView(),
          IncomeInputView(),
        ],
      ),

      // 画面下部に大きめのボタンを配置
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, // BottomNavigationBarと重ならないようにする
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                // style: ElevatedButton.styleFrom(
                //   foregroundColor: Theme.of(context).elevatedButtonTheme.,
                // ),
                onPressed: () {
                  // TODO: 入力処理
                },
                child: Text(submitButtonLabel),
              ),
            ),
          ),
          // ボトムナビゲーションを配置
          BottomNavigation(
            currentIndex: _bottomNavIndex,
            onTap: (index) {
              setState(() {
                _bottomNavIndex = index;
              });
              // ここでNavigatorを使って他の画面に遷移するなど
              // 例: if (index == 1) Navigator.pushReplacement(...);
            },
          ),
        ],
      ),
    );
  }
}

// タブ切り替えで表示される「支出」用の入力ビュー
class ExpenseInputView extends StatelessWidget {
  const ExpenseInputView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 日付
          Row(
            children: [
              const Text('日付: '),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: 日付選択処理
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    // decoration: BoxDecoration(
                    //   color: Colors.orange.shade100,
                    //   borderRadius: BorderRadius.circular(4),
                    // ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('2025年2月4日 (火)'),
                        Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // メモ
          TextField(
            decoration: const InputDecoration(
              labelText: 'メモ',
              hintText: '未入力',
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          // 金額
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '支出',
              suffixText: '円',
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          // カテゴリ（例示）
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CategoryButton(label: '食費', icon: Icons.restaurant),
              CategoryButton(label: '日用品', icon: Icons.shopping_basket),
              CategoryButton(label: '交通費', icon: Icons.directions_bus),
              CategoryButton(label: '趣味', icon: Icons.music_note),
              CategoryButton(label: '編集する', icon: Icons.edit),
            ],
          ),
        ],
      ),
    );
  }
}

// タブ切り替えで表示される「収入」用の入力ビュー
class IncomeInputView extends StatelessWidget {
  const IncomeInputView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 日付
          Row(
            children: [
              const Text('日付: '),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: 日付選択処理
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    // decoration: BoxDecoration(
                    //   color: Colors.orange.shade100,
                    //   borderRadius: BorderRadius.circular(4),
                    // ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('2025年2月4日 (火)'),
                        Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // メモ
          TextField(
            decoration: const InputDecoration(
              labelText: 'メモ',
              hintText: '未入力',
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          // 金額
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '収入',
              suffixText: '円',
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          // カテゴリ（例示）
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CategoryButton(label: '給料', icon: Icons.account_balance_wallet),
              CategoryButton(label: 'おこづかい', icon: Icons.savings),
              CategoryButton(label: '賞与', icon: Icons.card_giftcard),
              CategoryButton(label: '副業', icon: Icons.store),
              CategoryButton(label: '投資', icon: Icons.monetization_on),
              CategoryButton(label: '臨時収入', icon: Icons.volunteer_activism),
              CategoryButton(label: '編集する', icon: Icons.edit),
            ],
          ),
        ],
      ),
    );
  }
}
