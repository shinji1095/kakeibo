import 'package:drift/drift.dart' as d;
import 'package:kakeibo/data/datasources/local/drift_db.dart';
import 'package:kakeibo/domain/entities/transaction.dart' as domain;
import 'package:kakeibo/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase db;
  CategoryRepositoryImpl(this.db);

  static const _uncategorizedName = '未分類';
  static const _bonusCategoryName = 'ボーナス支出';
  static const _fallbackColor = 0xFF9E9E9E;

  @override
  Future<List<domain.Category>> getAll() async {
    await db.ensureSeeded();
    final rows = await (db.select(db.categories)
          ..orderBy([(t) => d.OrderingTerm.asc(t.id)]))
        .get();

    return rows
        .map(
          (r) => domain.Category(
            id: r.id,
            name: r.name,
            color: r.color,
            type: r.type == 0 ? domain.TransactionType.expense : domain.TransactionType.income,
          ),
        )
        .toList();
  }

  @override
  Future<int> add(domain.Category category) async {
    return db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: category.name,
            color: category.color,
            type: category.type == domain.TransactionType.expense ? 0 : 1,
          ),
        );
  }

  @override
  Future<void> update(domain.Category category) async {
    if (category.id == null) {
      throw ArgumentError('Category id is required for update');
    }
    if (_isProtectedName(category.name)) return;

    await (db.update(db.categories)..where((t) => t.id.equals(category.id!))).write(
      CategoriesCompanion(
        name: d.Value(category.name),
        color: d.Value(category.color),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    final row = await (db.select(db.categories)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    if (_isProtectedName(row.name)) return;

    final replacement = await (db.select(db.categories)
          ..where((t) => t.type.equals(row.type) & t.name.equals(_uncategorizedName)))
        .getSingleOrNull();

    final replacementId = replacement?.id ??
        await db.into(db.categories).insert(
              CategoriesCompanion.insert(
                name: _uncategorizedName,
                color: _fallbackColor,
                type: row.type,
              ),
            );

    await (db.update(db.transactions)..where((t) => t.categoryId.equals(id))).write(
      TransactionsCompanion(categoryId: d.Value(replacementId)),
    );

    await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
  }

  bool _isProtectedName(String name) {
    return name == _uncategorizedName || name == _bonusCategoryName;
  }
}
