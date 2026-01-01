import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/add_category.dart';
import 'package:kakeibo/domain/usecases/delete_category.dart';
import 'package:kakeibo/domain/usecases/get_categories.dart';
import 'package:kakeibo/domain/usecases/update_category.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final use = sl<GetCategories>();
  return use();
});

final categoriesByTypeProvider = FutureProvider.family<List<Category>, TransactionType>((ref, type) async {
  final list = await ref.watch(categoriesProvider.future);
  return list.where((c) => c.type == type).toList();
});

final addCategoryProvider = Provider<AddCategory>((ref) => sl<AddCategory>());
final updateCategoryProvider = Provider<UpdateCategory>((ref) => sl<UpdateCategory>());
final deleteCategoryProvider = Provider<DeleteCategory>((ref) => sl<DeleteCategory>());
