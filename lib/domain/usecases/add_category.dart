import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/category_repository.dart';

class AddCategory {
  final CategoryRepository repo;
  AddCategory(this.repo);

  Future<int> call(Category category) => repo.add(category);
}
