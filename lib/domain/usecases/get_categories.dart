import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repo;
  GetCategories(this.repo);

  Future<List<Category>> call() => repo.getAll();
}