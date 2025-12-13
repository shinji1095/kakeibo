import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

/// Returns a map: categoryId -> total amount (yen) for the given month.
class GetMonthlySummary {
  final TransactionRepository repo;
  GetMonthlySummary(this.repo);

  Future<Map<int, int>> call(DateTime monthFirstDay, TransactionType type) {
    return repo.getMonthlyCategoryTotals(monthFirstDay, type);
  }
}
