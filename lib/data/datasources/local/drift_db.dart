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

class AnnualSchedules extends Table {
  IntColumn get year => integer()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get weekStart => integer()(); // 0=Mon..6=Sun

  @override
  Set<Column> get primaryKey => {year};
}

class AnnualPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scheduleYear => integer().references(AnnualSchedules, #year)();
  IntColumn get periodIndex => integer()();
  IntColumn get days => integer()(); // 35 or 42
}

class _SeedCategory {
  final String name;
  final int color;
  final int type;

  const _SeedCategory({
    required this.name,
    required this.color,
    required this.type,
  });
}

// Default categories are defined in docs/06_カテゴリ一覧.csv.
const List<_SeedCategory> _defaultCategories = [
  _SeedCategory(name: '未分類', color: 0xFF9E9E9E, type: 0),
  _SeedCategory(name: '食費', color: 0xFF4CAF50, type: 0),
  _SeedCategory(name: '日用品', color: 0xFF009688, type: 0),
  _SeedCategory(name: '美容', color: 0xFFE91E63, type: 0),
  _SeedCategory(name: '衣服', color: 0xFF9C27B0, type: 0),
  _SeedCategory(name: '交際費', color: 0xFFFF9800, type: 0),
  _SeedCategory(name: '医療費', color: 0xFFF44336, type: 0),
  _SeedCategory(name: '教育費', color: 0xFF3F51B5, type: 0),
  _SeedCategory(name: '光熱費', color: 0xFFFFC107, type: 0),
  _SeedCategory(name: '交通費', color: 0xFF2196F3, type: 0),
  _SeedCategory(name: '通信費', color: 0xFF03A9F4, type: 0),
  _SeedCategory(name: '住居費', color: 0xFF795548, type: 0),
  _SeedCategory(name: 'ボーナス支出', color: 0xFFFFB300, type: 0),
  _SeedCategory(name: '未分類', color: 0xFF9E9E9E, type: 1),
  _SeedCategory(name: '給料', color: 0xFF4CAF50, type: 1),
  _SeedCategory(name: 'おこづかい', color: 0xFF00BCD4, type: 1),
  _SeedCategory(name: '賞与', color: 0xFFFFC107, type: 1),
  _SeedCategory(name: '副業', color: 0xFFFF5722, type: 1),
  _SeedCategory(name: '投資', color: 0xFF2196F3, type: 1),
  _SeedCategory(name: '臨時収入', color: 0xFF9C27B0, type: 1),
];

String _seedKey(int type, String name) => '$type:$name';


@DriftDatabase(tables: [Categories, Transactions, AnnualSchedules, AnnualPeriods])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(transactions, transactions.expenseAttribute);
          }
          if (from < 3) {
            await m.createTable(annualSchedules);
            await m.createTable(annualPeriods);
          }
        },
      );

  // Seed default categories if missing.
  Future<void> ensureSeeded() async {
    var rows = await select(categories).get();
    final hasTransportFee = rows.any((row) => row.type == 0 && row.name == '交通費');
    if (!hasTransportFee) {
      final legacyTransport = rows.where((row) => row.type == 0 && row.name == '交通').toList();
      if (legacyTransport.isNotEmpty) {
        await batch((b) {
          for (final row in legacyTransport) {
            b.update(
              categories,
              CategoriesCompanion(name: const Value('交通費')),
              where: (tbl) => tbl.id.equals(row.id),
            );
          }
        });
        rows = await select(categories).get();
      }
    }

    final existing = {for (final row in rows) _seedKey(row.type, row.name)};
    final missing = _defaultCategories
        .where((cat) => !existing.contains(_seedKey(cat.type, cat.name)))
        .toList();
    if (missing.isEmpty) return;

    await batch((b) {
      b.insertAll(
        categories,
        [
          for (final cat in missing)
            CategoriesCompanion.insert(
              name: cat.name,
              color: cat.color,
              type: cat.type,
            ),
        ],
      );
    });
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
