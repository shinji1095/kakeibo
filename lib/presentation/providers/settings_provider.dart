import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class SettingsState {
  final double fontScale;
  final ThemeMode themeMode;
  final DateTime kakeiboStartDate;
  final int periodLengthDays;
  final int periodBudget;
  final int bonusMonth;

  const SettingsState({
    required this.fontScale,
    required this.themeMode,
    required this.kakeiboStartDate,
    required this.periodLengthDays,
    required this.periodBudget,
    required this.bonusMonth,
  });

  factory SettingsState.initial() {
    final now = DateTime.now();
    return SettingsState(
      fontScale: 1.0,
      themeMode: ThemeMode.system,
      kakeiboStartDate: DateTime(now.year, now.month, 1),
      periodLengthDays: 35,
      periodBudget: 50000,
      bonusMonth: now.month,
    );
  }

  SettingsState copyWith({
    double? fontScale,
    ThemeMode? themeMode,
    DateTime? kakeiboStartDate,
    int? periodLengthDays,
    int? periodBudget,
    int? bonusMonth,
  }) {
    return SettingsState(
      fontScale: fontScale ?? this.fontScale,
      themeMode: themeMode ?? this.themeMode,
      kakeiboStartDate: kakeiboStartDate ?? this.kakeiboStartDate,
      periodLengthDays: periodLengthDays ?? this.periodLengthDays,
      periodBudget: periodBudget ?? this.periodBudget,
      bonusMonth: bonusMonth ?? this.bonusMonth,
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

  void setPeriodLengthDays(int days) {
    final v = days == 42 ? 42 : 35;
    state = state.copyWith(periodLengthDays: v);
  }

  void setPeriodBudget(int value) {
    final v = value < 0 ? 0 : value;
    state = state.copyWith(periodBudget: v);
  }

  void setBonusMonth(int month) {
    final v = month.clamp(1, 12);
    state = state.copyWith(bonusMonth: v);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
