import 'package:kakeibo/domain/entities/annual_schedule.dart';

abstract class AnnualScheduleRepository {
  Future<AnnualScheduleConfig?> getConfig(int year);
  Future<void> saveConfig(AnnualScheduleConfig config);
}
