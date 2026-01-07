import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/usecases/get_annual_schedule.dart';
import 'package:kakeibo/domain/usecases/set_annual_schedule_bonus_periods.dart';

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

final setAnnualScheduleBonusPeriodsProvider = Provider<SetAnnualScheduleBonusPeriods>(
  (ref) => sl<SetAnnualScheduleBonusPeriods>(),
);

class AnnualScheduleCountStatus {
  static const int expected35Default = 10;
  static const int expected7Default = 2;

  final int count35;
  final int count7;
  final int expected35;
  final int expected7;

  const AnnualScheduleCountStatus({
    required this.count35,
    required this.count7,
    required this.expected35,
    required this.expected7,
  });

  bool get isValid => count35 == expected35 && count7 == expected7;

  factory AnnualScheduleCountStatus.fromSchedule(AnnualSchedule schedule) {
    final count35 = schedule.periods.where((period) => period.days == 35).length;
    final count7 = schedule.periods.where((period) => period.days == 7).length;
    return AnnualScheduleCountStatus(
      count35: count35,
      count7: count7,
      expected35: expected35Default,
      expected7: expected7Default,
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
