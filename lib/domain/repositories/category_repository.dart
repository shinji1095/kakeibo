import 'package:kakeibo/domain/entities/transaction.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAll();
  Future<int> add(Category category);
  Future<void> update(Category category);
  Future<void> delete(int id);
}
