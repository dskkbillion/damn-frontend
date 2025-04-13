// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OrdersTable extends Orders with TableInfo<$OrdersTable, OrderCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _orderSnMeta =
      const VerificationMeta('orderSn');
  @override
  late final GeneratedColumn<String> orderSn = GeneratedColumn<String>(
      'order_sn', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firstItemNameMeta =
      const VerificationMeta('firstItemName');
  @override
  late final GeneratedColumn<String> firstItemName = GeneratedColumn<String>(
      'first_item_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firstItemImageMeta =
      const VerificationMeta('firstItemImage');
  @override
  late final GeneratedColumn<String> firstItemImage = GeneratedColumn<String>(
      'first_item_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalPriceMeta =
      const VerificationMeta('totalPrice');
  @override
  late final GeneratedColumn<String> totalPrice = GeneratedColumn<String>(
      'total_price', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orderSn,
        state,
        firstItemName,
        firstItemImage,
        totalPrice,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<OrderCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_sn')) {
      context.handle(_orderSnMeta,
          orderSn.isAcceptableOrUnknown(data['order_sn']!, _orderSnMeta));
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('first_item_name')) {
      context.handle(
          _firstItemNameMeta,
          firstItemName.isAcceptableOrUnknown(
              data['first_item_name']!, _firstItemNameMeta));
    }
    if (data.containsKey('first_item_image')) {
      context.handle(
          _firstItemImageMeta,
          firstItemImage.isAcceptableOrUnknown(
              data['first_item_image']!, _firstItemImageMeta));
    }
    if (data.containsKey('total_price')) {
      context.handle(
          _totalPriceMeta,
          totalPrice.isAcceptableOrUnknown(
              data['total_price']!, _totalPriceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderCache(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderSn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_sn']),
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state']),
      firstItemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_item_name']),
      firstItemImage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}first_item_image']),
      totalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}total_price']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class OrderCache extends DataClass implements Insertable<OrderCache> {
  final int id;
  final String? orderSn;
  final String? state;
  final String? firstItemName;
  final String? firstItemImage;
  final String? totalPrice;
  final DateTime? createdAt;
  const OrderCache(
      {required this.id,
      this.orderSn,
      this.state,
      this.firstItemName,
      this.firstItemImage,
      this.totalPrice,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || orderSn != null) {
      map['order_sn'] = Variable<String>(orderSn);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || firstItemName != null) {
      map['first_item_name'] = Variable<String>(firstItemName);
    }
    if (!nullToAbsent || firstItemImage != null) {
      map['first_item_image'] = Variable<String>(firstItemImage);
    }
    if (!nullToAbsent || totalPrice != null) {
      map['total_price'] = Variable<String>(totalPrice);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      orderSn: orderSn == null && nullToAbsent
          ? const Value.absent()
          : Value(orderSn),
      state:
          state == null && nullToAbsent ? const Value.absent() : Value(state),
      firstItemName: firstItemName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstItemName),
      firstItemImage: firstItemImage == null && nullToAbsent
          ? const Value.absent()
          : Value(firstItemImage),
      totalPrice: totalPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPrice),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory OrderCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderCache(
      id: serializer.fromJson<int>(json['id']),
      orderSn: serializer.fromJson<String?>(json['orderSn']),
      state: serializer.fromJson<String?>(json['state']),
      firstItemName: serializer.fromJson<String?>(json['firstItemName']),
      firstItemImage: serializer.fromJson<String?>(json['firstItemImage']),
      totalPrice: serializer.fromJson<String?>(json['totalPrice']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderSn': serializer.toJson<String?>(orderSn),
      'state': serializer.toJson<String?>(state),
      'firstItemName': serializer.toJson<String?>(firstItemName),
      'firstItemImage': serializer.toJson<String?>(firstItemImage),
      'totalPrice': serializer.toJson<String?>(totalPrice),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  OrderCache copyWith(
          {int? id,
          Value<String?> orderSn = const Value.absent(),
          Value<String?> state = const Value.absent(),
          Value<String?> firstItemName = const Value.absent(),
          Value<String?> firstItemImage = const Value.absent(),
          Value<String?> totalPrice = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      OrderCache(
        id: id ?? this.id,
        orderSn: orderSn.present ? orderSn.value : this.orderSn,
        state: state.present ? state.value : this.state,
        firstItemName:
            firstItemName.present ? firstItemName.value : this.firstItemName,
        firstItemImage:
            firstItemImage.present ? firstItemImage.value : this.firstItemImage,
        totalPrice: totalPrice.present ? totalPrice.value : this.totalPrice,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  OrderCache copyWithCompanion(OrdersCompanion data) {
    return OrderCache(
      id: data.id.present ? data.id.value : this.id,
      orderSn: data.orderSn.present ? data.orderSn.value : this.orderSn,
      state: data.state.present ? data.state.value : this.state,
      firstItemName: data.firstItemName.present
          ? data.firstItemName.value
          : this.firstItemName,
      firstItemImage: data.firstItemImage.present
          ? data.firstItemImage.value
          : this.firstItemImage,
      totalPrice:
          data.totalPrice.present ? data.totalPrice.value : this.totalPrice,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderCache(')
          ..write('id: $id, ')
          ..write('orderSn: $orderSn, ')
          ..write('state: $state, ')
          ..write('firstItemName: $firstItemName, ')
          ..write('firstItemImage: $firstItemImage, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, orderSn, state, firstItemName, firstItemImage, totalPrice, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderCache &&
          other.id == this.id &&
          other.orderSn == this.orderSn &&
          other.state == this.state &&
          other.firstItemName == this.firstItemName &&
          other.firstItemImage == this.firstItemImage &&
          other.totalPrice == this.totalPrice &&
          other.createdAt == this.createdAt);
}

class OrdersCompanion extends UpdateCompanion<OrderCache> {
  final Value<int> id;
  final Value<String?> orderSn;
  final Value<String?> state;
  final Value<String?> firstItemName;
  final Value<String?> firstItemImage;
  final Value<String?> totalPrice;
  final Value<DateTime?> createdAt;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.orderSn = const Value.absent(),
    this.state = const Value.absent(),
    this.firstItemName = const Value.absent(),
    this.firstItemImage = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OrdersCompanion.insert({
    this.id = const Value.absent(),
    this.orderSn = const Value.absent(),
    this.state = const Value.absent(),
    this.firstItemName = const Value.absent(),
    this.firstItemImage = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<OrderCache> custom({
    Expression<int>? id,
    Expression<String>? orderSn,
    Expression<String>? state,
    Expression<String>? firstItemName,
    Expression<String>? firstItemImage,
    Expression<String>? totalPrice,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderSn != null) 'order_sn': orderSn,
      if (state != null) 'state': state,
      if (firstItemName != null) 'first_item_name': firstItemName,
      if (firstItemImage != null) 'first_item_image': firstItemImage,
      if (totalPrice != null) 'total_price': totalPrice,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OrdersCompanion copyWith(
      {Value<int>? id,
      Value<String?>? orderSn,
      Value<String?>? state,
      Value<String?>? firstItemName,
      Value<String?>? firstItemImage,
      Value<String?>? totalPrice,
      Value<DateTime?>? createdAt}) {
    return OrdersCompanion(
      id: id ?? this.id,
      orderSn: orderSn ?? this.orderSn,
      state: state ?? this.state,
      firstItemName: firstItemName ?? this.firstItemName,
      firstItemImage: firstItemImage ?? this.firstItemImage,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderSn.present) {
      map['order_sn'] = Variable<String>(orderSn.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (firstItemName.present) {
      map['first_item_name'] = Variable<String>(firstItemName.value);
    }
    if (firstItemImage.present) {
      map['first_item_image'] = Variable<String>(firstItemImage.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<String>(totalPrice.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('orderSn: $orderSn, ')
          ..write('state: $state, ')
          ..write('firstItemName: $firstItemName, ')
          ..write('firstItemImage: $firstItemImage, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrdersTable orders = $OrdersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [orders];
}

typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  Value<String?> orderSn,
  Value<String?> state,
  Value<String?> firstItemName,
  Value<String?> firstItemImage,
  Value<String?> totalPrice,
  Value<DateTime?> createdAt,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  Value<String?> orderSn,
  Value<String?> state,
  Value<String?> firstItemName,
  Value<String?> firstItemImage,
  Value<String?> totalPrice,
  Value<DateTime?> createdAt,
});

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderSn => $composableBuilder(
      column: $table.orderSn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstItemName => $composableBuilder(
      column: $table.firstItemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstItemImage => $composableBuilder(
      column: $table.firstItemImage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderSn => $composableBuilder(
      column: $table.orderSn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstItemName => $composableBuilder(
      column: $table.firstItemName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstItemImage => $composableBuilder(
      column: $table.firstItemImage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderSn =>
      $composableBuilder(column: $table.orderSn, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get firstItemName => $composableBuilder(
      column: $table.firstItemName, builder: (column) => column);

  GeneratedColumn<String> get firstItemImage => $composableBuilder(
      column: $table.firstItemImage, builder: (column) => column);

  GeneratedColumn<String> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTable,
    OrderCache,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (OrderCache, BaseReferences<_$AppDatabase, $OrdersTable, OrderCache>),
    OrderCache,
    PrefetchHooks Function()> {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> orderSn = const Value.absent(),
            Value<String?> state = const Value.absent(),
            Value<String?> firstItemName = const Value.absent(),
            Value<String?> firstItemImage = const Value.absent(),
            Value<String?> totalPrice = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
          }) =>
              OrdersCompanion(
            id: id,
            orderSn: orderSn,
            state: state,
            firstItemName: firstItemName,
            firstItemImage: firstItemImage,
            totalPrice: totalPrice,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> orderSn = const Value.absent(),
            Value<String?> state = const Value.absent(),
            Value<String?> firstItemName = const Value.absent(),
            Value<String?> firstItemImage = const Value.absent(),
            Value<String?> totalPrice = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
          }) =>
              OrdersCompanion.insert(
            id: id,
            orderSn: orderSn,
            state: state,
            firstItemName: firstItemName,
            firstItemImage: firstItemImage,
            totalPrice: totalPrice,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrdersTable,
    OrderCache,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (OrderCache, BaseReferences<_$AppDatabase, $OrdersTable, OrderCache>),
    OrderCache,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
}
