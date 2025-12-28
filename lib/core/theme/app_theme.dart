import 'package:flutter/material.dart';

enum AppColorTheme {
  sky,
  leaf,
  sunset,
  berry,
  slate,
}

extension AppColorThemeX on AppColorTheme {
  String get label {
    switch (this) {
      case AppColorTheme.sky:
        return 'スカイ';
      case AppColorTheme.leaf:
        return 'リーフ';
      case AppColorTheme.sunset:
        return 'サンセット';
      case AppColorTheme.berry:
        return 'ベリー';
      case AppColorTheme.slate:
        return 'スレート';
    }
  }

  Color get seedColor {
    switch (this) {
      case AppColorTheme.sky:
        return const Color(0xFF99C8FF);
      case AppColorTheme.leaf:
        return const Color(0xFF43A047);
      case AppColorTheme.sunset:
        return const Color(0xFFFF8A65);
      case AppColorTheme.berry:
        return const Color(0xFFE91E63);
      case AppColorTheme.slate:
        return const Color(0xFF607D8B);
    }
  }
}

class AppTheme {
  static ThemeData themeFor(AppColorTheme colorTheme, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: colorTheme.seedColor,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;
    final background = isDark ? scheme.background : const Color(0xFFF4F6FA);
    final surface = isDark ? scheme.surface : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme.copyWith(
        background: background,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
