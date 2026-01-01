// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_db.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, color, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final int color;
  final int type;
  const Category(
      {required this.id,
      required this.name,
      required this.color,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['type'] = Variable<int>(type);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      type: Value(type),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      type: serializer.fromJson<int>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'type': serializer.toJson<int>(type),
    };
  }

  Category copyWith({int? id, String? name, int? color, int? type}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        type: type ?? this.type,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.type == this.type);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  final Value<int> type;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int color,
    required int type,
  })  : name = Value(name),
        color = Value(color),
        type = Value(type);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? color,
      Value<int>? type}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _expenseAttributeMeta =
      const VerificationMeta('expenseAttribute');
  @override
  late final GeneratedColumn<int> expenseAttribute = GeneratedColumn<int>(
      'expense_attribute', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, amount, memo, categoryId, type, expenseAttribute];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('expense_attribute')) {
      context.handle(
          _expenseAttributeMeta,
          expenseAttribute.isAcceptableOrUnknown(
              data['expense_attribute']!, _expenseAttributeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      expenseAttribute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expense_attribute'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final DateTime date;
  final int amount;
  final String memo;
  final int categoryId;
  final int type;
  final int expenseAttribute;
  const Transaction(
      {required this.id,
      required this.date,
      required this.amount,
      required this.memo,
      required this.categoryId,
      required this.type,
      required this.expenseAttribute});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<int>(amount);
    map['memo'] = Variable<String>(memo);
    map['category_id'] = Variable<int>(categoryId);
    map['type'] = Variable<int>(type);
    map['expense_attribute'] = Variable<int>(expenseAttribute);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      date: Value(date),
      amount: Value(amount),
      memo: Value(memo),
      categoryId: Value(categoryId),
      type: Value(type),
      expenseAttribute: Value(expenseAttribute),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<int>(json['amount']),
      memo: serializer.fromJson<String>(json['memo']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      type: serializer.fromJson<int>(json['type']),
      expenseAttribute: serializer.fromJson<int>(json['expenseAttribute']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<int>(amount),
      'memo': serializer.toJson<String>(memo),
      'categoryId': serializer.toJson<int>(categoryId),
      'type': serializer.toJson<int>(type),
      'expenseAttribute': serializer.toJson<int>(expenseAttribute),
    };
  }

  Transaction copyWith(
          {int? id,
          DateTime? date,
          int? amount,
          String? memo,
          int? categoryId,
          int? type,
          int? expenseAttribute}) =>
      Transaction(
        id: id ?? this.id,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        memo: memo ?? this.memo,
        categoryId: categoryId ?? this.categoryId,
        type: type ?? this.type,
        expenseAttribute: expenseAttribute ?? this.expenseAttribute,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      memo: data.memo.present ? data.memo.value : this.memo,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      type: data.type.present ? data.type.value : this.type,
      expenseAttribute: data.expenseAttribute.present
          ? data.expenseAttribute.value
          : this.expenseAttribute,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('expenseAttribute: $expenseAttribute')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, amount, memo, categoryId, type, expenseAttribute);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.memo == this.memo &&
          other.categoryId == this.categoryId &&
          other.type == this.type &&
          other.expenseAttribute == this.expenseAttribute);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> amount;
  final Value<String> memo;
  final Value<int> categoryId;
  final Value<int> type;
  final Value<int> expenseAttribute;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.memo = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.type = const Value.absent(),
    this.expenseAttribute = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int amount,
    this.memo = const Value.absent(),
    required int categoryId,
    required int type,
    this.expenseAttribute = const Value.absent(),
  })  : date = Value(date),
        amount = Value(amount),
        categoryId = Value(categoryId),
        type = Value(type);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? amount,
    Expression<String>? memo,
    Expression<int>? categoryId,
    Expression<int>? type,
    Expression<int>? expenseAttribute,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (memo != null) 'memo': memo,
      if (categoryId != null) 'category_id': categoryId,
      if (type != null) 'type': type,
      if (expenseAttribute != null) 'expense_attribute': expenseAttribute,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<int>? amount,
      Value<String>? memo,
      Value<int>? categoryId,
      Value<int>? type,
      Value<int>? expenseAttribute}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      expenseAttribute: expenseAttribute ?? this.expenseAttribute,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (expenseAttribute.present) {
      map['expense_attribute'] = Variable<int>(expenseAttribute.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('expenseAttribute: $expenseAttribute')
          ..write(')'))
        .toString();
  }
}

