import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/usecases/get_annual_schedule.dart';
import 'package:kakeibo/domain/usecases/set_bonus_month_override.dart';
import 'package:kakeibo/domain/usecases/update_annual_schedule_period.dart';

final annualSchedulePageYearProvider = StateProvider<int>((ref) => DateTime.now().year);

const int annualScheduleYearsAroundNow = 5;

final annualScheduleForYearProvider = FutureProvider.family<AnnualSchedule?, int>((ref, year) async {
  if (!sl.isRegistered<GetAnnualSchedule>()) return null;
  final startDate = DateTime(year, 1, 1);
  final usecase = sl<GetAnnualSchedule>();
  return usecase(year: year, startDate: startDate, weekStart: 0);
});

final preloadAnnualSchedulesProvider = FutureProvider<void>((ref) async {
  if (!sl.isRegistered<GetAnnualSchedule>()) return;
  final now = DateTime.now();
  final usecase = sl<GetAnnualSchedule>();
  for (var year = now.year - annualScheduleYearsAroundNow;
      year <= now.year + annualScheduleYearsAroundNow;
      year++) {
    final startDate = DateTime(year, 1, 1);
    await usecase(year: year, startDate: startDate, weekStart: 0);
  }
});

final annualSchedulesAroundNowProvider = Provider<Map<int, AnnualSchedule>>((ref) {
  final now = DateTime.now();
  final map = <int, AnnualSchedule>{};
  for (var year = now.year - annualScheduleYearsAroundNow;
      year <= now.year + annualScheduleYearsAroundNow;
      year++) {
    final schedule = ref.watch(annualScheduleForYearProvider(year)).valueOrNull;
    if (schedule != null) {
      map[year] = schedule;
    }
  }
  return map;
});

final currentAnnualScheduleProvider = FutureProvider<AnnualSchedule?>((ref) async {
  final year = DateTime.now().year;
  return ref.watch(annualScheduleForYearProvider(year).future);
});

final updateAnnualSchedulePeriodProvider = Provider<UpdateAnnualSchedulePeriod>(
  (ref) => sl<UpdateAnnualSchedulePeriod>(),
);

final setBonusMonthOverrideProvider = Provider<SetBonusMonthOverride>(
  (ref) => sl<SetBonusMonthOverride>(),
);

class AnnualScheduleCountStatus {
  static const int expected35Default = 8;
  static const int expected42Default = 2;

  final int count35;
  final int count42;
  final int expected35;
  final int expected42;

  const AnnualScheduleCountStatus({
    required this.count35,
    required this.count42,
    required this.expected35,
    required this.expected42,
  });

  bool get isValid => count35 == expected35 && count42 == expected42;

  factory AnnualScheduleCountStatus.fromSchedule(AnnualSchedule schedule) {
    final count35 = schedule.periods.where((period) => period.days == 35).length;
    final count42 = schedule.periods.where((period) => period.days == 42).length;
    return AnnualScheduleCountStatus(
      count35: count35,
      count42: count42,
      expected35: expected35Default,
      expected42: expected42Default,
    );
  }
}

final annualScheduleCountStatusProvider = Provider.family<AnnualScheduleCountStatus?, int>((ref, year) {
  final schedule = ref.watch(annualScheduleForYearProvider(year)).valueOrNull;
  if (schedule == null) return null;
  return AnnualScheduleCountStatus.fromSchedule(schedule);
});

final currentAnnualScheduleCountStatusProvider = Provider<AnnualScheduleCountStatus?>((ref) {
  final schedule = ref.watch(currentAnnualScheduleProvider).valueOrNull;
  if (schedule == null) return null;
  return AnnualScheduleCountStatus.fromSchedule(schedule);
});
