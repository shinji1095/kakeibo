import 'package:flutter/material.dart';
import 'package:kakeibo/core/constants/app_colors.dart';

class AppTheme {
  // アプリ全体で使用するカラーパレット
  static const Color primaryColor = AppColors.primary;
  static const Color backgroundColor = AppColors.background;
  static const Color errorColor = AppColors.error;
  static const Color textPrimaryColor = AppColors.textPrimary;
  static const Color textSecondaryColor = AppColors.textSecondary;

  // テーマデータ（ライトモード）
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,

    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: Colors.lightBlue),
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
        foregroundColor: textPrimaryColor,
        side: const BorderSide(color: primaryColor),
        textStyle: const TextStyle(fontSize: 14),
      ),
    ),

    // テキストフィールドの統一スタイル
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      labelStyle: TextStyle(color: Colors.black87, fontSize: 14),
    ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textPrimaryColor,
      ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white, // ボトムバーの背景色
      selectedItemColor: Colors.blueAccent, // 選択中のアイテムの色
      unselectedItemColor: Colors.grey, // 未選択アイテムの色
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.blue, // 選択中の文字色
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        color: Colors.black, // 未選択の文字色
      ),
    ),

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
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black, // ボトムバー背景色
      selectedItemColor: Colors.orange, // 選択されたアイテムの色
      unselectedItemColor: Colors.black87, // 未選択のアイテムの色
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        color: Colors.black87,
      ),
    ),
  );

  // アイコン
  static const Color iconColor = Color(0xFFC5E0FF);
}
