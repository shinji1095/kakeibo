import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class GetTransactionsByMonth {
  final TransactionRepository repo;
  GetTransactionsByMonth(this.repo);

  Future<List<KakeiboTransaction>> call(DateTime monthFirstDay) => repo.getByMonth(monthFirstDay);
}
