import 'package:flutter/material.dart';
import 'package:kakeibo/core/constants/app_colors.dart';

// カテゴリボタンの例
class CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const CategoryButton({
    Key? key,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: カテゴリ選択処理
      },
      icon: Icon(icon, color: AppColors.secondary),
      label: Text(label, style: const TextStyle(color: Colors.black87)),
      // // style: OutlinedButton.styleFrom(
      // //   foregroundColor: Theme.of(context).secondaryHeaderColor,
      // //   side: const BorderSide(color:AppColors.secondary),
      // ),
    );
  }
}