class $AnnualSchedulesTable extends AnnualSchedules
    with TableInfo<$AnnualSchedulesTable, AnnualSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnualSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _weekStartMeta =
      const VerificationMeta('weekStart');
  @override
  late final GeneratedColumn<int> weekStart = GeneratedColumn<int>(
      'week_start', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [year, startDate, weekStart];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annual_schedules';
  @override
  VerificationContext validateIntegrity(Insertable<AnnualSchedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(_weekStartMeta,
          weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta));
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {year};
  @override
  AnnualSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnnualSchedule(
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      weekStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week_start'])!,
    );
  }

  @override
  $AnnualSchedulesTable createAlias(String alias) {
    return $AnnualSchedulesTable(attachedDatabase, alias);
  }
}

class AnnualSchedule extends DataClass implements Insertable<AnnualSchedule> {
  final int year;
  final DateTime startDate;
  final int weekStart;
  const AnnualSchedule(
      {required this.year, required this.startDate, required this.weekStart});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['year'] = Variable<int>(year);
    map['start_date'] = Variable<DateTime>(startDate);
    map['week_start'] = Variable<int>(weekStart);
    return map;
  }

  AnnualSchedulesCompanion toCompanion(bool nullToAbsent) {
    return AnnualSchedulesCompanion(
      year: Value(year),
      startDate: Value(startDate),
      weekStart: Value(weekStart),
    );
  }

  factory AnnualSchedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnnualSchedule(
      year: serializer.fromJson<int>(json['year']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      weekStart: serializer.fromJson<int>(json['weekStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'year': serializer.toJson<int>(year),
      'startDate': serializer.toJson<DateTime>(startDate),
      'weekStart': serializer.toJson<int>(weekStart),
    };
  }

  AnnualSchedule copyWith({int? year, DateTime? startDate, int? weekStart}) =>
      AnnualSchedule(
        year: year ?? this.year,
        startDate: startDate ?? this.startDate,
        weekStart: weekStart ?? this.weekStart,
      );
  AnnualSchedule copyWithCompanion(AnnualSchedulesCompanion data) {
    return AnnualSchedule(
      year: data.year.present ? data.year.value : this.year,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnnualSchedule(')
          ..write('year: $year, ')
          ..write('startDate: $startDate, ')
          ..write('weekStart: $weekStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(year, startDate, weekStart);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnnualSchedule &&
          other.year == this.year &&
          other.startDate == this.startDate &&
          other.weekStart == this.weekStart);
}

class AnnualSchedulesCompanion extends UpdateCompanion<AnnualSchedule> {
  final Value<int> year;
  final Value<DateTime> startDate;
  final Value<int> weekStart;
  const AnnualSchedulesCompanion({
    this.year = const Value.absent(),
    this.startDate = const Value.absent(),
    this.weekStart = const Value.absent(),
  });
  AnnualSchedulesCompanion.insert({
    this.year = const Value.absent(),
    required DateTime startDate,
    required int weekStart,
  })  : startDate = Value(startDate),
        weekStart = Value(weekStart);
  static Insertable<AnnualSchedule> custom({
    Expression<int>? year,
    Expression<DateTime>? startDate,
    Expression<int>? weekStart,
  }) {
    return RawValuesInsertable({
      if (year != null) 'year': year,
      if (startDate != null) 'start_date': startDate,
      if (weekStart != null) 'week_start': weekStart,
    });
  }

  AnnualSchedulesCompanion copyWith(
      {Value<int>? year, Value<DateTime>? startDate, Value<int>? weekStart}) {
    return AnnualSchedulesCompanion(
      year: year ?? this.year,
      startDate: startDate ?? this.startDate,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<int>(weekStart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnualSchedulesCompanion(')
          ..write('year: $year, ')
          ..write('startDate: $startDate, ')
          ..write('weekStart: $weekStart')
          ..write(')'))
        .toString();
  }
}

class $AnnualPeriodsTable extends AnnualPeriods
    with TableInfo<$AnnualPeriodsTable, AnnualPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnualPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _scheduleYearMeta =
      const VerificationMeta('scheduleYear');
  @override
  late final GeneratedColumn<int> scheduleYear = GeneratedColumn<int>(
      'schedule_year', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES annual_schedules (year)'));
  static const VerificationMeta _periodIndexMeta =
      const VerificationMeta('periodIndex');
  @override
  late final GeneratedColumn<int> periodIndex = GeneratedColumn<int>(
      'period_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
      'days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, scheduleYear, periodIndex, days];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annual_periods';
  @override
  VerificationContext validateIntegrity(Insertable<AnnualPeriod> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_year')) {
      context.handle(
          _scheduleYearMeta,
          scheduleYear.isAcceptableOrUnknown(
              data['schedule_year']!, _scheduleYearMeta));
    } else if (isInserting) {
      context.missing(_scheduleYearMeta);
    }
    if (data.containsKey('period_index')) {
      context.handle(
          _periodIndexMeta,
          periodIndex.isAcceptableOrUnknown(
              data['period_index']!, _periodIndexMeta));
    } else if (isInserting) {
      context.missing(_periodIndexMeta);
    }
    if (data.containsKey('days')) {
      context.handle(
          _daysMeta, days.isAcceptableOrUnknown(data['days']!, _daysMeta));
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnnualPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnnualPeriod(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      scheduleYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schedule_year'])!,
      periodIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_index'])!,
      days: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}days'])!,
    );
  }

  @override
  $AnnualPeriodsTable createAlias(String alias) {
    return $AnnualPeriodsTable(attachedDatabase, alias);
  }
}

class AnnualPeriod extends DataClass implements Insertable<AnnualPeriod> {
  final int id;
  final int scheduleYear;
  final int periodIndex;
  final int days;
  const AnnualPeriod(
      {required this.id,
      required this.scheduleYear,
      required this.periodIndex,
      required this.days});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schedule_year'] = Variable<int>(scheduleYear);
    map['period_index'] = Variable<int>(periodIndex);
    map['days'] = Variable<int>(days);
    return map;
  }

  AnnualPeriodsCompanion toCompanion(bool nullToAbsent) {
    return AnnualPeriodsCompanion(
      id: Value(id),
      scheduleYear: Value(scheduleYear),
      periodIndex: Value(periodIndex),
      days: Value(days),
    );
  }

  factory AnnualPeriod.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnnualPeriod(
      id: serializer.fromJson<int>(json['id']),
      scheduleYear: serializer.fromJson<int>(json['scheduleYear']),
      periodIndex: serializer.fromJson<int>(json['periodIndex']),
      days: serializer.fromJson<int>(json['days']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduleYear': serializer.toJson<int>(scheduleYear),
      'periodIndex': serializer.toJson<int>(periodIndex),
      'days': serializer.toJson<int>(days),
    };
  }

  AnnualPeriod copyWith(
          {int? id, int? scheduleYear, int? periodIndex, int? days}) =>
      AnnualPeriod(
        id: id ?? this.id,
        scheduleYear: scheduleYear ?? this.scheduleYear,
        periodIndex: periodIndex ?? this.periodIndex,
        days: days ?? this.days,
      );
  AnnualPeriod copyWithCompanion(AnnualPeriodsCompanion data) {
    return AnnualPeriod(
      id: data.id.present ? data.id.value : this.id,
      scheduleYear: data.scheduleYear.present
          ? data.scheduleYear.value
          : this.scheduleYear,
      periodIndex:
          data.periodIndex.present ? data.periodIndex.value : this.periodIndex,
      days: data.days.present ? data.days.value : this.days,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnnualPeriod(')
          ..write('id: $id, ')
          ..write('scheduleYear: $scheduleYear, ')
          ..write('periodIndex: $periodIndex, ')
          ..write('days: $days')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scheduleYear, periodIndex, days);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnnualPeriod &&
          other.id == this.id &&
          other.scheduleYear == this.scheduleYear &&
          other.periodIndex == this.periodIndex &&
          other.days == this.days);
}

class AnnualPeriodsCompanion extends UpdateCompanion<AnnualPeriod> {
  final Value<int> id;
  final Value<int> scheduleYear;
  final Value<int> periodIndex;
  final Value<int> days;
  const AnnualPeriodsCompanion({
    this.id = const Value.absent(),
    this.scheduleYear = const Value.absent(),
    this.periodIndex = const Value.absent(),
    this.days = const Value.absent(),
  });
  AnnualPeriodsCompanion.insert({
    this.id = const Value.absent(),
    required int scheduleYear,
    required int periodIndex,
    required int days,
  })  : scheduleYear = Value(scheduleYear),
        periodIndex = Value(periodIndex),
        days = Value(days);
  static Insertable<AnnualPeriod> custom({
    Expression<int>? id,
    Expression<int>? scheduleYear,
    Expression<int>? periodIndex,
    Expression<int>? days,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleYear != null) 'schedule_year': scheduleYear,
      if (periodIndex != null) 'period_index': periodIndex,
      if (days != null) 'days': days,
    });
  }

  AnnualPeriodsCompanion copyWith(
      {Value<int>? id,
      Value<int>? scheduleYear,
      Value<int>? periodIndex,
      Value<int>? days}) {
    return AnnualPeriodsCompanion(
      id: id ?? this.id,
      scheduleYear: scheduleYear ?? this.scheduleYear,
      periodIndex: periodIndex ?? this.periodIndex,
      days: days ?? this.days,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduleYear.present) {
      map['schedule_year'] = Variable<int>(scheduleYear.value);
    }
    if (periodIndex.present) {
      map['period_index'] = Variable<int>(periodIndex.value);
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnualPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('scheduleYear: $scheduleYear, ')
          ..write('periodIndex: $periodIndex, ')
          ..write('days: $days')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $AnnualSchedulesTable annualSchedules =
      $AnnualSchedulesTable(this);
  late final $AnnualPeriodsTable annualPeriods = $AnnualPeriodsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [categories, transactions, annualSchedules, annualPeriods];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required int color,
  required int type,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> color,
  Value<int> type,
});

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CategoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CategoriesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<int> type = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            color: color,
            type: type,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int color,
            required int type,
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            color: color,
            type: type,
          ),
        ));
}

class $$CategoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter transactionsRefs(
      ComposableFilter Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.transactions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder, parentComposers) =>
            $$TransactionsTableFilterComposer(ComposerState($state.db,
                $state.db.transactions, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required int amount,
  Value<String> memo,
  required int categoryId,
  required int type,
  Value<int> expenseAttribute,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> amount,
  Value<String> memo,
  Value<int> categoryId,
  Value<int> type,
  Value<int> expenseAttribute,
});

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TransactionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TransactionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String> memo = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<int> expenseAttribute = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            date: date,
            amount: amount,
            memo: memo,
            categoryId: categoryId,
            type: type,
            expenseAttribute: expenseAttribute,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required int amount,
            Value<String> memo = const Value.absent(),
            required int categoryId,
            required int type,
            Value<int> expenseAttribute = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            date: date,
            amount: amount,
            memo: memo,
            categoryId: categoryId,
            type: type,
            expenseAttribute: expenseAttribute,
          ),
        ));
}

