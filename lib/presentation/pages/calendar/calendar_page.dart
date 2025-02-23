import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kakeibo/presentation/widgets/base_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay; // 現在表示している月
  late DateTime _selectedDay; // 選択されている日付

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  /// 前月へ移動
  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month - 1,
        _focusedDay.day,
      );
    });
  }

  /// 次月へ移動
  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + 1,
        _focusedDay.day,
      );
    });
  }

  /// カレンダー上部の年月フォーマット
  String get _formattedMonthYear {
    return '${_focusedDay.year}年${_focusedDay.month}月';
  }

  // 月の収支データ（仮データ）
  int get monthlyIncome => 0;
  int get monthlyExpense => 0;
  int get monthlyTotal => monthlyIncome - monthlyExpense;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      currentIndex: 1, // ボトムバーのカレンダータブに対応するインデックス
      child: Scaffold(
        appBar: AppBar(
          title: const Text('カレンダー'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: 検索機能を追加
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // 上部の年月選択部分
            _buildMonthSelector(context),

            // カレンダー表示
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                locale: 'ja_JP', // 日本語化
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                headerVisible: false, // ヘッダーを非表示
              ),
            ),

            // 収支サマリー
            _buildSummarySection(),
          ],
        ),
      ),
    );
  }

  /// カレンダーヘッダー部分（年月選択用UI）
  Widget _buildMonthSelector(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
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
                  color: Colors.white,
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

  /// 画面下部の収支サマリー表示部分
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
              const Text('収入', style: TextStyle(color: Colors.blue)),
              Text('${monthlyIncome}円',
                  style: const TextStyle(color: Colors.blue, fontSize: 16)),
            ],
          ),
          // 支出
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('支出', style: TextStyle(color: Colors.orange)),
              Text('${monthlyExpense}円',
                  style: const TextStyle(color: Colors.orange, fontSize: 16)),
            ],
          ),
          // 合計
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('合計'),
              Text('${monthlyTotal}円', style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
