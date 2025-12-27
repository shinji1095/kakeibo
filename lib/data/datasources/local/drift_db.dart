// ignore_for_file: unnecessary_cast

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'drift_db.g.dart';

// --- Drift tables ---
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get color => integer()(); // ARGB
  IntColumn get type => integer()(); // 0: expense, 1: income
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get amount => integer()();
  TextColumn get memo => text().withDefault(const Constant(''))();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get type => integer()(); // 0: expense, 1: income
  IntColumn get expenseAttribute =>
      integer().withDefault(const Constant(1))(); // 0: fixed, 1: variable, 2: bonus
}

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(transactions, transactions.expenseAttribute);
          }
        },
      );

  // Seed default categories if empty
  Future<void> ensureSeeded() async {
    final count = await (select(categories).get()).then((rows) => rows.length);
    if (count == 0) {
      await batch((b) {
        b.insertAll(categories, [
          CategoriesCompanion.insert(name: '食費',   color: 0xFF4CAF50, type: 0),
          CategoriesCompanion.insert(name: '交通',   color: 0xFF2196F3, type: 0),
          CategoriesCompanion.insert(name: '光熱費', color: 0xFFFF9800, type: 0),
          CategoriesCompanion.insert(name: '給料',   color: 0xFF3F51B5, type: 1),
          CategoriesCompanion.insert(name: '臨時収入', color: 0xFF9C27B0, type: 1),
        ]);
      });
    }
  }
}

// Create a lazy database in app docs dir (used only if this file is used standalone)
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kakeibo.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
