import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/datasources/local/drift_db.dart';
import 'package:kakeibo/data/repositories/annual_schedule_repository_impl.dart';
import 'package:kakeibo/domain/entities/annual_schedule.dart';
import 'package:kakeibo/domain/usecases/annual_schedule_generator.dart';

void main() {
  test('persists annual start, bonus weeks, six-week periods, and budget',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = AnnualScheduleRepositoryImpl(db);
    final config = AnnualScheduleGenerator().configure(
      year: 2026,
      startDate: DateTime(2026, 1, 1),
      weekStart: 0,
      bonusMonths: const [
        BonusMonthSetting(month: 9, weeks: 0),
        BonusMonthSetting(month: 12, weeks: 1, periodIndex: 10),
      ],
      sixWeekPeriods: const [0],
      periodBudget: 65000,
    );
    await repo.saveConfig(config);
    final loaded = await repo.getConfig(2026);
    expect(loaded, isNotNull);
    expect(loaded!.startDate, DateTime(2026, 1, 1));
    expect(loaded.bonusMonths.map((month) => (month.month, month.weeks)),
        [(9, 0), (12, 1)]);
    expect(loaded.bonusMonths.last.periodIndex, 10);
    expect(loaded.sixWeekPeriods, [0]);
    expect(loaded.periodDays, config.periodDays);
    expect(loaded.periodBudget, 65000);
  });
}
