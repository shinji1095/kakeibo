import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class GetTotalByRange {
  final TransactionRepository repo;
  GetTotalByRange(this.repo);

  Future<int> call(DateTime startInclusive, DateTime endExclusive, TransactionType type) {
    return repo.getTotalByRange(startInclusive, endExclusive, type);
  }
}
