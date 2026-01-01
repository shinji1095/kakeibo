import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/repositories/annual_schedule_repository.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';

class RegenerateAnnualSchedule {
  final AnnualScheduleRepository repo;
  final AnnualScheduleGenerator generator;

  RegenerateAnnualSchedule(this.repo, this.generator);

  Future<AnnualSchedule> call({
    required int year,
    required DateTime startDate,
    required int weekStart,
  }) async {
    final config = generator.generate(year: year, startDate: startDate, weekStart: weekStart);
    await repo.saveConfig(config);
    return generator.buildSchedule(config);
  }
}
