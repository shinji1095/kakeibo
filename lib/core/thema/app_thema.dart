import 'package:flutter/material.dart';
import 'package:kakeibo/core/constants/app_colors.dart';

class AppTheme {
  // アプリ全体で使用するカラーパレット
  static const Color primaryColor = AppColors.primary;
  static const Color backgroundColor = AppColors.background;
  static const Color textPrimaryColor = AppColors.textPrimary;
  static const Color textSecondaryColor = AppColors.textSecondary;

  // テーマデータ（ライトモード）
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: textPrimaryColor),
      bodyMedium: TextStyle(fontSize: 14, color: textSecondaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, // ボタンの背景色
        foregroundColor: Colors.white, // ボタン内の文字色
      )
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        textStyle: const TextStyle(fontSize: 14),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: textPrimaryColor),
      hintStyle: TextStyle(color: textSecondaryColor),
    )
  );

  // ダークテーマ
  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.orange,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );

  // アイコン
  static const Color iconColor = Color(0xFFC5E0FF);
}
