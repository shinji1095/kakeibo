import 'package:flutter/material.dart';
import 'package:kakeibo/core/theme/app_theme.dart';
import 'package:kakeibo/domain/entities/transaction.dart';

enum AppLanguage { japanese, english }

extension AppLanguageX on AppLanguage {
  Locale get locale {
    switch (this) {
      case AppLanguage.japanese:
        return const Locale('ja', 'JP');
      case AppLanguage.english:
        return const Locale('en', 'US');
    }
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('ja', 'JP'),
    Locale('en', 'US'),
  ];

  static const Map<String, Map<String, String>> _localizedStrings = {
    'ja': {
      'appTitle': '35日家計簿 ~フトコロ~',
      'navHome': 'ホーム',
      'navList': '一覧',
      'navInput': '入力',
      'navBreakdown': '内訳',
      'navTrend': '推移',
      'settingsTitle': '設定',
      'displaySection': '表示',
      'fontSize': '文字サイズ',
      'colorTheme': 'カラーテーマ',
      'displayMode': '表示モード',
      'themeSystem': 'システム',
      'themeLight': 'ライト',
      'themeDark': 'ダーク',
      'language': '言語',
      'languageJapanese': '日本語',
      'languageEnglish': '英語',
      'kakeiboSection': '家計簿',
      'startDate': '家計簿の開始日',
      'periodLength': '期間の長さ（35/42日）',
      'periodLength35': '35日',
      'periodLength42': '42日',
      'periodChangeNote': '設定変更は以後の期間から適用されます',
      'accountSection': 'アカウント',
      'profileSetting': 'プロフィール設定',
      'dataSharingSetting': 'データ共有設定',
      'languageSetting': '言語設定',
      'managementSection': '管理',
      'csvExport': 'CSVエクスポート',
      'categoryManage': 'カテゴリ管理',
      'bonusSettings': 'ボーナス設定',
      'reminderManage': 'リマインダー管理',
      'reminderOutOfScope': '初期リリース対象外',
      'notImplemented': '{label} は未実装です',
      'noCategories': 'カテゴリがありません',
      'errorMessage': 'エラー: {error}',
      'inputTitle': '入力',
      'expenseTab': '支出',
      'incomeTab': '収入',
      'amountLabel': '金額（円）',
      'dateLabel': '日付',
      'memoLabel': 'メモ',
      'categoryLabel': 'カテゴリ',
      'saveExpense': '支出を保存',
      'saveIncome': '収入を保存',
      'validationEnterAmount': '金額を入力してください',
      'validationSelectCategory': 'カテゴリを選択してください',
      'savedExpense': '支出を保存しました',
      'savedIncome': '収入を保存しました',
      'editTitle': '取引の編集',
      'typeLabel': '種別',
      'updateButton': '更新',
      'updatedMessage': '更新しました',
      'validationSelectExpenseAttribute': '支出属性を選択してください',
      'listTitle': '一覧',
      'filterAll': 'すべて',
      'filterExpense': '支出',
      'filterIncome': '収入',
      'expenseAttribute': '支出属性',
      'noTransactions': '取引がありません',
      'deleteConfirmTitle': '削除確認',
      'deleteConfirmBody': 'この取引を削除しますか？',
      'deleteCancel': 'キャンセル',
      'deleteOk': '削除',
      'deletedMessage': '削除しました',
      'currencySuffix': '円',
      'typeExpense': '支出',
      'typeIncome': '収入',
      'categoryFallback': 'カテゴリ{id}',
      'breakdownTitle': '内訳',
      'breakdownExpenseCategory': '支出内訳',
      'breakdownIncomeCategory': '収入内訳',
      'noData': 'データがありません',
      'trendTitle': '推移',
      'trendTargetPeriod': '対象期間: {start} ～ {end}',
      'rangeTypePeriod': '期間',
      'rangeTypeWeek': '週別',
      'metricBalance': '収支',
      'metricIncome': '収入',
      'metricExpense': '支出',
      'trendCountLabel': '表示期間: {count}',
      'homeTitle': 'ホーム',
      'homeCurrentPeriod': '現在の期間',
      'homeStartDate': '開始日',
      'homeEndDate': '終了日',
      'homePeriodLengthLabel': '期間長: {days}日',
      'homeDaysRemaining': '終了日まであと{days}日',
      'homeCalendarTitle': '期間カレンダー',
      'homeBudgetRemainingLabel': 'やりくり費 残額',
      'homeBonusPlaceholder': 'ボーナス表示は未実装です（プレースホルダー）',
      'expenseAttrFixed': '固定費',
      'expenseAttrVariable': 'やりくり費',
      'expenseAttrBonus': 'ボーナス支出',
      'colorThemeSky': 'スカイ',
      'colorThemeLeaf': 'リーフ',
      'colorThemeSunset': 'サンセット',
      'colorThemeBerry': 'ベリー',
      'colorThemeSlate': 'スレート',
      'csvExportTitle': 'CSVエクスポート',
      'csvExportPlaceholder': 'CSVエクスポートは未実装です（プレースホルダー）。',
      'categoryManageTitle': 'カテゴリ管理',
      'categoryManagePlaceholder': 'カテゴリ管理は未実装です（プレースホルダー）。',
      'reminderManageTitle': 'リマインダー管理',
      'reminderManagePlaceholder': '初期リリース対象外のため未実装です（プレースホルダー）。',
      'bonusSettingsTitle': 'ボーナス設定',
      'bonusBudgetTitle': 'やりくり費',
      'bonusBudgetLabel': '期間のやりくり費（円）',
      'bonusBudgetHint': '例: 50000',
      'bonusBudgetNote': 'デフォルトは50,000円です',
      'bonusBudgetApplyNote': '設定変更は以後の期間から適用されます',
      'bonusMonthTitle': 'ボーナス月',
      'bonusMonthLabel': 'ボーナス月',
    },
    'en': {
      'appTitle': '35-Day Kakeibo ~Futokoro~',
      'navHome': 'Home',
      'navList': 'List',
      'navInput': 'Input',
      'navBreakdown': 'Breakdown',
      'navTrend': 'Trends',
      'settingsTitle': 'Settings',
      'displaySection': 'Display',
      'fontSize': 'Font Size',
      'colorTheme': 'Color Theme',
      'displayMode': 'Display Mode',
      'themeSystem': 'System',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'language': 'Language',
      'languageJapanese': 'Japanese',
      'languageEnglish': 'English',
      'kakeiboSection': 'Kakeibo',
      'startDate': 'Start Date',
      'periodLength': 'Period Length (35/42 days)',
      'periodLength35': '35 days',
      'periodLength42': '42 days',
      'periodChangeNote': 'Changes apply from the next period.',
      'accountSection': 'Account',
      'profileSetting': 'Profile',
      'dataSharingSetting': 'Data Sharing',
      'languageSetting': 'Language',
      'managementSection': 'Management',
      'csvExport': 'CSV Export',
      'categoryManage': 'Category Management',
      'bonusSettings': 'Bonus Settings',
      'reminderManage': 'Reminders',
      'reminderOutOfScope': 'Out of scope for v1',
      'notImplemented': '{label} is not implemented.',
      'noCategories': 'No categories.',
      'errorMessage': 'Error: {error}',
      'inputTitle': 'Input',
      'expenseTab': 'Expense',
      'incomeTab': 'Income',
      'amountLabel': 'Amount (JPY)',
      'dateLabel': 'Date',
      'memoLabel': 'Memo',
      'categoryLabel': 'Category',
      'saveExpense': 'Save Expense',
      'saveIncome': 'Save Income',
      'validationEnterAmount': 'Enter an amount.',
      'validationSelectCategory': 'Select a category.',
      'savedExpense': 'Expense saved.',
      'savedIncome': 'Income saved.',
      'editTitle': 'Edit Transaction',
      'typeLabel': 'Type',
      'updateButton': 'Update',
      'updatedMessage': 'Updated.',
      'validationSelectExpenseAttribute': 'Select an expense attribute.',
      'listTitle': 'Transactions',
      'filterAll': 'All',
      'filterExpense': 'Expense',
      'filterIncome': 'Income',
      'expenseAttribute': 'Expense Attribute',
      'noTransactions': 'No transactions.',
      'deleteConfirmTitle': 'Confirm Delete',
      'deleteConfirmBody': 'Delete this transaction?',
      'deleteCancel': 'Cancel',
      'deleteOk': 'Delete',
      'deletedMessage': 'Deleted.',
      'currencySuffix': 'JPY',
      'typeExpense': 'Expense',
      'typeIncome': 'Income',
      'categoryFallback': 'Category {id}',
      'breakdownTitle': 'Breakdown',
      'breakdownExpenseCategory': 'Expense Breakdown',
      'breakdownIncomeCategory': 'Income Breakdown',
      'noData': 'No data.',
      'trendTitle': 'Trends',
      'trendTargetPeriod': 'Period: {start} - {end}',
      'rangeTypePeriod': 'Period',
      'rangeTypeWeek': 'Weekly',
      'metricBalance': 'Balance',
      'metricIncome': 'Income',
      'metricExpense': 'Expense',
      'trendCountLabel': 'Periods: {count}',
      'homeTitle': 'Home',
      'homeCurrentPeriod': 'Current Period',
      'homeStartDate': 'Start',
      'homeEndDate': 'End',
      'homePeriodLengthLabel': 'Length: {days} days',
      'homeDaysRemaining': '{days} days remaining',
      'homeCalendarTitle': 'Period Calendar',
      'homeBudgetRemainingLabel': 'Remaining Budget',
      'homeBonusPlaceholder': 'Bonus view is not implemented (placeholder).',
      'expenseAttrFixed': 'Fixed',
      'expenseAttrVariable': 'Variable',
      'expenseAttrBonus': 'Bonus',
      'colorThemeSky': 'Sky',
      'colorThemeLeaf': 'Leaf',
      'colorThemeSunset': 'Sunset',
      'colorThemeBerry': 'Berry',
      'colorThemeSlate': 'Slate',
      'csvExportTitle': 'CSV Export',
      'csvExportPlaceholder': 'CSV export is not implemented (placeholder).',
      'categoryManageTitle': 'Category Management',
      'categoryManagePlaceholder': 'Category management is not implemented (placeholder).',
      'reminderManageTitle': 'Reminders',
      'reminderManagePlaceholder': 'Out of scope for v1 (placeholder).',
      'bonusSettingsTitle': 'Bonus Settings',
      'bonusBudgetTitle': 'Budget',
      'bonusBudgetLabel': 'Period budget (JPY)',
      'bonusBudgetHint': 'e.g. 50000',
      'bonusBudgetNote': 'Default is 50,000 JPY.',
      'bonusBudgetApplyNote': 'Changes apply from the next period.',
      'bonusMonthTitle': 'Bonus Month',
      'bonusMonthLabel': 'Bonus Month',
    },
  };

