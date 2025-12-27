enum TransactionType { expense, income }

enum ExpenseAttribute { fixed, variable, bonus }

const ExpenseAttribute kDefaultExpenseAttribute = ExpenseAttribute.variable;

extension ExpenseAttributeX on ExpenseAttribute {
  String get label {
    switch (this) {
      case ExpenseAttribute.fixed:
        return '固定費';
      case ExpenseAttribute.variable:
        return 'やりくり費';
      case ExpenseAttribute.bonus:
        return 'ボーナス支出';
    }
  }

  int get dbValue {
    switch (this) {
      case ExpenseAttribute.fixed:
        return 0;
      case ExpenseAttribute.variable:
        return 1;
      case ExpenseAttribute.bonus:
        return 2;
    }
  }
}

ExpenseAttribute? expenseAttributeFromDb(int? value) {
  switch (value) {
    case 0:
      return ExpenseAttribute.fixed;
    case 1:
      return ExpenseAttribute.variable;
    case 2:
      return ExpenseAttribute.bonus;
    default:
      return null;
  }
}

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
  final ExpenseAttribute? expenseAttribute;

  const KakeiboTransaction({
    this.id,
    required this.date,
    required this.amount,
    required this.memo,
    required this.categoryId,
    required this.type,
    this.expenseAttribute,
  }) : assert(
          type != TransactionType.expense || expenseAttribute != null,
          'Expense attribute is required for expense transactions.',
        );

  KakeiboTransaction copyWith({
    int? id,
    DateTime? date,
    Money? amount,
    String? memo,
    int? categoryId,
    TransactionType? type,
    ExpenseAttribute? expenseAttribute,
  }) {
    return KakeiboTransaction(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      expenseAttribute: expenseAttribute ?? this.expenseAttribute,
    );
  }
}
