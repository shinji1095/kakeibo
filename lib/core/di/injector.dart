import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/native.dart';
import 'package:kakeibo/data/datasources/local/drift_db.dart';
import 'package:kakeibo/data/repositories/transaction_repository_impl.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';
import 'package:kakeibo/domain/usecases/add_transaction.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_month.dart';
import 'package:kakeibo/domain/usecases/delete_transaction.dart';
import 'package:kakeibo/domain/usecases/get_monthly_summary.dart';
import 'package:kakeibo/domain/usecases/get_total_by_range.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Create / open local database path
  final dir = await getApplicationDocumentsDirectory();
  final dbFile = File('${dir.path}/kakeibo.sqlite');
  final db = AppDatabase(NativeDatabase.createInBackground(dbFile));

  // DataSource / Repos
  sl.registerSingleton<AppDatabase>(db);
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl<AppDatabase>()),
  );

  // UseCases
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => GetTransactionsByMonth(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerLazySingleton(() => GetMonthlySummary(sl()));
  sl.registerLazySingleton(() => GetTotalByRange(sl()));
}
