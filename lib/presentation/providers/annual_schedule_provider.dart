import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/usecases/get_annual_schedule.dart';
import 'package:kakeibo/domain/usecases/save_annual_schedule.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';

final annualSchedulePageYearProvider =
    StateProvider<int>((ref) => DateTime.now().year);

const int annualScheduleYearsAroundNow = 5;

DateTime defaultAnnualStartDate(int year) =>
    AnnualScheduleGenerator.defaultStartDate(year);

final annualScheduleForYearProvider =
    FutureProvider.family<AnnualSchedule?, int>((ref, year) async {
  if (!sl.isRegistered<GetAnnualSchedule>()) return null;
  final startDate = defaultAnnualStartDate(year);
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
    final startDate = defaultAnnualStartDate(year);
    await usecase(year: year, startDate: startDate, weekStart: 0);
  }
});

final annualSchedulesAroundNowProvider =
    Provider<Map<int, AnnualSchedule>>((ref) {
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

final currentAnnualScheduleProvider =
    FutureProvider<AnnualSchedule?>((ref) async {
  final now = DateTime.now();
  final schedules = <AnnualSchedule>[];
  for (final year in [now.year - 1, now.year, now.year + 1]) {
    final schedule =
        await ref.watch(annualScheduleForYearProvider(year).future);
    if (schedule != null) schedules.add(schedule);
  }
  schedules.sort((a, b) => b.startDate.compareTo(a.startDate));
  for (final schedule in schedules) {
    if (!now.isBefore(schedule.startDate) &&
        !now.isAfter(schedule.periods.last.endDate)) {
      return schedule;
    }
  }
  if (schedules.isEmpty) return null;
  return schedules.firstWhere(
    (schedule) => !now.isBefore(schedule.startDate),
    orElse: () => schedules.last,
  );
});

final annualScheduleGeneratorProvider = Provider<AnnualScheduleGenerator>(
  (ref) => sl.isRegistered<AnnualScheduleGenerator>()
      ? sl<AnnualScheduleGenerator>()
      : AnnualScheduleGenerator(),
);

final saveAnnualScheduleProvider = Provider<SaveAnnualSchedule>(
  (ref) => sl<SaveAnnualSchedule>(),
);
