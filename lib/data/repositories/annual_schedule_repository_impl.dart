import 'package:drift/drift.dart' as d;
import 'package:kakeibo/data/datasources/local/drift_db.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/repositories/annual_schedule_repository.dart';

class AnnualScheduleRepositoryImpl implements AnnualScheduleRepository {
  final AppDatabase db;
  AnnualScheduleRepositoryImpl(this.db);

  @override
  Future<AnnualScheduleConfig?> getConfig(int year) async {
    final schedule = await (db.select(db.annualSchedules)
          ..where((t) => t.year.equals(year)))
        .getSingleOrNull();
    if (schedule == null) return null;

    final periods = await (db.select(db.annualPeriods)
          ..where((t) => t.scheduleYear.equals(year))
          ..orderBy([(t) => d.OrderingTerm.asc(t.periodIndex)]))
        .get();
    final periodDays = periods.map((p) => p.days).toList();
    return AnnualScheduleConfig(
      year: year,
      startDate: schedule.startDate,
      weekStart: schedule.weekStart,
      periodDays: periodDays,
      bonusMonths: schedule.bonusConfig.isEmpty
          ? const []
          : schedule.bonusConfig.split(',').map((entry) {
              final parts = entry.split(':');
              return BonusMonthSetting(
                month: int.parse(parts[0]),
                weeks: int.parse(parts[1]),
                periodIndex: parts.length > 2 ? int.parse(parts[2]) : null,
              );
            }).toList(),
      sixWeekPeriods: schedule.sixWeekPeriods.isEmpty
          ? const []
          : schedule.sixWeekPeriods.split(',').map(int.parse).toList(),
      periodBudget: schedule.periodBudget,
    );
  }

  @override
  Future<void> saveConfig(AnnualScheduleConfig config) async {
    await db.transaction(() async {
      await db.into(db.annualSchedules).insertOnConflictUpdate(
            AnnualSchedulesCompanion(
              year: d.Value(config.year),
              startDate: d.Value(config.startDate),
              weekStart: d.Value(config.weekStart),
              bonusConfig: d.Value(config.bonusMonths
                  .map((month) => month.periodIndex == null
                      ? '${month.month}:${month.weeks}'
                      : '${month.month}:${month.weeks}:${month.periodIndex}')
                  .join(',')),
              sixWeekPeriods: d.Value(config.sixWeekPeriods.join(',')),
              periodBudget: d.Value(config.periodBudget),
            ),
          );

      await (db.delete(db.annualPeriods)
            ..where((t) => t.scheduleYear.equals(config.year)))
          .go();
      if (config.periodDays.isNotEmpty) {
        await db.batch((b) {
          b.insertAll(
            db.annualPeriods,
            [
              for (var i = 0; i < config.periodDays.length; i++)
                AnnualPeriodsCompanion.insert(
                  scheduleYear: config.year,
                  periodIndex: i,
                  days: config.periodDays[i],
                ),
            ],
          );
        });
      }
    });
  }
}
