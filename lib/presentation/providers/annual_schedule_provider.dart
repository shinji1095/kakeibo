import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/usecases/get_annual_schedule.dart';
import 'package:kakeibo/domain/usecases/regenerate_annual_schedule.dart';
import 'package:kakeibo/domain/usecases/update_annual_schedule_period.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';

final annualSchedulePageYearProvider = StateProvider<int>((ref) => DateTime.now().year);

final annualScheduleForYearProvider = FutureProvider.family<AnnualSchedule?, int>((ref, year) async {
  if (!sl.isRegistered<GetAnnualSchedule>()) return null;
  final settings = ref.watch(settingsProvider);
  final startDate = settings.kakeiboStartDate.year == year
      ? settings.kakeiboStartDate
      : DateTime(year, 1, 1);
  final usecase = sl<GetAnnualSchedule>();
  return usecase(year: year, startDate: startDate, weekStart: 0);
});

final currentAnnualScheduleProvider = FutureProvider<AnnualSchedule?>((ref) async {
  final year = DateTime.now().year;
  return ref.watch(annualScheduleForYearProvider(year).future);
});

final regenerateAnnualScheduleProvider = Provider<RegenerateAnnualSchedule>(
  (ref) => sl<RegenerateAnnualSchedule>(),
);

final updateAnnualSchedulePeriodProvider = Provider<UpdateAnnualSchedulePeriod>(
  (ref) => sl<UpdateAnnualSchedulePeriod>(),
);
