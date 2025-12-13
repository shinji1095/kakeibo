enum TransactionType { expense, income }

class Money {
  /// Amount in yen (integer).
  final int value;
  const Money(this.value);
}

class Category {
  final int? id;
  final String name;
  final int color; // ARGB
  final TransactionType type;
  const Category({this.id, required this.name, required this.color, required this.type});
}

class KakeiboTransaction {
  final int? id;
  final DateTime date;
  final Money amount;
  final String memo;
  final int categoryId;
  final TransactionType type;

  const KakeiboTransaction({
    this.id,
    required this.date,
    required this.amount,
    required this.memo,
    required this.categoryId,
    required this.type,
  });

  KakeiboTransaction copyWith({
    int? id,
    DateTime? date,
    Money? amount,
    String? memo,
    int? categoryId,
    TransactionType? type,
  }) {
    return KakeiboTransaction(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
    );
  }
}
