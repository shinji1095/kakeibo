import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';

String buildPeriodHeaderTitle({
  required AppLocalizations l10n,
  required RangeBasis basis,
  required DateTime rangeStart,
  required DateTime rangeEndExclusive,
  required AnnualSchedule? schedule,
}) {
  if (basis == RangeBasis.month) {
    return _formatYearMonth(l10n, rangeStart);
  }
  final periodIndex = _resolvePeriodIndex(schedule, rangeStart, rangeEndExclusive);
  return _formatYearPeriod(l10n, rangeStart.year, periodIndex);
}

String buildPeriodHeaderSubtitle({
  required AppLocalizations l10n,
  required DateTime rangeStart,
  required DateTime rangeEndInclusive,
}) {
  return '${l10n.formatDate(rangeStart)}'
      '${l10n.rangeSeparator}'
      '${l10n.formatDate(rangeEndInclusive)}';
}

String buildRangeLegendLabel({
  required AppLocalizations l10n,
  required RangeBasis basis,
  required DateTime rangeStart,
  required DateTime rangeEndExclusive,
  required AnnualSchedule? schedule,
}) {
  if (basis == RangeBasis.month) {
    return l10n.formatMonth(rangeStart.month);
  }
  final periodIndex = _resolvePeriodIndex(schedule, rangeStart, rangeEndExclusive);
  return _formatPeriodLabel(l10n, periodIndex);
}

int _resolvePeriodIndex(
  AnnualSchedule? schedule,
  DateTime rangeStart,
  DateTime rangeEndExclusive,
) {
  if (schedule != null && schedule.periods.isNotEmpty) {
    final match = schedule.periods.firstWhere(
      (period) => period.startDate == rangeStart,
      orElse: () => resolveSchedulePeriod(schedule.periods, rangeStart),
    );
    return match.index + 1;
  }

  final length = rangeEndExclusive.difference(rangeStart).inDays;
  if (length <= 0) {
    return 1;
  }
  final yearStart = DateTime(rangeStart.year, 1, 1);
  final diffDays = rangeStart.difference(yearStart).inDays;
  return diffDays < 0 ? 1 : diffDays ~/ length + 1;
}

String _formatYearMonth(AppLocalizations l10n, DateTime date) {
  if (l10n.locale.languageCode == 'ja') {
    return '${date.year}\u5e74${date.month}\u6708';
  }
  return '${date.year} ${l10n.formatMonth(date.month)}';
}

String _formatPeriodLabel(AppLocalizations l10n, int periodIndex) {
  if (l10n.locale.languageCode == 'ja') {
    return '${periodIndex}\u671f';
  }
  return l10n.homePeriodLabel(periodIndex);
}

String _formatYearPeriod(AppLocalizations l10n, int year, int periodIndex) {
  if (l10n.locale.languageCode == 'ja') {
    return '${year}\u5e74${periodIndex}\u671f';
  }
  return '$year ${_formatPeriodLabel(l10n, periodIndex)}';
}
