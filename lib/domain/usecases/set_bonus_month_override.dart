import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/repositories/annual_schedule_repository.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';

class SetBonusMonthOverride {
  final AnnualScheduleRepository repo;
  final AnnualScheduleGenerator generator;

  SetBonusMonthOverride(this.repo, this.generator);

  Future<AnnualSchedule> call({
    required int year,
    required int month,
    required bool isBonus,
  }) async {
    final config = await repo.getConfig(year);
    if (config == null) {
      throw StateError('Annual schedule not found for year $year');
    }

    final normalizedMonth = month.clamp(1, 12);
    final updatedOverrides = Map<int, bool>.from(config.bonusMonthOverrides);
    if (updatedOverrides[normalizedMonth] == isBonus) {
      return generator.buildSchedule(config);
    }
    updatedOverrides[normalizedMonth] = isBonus;

    final updated = AnnualScheduleConfig(
      year: config.year,
      startDate: config.startDate,
      weekStart: config.weekStart,
      periodDays: config.periodDays,
      bonusMonthOverrides: updatedOverrides,
    );
    await repo.saveConfig(updated);
    return generator.buildSchedule(updated);
  }
}