class $$TransactionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get memo => $state.composableBuilder(
      column: $state.table.memo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get expenseAttribute => $state.composableBuilder(
      column: $state.table.expenseAttribute,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $state.db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriesTableFilterComposer(ComposerState($state.db,
                $state.db.categories, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get memo => $state.composableBuilder(
      column: $state.table.memo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get expenseAttribute => $state.composableBuilder(
      column: $state.table.expenseAttribute,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $state.db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriesTableOrderingComposer(ComposerState($state.db,
                $state.db.categories, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$AnnualSchedulesTableCreateCompanionBuilder = AnnualSchedulesCompanion
    Function({
  Value<int> year,
  required DateTime startDate,
  required int weekStart,
});
typedef $$AnnualSchedulesTableUpdateCompanionBuilder = AnnualSchedulesCompanion
    Function({
  Value<int> year,
  Value<DateTime> startDate,
  Value<int> weekStart,
});

class $$AnnualSchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnnualSchedulesTable,
    AnnualSchedule,
    $$AnnualSchedulesTableFilterComposer,
    $$AnnualSchedulesTableOrderingComposer,
    $$AnnualSchedulesTableCreateCompanionBuilder,
    $$AnnualSchedulesTableUpdateCompanionBuilder> {
  $$AnnualSchedulesTableTableManager(
      _$AppDatabase db, $AnnualSchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AnnualSchedulesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AnnualSchedulesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> year = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<int> weekStart = const Value.absent(),
          }) =>
              AnnualSchedulesCompanion(
            year: year,
            startDate: startDate,
            weekStart: weekStart,
          ),
          createCompanionCallback: ({
            Value<int> year = const Value.absent(),
            required DateTime startDate,
            required int weekStart,
          }) =>
              AnnualSchedulesCompanion.insert(
            year: year,
            startDate: startDate,
            weekStart: weekStart,
          ),
        ));
}

class $$AnnualSchedulesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AnnualSchedulesTable> {
  $$AnnualSchedulesTableFilterComposer(super.$state);
  ColumnFilters<int> get year => $state.composableBuilder(
      column: $state.table.year,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get weekStart => $state.composableBuilder(
      column: $state.table.weekStart,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter annualPeriodsRefs(
      ComposableFilter Function($$AnnualPeriodsTableFilterComposer f) f) {
    final $$AnnualPeriodsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.year,
        referencedTable: $state.db.annualPeriods,
        getReferencedColumn: (t) => t.scheduleYear,
        builder: (joinBuilder, parentComposers) =>
            $$AnnualPeriodsTableFilterComposer(ComposerState($state.db,
                $state.db.annualPeriods, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$AnnualSchedulesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AnnualSchedulesTable> {
  $$AnnualSchedulesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get year => $state.composableBuilder(
      column: $state.table.year,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get weekStart => $state.composableBuilder(
      column: $state.table.weekStart,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AnnualPeriodsTableCreateCompanionBuilder = AnnualPeriodsCompanion
    Function({
  Value<int> id,
  required int scheduleYear,
  required int periodIndex,
  required int days,
});
typedef $$AnnualPeriodsTableUpdateCompanionBuilder = AnnualPeriodsCompanion
    Function({
  Value<int> id,
  Value<int> scheduleYear,
  Value<int> periodIndex,
  Value<int> days,
});

class $$AnnualPeriodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnnualPeriodsTable,
    AnnualPeriod,
    $$AnnualPeriodsTableFilterComposer,
    $$AnnualPeriodsTableOrderingComposer,
    $$AnnualPeriodsTableCreateCompanionBuilder,
    $$AnnualPeriodsTableUpdateCompanionBuilder> {
  $$AnnualPeriodsTableTableManager(_$AppDatabase db, $AnnualPeriodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AnnualPeriodsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AnnualPeriodsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> scheduleYear = const Value.absent(),
            Value<int> periodIndex = const Value.absent(),
            Value<int> days = const Value.absent(),
          }) =>
              AnnualPeriodsCompanion(
            id: id,
            scheduleYear: scheduleYear,
            periodIndex: periodIndex,
            days: days,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int scheduleYear,
            required int periodIndex,
            required int days,
          }) =>
              AnnualPeriodsCompanion.insert(
            id: id,
            scheduleYear: scheduleYear,
            periodIndex: periodIndex,
            days: days,
          ),
        ));
}

class $$AnnualPeriodsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AnnualPeriodsTable> {
  $$AnnualPeriodsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get periodIndex => $state.composableBuilder(
      column: $state.table.periodIndex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get days => $state.composableBuilder(
      column: $state.table.days,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$AnnualSchedulesTableFilterComposer get scheduleYear {
    final $$AnnualSchedulesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.scheduleYear,
            referencedTable: $state.db.annualSchedules,
            getReferencedColumn: (t) => t.year,
            builder: (joinBuilder, parentComposers) =>
                $$AnnualSchedulesTableFilterComposer(ComposerState($state.db,
                    $state.db.annualSchedules, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$AnnualPeriodsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AnnualPeriodsTable> {
  $$AnnualPeriodsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get periodIndex => $state.composableBuilder(
      column: $state.table.periodIndex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get days => $state.composableBuilder(
      column: $state.table.days,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$AnnualSchedulesTableOrderingComposer get scheduleYear {
    final $$AnnualSchedulesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.scheduleYear,
            referencedTable: $state.db.annualSchedules,
            getReferencedColumn: (t) => t.year,
            builder: (joinBuilder, parentComposers) =>
                $$AnnualSchedulesTableOrderingComposer(ComposerState($state.db,
                    $state.db.annualSchedules, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$AnnualSchedulesTableTableManager get annualSchedules =>
      $$AnnualSchedulesTableTableManager(_db, _db.annualSchedules);
  $$AnnualPeriodsTableTableManager get annualPeriods =>
      $$AnnualPeriodsTableTableManager(_db, _db.annualPeriods);
}
