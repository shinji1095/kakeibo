import 'package:flutter/material.dart';
import 'package:kakeibo/presentation/widgets/category_button.dart'; // CategoryButtonをインポート

class ExpenseInputView extends StatelessWidget {
  const ExpenseInputView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日付
          _buildDatePicker(context, '日付', '2025年2月4日 (火)'),

          const SizedBox(height: 16),

          // メモ
          _buildTextField(context,label: 'メモ', hint: '未入力'),

          const SizedBox(height: 16),

          // 金額
          _buildTextField(context,label: '支出', hint: '0', suffix: '円', isNumber: true),

          const SizedBox(height: 16),

          // カテゴリ
          _buildCategorySection([
            const CategoryButton(label: '食費', icon: Icons.restaurant),
            const CategoryButton(label: '日用品', icon: Icons.shopping_basket),
            const CategoryButton(label: '美容', icon: Icons.brush),
            const CategoryButton(label: '衣服', icon: Icons.checkroom),
            const CategoryButton(label: '交際費', icon: Icons.group),
            const CategoryButton(label: '医療費', icon: Icons.medical_services),
            const CategoryButton(label: '教育費', icon: Icons.school),
            const CategoryButton(label: '光熱費', icon: Icons.lightbulb),
            const CategoryButton(label: '通信費', icon: Icons.phone),
            const CategoryButton(label: '住居費', icon: Icons.home),
            const CategoryButton(label: '編集する', icon: Icons.edit),
          ]),
        ],
      ),
    );
  }

  // 以下、IncomeInputViewのものを再利用
  Widget _buildDatePicker(BuildContext context, String label, String date) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: 日付選択処理
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.calendar_today, size: 20, color: Colors.blueAccent),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, {
    required String label,
    required String hint,
    String? suffix,
    bool isNumber = false,
  }) {
    return TextField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration().copyWith(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
      ).applyDefaults(Theme.of(context).inputDecorationTheme), // ここでテーマを適用
    );
  }



  Widget _buildCategorySection(List<Widget> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('カテゴリ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories,
        ),
      ],
    );
  }
}
