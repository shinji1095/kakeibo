import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/repositories/annual_schedule_repository.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';

abstract class SetAnnualScheduleBonusPeriods {
  Future<AnnualSchedule> call({
    required int year,
    required List<int> bonusPeriodIndices,
  });
}

class SetAnnualScheduleBonusPeriodsImpl implements SetAnnualScheduleBonusPeriods {
  final AnnualScheduleRepository repo;
  final AnnualScheduleGenerator generator;

  SetAnnualScheduleBonusPeriodsImpl(this.repo, this.generator);

  @override
  Future<AnnualSchedule> call({
    required int year,
    required List<int> bonusPeriodIndices,
  }) async {
    var config = await repo.getConfig(year);
    if (config == null) {
      throw StateError('Annual schedule not found for year $year');
    }

    final normalized = generator.normalizeConfig(config);
    if (!identical(normalized, config)) {
      await repo.saveConfig(normalized);
      config = normalized;
    }

    final sorted = bonusPeriodIndices.toSet().toList()..sort();
    final updated = generator.setBonusPeriods(
      config: config,
      bonusPeriodIndices: sorted,
    );
    if (identical(updated, config)) {
      return generator.buildSchedule(config);
    }

    await repo.saveConfig(updated);
    return generator.buildSchedule(updated);
  }
}
