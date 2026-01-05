import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/app.dart';
import 'package:kakeibo/core/theme/app_theme.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

void main() {
  testWidgets('color theme changes without crashing', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const KakeiboApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    Future<void> setColorTheme(AppColorTheme theme) async {
      container.read(settingsProvider.notifier).setColorTheme(theme);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
      expect(app.theme?.colorScheme.primary,
          AppTheme.themeFor(theme, Brightness.light).colorScheme.primary);
    }

    for (final theme in AppColorTheme.values) {
      await setColorTheme(theme);
    }
  });
}
