import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/repositories/annual_schedule_repository.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';

class UpdateAnnualSchedulePeriod {
  final AnnualScheduleRepository repo;
  final AnnualScheduleGenerator generator;

  UpdateAnnualSchedulePeriod(this.repo, this.generator);

  Future<AnnualSchedule> call({
    required int year,
    required int periodIndex,
    required int days,
  }) async {
    final config = await repo.getConfig(year);
    if (config == null) {
      throw StateError('Annual schedule not found for year $year');
    }
    final updated = generator.updatePeriodLength(
      config: config,
      periodIndex: periodIndex,
      days: days,
    );
    if (identical(updated, config)) {
      return generator.buildSchedule(config);
    }
    await repo.saveConfig(updated);
    return generator.buildSchedule(updated);
  }
}
