import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/repositories/annual_schedule_repository.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';

class SaveAnnualSchedule {
  final AnnualScheduleRepository repo;
  final AnnualScheduleGenerator generator;

  SaveAnnualSchedule(this.repo, this.generator);

  Future<AnnualSchedule> call(AnnualScheduleConfig config) async {
    final validated = generator.configure(
      year: config.year,
      startDate: config.startDate,
      weekStart: config.weekStart,
      bonusMonths: config.bonusMonths,
      sixWeekPeriods: config.sixWeekPeriods,
      periodBudget: config.periodBudget,
    );
    await repo.saveConfig(validated);
    return generator.buildSchedule(validated);
  }
}
