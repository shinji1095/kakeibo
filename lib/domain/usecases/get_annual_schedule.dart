import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/repositories/annual_schedule_repository.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';

class GetAnnualSchedule {
  final AnnualScheduleRepository repo;
  final AnnualScheduleGenerator generator;

  GetAnnualSchedule(this.repo, this.generator);

  Future<AnnualSchedule> call({
    required int year,
    required DateTime startDate,
    required int weekStart,
  }) async {
    var config = await repo.getConfig(year);
    if (config == null) {
      config = generator.generate(year: year, startDate: startDate, weekStart: weekStart);
      await repo.saveConfig(config);
    } else {
      final normalized = generator.normalizeConfig(config);
      if (!identical(normalized, config)) {
        await repo.saveConfig(normalized);
        config = normalized;
      }
    }
    return generator.buildSchedule(config);
  }
}
