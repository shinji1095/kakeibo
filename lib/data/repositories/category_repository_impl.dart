import 'package:drift/drift.dart' as d;
import 'package:kakeibo/data/datasources/local/drift_db.dart';
import 'package:kakeibo/domain/entities/transaction.dart' as domain;
import 'package:kakeibo/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase db;
  CategoryRepositoryImpl(this.db);

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
}
