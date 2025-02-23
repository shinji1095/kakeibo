import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kakeibo/presentation/widgets/base_page.dart';

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

  // テスト用カテゴリデータ
  final List<CategoryData> _expenseData = [
    CategoryData(name: '食費', amount: 50680, color: Colors.red),
    CategoryData(name: 'カード', amount: 9999, color: Colors.deepOrange),
    CategoryData(name: '生活用品', amount: 9248, color: Colors.yellow),
    CategoryData(name: 'お酒', amount: 824, color: Colors.amber),
  ];

  final List<CategoryData> _incomeData = [
    CategoryData(name: '給料', amount: 300000, color: Colors.green),
    CategoryData(name: '臨時収入', amount: 5000, color: Colors.lightGreen),
    CategoryData(name: '賞与', amount: 100000, color: Colors.teal),
  ];

  bool get isExpenseTab => _tabController.index == 0;

  int get totalAmount {
    return isExpenseTab
        ? _expenseData.fold(0, (sum, item) => sum + item.amount)
        : _incomeData.fold(0, (sum, item) => sum + item.amount);
  }

  List<CategoryData> get currentCategoryData {
    return isExpenseTab ? _expenseData : _incomeData;
  }

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
    return BasePage(
      currentIndex: 2, // 「レポート」タブのインデックス
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: _buildTitle(),
        ),
        body: Column(
          children: [
            // タブ: 「支出 / 収入」
            Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: TabBar(
                controller: _tabController,
                indicatorColor: isExpenseTab
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.secondary,
                labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                tabs: const [
                  Tab(text: '支出'),
                  Tab(text: '収入'),
                ],
              ),
            ),

            // 合計表示
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: Text(
                '${isExpenseTab ? '支出' : '収入'}  ¥${totalAmount.toString()}',
                style: Theme.of(context).textTheme.titleLarge,
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
      ),
    );
  }

  Widget _buildTitle() {
    final displayText = '${_focusedMonth.year}年${_focusedMonth.month}月';

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
        ),
        Text(
          displayText,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
        ),
        const Spacer(),
        DropdownButton<String>(
          value: _selectedPeriod,
          dropdownColor: Theme.of(context).appBarTheme.backgroundColor,
          style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildPieChart() {
    final data = currentCategoryData;
    final total = totalAmount;

    if (total == 0) {
      return Center(
        child: Text(
          'データがありません',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final sections = data.map((cat) {
      final ratio = cat.amount / total;
      final percentage = (ratio * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: cat.color,
        value: cat.amount.toDouble(),
        radius: 70,
        showTitle: true,
        title: '$percentage%',
        titleStyle: Theme.of(context).textTheme.bodyMedium,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final data = currentCategoryData;
    final total = totalAmount;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Theme.of(context).cardColor,
      child: Column(
        children: data.map((cat) {
          final ratio = total == 0 ? 0.0 : (cat.amount / total) * 100;
          final ratioText = '${ratio.toStringAsFixed(0)}%';

          return ListTile(
            leading: Container(
              width: 30,
              height: 20,
              color: cat.color,
              alignment: Alignment.center,
              child: Text(
                ratioText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            title: Text(cat.name, style: Theme.of(context).textTheme.bodyLarge),
            trailing: Text(
              '¥ ${cat.amount}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CategoryData {
  final String name;
  final int amount;
  final Color color;

  CategoryData({required this.name, required this.amount, required this.color});
}
