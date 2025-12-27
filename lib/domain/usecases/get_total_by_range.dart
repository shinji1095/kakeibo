import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class GetTotalByRange {
  final TransactionRepository repo;
  GetTotalByRange(this.repo);

  Future<int> call(
    DateTime startInclusive,
    DateTime endExclusive,
    TransactionType type, {
    Set<ExpenseAttribute>? expenseAttributes,
  }) async {
    final shouldFilter = type == TransactionType.expense &&
        expenseAttributes != null &&
        expenseAttributes.isNotEmpty &&
        expenseAttributes.length != ExpenseAttribute.values.length;

    if (!shouldFilter) {
      return repo.getTotalByRange(startInclusive, endExclusive, type);
    }

    final list = await repo.getByRange(startInclusive, endExclusive);
    var total = 0;
    for (final tx in list) {
      if (tx.type != type) continue;
      final attr = tx.expenseAttribute ?? kDefaultExpenseAttribute;
      if (!expenseAttributes!.contains(attr)) continue;
      total += tx.amount.value;
    }
    return total;
  }
}
