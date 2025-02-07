import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kakeibo/presentation/widgets/bottom_navigation.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with SingleTickerProviderStateMixin {
  // 年月の選択（例：2025年2月）
  DateTime _focusedMonth = DateTime(2025, 2);

  // 支出・収入のタブ
  late TabController _tabController;

  // 「月間」「年間」などの表示単位
  String _selectedPeriod = '月間'; // Dropdown用

  // テスト用にカテゴリ別のデータを用意
  final List<CategoryData> _expenseData = [
    CategoryData(name: '食費', amount: 50680, color: Colors.red),
    CategoryData(name: 'カード', amount: 9999, color: Colors.deepOrange),
    CategoryData(name: '生活用品', amount: 9248, color: Colors.yellow),
    CategoryData(name: 'お酒', amount: 824, color: Colors.amber),
    // これらの合計が 70,751円 という設定
  ];

  final List<CategoryData> _incomeData = [
    CategoryData(name: '給料', amount: 300000, color: Colors.green),
    CategoryData(name: '臨時収入', amount: 5000, color: Colors.lightGreen),
    CategoryData(name: '賞与', amount: 100000, color: Colors.teal),
    // ・・・など
  ];

  // 現在選択中のタブが支出かどうか
  bool get isExpenseTab => _tabController.index == 0;

  // グラフに表示する合計金額
  int get totalAmount {
    if (isExpenseTab) {
      return _expenseData.fold(0, (sum, item) => sum + item.amount);
    } else {
      return _incomeData.fold(0, (sum, item) => sum + item.amount);
    }
  }

  // グラフに表示するカテゴリデータ
  List<CategoryData> get currentCategoryData {
    return isExpenseTab ? _expenseData : _incomeData;
  }

  // ボトムナビゲーションのインデックス（例：入力=0, カレンダー=1, レポート=2, ...）
  int _bottomNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ダークテーマにしたい場合の例
    final bgColor = const Color(0xFF333333); // 背景
    final textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: _buildTitle(),
      ),
      body: Column(
        children: [
          // タブ: 「支出 / 収入」
          Container(
            color: Colors.black87,
            child: TabBar(
              controller: _tabController,
              indicatorColor: isExpenseTab ? Colors.red : Colors.green,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: '支出'),
                Tab(text: '収入'),
              ],
            ),
          ),

          // 「支出 ¥70,751」のような合計表示
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            color: Colors.black87,
            child: Text(
              '${isExpenseTab ? '支出' : '収入'}  ¥${totalAmount.toString()}',
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // 円グラフ部分
          Expanded(
            child: _buildPieChart(),
          ),

          // カテゴリリスト
          _buildCategoryList(),
        ],
      ),

      // ボトムナビゲーション
      bottomNavigationBar: BottomNavigation(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
          // 画面遷移処理
          // if (index == 0) Navigator.pushReplacement(...);
          // etc...
        },
      ),
    );
  }

  // AppBarの中身（年月選択 + 期間表示）
  Widget _buildTitle() {
    final displayText = '${_focusedMonth.year}年${_focusedMonth.month}月';

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              // 1ヶ月前へ
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
        ),
        Text(
          displayText,
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              // 1ヶ月後へ
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
        ),
        const Spacer(),
        // 「月間」「年間」などを切り替えるDropdown例
        DropdownButton<String>(
          value: _selectedPeriod,
          dropdownColor: Colors.black87,
          style: const TextStyle(color: Colors.white),
          items: const [
            DropdownMenuItem(value: '月間', child: Text('月間')),
            DropdownMenuItem(value: '年間', child: Text('年間')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
            }
          },
        ),
      ],
    );
  }

  // fl_chartを使った円グラフ
  Widget _buildPieChart() {
    final data = currentCategoryData;
    final total = totalAmount;

    // データがない場合の簡易ハンドリング
    if (total == 0) {
      return const Center(
        child: Text('データがありません', style: TextStyle(color: Colors.white70)),
      );
    }

    // PieChartSectionDataのリストを生成
    final sections = data.map((cat) {
      final ratio = cat.amount / total;
      final percentage = (ratio * 100).toStringAsFixed(1); // 71.6など
      return PieChartSectionData(
        color: cat.color,
        value: cat.amount.toDouble(),
        radius: 70,
        showTitle: true,
        title: '$percentage%',
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40, // 中央の空き
          // タップアクションなどを有効にしたい場合はここで設定
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // カテゴリの内訳リスト
  Widget _buildCategoryList() {
    final data = currentCategoryData;
    final total = totalAmount;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey.shade900,
      child: Column(
        children: data.map((cat) {
          // 割合計算
          final ratio = total == 0 ? 0.0 : (cat.amount / total) * 100;
          final ratioText = '${ratio.toStringAsFixed(0)}%'; // 72%, 14% など

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            child: Row(
              children: [
                // 色付きラベル
                Container(
                  width: 30,
                  height: 20,
                  color: cat.color,
                  alignment: Alignment.center,
                  child: Text(
                    ratioText,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Text(
                  '¥ ${cat.amount}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// カテゴリデータ用のモデル
class CategoryData {
  final String name;
  final int amount;
  final Color color;

  CategoryData({
    required this.name,
    required this.amount,
    required this.color,
  });
}
