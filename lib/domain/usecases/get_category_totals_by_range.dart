import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class GetCategoryTotalsByRange {
  final TransactionRepository repo;
  GetCategoryTotalsByRange(this.repo);

  Future<Map<int, int>> call(
    DateTime startInclusive,
    DateTime endExclusive,
    TransactionType type, {
    Set<ExpenseAttribute>? expenseAttributes,
  }) async {
    final list = await repo.getByRange(startInclusive, endExclusive);
    final totals = <int, int>{};
    final effectiveAttributes = (expenseAttributes == null || expenseAttributes.isEmpty)
        ? ExpenseAttribute.values.toSet()
        : expenseAttributes;

    for (final tx in list) {
      if (tx.type != type) continue;
      if (type == TransactionType.expense) {
        final attr = tx.expenseAttribute ?? kDefaultExpenseAttribute;
        if (!effectiveAttributes.contains(attr)) continue;
      }
      totals[tx.categoryId] = (totals[tx.categoryId] ?? 0) + tx.amount.value;
    }

    return totals;
  }
}
