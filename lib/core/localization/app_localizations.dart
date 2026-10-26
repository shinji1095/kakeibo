import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
      'periodLength': '期間の長さ（35/7日）',
      'periodLength35': '35日',
      'periodLength42': '7日',
      'periodChangeNote': '設定変更は以後の期間から適用されます',
      'accountSection': 'アカウント',
      'profileSetting': 'プロフィール設定',
      'dataSharingSetting': 'データ共有設定',
      'languageSetting': '言語設定',
      'managementSection': '管理',
      'csvExport': 'CSVエクスポート',
      'categoryManage': 'カテゴリ管理',
      'budgetSettings': 'やりくり費設定',
      'budgetSettingsTitle': 'やりくり費設定',
      'budgetBackButton': '戻る',
      'budgetSaveButton': 'やりくり費保存',
      'budgetSavedMessage': 'やりくり費を保存しました',
      'bonusSettings': 'ボーナス設定',
      'annualSchedule': '年間スケジュール',
      'annualScheduleYear': '{year}年スケジュール',
      'annualScheduleStartDate': '開始日: {date}',
      'annualSchedulePeriodCount': '期間数: {count}',
      'annualScheduleTotalDays': '合計日数: {days}日',
      'annualSchedulePeriodSelectionCount': '{days}日 {current} / {expected}',
      'annualScheduleCountMismatchWarning':
          '35日/7日の選択数が不足しています。年間スケジュールを確認してください。',
      'annualScheduleRegenerate': '自動生成',
      'annualScheduleListTitle': '期間一覧',
      'annualSchedulePeriodLabel': '{index}期: {range}',
      'annualSchedulePeriodIndex': '{index}期',
      'annualSchedulePeriodDays': '{days}日',
      'annualScheduleMissing': '年間スケジュールを取得できません。',
      'annualScheduleBasics': '基本設定',
      'annualStartWeekday': '開始する曜日',
      'annualBasicStartHelp': '開始日: {date}',
      'annualBasicCustomActive': '詳細設定が適用されています。基本設定に戻すと固定配分で再計算します。',
      'annualBasicReset': '基本設定に戻す',
      'annualAdvancedTitle': '詳細設定',
      'annualAdvancedHelp': '家計簿の開始日、ボーナス月とそのやりくり期間、6週目を設ける月を変更できます。',
      'annualAdvancedHelpTooltip': '詳細設定の説明',
      'annualSelectYear': '年を選択',
      'annualClose': '閉じる',
      'annualBudgetHelp': '各通常期の目標額に適用します',
      'annualBudgetUnit': '円/月',
      'annualBonusHelp': '0週は暦月、1週は7日間にする期を選びます。',
      'annualBonusWeeks': '集計する週',
      'annualSixWeekTitle': '6週にする月',
      'annualSixWeekHelp':
          '6週目を設ける月を選択（必要数: {count}）。0週のボーナス月が2つなら、選択したうち期番号が最も大きい期の6週目は1日または2日です。実際の日付は下で確認できます。',
      'annualPreviewTitle': '期間の確認',
      'annualPreviewSaved': '設定を整えると変更後の期間を表示します。現在の保存内容を表示中です。',
      'annualWeeks': '{count}週',
      'annualBonusTag': 'ボーナス',
      'annualWeekOfMonth': '第{week}週から',
      'annualZeroWeekDate': '{date}（第{week}週から・集計0週）',
      'annualScheduleSaved': '年間スケジュールを保存しました',
      'annualNeighborWarning': '前後の年間スケジュールと日付が連続しません。隣接年の開始日も確認してください。',
      'annualChooseBonus': 'ボーナス設定（年2回）',
      'annualZeroMonthHelp': '独立したボーナス期を設けない暦月を選択',
      'annualZeroMonthSummary': '{month}は0週。独立したボーナス期はありません。',
      'annualOnePeriodHelp': '1週にする期を選択',
      'annualChoosePeriod': '7日間のボーナス期間にする期',
      'annualPeriodUnavailable': 'この期は他のボーナス設定と両立しません',
      'annualOnePeriodDate': '{start} ～ {end}・第{week}週から',
      'annualBoundaryHelp': '各月の最初の期間境界から始まります。',
      'annualBoundaryInvalid':
          'この組み合わせでは年間365日／366日にできません。開始日やボーナス期、6週にする月を変更してください。',
      'annualBoundaryDate': '{date}・第{week}週から',
      'annualUnsavedBadge': '未保存の変更があります',
      'annualReplaceMonthTitle': '{month}に変更する月を選択',
      'annualReplaceMonth': '{month}と入れ替える',
      'annualBudgetError': 'やりくり費は1円以上で入力してください',
      'annualSixWeekRequired': '6週目を設ける通常期を{count}期選んでください',
      'annualSixUnavailable': 'この月に始まる6週の通常期は選択できません',
      'annualSixCandidate': '{start} ～ {end}（変更後）',
      'annualTimelineSummary': '{count}期',
      'annualWeeksExtra': '{weeks}週＋{extra}',
      'annualPartialSixWeeks': '5週＋{extra}（6週目・計{days}日）',
      'annualZeroBoundary': '{date}に境界',
      'annualNoCollection': '集計なし',
      'annualSaveThis': 'この内容で設定',
      'annualStartDateColumn': '開始日',
      'annualEndDateColumn': '終了日',
      'annualUnsavedTitle': '未保存の変更があります',
      'annualUnsavedMessage': '年を切り替える前に変更を保存しますか？',
      'annualDiscard': '破棄して移動',
      'annualSaveAndContinue': '保存して移動',
      'previousYear': '前年',
      'nextYear': '翌年',
      'bonusSummaryTitle': 'ボーナス月',
      'bonusBalanceLabel': 'ボーナス残高',
      'bonusExpenseTotalLabel': 'ボーナス支出合計',
      'bonusMonthInactive': '今月はボーナス月ではありません',
      'categoryTabExpense': '支出カテゴリ',
      'categoryTabIncome': '収入カテゴリ',
      'categoryAddTitle': 'カテゴリを追加',
      'categoryEditTitle': 'カテゴリを編集',
      'categoryNameLabel': 'カテゴリ名',
      'categoryColorLabel': 'カラー',
      'categoryNameRequired': 'カテゴリ名を入力してください',
      'categoryDeleteTitle': 'カテゴリ削除',
      'categoryDeleteBody': '{name} を削除しますか？',
      'categoryDeleteProtected': 'このカテゴリは削除できません',
      'categoryProtectedLabel': '固定カテゴリ',
      'dialogCancel': 'キャンセル',
      'dialogApply': '設定',
      'dialogSave': '保存',
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
      'trendTargetPeriod': '期間: {start} ～ {end}',
      'rangeTypePeriod': '期間',
      'rangeTypeWeek': '週別',
      'metricBalance': '収支',
      'metricIncome': '収入',
      'metricExpense': '支出',
      'trendCountLabel': '表示期間: {count}',
      'trendVisibleStart': '表示開始',
      'trendVisibleEnd': '表示終了',
      'trendShowAmounts': '金額表示',
      'rangeBasisTitle': '表示期間',
      'rangeBasisPeriod': '期間ごと',
      'rangeBasisMonth': '月ごと',
      'dialogOk': 'OK',
      'homeTitle': 'ホーム',
      'homeDescription':
          '固定費・特別費は暦月で管理し、やりくり費は35日/7日の期間で管理する家計簿です。7日の期間はボーナス月として扱います。',
      'homeCurrentPeriod': '現在の期間',
      'homeSelectedPeriod': '選択中の期間',
      'homePeriodsTitle': 'やりくり期間',
      'homeModePeriod': '期間',
      'homeModeMonth': '暦月',
      'homeBudgetTitle': '予算',
      'homeMonthlyIncomeLabel': '月収',
      'homeVariableTotalLabel': 'やりくり費',
      'homeFixedExpensesLabel': '固定費',
      'homeSpecialExpensesLabel': '特別費',
      'homeIncomeLabel': '収入',
      'homeFixedSpecialLabel': '固定費・特別費',
      'homeBudgetLabel': 'やりくり費',
      'homePeriodLabel': '{index}期',
      'homeStartDate': '開始日',
      'homeEndDate': '終了日',
      'homePeriodLengthLabel': '期間長: {days}日',
      'homeCalendarTitle': 'カレンダー',
      'homeGoToToday': '今日に戻る',
      'homePeriodColorsLabel': '期間の色分け',
      'homePeriodColorsOn': '期間の色分け：ON',
      'homePeriodColorsOff': '期間の色分け：OFF',
      'homeMonthColorsLabel': '月の色分け',
      'homeMonthColorsOn': '月の色分け：ON',
      'homeMonthColorsOff': '月の色分け：OFF',
      'homeCountdownPrefix': 'あと',
      'homeCountdownDays': '{days}日',
      'homeProgressSpent': '支出 {amount}',
      'homeRemainingLabel': '残り',
      'homeBudgetUnitWeek': '週',
      'homeBudgetUnitMonth': '月',
      'homeWeeklyBudgetOver': '週の目安を{amount}超過',
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
      'csvRangeTitle': '出力期間',
      'csvStartDateLabel': '開始日',
      'csvEndDateLabel': '終了日',
      'csvExportButton': 'CSVを保存',
      'csvExporting': '出力中...',
      'csvShareButton': 'CSVを共有',
      'csvShareWarningTitle': 'CSV共有の注意',
      'csvShareWarningBody': 'CSV共有は外部アプリに渡る可能性があります。続行しますか？',
      'csvShareConfirm': '共有する',
      'csvSavedMessage': 'CSVを保存しました: {path}',
      'csvInvalidRange': '開始日と終了日を確認してください',
      'csvFilePathLabel': '保存先',
      'csvExportUnavailable': 'CSV出力が利用できません',
      'csvColumnDate': '日付',
      'csvColumnCategory': 'カテゴリ',
      'csvColumnType': '収支',
      'csvColumnAmount': '金額',
      'csvColumnAttribute': '属性',
      'categoryManageTitle': 'カテゴリ管理',
      'categoryManagePlaceholder': 'カテゴリ管理は未実装です（プレースホルダー）。',
      'annualScheduleTitle': '年間スケジュール',
      'annualSchedulePlaceholder': '年間スケジュールは未実装です（プレースホルダー）。',
      'bonusExpenseTitle': 'ボーナス支出',
      'bonusExpenseAmountLabel': 'ボーナス支出額（円）',
      'bonusExpenseSave': 'ボーナス支出を保存',
      'bonusExpenseSaved': 'ボーナス支出を保存しました',
      'bonusExpenseMissingCategory': 'ボーナス支出カテゴリが見つかりません。',
      'bonusExpenseCategoryName': 'ボーナス支出',
      'noBonusMonths': 'ボーナス月はありません',
      'reminderManageTitle': 'リマインダー管理',
      'reminderManagePlaceholder': '初期リリース対象外のため未実装です（プレースホルダー）。',
      'bonusSettingsTitle': 'ボーナス設定',
      'bonusBudgetTitle': 'やりくり費',
      'bonusBudgetLabel': '目標：やりくり費',
      'bonusBudgetHint': '例: 50000',
      'bonusBudgetNote': 'デフォルトは50,000円です',
      'bonusBudgetApplyNote': '設定変更は以後の期間から適用されます',
      'bonusMonthTitle': 'ボーナス月',
      'bonusMonthLabel': 'ボーナス月',
      'bonusMonthToggleTitle': 'ボーナス月の切替',
      'bonusMonthToggleOn': 'ボーナス月にする',
      'bonusMonthToggleOff': 'ボーナス月にしない',
      'bonusMonthSwapTitle': 'ボーナス月の設定',
      'bonusMonthPrimary': 'ボーナス設定1',
      'bonusMonthSecondary': 'ボーナス設定2',
      'bonusMonthSwapOption': '{from}をボーナス月から外す',
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
      'periodLength': 'Period Length (35/7 days)',
      'periodLength35': '35 days',
      'periodLength42': '7 days',
      'periodChangeNote': 'Changes apply from the next period.',
      'accountSection': 'Account',
      'profileSetting': 'Profile',
      'dataSharingSetting': 'Data Sharing',
      'languageSetting': 'Language',
      'managementSection': 'Management',
      'csvExport': 'CSV Export',
      'categoryManage': 'Category Management',
      'budgetSettings': 'Budget Settings',
      'budgetSettingsTitle': 'Budget Settings',
      'budgetBackButton': 'Back',
      'budgetSaveButton': 'Save Budget',
      'budgetSavedMessage': 'Budget saved.',
      'bonusSettings': 'Bonus Settings',
      'annualSchedule': 'Annual Schedule',
      'annualScheduleYear': '{year} Schedule',
      'annualScheduleStartDate': 'Start: {date}',
      'annualSchedulePeriodCount': 'Periods: {count}',
      'annualScheduleTotalDays': 'Total Days: {days}',
      'annualSchedulePeriodSelectionCount':
          '{days} days {current} / {expected}',
      'annualScheduleCountMismatchWarning':
          'Update the 35/7-day counts before returning home.',
      'annualScheduleRegenerate': 'Regenerate',
      'annualScheduleListTitle': 'Period List',
      'annualSchedulePeriodLabel': 'Period {index}: {range}',
      'annualSchedulePeriodIndex': 'P{index}',
      'annualSchedulePeriodDays': '{days} days',
      'annualScheduleMissing': 'Unable to load annual schedule.',
      'bonusSummaryTitle': 'Bonus Month',
      'bonusBalanceLabel': 'Bonus Balance',
      'bonusExpenseTotalLabel': 'Bonus Expense Total',
      'bonusMonthInactive': 'Not a bonus month.',
      'categoryTabExpense': 'Expense Categories',
      'categoryTabIncome': 'Income Categories',
      'categoryAddTitle': 'Add Category',
      'categoryEditTitle': 'Edit Category',
      'categoryNameLabel': 'Category Name',
      'categoryColorLabel': 'Color',
      'categoryNameRequired': 'Enter a category name.',
      'categoryDeleteTitle': 'Delete Category',
      'categoryDeleteBody': 'Delete {name}?',
      'categoryDeleteProtected': 'This category cannot be deleted.',
      'categoryProtectedLabel': 'Protected category',
      'dialogCancel': 'Cancel',
      'dialogApply': 'Apply',
      'dialogSave': 'Save',
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
      'trendVisibleStart': 'Display Start',
      'trendVisibleEnd': 'Display End',
      'trendShowAmounts': 'Show amounts',
      'rangeBasisTitle': 'Range Basis',
      'rangeBasisPeriod': 'By Period',
      'rangeBasisMonth': 'By Month',
      'dialogOk': 'OK',
      'homeTitle': 'Home',
      'homeDescription':
          'Fixed/special expenses are managed monthly, and the discretionary budget is managed in 35/7-day periods. The 7-day periods are treated as bonus months.',
      'homeCurrentPeriod': 'Current Period',
      'homeSelectedPeriod': 'Selected period',
      'homePeriodsTitle': 'Budget Periods',
      'homeModePeriod': 'Period',
      'homeModeMonth': 'Month',
      'homeBudgetTitle': 'Budget',
      'homeMonthlyIncomeLabel': 'Monthly income',
      'homeVariableTotalLabel': 'Discretionary spending',
      'homeFixedExpensesLabel': 'Fixed expenses',
      'homeSpecialExpensesLabel': 'Special expenses',
      'homeIncomeLabel': 'Income',
      'homeFixedSpecialLabel': 'Fixed/Special',
      'homeBudgetLabel': 'Budget',
      'homePeriodLabel': 'Period {index}',
      'homeStartDate': 'Start',
      'homeEndDate': 'End',
      'homePeriodLengthLabel': 'Length: {days} days',
      'homeCalendarTitle': 'Calendar',
      'homeGoToToday': 'Go to today',
      'homePeriodColorsLabel': 'Period colors',
      'homePeriodColorsOn': 'Period colors: ON',
      'homePeriodColorsOff': 'Period colors: OFF',
      'homeMonthColorsLabel': 'Month colors',
      'homeMonthColorsOn': 'Month colors: ON',
      'homeMonthColorsOff': 'Month colors: OFF',
      'homeCountdownPrefix': 'Ends in',
      'homeCountdownDays': '{days} days',
      'homeProgressSpent': 'Spent {amount}',
      'homeRemainingLabel': 'Remaining',
      'homeBudgetUnitWeek': 'week',
      'homeBudgetUnitMonth': 'month',
      'homeWeeklyBudgetOver': '{amount} over weekly target',
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
      'csvRangeTitle': 'Export Range',
      'csvStartDateLabel': 'Start Date',
      'csvEndDateLabel': 'End Date',
      'csvExportButton': 'Save CSV',
      'csvExporting': 'Exporting...',
      'csvShareButton': 'Share CSV',
      'csvShareWarningTitle': 'Share Warning',
      'csvShareWarningBody':
          'CSV data may be shared with other apps. Continue?',
      'csvShareConfirm': 'Share',
      'csvSavedMessage': 'CSV saved: {path}',
      'csvInvalidRange': 'Check the start and end dates.',
      'csvFilePathLabel': 'Saved Path',
      'csvExportUnavailable': 'CSV export is not available.',
      'csvColumnDate': 'Date',
      'csvColumnCategory': 'Category',
      'csvColumnType': 'Type',
      'csvColumnAmount': 'Amount',
      'csvColumnAttribute': 'Attribute',
      'categoryManageTitle': 'Category Management',
      'categoryManagePlaceholder':
          'Category management is not implemented (placeholder).',
      'annualScheduleTitle': 'Annual Schedule',
      'annualScheduleBasics': 'Basic settings',
      'annualStartWeekday': 'Starting weekday',
      'annualBasicStartHelp': 'Start date: {date}',
      'annualBasicCustomActive':
          'Advanced settings are active. Reset to basic settings to recalculate the fixed schedule.',
      'annualBasicReset': 'Reset to basic settings',
      'annualAdvancedTitle': 'Advanced settings',
      'annualAdvancedHelp':
          'Change the ledger start date, bonus months and their spending periods, and the periods with a sixth week.',
      'annualAdvancedHelpTooltip': 'About advanced settings',
      'annualSelectYear': 'Select year',
      'annualClose': 'Close',
      'annualBudgetHelp': 'Applied as the target for each regular period',
      'annualBudgetUnit': 'JPY/month',
      'annualBonusHelp':
          'Choose a calendar month for zero weeks, or a seven-day period for one week.',
      'annualBonusWeeks': 'Weeks counted',
      'annualSixWeekTitle': 'Six-week months',
      'annualSixWeekHelp':
          'Choose periods with a sixth week ({count} needed). With two zero-week bonus months, the selected period with the highest number has only one or two days in its sixth week. Check actual dates below.',
      'annualPreviewTitle': 'Review periods',
      'annualPreviewSaved':
          'Complete the settings to preview the changes. Showing saved periods.',
      'annualWeeks': '{count} weeks',
      'annualBonusTag': 'Bonus',
      'annualWeekOfMonth': 'from week {week}',
      'annualZeroWeekDate': '{date} (week {week}, zero weeks counted)',
      'annualScheduleSaved': 'Annual schedule saved.',
      'annualNeighborWarning':
          'This schedule does not meet the adjacent year. Check the neighboring start dates.',
      'annualChooseBonus': 'Bonus settings (twice a year)',
      'annualZeroMonthHelp':
          'Choose a calendar month without a separate bonus period',
      'annualZeroMonthSummary':
          '{month} has zero weeks and no separate bonus period.',
      'annualOnePeriodHelp': 'Choose the one-week period',
      'annualChoosePeriod': 'Choose the seven-day bonus period',
      'annualPeriodUnavailable':
          'This period conflicts with the other bonus setting',
      'annualOnePeriodDate': '{start} - {end} · from week {week}',
      'annualBoundaryHelp':
          'Each bonus month starts at its first period boundary.',
      'annualBoundaryInvalid':
          'This combination cannot cover 365 or 366 days. Change the start date, bonus period, or six-week month.',
      'annualBoundaryDate': '{date} · from week {week}',
      'annualUnsavedBadge': 'Unsaved changes',
      'annualReplaceMonthTitle': 'Which month should {month} replace?',
      'annualReplaceMonth': 'Replace {month}',
      'annualBudgetError': 'Enter a budget of at least 1 JPY.',
      'annualSixWeekRequired':
          'Choose {count} regular periods to make six weeks.',
      'annualSixUnavailable':
          'No selectable six-week period starts in this month.',
      'annualSixCandidate': '{start} - {end} (after change)',
      'annualTimelineSummary': '{count} periods',
      'annualWeeksExtra': '{weeks} weeks + {extra}',
      'annualPartialSixWeeks': '5 weeks + {extra} (week 6, {days} days total)',
      'annualZeroBoundary': 'Boundary on {date}',
      'annualNoCollection': 'No weeks counted',
      'annualSaveThis': 'Apply these settings',
      'annualStartDateColumn': 'Start date',
      'annualEndDateColumn': 'End date',
      'annualUnsavedTitle': 'Unsaved changes',
      'annualUnsavedMessage': 'Save your changes before switching years?',
      'annualDiscard': 'Discard and switch',
      'annualSaveAndContinue': 'Save and switch',
      'previousYear': 'Previous year',
      'nextYear': 'Next year',
      'annualSchedulePlaceholder':
          'Annual schedule is not implemented (placeholder).',
      'bonusExpenseTitle': 'Bonus Expense',
      'bonusExpenseAmountLabel': 'Bonus expense (JPY)',
      'bonusExpenseSave': 'Save Bonus Expense',
      'bonusExpenseSaved': 'Bonus expense saved.',
      'bonusExpenseMissingCategory': 'Bonus category is missing.',
      'bonusExpenseCategoryName': 'ボーナス支出',
      'noBonusMonths': 'No bonus months.',
      'reminderManageTitle': 'Reminders',
      'reminderManagePlaceholder': 'Out of scope for v1 (placeholder).',
      'bonusSettingsTitle': 'Bonus Settings',
      'bonusBudgetTitle': 'Budget',
      'bonusBudgetLabel': 'Target: variable spending',
      'bonusBudgetHint': 'e.g. 50000',
      'bonusBudgetNote': 'Default is 50,000 JPY.',
      'bonusBudgetApplyNote': 'Changes apply from the next period.',
      'bonusMonthTitle': 'Bonus Month',
      'bonusMonthLabel': 'Bonus Month',
      'bonusMonthToggleTitle': 'Bonus Month',
      'bonusMonthToggleOn': 'Set as bonus month',
      'bonusMonthToggleOff': 'Remove bonus month',
      'bonusMonthSwapTitle': 'Set Bonus Months',
      'bonusMonthPrimary': 'Bonus 1',
      'bonusMonthSecondary': 'Bonus 2',
      'bonusMonthSwapOption': 'Remove {from} from bonus months',
    },
  };

  String _value(String key) {
    final lang = locale.languageCode;
    return _localizedStrings[lang]?[key] ??
        _localizedStrings['ja']?[key] ??
        key;
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
  String get budgetSettings => _value('budgetSettings');
  String get budgetSettingsTitle => _value('budgetSettingsTitle');
  String get budgetBackButton => _value('budgetBackButton');
  String get budgetSaveButton => _value('budgetSaveButton');
  String get budgetSavedMessage => _value('budgetSavedMessage');
  String get bonusSettings => _value('bonusSettings');
  String get annualSchedule => _value('annualSchedule');
  String get annualScheduleRegenerate => _value('annualScheduleRegenerate');
  String get annualScheduleCountMismatchWarning =>
      _value('annualScheduleCountMismatchWarning');
  String get annualScheduleListTitle => _value('annualScheduleListTitle');
  String get annualScheduleMissing => _value('annualScheduleMissing');
  String get annualScheduleBasics => _value('annualScheduleBasics');
  String get annualStartWeekday => _value('annualStartWeekday');
  String get annualBasicCustomActive => _value('annualBasicCustomActive');
  String get annualBasicReset => _value('annualBasicReset');
  String get annualAdvancedTitle => _value('annualAdvancedTitle');
  String get annualAdvancedHelp => _value('annualAdvancedHelp');
  String get annualAdvancedHelpTooltip => _value('annualAdvancedHelpTooltip');
  String get annualSelectYear => _value('annualSelectYear');
  String get annualClose => _value('annualClose');
  String get annualBudgetHelp => _value('annualBudgetHelp');
  String get annualBudgetUnit => _value('annualBudgetUnit');
  String get annualBonusHelp => _value('annualBonusHelp');
  String get annualBonusWeeks => _value('annualBonusWeeks');
  String get annualSixWeekTitle => _value('annualSixWeekTitle');
  String get annualPreviewTitle => _value('annualPreviewTitle');
  String get annualPreviewSaved => _value('annualPreviewSaved');
  String get annualBonusTag => _value('annualBonusTag');
  String get annualScheduleSaved => _value('annualScheduleSaved');
  String get annualNeighborWarning => _value('annualNeighborWarning');
  String get annualChooseBonus => _value('annualChooseBonus');
  String get annualZeroMonthHelp => _value('annualZeroMonthHelp');
  String get annualOnePeriodHelp => _value('annualOnePeriodHelp');
  String get annualChoosePeriod => _value('annualChoosePeriod');
  String get annualPeriodUnavailable => _value('annualPeriodUnavailable');
  String get annualBoundaryHelp => _value('annualBoundaryHelp');
  String get annualBoundaryInvalid => _value('annualBoundaryInvalid');
  String get annualUnsavedBadge => _value('annualUnsavedBadge');
  String get annualBudgetError => _value('annualBudgetError');
  String get annualSixUnavailable => _value('annualSixUnavailable');
  String get annualNoCollection => _value('annualNoCollection');
  String get annualSaveThis => _value('annualSaveThis');
  String get annualStartDateColumn => _value('annualStartDateColumn');
  String get annualEndDateColumn => _value('annualEndDateColumn');
  String get annualUnsavedTitle => _value('annualUnsavedTitle');
  String get annualUnsavedMessage => _value('annualUnsavedMessage');
  String get annualDiscard => _value('annualDiscard');
  String get annualSaveAndContinue => _value('annualSaveAndContinue');
  String get previousYear => _value('previousYear');
  String get nextYear => _value('nextYear');
  String get bonusSummaryTitle => _value('bonusSummaryTitle');
  String get bonusBalanceLabel => _value('bonusBalanceLabel');
  String get bonusExpenseTotalLabel => _value('bonusExpenseTotalLabel');
  String get bonusMonthInactive => _value('bonusMonthInactive');
  String get categoryTabExpense => _value('categoryTabExpense');
  String get categoryTabIncome => _value('categoryTabIncome');
  String get categoryAddTitle => _value('categoryAddTitle');
  String get categoryEditTitle => _value('categoryEditTitle');
  String get categoryNameLabel => _value('categoryNameLabel');
  String get categoryColorLabel => _value('categoryColorLabel');
  String get categoryNameRequired => _value('categoryNameRequired');
  String get categoryDeleteTitle => _value('categoryDeleteTitle');
  String get categoryDeleteProtected => _value('categoryDeleteProtected');
  String get categoryProtectedLabel => _value('categoryProtectedLabel');
  String get dialogCancel => _value('dialogCancel');
  String get dialogApply => _value('dialogApply');
  String get dialogSave => _value('dialogSave');
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
  String get validationSelectExpenseAttribute =>
      _value('validationSelectExpenseAttribute');
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
  String get trendShowAmounts => _value('trendShowAmounts');
  String get trendVisibleStart => _value('trendVisibleStart');
  String get trendVisibleEnd => _value('trendVisibleEnd');
  String get rangeBasisTitle => _value('rangeBasisTitle');
  String get rangeBasisPeriod => _value('rangeBasisPeriod');
  String get rangeBasisMonth => _value('rangeBasisMonth');
  String get dialogOk => _value('dialogOk');
  String get homeTitle => _value('homeTitle');
  String get homeDescription => _value('homeDescription');
  String get homeCurrentPeriod => _value('homeCurrentPeriod');
  String get homeSelectedPeriod => _value('homeSelectedPeriod');
  String get homePeriodsTitle => _value('homePeriodsTitle');
  String get homeBudgetTitle => _value('homeBudgetTitle');
  String get homeModePeriod => _value('homeModePeriod');
  String get homeModeMonth => _value('homeModeMonth');
  String get homeMonthlyIncomeLabel => _value('homeMonthlyIncomeLabel');
  String get homeVariableTotalLabel => _value('homeVariableTotalLabel');
  String get homeFixedExpensesLabel => _value('homeFixedExpensesLabel');
  String get homeSpecialExpensesLabel => _value('homeSpecialExpensesLabel');
  String get homeIncomeLabel => _value('homeIncomeLabel');
  String get homeFixedSpecialLabel => _value('homeFixedSpecialLabel');
  String get homeBudgetLabel => _value('homeBudgetLabel');
  String get homeStartDate => _value('homeStartDate');
  String get homeEndDate => _value('homeEndDate');
  String get homeCalendarTitle => _value('homeCalendarTitle');
  String get homeGoToToday => _value('homeGoToToday');
  String get homePeriodColorsLabel => _value('homePeriodColorsLabel');
  String get homePeriodColorsOn => _value('homePeriodColorsOn');
  String get homePeriodColorsOff => _value('homePeriodColorsOff');
  String get homeMonthColorsLabel => _value('homeMonthColorsLabel');
  String get homeMonthColorsOn => _value('homeMonthColorsOn');
  String get homeMonthColorsOff => _value('homeMonthColorsOff');
  String get homeCountdownPrefix => _value('homeCountdownPrefix');
  String get homeRemainingLabel => _value('homeRemainingLabel');
  String get homeBudgetUnitWeek => _value('homeBudgetUnitWeek');
  String get homeBudgetUnitMonth => _value('homeBudgetUnitMonth');
  String get homeBonusPlaceholder => _value('homeBonusPlaceholder');
  String get csvExportTitle => _value('csvExportTitle');
  String get csvExportPlaceholder => _value('csvExportPlaceholder');
  String get csvRangeTitle => _value('csvRangeTitle');
  String get csvStartDateLabel => _value('csvStartDateLabel');
  String get csvEndDateLabel => _value('csvEndDateLabel');
  String get csvExportButton => _value('csvExportButton');
  String get csvExporting => _value('csvExporting');
  String get csvShareButton => _value('csvShareButton');
  String get csvShareWarningTitle => _value('csvShareWarningTitle');
  String get csvShareWarningBody => _value('csvShareWarningBody');
  String get csvShareConfirm => _value('csvShareConfirm');
  String get csvInvalidRange => _value('csvInvalidRange');
  String get csvFilePathLabel => _value('csvFilePathLabel');
  String get csvExportUnavailable => _value('csvExportUnavailable');
  String get csvColumnDate => _value('csvColumnDate');
  String get csvColumnCategory => _value('csvColumnCategory');
  String get csvColumnType => _value('csvColumnType');
  String get csvColumnAmount => _value('csvColumnAmount');
  String get csvColumnAttribute => _value('csvColumnAttribute');
  String get categoryManageTitle => _value('categoryManageTitle');
  String get categoryManagePlaceholder => _value('categoryManagePlaceholder');
  String get annualScheduleTitle => _value('annualScheduleTitle');
  String get annualSchedulePlaceholder => _value('annualSchedulePlaceholder');
  String get bonusExpenseTitle => _value('bonusExpenseTitle');
  String get bonusExpenseAmountLabel => _value('bonusExpenseAmountLabel');
  String get bonusExpenseSave => _value('bonusExpenseSave');
  String get bonusExpenseSaved => _value('bonusExpenseSaved');
  String get bonusExpenseMissingCategory =>
      _value('bonusExpenseMissingCategory');
  String get bonusExpenseCategoryName => _value('bonusExpenseCategoryName');
  String get noBonusMonths => _value('noBonusMonths');
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
  String get bonusMonthToggleTitle => _value('bonusMonthToggleTitle');
  String get bonusMonthToggleOn => _value('bonusMonthToggleOn');
  String get bonusMonthToggleOff => _value('bonusMonthToggleOff');
  String get bonusMonthSwapTitle => _value('bonusMonthSwapTitle');
  String get bonusMonthPrimary => _value('bonusMonthPrimary');
  String get bonusMonthSecondary => _value('bonusMonthSecondary');

  String notImplemented(String label) =>
      _format('notImplemented', {'label': label});
  String errorMessage(Object error) =>
      _format('errorMessage', {'error': error.toString()});

  String categoryFallback(int id) =>
      _format('categoryFallback', {'id': id.toString()});

  String trendTargetPeriod(String start, String end) =>
      _format('trendTargetPeriod', {'start': start, 'end': end});

  String trendCountLabel(int count) =>
      _format('trendCountLabel', {'count': count.toString()});

  String categoryDeleteBody(String name) =>
      _format('categoryDeleteBody', {'name': name});

  String csvSavedMessage(String path) =>
      _format('csvSavedMessage', {'path': path});

  String annualScheduleYear(int year) =>
      _format('annualScheduleYear', {'year': year.toString()});

  String annualBasicStartHelp(String date) =>
      _format('annualBasicStartHelp', {'date': date});

  String annualZeroMonthSummary(String month) =>
      _format('annualZeroMonthSummary', {'month': month});

  String annualTimelineSummary(int count) =>
      _format('annualTimelineSummary', {'count': count.toString()});

  String annualWeeksExtra(int weeks, int extra) => _format('annualWeeksExtra',
      {'weeks': weeks.toString(), 'extra': _extraDays(extra)});

  String annualPartialSixWeeks(int extra, int days) =>
      _format('annualPartialSixWeeks', {
        'extra': _extraDays(extra),
        'days': days.toString(),
      });

  String annualSixWeekHelp(int count) =>
      _format('annualSixWeekHelp', {'count': count.toString()});

  String annualWeeks(int count) =>
      _format('annualWeeks', {'count': count.toString()});

  String annualZeroWeekDate(String date, int week) =>
      _format('annualZeroWeekDate', {'date': date, 'week': week.toString()});

  String annualWeekOfMonth(int week) =>
      _format('annualWeekOfMonth', {'week': week.toString()});

  String annualBoundaryDate(String date, int week) =>
      _format('annualBoundaryDate', {'date': date, 'week': week.toString()});

  String annualOnePeriodDate(String start, String end, int week) =>
      _format('annualOnePeriodDate', {
        'start': start,
        'end': end,
        'week': week.toString(),
      });

  String _extraDays(int count) => locale.languageCode == 'ja'
      ? '$count日'
      : '$count ${count == 1 ? 'day' : 'days'}';

  String annualReplaceMonthTitle(String month) =>
      _format('annualReplaceMonthTitle', {'month': month});

  String annualReplaceMonth(String month) =>
      _format('annualReplaceMonth', {'month': month});

  String annualSixWeekRequired(int count) =>
      _format('annualSixWeekRequired', {'count': count.toString()});

  String annualSixCandidate(String start, String end) =>
      _format('annualSixCandidate', {'start': start, 'end': end});

  String annualZeroBoundary(String date) =>
      _format('annualZeroBoundary', {'date': date});

  String annualScheduleStartDate(String date) =>
      _format('annualScheduleStartDate', {'date': date});

  String annualSchedulePeriodCount(int count) =>
      _format('annualSchedulePeriodCount', {'count': count.toString()});

  String annualScheduleTotalDays(int days) =>
      _format('annualScheduleTotalDays', {'days': days.toString()});

  String annualSchedulePeriodSelectionCount(
          int days, int current, int expected) =>
      _format(
        'annualSchedulePeriodSelectionCount',
        {
          'days': days.toString(),
          'current': current.toString(),
          'expected': expected.toString(),
        },
      );

  String annualSchedulePeriodLabel(int index, String range) => _format(
        'annualSchedulePeriodLabel',
        {'index': index.toString(), 'range': range},
      );

  String annualSchedulePeriodIndex(int index) =>
      _format('annualSchedulePeriodIndex', {'index': index.toString()});

  String bonusMonthSwapOption(String from) =>
      _format('bonusMonthSwapOption', {'from': from});

  String annualSchedulePeriodDays(int days) =>
      _format('annualSchedulePeriodDays', {'days': days.toString()});

  String homePeriodLengthLabel(int days) =>
      _format('homePeriodLengthLabel', {'days': days.toString()});

  String homeCountdownDays(int days) =>
      _format('homeCountdownDays', {'days': days.toString()});

  String formatYenAmount(int? amount) {
    if (amount == null) return '—';
    final formatted =
        NumberFormat.decimalPattern(locale.languageCode).format(amount.abs());
    return amount < 0 ? '-¥$formatted' : '¥$formatted';
  }

  String homeProgressSpent(int? amount) =>
      _format('homeProgressSpent', {'amount': formatYenAmount(amount)});

  String homePeriodLabel(int index) =>
      _format('homePeriodLabel', {'index': index.toString()});

  String homeWeeklyBudgetOver(int amount) =>
      _format('homeWeeklyBudgetOver', {'amount': formatCurrency(amount)});

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

  String formatDate(DateTime d) =>
      '${d.year}/${_twoDigits(d.month)}/${_twoDigits(d.day)}';

  String formatSpacedDate(DateTime d) =>
      '${d.year} / ${_twoDigits(d.month)} / ${_twoDigits(d.day)}';

  String formatShortDate(DateTime d) =>
      '${_twoDigits(d.month)}/${_twoDigits(d.day)}';

  String formatMonthDay(DateTime d) => locale.languageCode == 'ja'
      ? '${d.month}月${d.day}日'
      : '${d.month}/${d.day}';

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String formatLongDate(DateTime d) {
    if (locale.languageCode == 'ja') {
      return '${d.year}年${d.month}月${d.day}日';
    }
    return formatDate(d);
  }

  String formatMonth(int month) {
    if (locale.languageCode == 'ja') {
      return '$month月';
    }
    return 'Month $month';
  }

  String formatWeekday(int weekday) {
    const japanese = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
    const english = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return (locale.languageCode == 'ja' ? japanese : english)[weekday - 1];
  }

  String formatCurrency(int amount) {
    if (locale.languageCode == 'ja') {
      return '$amount 円';
    }
    return '$amount JPY';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'ja' || locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
