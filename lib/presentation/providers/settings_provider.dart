import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class SettingsState {
  final double fontScale;
  final ThemeMode themeMode;
  final DateTime kakeiboStartDate;
  final int periodLengthDays;

  const SettingsState({
    required this.fontScale,
    required this.themeMode,
    required this.kakeiboStartDate,
    required this.periodLengthDays,
  });

  factory SettingsState.initial() {
    final now = DateTime.now();
    return SettingsState(
      fontScale: 1.0,
      themeMode: ThemeMode.system,
      kakeiboStartDate: DateTime(now.year, now.month, 1),
      periodLengthDays: 35,
    );
  }

  SettingsState copyWith({
    double? fontScale,
    ThemeMode? themeMode,
    DateTime? kakeiboStartDate,
    int? periodLengthDays,
  }) {
    return SettingsState(
      fontScale: fontScale ?? this.fontScale,
      themeMode: themeMode ?? this.themeMode,
      kakeiboStartDate: kakeiboStartDate ?? this.kakeiboStartDate,
      periodLengthDays: periodLengthDays ?? this.periodLengthDays,
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
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);