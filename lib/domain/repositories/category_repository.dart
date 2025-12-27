import 'package:kakeibo/domain/entities/transaction.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAll();
}