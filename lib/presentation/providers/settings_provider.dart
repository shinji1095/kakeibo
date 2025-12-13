import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class SettingsState {
  final double fontScale;
  final ThemeMode themeMode;
  final DateTime kakeiboStartDate;
  final int salaryDay;

  /// Fixed expense day-of-month (1..31). null means "not set".
  final int? fixedExpenseDay;

  /// Fixed expense amount in JPY (>= 0)
  final int fixedExpenseAmount;

  const SettingsState({
    required this.fontScale,
    required this.themeMode,
    required this.kakeiboStartDate,
    required this.salaryDay,
    required this.fixedExpenseDay,
    required this.fixedExpenseAmount,
  });

  factory SettingsState.initial() {
    final now = DateTime.now();
    return SettingsState(
      fontScale: 1.0,
      themeMode: ThemeMode.system,
      kakeiboStartDate: DateTime(now.year, now.month, 1),
      salaryDay: 25,
      fixedExpenseDay: null,
      fixedExpenseAmount: 0,
    );
  }

  SettingsState copyWith({
    double? fontScale,
    ThemeMode? themeMode,
    DateTime? kakeiboStartDate,
    int? salaryDay,
    int? fixedExpenseDay,
    bool setFixedExpenseDayNull = false,
    int? fixedExpenseAmount,
  }) {
    return SettingsState(
      fontScale: fontScale ?? this.fontScale,
      themeMode: themeMode ?? this.themeMode,
      kakeiboStartDate: kakeiboStartDate ?? this.kakeiboStartDate,
      salaryDay: salaryDay ?? this.salaryDay,
      fixedExpenseDay: setFixedExpenseDayNull ? null : (fixedExpenseDay ?? this.fixedExpenseDay),
      fixedExpenseAmount: fixedExpenseAmount ?? this.fixedExpenseAmount,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState.initial());

  void setFontScale(double value) {
    final v = value.clamp(0.8, 1.4);
    state = state.copyWith(fontScale: v);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setKakeiboStartDate(DateTime date) {
    state = state.copyWith(kakeiboStartDate: DateTime(date.year, date.month, date.day));
  }

  void setSalaryDay(int day) {
    final v = day.clamp(1, 31);
    state = state.copyWith(salaryDay: v);
  }

  void setFixedExpenseDay(int? day) {
    if (day == null) {
      state = state.copyWith(setFixedExpenseDayNull: true);
      return;
    }
    final v = day.clamp(1, 31);
    state = state.copyWith(fixedExpenseDay: v);
  }

  void setFixedExpenseAmount(int amount) {
    final v = amount < 0 ? 0 : amount;
    state = state.copyWith(fixedExpenseAmount: v);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
      (ref) => SettingsNotifier(),
);
