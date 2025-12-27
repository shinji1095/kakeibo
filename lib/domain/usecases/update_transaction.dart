import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repo;
  UpdateTransaction(this.repo);

  Future<void> call(KakeiboTransaction tx) => repo.update(tx);
}