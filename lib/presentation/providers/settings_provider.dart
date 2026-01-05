import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/core/theme/app_theme.dart';

@immutable
class SettingsState {
  final AppColorTheme colorTheme;
  final AppLanguage language;
  final int periodBudget;
  final int bonusMonth;

  const SettingsState({
    required this.colorTheme,
    required this.language,
    required this.periodBudget,
    required this.bonusMonth,
  });

  factory SettingsState.initial() {
    final now = DateTime.now();
    return SettingsState(
      colorTheme: AppColorTheme.sky,
      language: AppLanguage.japanese,
      periodBudget: 50000,
      bonusMonth: now.month,
    );
  }

  SettingsState copyWith({
    AppColorTheme? colorTheme,
    AppLanguage? language,
    int? periodBudget,
    int? bonusMonth,
  }) {
    return SettingsState(
      colorTheme: colorTheme ?? this.colorTheme,
      language: language ?? this.language,
      periodBudget: periodBudget ?? this.periodBudget,
      bonusMonth: bonusMonth ?? this.bonusMonth,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState.initial());

  void setColorTheme(AppColorTheme theme) {
    state = state.copyWith(colorTheme: theme);
  }

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
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
