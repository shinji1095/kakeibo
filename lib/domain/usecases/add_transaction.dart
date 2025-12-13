import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repo;
  AddTransaction(this.repo);

  Future<int> call(KakeiboTransaction tx) => repo.add(tx);
}