  String _value(String key) {
    final lang = locale.languageCode;
    return _localizedStrings[lang]?[key] ?? _localizedStrings['ja']?[key] ?? key;
  }

  String _format(String key, Map<String, String> params) {
    var text = _value(key);
    params.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  String get appTitle => _value('appTitle');
  String get navHome => _value('navHome');
  String get navList => _value('navList');
  String get navInput => _value('navInput');
  String get navBreakdown => _value('navBreakdown');
  String get navTrend => _value('navTrend');
  String get settingsTitle => _value('settingsTitle');
  String get displaySection => _value('displaySection');
  String get fontSize => _value('fontSize');
  String get colorTheme => _value('colorTheme');
  String get displayMode => _value('displayMode');
  String get themeSystem => _value('themeSystem');
  String get themeLight => _value('themeLight');
  String get themeDark => _value('themeDark');
  String get language => _value('language');
  String get kakeiboSection => _value('kakeiboSection');
  String get startDate => _value('startDate');
  String get periodLength => _value('periodLength');
  String get periodLength35 => _value('periodLength35');
  String get periodLength42 => _value('periodLength42');
  String get periodChangeNote => _value('periodChangeNote');
  String get accountSection => _value('accountSection');
  String get profileSetting => _value('profileSetting');
  String get dataSharingSetting => _value('dataSharingSetting');
  String get languageSetting => _value('languageSetting');
  String get managementSection => _value('managementSection');
  String get csvExport => _value('csvExport');
  String get categoryManage => _value('categoryManage');
  String get bonusSettings => _value('bonusSettings');
  String get reminderManage => _value('reminderManage');
  String get reminderOutOfScope => _value('reminderOutOfScope');
  String get noCategories => _value('noCategories');
  String get inputTitle => _value('inputTitle');
  String get expenseTab => _value('expenseTab');
  String get incomeTab => _value('incomeTab');
  String get amountLabel => _value('amountLabel');
  String get dateLabel => _value('dateLabel');
  String get memoLabel => _value('memoLabel');
  String get categoryLabel => _value('categoryLabel');
  String get saveExpense => _value('saveExpense');
  String get saveIncome => _value('saveIncome');
  String get validationEnterAmount => _value('validationEnterAmount');
  String get validationSelectCategory => _value('validationSelectCategory');
  String get savedExpense => _value('savedExpense');
  String get savedIncome => _value('savedIncome');
  String get editTitle => _value('editTitle');
  String get typeLabel => _value('typeLabel');
  String get updateButton => _value('updateButton');
  String get updatedMessage => _value('updatedMessage');
  String get validationSelectExpenseAttribute => _value('validationSelectExpenseAttribute');
  String get listTitle => _value('listTitle');
  String get filterAll => _value('filterAll');
  String get filterExpense => _value('filterExpense');
  String get filterIncome => _value('filterIncome');
  String get expenseAttribute => _value('expenseAttribute');
  String get noTransactions => _value('noTransactions');
  String get deleteConfirmTitle => _value('deleteConfirmTitle');
  String get deleteConfirmBody => _value('deleteConfirmBody');
  String get deleteCancel => _value('deleteCancel');
  String get deleteOk => _value('deleteOk');
  String get deletedMessage => _value('deletedMessage');
  String get currencySuffix => _value('currencySuffix');
  String get typeExpense => _value('typeExpense');
  String get typeIncome => _value('typeIncome');
  String get breakdownTitle => _value('breakdownTitle');
  String get breakdownExpenseCategory => _value('breakdownExpenseCategory');
  String get breakdownIncomeCategory => _value('breakdownIncomeCategory');
  String get noData => _value('noData');
  String get trendTitle => _value('trendTitle');
  String get rangeTypePeriod => _value('rangeTypePeriod');
  String get rangeTypeWeek => _value('rangeTypeWeek');
  String get metricBalance => _value('metricBalance');
  String get metricIncome => _value('metricIncome');
  String get metricExpense => _value('metricExpense');
  String get homeTitle => _value('homeTitle');
  String get homeCurrentPeriod => _value('homeCurrentPeriod');
  String get homeStartDate => _value('homeStartDate');
  String get homeEndDate => _value('homeEndDate');
  String get homeCalendarTitle => _value('homeCalendarTitle');
  String get homeBudgetRemainingLabel => _value('homeBudgetRemainingLabel');
  String get homeBonusPlaceholder => _value('homeBonusPlaceholder');
  String get csvExportTitle => _value('csvExportTitle');
  String get csvExportPlaceholder => _value('csvExportPlaceholder');
  String get categoryManageTitle => _value('categoryManageTitle');
  String get categoryManagePlaceholder => _value('categoryManagePlaceholder');
  String get reminderManageTitle => _value('reminderManageTitle');
  String get reminderManagePlaceholder => _value('reminderManagePlaceholder');
  String get bonusSettingsTitle => _value('bonusSettingsTitle');
  String get bonusBudgetTitle => _value('bonusBudgetTitle');
  String get bonusBudgetLabel => _value('bonusBudgetLabel');
  String get bonusBudgetHint => _value('bonusBudgetHint');
  String get bonusBudgetNote => _value('bonusBudgetNote');
  String get bonusBudgetApplyNote => _value('bonusBudgetApplyNote');
  String get bonusMonthTitle => _value('bonusMonthTitle');
  String get bonusMonthLabel => _value('bonusMonthLabel');

  String notImplemented(String label) => _format('notImplemented', {'label': label});
  String errorMessage(Object error) => _format('errorMessage', {'error': error.toString()});

  String categoryFallback(int id) => _format('categoryFallback', {'id': id.toString()});

  String trendTargetPeriod(String start, String end) =>
      _format('trendTargetPeriod', {'start': start, 'end': end});

  String trendCountLabel(int count) => _format('trendCountLabel', {'count': count.toString()});

  String homePeriodLengthLabel(int days) =>
      _format('homePeriodLengthLabel', {'days': days.toString()});

  String homeDaysRemaining(int days) =>
      _format('homeDaysRemaining', {'days': days.toString()});

  String languageLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.japanese:
        return _value('languageJapanese');
      case AppLanguage.english:
        return _value('languageEnglish');
    }
  }

  String colorThemeLabel(AppColorTheme theme) {
    switch (theme) {
      case AppColorTheme.sky:
        return _value('colorThemeSky');
      case AppColorTheme.leaf:
        return _value('colorThemeLeaf');
      case AppColorTheme.sunset:
        return _value('colorThemeSunset');
      case AppColorTheme.berry:
        return _value('colorThemeBerry');
      case AppColorTheme.slate:
        return _value('colorThemeSlate');
    }
  }

  String expenseAttributeLabel(ExpenseAttribute attr) {
    switch (attr) {
      case ExpenseAttribute.fixed:
        return _value('expenseAttrFixed');
      case ExpenseAttribute.variable:
        return _value('expenseAttrVariable');
      case ExpenseAttribute.bonus:
        return _value('expenseAttrBonus');
    }
  }

  String get rangeSeparator => locale.languageCode == 'ja' ? ' ～ ' : ' - ';

  String formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  String formatShortDate(DateTime d) => '${d.month}/${d.day}';

  String formatLongDate(DateTime d) {
    if (locale.languageCode == 'ja') {
      return '${d.year}年${d.month}月${d.day}日';
    }
    return formatDate(d);
  }

  String formatMonth(int month) {
    if (locale.languageCode == 'ja') {
      return '${month}月';
    }
    return 'Month $month';
  }

  String formatCurrency(int amount) {
    if (locale.languageCode == 'ja') {
      return '$amount 円';
    }
    return '$amount JPY';
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ja' || locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
