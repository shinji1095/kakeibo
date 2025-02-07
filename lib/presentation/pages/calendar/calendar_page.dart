import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kakeibo/presentation/widgets/bottom_navigation.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;    // 現在表示している月
  late DateTime _selectedDay;   // 選択されている日付

  // ボトムナビゲーションのインデックス（「カレンダー」タブを想定して 1 に設定）
  final int _bottomNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  /// 前月へ
  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month - 1,
        _focusedDay.day,
      );
    });
  }

  /// 次月へ
  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + 1,
        _focusedDay.day,
      );
    });
  }

  /// カレンダーヘッダ中央に表示する「2025年2月」など
  String get _formattedMonthYear {
    return '${_focusedDay.year}年${_focusedDay.month}月';
  }

  // サンプル用のデータ（実際はDBやAPIから取得して計算する想定）
  // 月ごとの収支合計などを管理し、画面下のサマリーに表示したりします。
  // ここではすべて 0円 のダミーです。
  int get monthlyIncome => 0;
  int get monthlyExpense => 0;
  int get monthlyTotal => monthlyIncome - monthlyExpense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 検索ボタン押下時の処理 (例: 検索画面へ遷移など)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 月表示・日付選択ボタン部分
          _buildMonthSelector(context),

          // カレンダー
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              locale: 'ja_JP', // 日本語表示にしたい場合は設定

              // 選択日の管理
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                // ここで「その日付の明細画面を開く」などの処理を行う
              },
              onPageChanged: (focusedDay) {
                // スワイプで月が切り替わった時に呼ばれる
                setState(() {
                  _focusedDay = focusedDay;
                });
              },

              // カレンダースタイル
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
              ),

              // ヘッダはカスタマイズせずに非表示にし、上部の自前UI (_buildMonthSelector) で制御
              headerVisible: false,
            ),
          ),

          // 画面下の収支サマリー
          _buildSummarySection(),
        ],
      ),

      // ボトムナビゲーション
      bottomNavigationBar: BottomNavigation(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          // 例: 他のページへの遷移処理
          // if (index == 0) Navigator.pushReplacement(...);  // 入力画面へ etc.
        },
      ),
    );
  }

  /// カレンダーヘッダー部分（「< 2025年2月 >」や日付ピッカーアイコンなど）
  Widget _buildMonthSelector(BuildContext context) {
    return Container(
      color: Colors.orange.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _goToPreviousMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                // 日付ピッカーを開いて、その月にジャンプする例
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _focusedDay,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selected != null) {
                  setState(() {
                    _focusedDay = DateTime(selected.year, selected.month, _focusedDay.day);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_formattedMonthYear, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _goToNextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  /// 画面下部の「収入・支出・合計」表示部分
  Widget _buildSummarySection() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 収入
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '収入',
                style: TextStyle(color: Colors.blue),
              ),
              Text(
                '${monthlyIncome}円',
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ],
          ),
          // 支出
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '支出',
                style: TextStyle(color: Colors.orange),
              ),
              Text(
                '${monthlyExpense}円',
                style: const TextStyle(color: Colors.orange, fontSize: 16),
              ),
            ],
          ),
          // 合計
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('合計'),
              Text(
                '${monthlyTotal}円',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
