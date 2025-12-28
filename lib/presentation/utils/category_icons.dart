import 'package:flutter/material.dart';
import 'package:kakeibo/domain/entities/transaction.dart';

const Map<String, IconData> _expenseIcons = {
  '未分類': Icons.label,
  '食費': Icons.restaurant,
  '日用品': Icons.shopping_cart,
  '美容': Icons.face_retouching_natural,
  '衣服': Icons.checkroom,
  '交際費': Icons.people,
  '医療費': Icons.medical_services,
  '教育費': Icons.school,
  '光熱費': Icons.lightbulb,
  '交通費': Icons.directions_bus,
  '交通': Icons.directions_bus,
  '通信費': Icons.wifi,
  '住居費': Icons.home,
};

const Map<String, IconData> _incomeIcons = {
  '未分類': Icons.label,
  '給料': Icons.attach_money,
  'おこづかい': Icons.card_giftcard,
  '賞与': Icons.emoji_events,
  '副業': Icons.work,
  '投資': Icons.trending_up,
  '臨時収入': Icons.auto_graph,
};

IconData categoryIconFor(Category category) {
  final map = category.type == TransactionType.expense ? _expenseIcons : _incomeIcons;
  return map[category.name] ?? Icons.category;
}
