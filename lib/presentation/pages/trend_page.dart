import 'package:flutter/material.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';

class TrendPage extends StatelessWidget {
  const TrendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: '推移',
      currentIndex: 4,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('推移は未実装です（プレースホルダー）'),
        ),
      ),
    );
  }
}