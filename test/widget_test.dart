import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/app.dart';

void main() {
  testWidgets('KakeiboApp shows home', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KakeiboApp()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'ホーム'), findsOneWidget);
  });
}