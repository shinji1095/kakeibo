import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class GetTransactionsByRange {
  final TransactionRepository repo;
  GetTransactionsByRange(this.repo);

  Future<List<KakeiboTransaction>> call(DateTime startInclusive, DateTime endExclusive) {
    return repo.getByRange(startInclusive, endExclusive);
  }
}