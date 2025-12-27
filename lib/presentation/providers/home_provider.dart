import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

class HomeStats {
  final DateTime periodStart;
  final DateTime periodEndExclusive;
  final int daysUntilPeriodEnd;
  final int periodLengthDays;

  const HomeStats({
    required this.periodStart,
    required this.periodEndExclusive,
    required this.daysUntilPeriodEnd,
    required this.periodLengthDays,
  });
}

final homeStatsProvider = Provider<HomeStats>((ref) {
  final settings = ref.watch(settingsProvider);
  final length = settings.periodLengthDays <= 0 ? 35 : settings.periodLengthDays;
  final start = currentPeriodStart(settings.kakeiboStartDate, length, DateTime.now());
  final periodEndExclusive = start.add(Duration(days: length));
  final remaining = periodEndExclusive.difference(truncateDate(DateTime.now())).inDays;

  return HomeStats(
    periodStart: start,
    periodEndExclusive: periodEndExclusive,
    daysUntilPeriodEnd: remaining < 0 ? 0 : remaining,
    periodLengthDays: length,
  );
});