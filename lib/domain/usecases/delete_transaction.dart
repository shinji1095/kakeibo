import 'package:kakeibo/domain/repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repo;
  DeleteTransaction(this.repo);

  Future<void> call(int id) => repo.delete(id);
}
