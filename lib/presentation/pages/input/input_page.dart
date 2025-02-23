import 'package:flutter/material.dart';
import 'package:kakeibo/presentation/widgets/bottom_navigation.dart';
import 'package:kakeibo/presentation/widgets/category_button.dart';
import 'package:kakeibo/presentation/pages/input/income_input_view.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/presentation/widgets/base_page.dart';
import 'package:kakeibo/presentation/pages/input/expense_input_view.dart';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return BasePage(
      currentIndex: 0, // 「入力」タブのインデックス
      child: Scaffold(
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
        floatingActionButton: SizedBox(
          width: double.infinity,
          height: 48,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: 入力処理
              },
              child: Text(submitButtonLabel),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
