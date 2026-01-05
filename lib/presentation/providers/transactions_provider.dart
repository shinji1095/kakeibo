import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/add_transaction.dart';
import 'package:kakeibo/domain/usecases/delete_transaction.dart';
import 'package:kakeibo/domain/usecases/get_category_totals_by_range.dart';
import 'package:kakeibo/domain/usecases/get_monthly_summary.dart';
import 'package:kakeibo/domain/usecases/get_total_by_range.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_range.dart';
import 'package:kakeibo/domain/usecases/update_transaction.dart';
import 'package:kakeibo/presentation/providers/annual_schedule_provider.dart';

final periodOffsetProvider = StateProvider<int>((ref) => 0);

enum TrendMetric { balance, income, expense }

final trendMetricProvider = StateProvider<TrendMetric>((ref) => TrendMetric.balance);
final trendShowAmountsProvider = StateProvider<bool>((ref) => true);

final expenseAttributeFilterProvider = StateProvider<Set<ExpenseAttribute>>(
  (ref) => ExpenseAttribute.values.toSet(),
);

enum RangeBasis { period, month }

final rangeBasisProvider = StateProvider<RangeBasis>((ref) => RangeBasis.period);

List<AnnualSchedule> _sortedSchedules(Map<int, AnnualSchedule> schedules) {
  final list = schedules.values.toList()
    ..sort((a, b) => a.year.compareTo(b.year));
  return list;
}

List<({DateTime start, DateTime end})> _collectScheduleRanges(
  List<AnnualSchedule> schedules,
) {
  final ranges = <({DateTime start, DateTime end})>[];
  for (final schedule in schedules) {
    for (final period in schedule.periods) {
      ranges.add((
        start: period.startDate,
        end: period.endDate.add(const Duration(days: 1)),
      ));
    }
  }
  return ranges;
}

int _findRangeIndex(
  List<({DateTime start, DateTime end})> ranges,
  DateTime date,
) {
  if (ranges.isEmpty) return -1;
  final normalized = truncateDate(date);
  if (normalized.isBefore(ranges.first.start)) {
    return 0;
  }
  for (var i = 0; i < ranges.length; i++) {
    final range = ranges[i];
    if (!normalized.isBefore(range.start) && normalized.isBefore(range.end)) {
      return i;
    }
    if (!normalized.isBefore(range.end)) {
      if (i == ranges.length - 1) {
        return i;
      }
      if (normalized.isBefore(ranges[i + 1].start)) {
        return i;
      }
    }
  }
  return ranges.length - 1;
}

final periodRangeProvider = Provider<({DateTime start, DateTime end})>((ref) {
  final basis = ref.watch(rangeBasisProvider);
  final offset = ref.watch(periodOffsetProvider);
  if (basis == RangeBasis.month) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month + offset, 1);
    return (start: start, end: DateTime(start.year, start.month + 1, 1));
  }
  final scheduleMap = ref.watch(annualSchedulesAroundNowProvider);
  final schedules = _sortedSchedules(scheduleMap);
  final ranges = _collectScheduleRanges(schedules);
  final currentIndex = _findRangeIndex(ranges, DateTime.now());
  if (currentIndex >= 0) {
    final targetIndex = (currentIndex + offset).clamp(0, ranges.length - 1).toInt();
    final target = ranges[targetIndex];
    return (start: target.start, end: target.end);
  }

  final schedule = ref.watch(currentAnnualScheduleProvider).valueOrNull;
  if (schedule != null && schedule.periods.isNotEmpty) {
    final current = resolveSchedulePeriod(schedule.periods, DateTime.now());
    final targetIndex =
        (current.index + offset).clamp(0, schedule.periods.length - 1).toInt();
    final target = schedule.periods[targetIndex];
    return (start: target.startDate, end: target.endDate.add(const Duration(days: 1)));
  }

  final length = 35;
  final baseStart = currentPeriodStart(DateTime(DateTime.now().year, 1, 1), length, DateTime.now());
  final start = baseStart.add(Duration(days: length * offset));
  final end = start.add(Duration(days: length));
  return (start: start, end: end);
});

final transactionsProvider = FutureProvider<List<KakeiboTransaction>>((ref) async {
  final range = ref.watch(periodRangeProvider);
  final use = sl<GetTransactionsByRange>();
  return use(range.start, range.end);
});

final addTransactionProvider = Provider<AddTransaction>((ref) => sl<AddTransaction>());
final updateTransactionProvider = Provider<UpdateTransaction>((ref) => sl<UpdateTransaction>());
final deleteTransactionProvider = Provider<DeleteTransaction>((ref) => sl<DeleteTransaction>());

final monthlySummaryProvider = FutureProvider.family<Map<int, int>, ({DateTime month, TransactionType type})>((ref, arg) async {
  final use = sl<GetMonthlySummary>();
  return use(arg.month, arg.type);
});

final periodCategoryTotalsProvider = FutureProvider.family<Map<int, int>, TransactionType>((ref, type) async {
  final range = ref.watch(periodRangeProvider);
  final filters = ref.watch(expenseAttributeFilterProvider);
  final use = sl<GetCategoryTotalsByRange>();
  return use(range.start, range.end, type, expenseAttributes: filters);
});

final trendCountProvider = StateProvider<int>((ref) => 3);

final periodTotalsProvider = FutureProvider<List<({DateTime start, DateTime end, int income, int expense})>>((ref) async {
  final range = ref.watch(periodRangeProvider);
  final offset = ref.watch(periodOffsetProvider);
  final count = ref.watch(trendCountProvider);
  final basis = ref.watch(rangeBasisProvider);
  final scheduleMap = ref.watch(annualSchedulesAroundNowProvider);
  final schedules = _sortedSchedules(scheduleMap);
  final combinedRanges = _collectScheduleRanges(schedules);
  final currentIndex = _findRangeIndex(combinedRanges, DateTime.now());
  final ranges = basis == RangeBasis.month
      ? buildMonthRanges(range.start, count)
      : (currentIndex >= 0 && combinedRanges.isNotEmpty)
          ? () {
              final targetIndex =
                  (currentIndex + offset).clamp(0, combinedRanges.length - 1).toInt();
              final startIndex = (targetIndex - (count - 1)).clamp(0, targetIndex).toInt();
              return combinedRanges.sublist(startIndex, targetIndex + 1);
            }()
          : buildPeriodRanges(range.start, range.end.difference(range.start).inDays, count);
  final use = sl<GetTotalByRange>();
  final filters = ref.watch(expenseAttributeFilterProvider);

  final results = <({DateTime start, DateTime end, int income, int expense})>[];
  for (final r in ranges) {
    final income = await use(r.start, r.end, TransactionType.income);
    final expense = await use(
      r.start,
      r.end,
      TransactionType.expense,
      expenseAttributes: filters,
    );
    results.add((start: r.start, end: r.end, income: income, expense: expense));
  }

  return results;
});
