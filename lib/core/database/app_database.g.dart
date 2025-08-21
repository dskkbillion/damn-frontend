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

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
      'chat_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<int> senderId = GeneratedColumn<int>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<int> memberId = GeneratedColumn<int>(
      'member_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _doctorIdMeta =
      const VerificationMeta('doctorId');
  @override
  late final GeneratedColumn<int> doctorId = GeneratedColumn<int>(
      'doctor_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createTimeMeta =
      const VerificationMeta('createTime');
  @override
  late final GeneratedColumn<DateTime> createTime = GeneratedColumn<DateTime>(
      'create_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _withdrawFlagMeta =
      const VerificationMeta('withdrawFlag');
  @override
  late final GeneratedColumn<bool> withdrawFlag = GeneratedColumn<bool>(
      'withdraw_flag', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("withdraw_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _readFlagMeta =
      const VerificationMeta('readFlag');
  @override
  late final GeneratedColumn<bool> readFlag = GeneratedColumn<bool>(
      'read_flag', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("read_flag" IN (0, 1))'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('sent'));
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localTimestampMeta =
      const VerificationMeta('localTimestamp');
  @override
  late final GeneratedColumn<DateTime> localTimestamp =
      GeneratedColumn<DateTime>('local_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chatId,
        senderId,
        memberId,
        doctorId,
        content,
        messageType,
        createTime,
        withdrawFlag,
        readFlag,
        status,
        metadata,
        localTimestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessageCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta,
          chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta));
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    }
    if (data.containsKey('doctor_id')) {
      context.handle(_doctorIdMeta,
          doctorId.isAcceptableOrUnknown(data['doctor_id']!, _doctorIdMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('create_time')) {
      context.handle(
          _createTimeMeta,
          createTime.isAcceptableOrUnknown(
              data['create_time']!, _createTimeMeta));
    } else if (isInserting) {
      context.missing(_createTimeMeta);
    }
    if (data.containsKey('withdraw_flag')) {
      context.handle(
          _withdrawFlagMeta,
          withdrawFlag.isAcceptableOrUnknown(
              data['withdraw_flag']!, _withdrawFlagMeta));
    }
    if (data.containsKey('read_flag')) {
      context.handle(_readFlagMeta,
          readFlag.isAcceptableOrUnknown(data['read_flag']!, _readFlagMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('local_timestamp')) {
      context.handle(
          _localTimestampMeta,
          localTimestamp.isAcceptableOrUnknown(
              data['local_timestamp']!, _localTimestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageCache(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      chatId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chat_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sender_id'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}member_id']),
      doctorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}doctor_id']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type'])!,
      createTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}create_time'])!,
      withdrawFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}withdraw_flag'])!,
      readFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}read_flag']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
      localTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_timestamp'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageCache extends DataClass
    implements Insertable<ChatMessageCache> {
  final int id;
  final int chatId;
  final int senderId;
  final int? memberId;
  final int? doctorId;
  final String content;
  final String messageType;
  final DateTime createTime;
  final bool withdrawFlag;
  final bool? readFlag;
  final String status;
  final String? metadata;
  final DateTime localTimestamp;
  const ChatMessageCache(
      {required this.id,
      required this.chatId,
      required this.senderId,
      this.memberId,
      this.doctorId,
      required this.content,
      required this.messageType,
      required this.createTime,
      required this.withdrawFlag,
      this.readFlag,
      required this.status,
      this.metadata,
      required this.localTimestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chat_id'] = Variable<int>(chatId);
    map['sender_id'] = Variable<int>(senderId);
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<int>(memberId);
    }
    if (!nullToAbsent || doctorId != null) {
      map['doctor_id'] = Variable<int>(doctorId);
    }
    map['content'] = Variable<String>(content);
    map['message_type'] = Variable<String>(messageType);
    map['create_time'] = Variable<DateTime>(createTime);
    map['withdraw_flag'] = Variable<bool>(withdrawFlag);
    if (!nullToAbsent || readFlag != null) {
      map['read_flag'] = Variable<bool>(readFlag);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['local_timestamp'] = Variable<DateTime>(localTimestamp);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderId: Value(senderId),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      doctorId: doctorId == null && nullToAbsent
          ? const Value.absent()
          : Value(doctorId),
      content: Value(content),
      messageType: Value(messageType),
      createTime: Value(createTime),
      withdrawFlag: Value(withdrawFlag),
      readFlag: readFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(readFlag),
      status: Value(status),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      localTimestamp: Value(localTimestamp),
    );
  }

  factory ChatMessageCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageCache(
      id: serializer.fromJson<int>(json['id']),
      chatId: serializer.fromJson<int>(json['chatId']),
      senderId: serializer.fromJson<int>(json['senderId']),
      memberId: serializer.fromJson<int?>(json['memberId']),
      doctorId: serializer.fromJson<int?>(json['doctorId']),
      content: serializer.fromJson<String>(json['content']),
      messageType: serializer.fromJson<String>(json['messageType']),
      createTime: serializer.fromJson<DateTime>(json['createTime']),
      withdrawFlag: serializer.fromJson<bool>(json['withdrawFlag']),
      readFlag: serializer.fromJson<bool?>(json['readFlag']),
      status: serializer.fromJson<String>(json['status']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      localTimestamp: serializer.fromJson<DateTime>(json['localTimestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chatId': serializer.toJson<int>(chatId),
      'senderId': serializer.toJson<int>(senderId),
      'memberId': serializer.toJson<int?>(memberId),
      'doctorId': serializer.toJson<int?>(doctorId),
      'content': serializer.toJson<String>(content),
      'messageType': serializer.toJson<String>(messageType),
      'createTime': serializer.toJson<DateTime>(createTime),
      'withdrawFlag': serializer.toJson<bool>(withdrawFlag),
      'readFlag': serializer.toJson<bool?>(readFlag),
      'status': serializer.toJson<String>(status),
      'metadata': serializer.toJson<String?>(metadata),
      'localTimestamp': serializer.toJson<DateTime>(localTimestamp),
    };
  }

  ChatMessageCache copyWith(
          {int? id,
          int? chatId,
          int? senderId,
          Value<int?> memberId = const Value.absent(),
          Value<int?> doctorId = const Value.absent(),
          String? content,
          String? messageType,
          DateTime? createTime,
          bool? withdrawFlag,
          Value<bool?> readFlag = const Value.absent(),
          String? status,
          Value<String?> metadata = const Value.absent(),
          DateTime? localTimestamp}) =>
      ChatMessageCache(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        senderId: senderId ?? this.senderId,
        memberId: memberId.present ? memberId.value : this.memberId,
        doctorId: doctorId.present ? doctorId.value : this.doctorId,
        content: content ?? this.content,
        messageType: messageType ?? this.messageType,
        createTime: createTime ?? this.createTime,
        withdrawFlag: withdrawFlag ?? this.withdrawFlag,
        readFlag: readFlag.present ? readFlag.value : this.readFlag,
        status: status ?? this.status,
        metadata: metadata.present ? metadata.value : this.metadata,
        localTimestamp: localTimestamp ?? this.localTimestamp,
      );
  ChatMessageCache copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageCache(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      doctorId: data.doctorId.present ? data.doctorId.value : this.doctorId,
      content: data.content.present ? data.content.value : this.content,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
      createTime:
          data.createTime.present ? data.createTime.value : this.createTime,
      withdrawFlag: data.withdrawFlag.present
          ? data.withdrawFlag.value
          : this.withdrawFlag,
      readFlag: data.readFlag.present ? data.readFlag.value : this.readFlag,
      status: data.status.present ? data.status.value : this.status,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      localTimestamp: data.localTimestamp.present
          ? data.localTimestamp.value
          : this.localTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageCache(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('memberId: $memberId, ')
          ..write('doctorId: $doctorId, ')
          ..write('content: $content, ')
          ..write('messageType: $messageType, ')
          ..write('createTime: $createTime, ')
          ..write('withdrawFlag: $withdrawFlag, ')
          ..write('readFlag: $readFlag, ')
          ..write('status: $status, ')
          ..write('metadata: $metadata, ')
          ..write('localTimestamp: $localTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      chatId,
      senderId,
      memberId,
      doctorId,
      content,
      messageType,
      createTime,
      withdrawFlag,
      readFlag,
      status,
      metadata,
      localTimestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageCache &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.memberId == this.memberId &&
          other.doctorId == this.doctorId &&
          other.content == this.content &&
          other.messageType == this.messageType &&
          other.createTime == this.createTime &&
          other.withdrawFlag == this.withdrawFlag &&
          other.readFlag == this.readFlag &&
          other.status == this.status &&
          other.metadata == this.metadata &&
          other.localTimestamp == this.localTimestamp);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageCache> {
  final Value<int> id;
  final Value<int> chatId;
  final Value<int> senderId;
  final Value<int?> memberId;
  final Value<int?> doctorId;
  final Value<String> content;
  final Value<String> messageType;
  final Value<DateTime> createTime;
  final Value<bool> withdrawFlag;
  final Value<bool?> readFlag;
  final Value<String> status;
  final Value<String?> metadata;
  final Value<DateTime> localTimestamp;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.doctorId = const Value.absent(),
    this.content = const Value.absent(),
    this.messageType = const Value.absent(),
    this.createTime = const Value.absent(),
    this.withdrawFlag = const Value.absent(),
    this.readFlag = const Value.absent(),
    this.status = const Value.absent(),
    this.metadata = const Value.absent(),
    this.localTimestamp = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int chatId,
    required int senderId,
    this.memberId = const Value.absent(),
    this.doctorId = const Value.absent(),
    required String content,
    required String messageType,
    required DateTime createTime,
    this.withdrawFlag = const Value.absent(),
    this.readFlag = const Value.absent(),
    this.status = const Value.absent(),
    this.metadata = const Value.absent(),
    this.localTimestamp = const Value.absent(),
  })  : chatId = Value(chatId),
        senderId = Value(senderId),
        content = Value(content),
        messageType = Value(messageType),
        createTime = Value(createTime);
  static Insertable<ChatMessageCache> custom({
    Expression<int>? id,
    Expression<int>? chatId,
    Expression<int>? senderId,
    Expression<int>? memberId,
    Expression<int>? doctorId,
    Expression<String>? content,
    Expression<String>? messageType,
    Expression<DateTime>? createTime,
    Expression<bool>? withdrawFlag,
    Expression<bool>? readFlag,
    Expression<String>? status,
    Expression<String>? metadata,
    Expression<DateTime>? localTimestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (memberId != null) 'member_id': memberId,
      if (doctorId != null) 'doctor_id': doctorId,
      if (content != null) 'content': content,
      if (messageType != null) 'message_type': messageType,
      if (createTime != null) 'create_time': createTime,
      if (withdrawFlag != null) 'withdraw_flag': withdrawFlag,
      if (readFlag != null) 'read_flag': readFlag,
      if (status != null) 'status': status,
      if (metadata != null) 'metadata': metadata,
      if (localTimestamp != null) 'local_timestamp': localTimestamp,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? chatId,
      Value<int>? senderId,
      Value<int?>? memberId,
      Value<int?>? doctorId,
      Value<String>? content,
      Value<String>? messageType,
      Value<DateTime>? createTime,
      Value<bool>? withdrawFlag,
      Value<bool?>? readFlag,
      Value<String>? status,
      Value<String?>? metadata,
      Value<DateTime>? localTimestamp}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      memberId: memberId ?? this.memberId,
      doctorId: doctorId ?? this.doctorId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      createTime: createTime ?? this.createTime,
      withdrawFlag: withdrawFlag ?? this.withdrawFlag,
      readFlag: readFlag ?? this.readFlag,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      localTimestamp: localTimestamp ?? this.localTimestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<int>(senderId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<int>(memberId.value);
    }
    if (doctorId.present) {
      map['doctor_id'] = Variable<int>(doctorId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (createTime.present) {
      map['create_time'] = Variable<DateTime>(createTime.value);
    }
    if (withdrawFlag.present) {
      map['withdraw_flag'] = Variable<bool>(withdrawFlag.value);
    }
    if (readFlag.present) {
      map['read_flag'] = Variable<bool>(readFlag.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (localTimestamp.present) {
      map['local_timestamp'] = Variable<DateTime>(localTimestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('memberId: $memberId, ')
          ..write('doctorId: $doctorId, ')
          ..write('content: $content, ')
          ..write('messageType: $messageType, ')
          ..write('createTime: $createTime, ')
          ..write('withdrawFlag: $withdrawFlag, ')
          ..write('readFlag: $readFlag, ')
          ..write('status: $status, ')
          ..write('metadata: $metadata, ')
          ..write('localTimestamp: $localTimestamp')
          ..write(')'))
        .toString();
  }
}

class $ChatRoomsTable extends ChatRooms
    with TableInfo<$ChatRoomsTable, ChatRoomCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatRoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _participant1Meta =
      const VerificationMeta('participant1');
  @override
  late final GeneratedColumn<String> participant1 = GeneratedColumn<String>(
      'participant1', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _participant2Meta =
      const VerificationMeta('participant2');
  @override
  late final GeneratedColumn<String> participant2 = GeneratedColumn<String>(
      'participant2', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastMessageIdMeta =
      const VerificationMeta('lastMessageId');
  @override
  late final GeneratedColumn<int> lastMessageId = GeneratedColumn<int>(
      'last_message_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _productInfoMeta =
      const VerificationMeta('productInfo');
  @override
  late final GeneratedColumn<String> productInfo = GeneratedColumn<String>(
      'product_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastActivityTimeMeta =
      const VerificationMeta('lastActivityTime');
  @override
  late final GeneratedColumn<DateTime> lastActivityTime =
      GeneratedColumn<DateTime>('last_activity_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        participant1,
        participant2,
        unreadCount,
        lastMessageId,
        productInfo,
        lastActivityTime,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_rooms';
  @override
  VerificationContext validateIntegrity(Insertable<ChatRoomCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('participant1')) {
      context.handle(
          _participant1Meta,
          participant1.isAcceptableOrUnknown(
              data['participant1']!, _participant1Meta));
    } else if (isInserting) {
      context.missing(_participant1Meta);
    }
    if (data.containsKey('participant2')) {
      context.handle(
          _participant2Meta,
          participant2.isAcceptableOrUnknown(
              data['participant2']!, _participant2Meta));
    } else if (isInserting) {
      context.missing(_participant2Meta);
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('last_message_id')) {
      context.handle(
          _lastMessageIdMeta,
          lastMessageId.isAcceptableOrUnknown(
              data['last_message_id']!, _lastMessageIdMeta));
    }
    if (data.containsKey('product_info')) {
      context.handle(
          _productInfoMeta,
          productInfo.isAcceptableOrUnknown(
              data['product_info']!, _productInfoMeta));
    }
    if (data.containsKey('last_activity_time')) {
      context.handle(
          _lastActivityTimeMeta,
          lastActivityTime.isAcceptableOrUnknown(
              data['last_activity_time']!, _lastActivityTimeMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatRoomCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRoomCache(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      participant1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}participant1'])!,
      participant2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}participant2'])!,
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      lastMessageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_message_id']),
      productInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_info']),
      lastActivityTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_activity_time']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ChatRoomsTable createAlias(String alias) {
    return $ChatRoomsTable(attachedDatabase, alias);
  }
}

class ChatRoomCache extends DataClass implements Insertable<ChatRoomCache> {
  final int id;
  final String participant1;
  final String participant2;
  final int unreadCount;
  final int? lastMessageId;
  final String? productInfo;
  final DateTime? lastActivityTime;
  final DateTime updatedAt;
  const ChatRoomCache(
      {required this.id,
      required this.participant1,
      required this.participant2,
      required this.unreadCount,
      this.lastMessageId,
      this.productInfo,
      this.lastActivityTime,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['participant1'] = Variable<String>(participant1);
    map['participant2'] = Variable<String>(participant2);
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || lastMessageId != null) {
      map['last_message_id'] = Variable<int>(lastMessageId);
    }
    if (!nullToAbsent || productInfo != null) {
      map['product_info'] = Variable<String>(productInfo);
    }
    if (!nullToAbsent || lastActivityTime != null) {
      map['last_activity_time'] = Variable<DateTime>(lastActivityTime);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChatRoomsCompanion toCompanion(bool nullToAbsent) {
    return ChatRoomsCompanion(
      id: Value(id),
      participant1: Value(participant1),
      participant2: Value(participant2),
      unreadCount: Value(unreadCount),
      lastMessageId: lastMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageId),
      productInfo: productInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(productInfo),
      lastActivityTime: lastActivityTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivityTime),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChatRoomCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRoomCache(
      id: serializer.fromJson<int>(json['id']),
      participant1: serializer.fromJson<String>(json['participant1']),
      participant2: serializer.fromJson<String>(json['participant2']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      lastMessageId: serializer.fromJson<int?>(json['lastMessageId']),
      productInfo: serializer.fromJson<String?>(json['productInfo']),
      lastActivityTime:
          serializer.fromJson<DateTime?>(json['lastActivityTime']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'participant1': serializer.toJson<String>(participant1),
      'participant2': serializer.toJson<String>(participant2),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'lastMessageId': serializer.toJson<int?>(lastMessageId),
      'productInfo': serializer.toJson<String?>(productInfo),
      'lastActivityTime': serializer.toJson<DateTime?>(lastActivityTime),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChatRoomCache copyWith(
          {int? id,
          String? participant1,
          String? participant2,
          int? unreadCount,
          Value<int?> lastMessageId = const Value.absent(),
          Value<String?> productInfo = const Value.absent(),
          Value<DateTime?> lastActivityTime = const Value.absent(),
          DateTime? updatedAt}) =>
      ChatRoomCache(
        id: id ?? this.id,
        participant1: participant1 ?? this.participant1,
        participant2: participant2 ?? this.participant2,
        unreadCount: unreadCount ?? this.unreadCount,
        lastMessageId:
            lastMessageId.present ? lastMessageId.value : this.lastMessageId,
        productInfo: productInfo.present ? productInfo.value : this.productInfo,
        lastActivityTime: lastActivityTime.present
            ? lastActivityTime.value
            : this.lastActivityTime,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ChatRoomCache copyWithCompanion(ChatRoomsCompanion data) {
    return ChatRoomCache(
      id: data.id.present ? data.id.value : this.id,
      participant1: data.participant1.present
          ? data.participant1.value
          : this.participant1,
      participant2: data.participant2.present
          ? data.participant2.value
          : this.participant2,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      lastMessageId: data.lastMessageId.present
          ? data.lastMessageId.value
          : this.lastMessageId,
      productInfo:
          data.productInfo.present ? data.productInfo.value : this.productInfo,
      lastActivityTime: data.lastActivityTime.present
          ? data.lastActivityTime.value
          : this.lastActivityTime,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomCache(')
          ..write('id: $id, ')
          ..write('participant1: $participant1, ')
          ..write('participant2: $participant2, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('productInfo: $productInfo, ')
          ..write('lastActivityTime: $lastActivityTime, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, participant1, participant2, unreadCount,
      lastMessageId, productInfo, lastActivityTime, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRoomCache &&
          other.id == this.id &&
          other.participant1 == this.participant1 &&
          other.participant2 == this.participant2 &&
          other.unreadCount == this.unreadCount &&
          other.lastMessageId == this.lastMessageId &&
          other.productInfo == this.productInfo &&
          other.lastActivityTime == this.lastActivityTime &&
          other.updatedAt == this.updatedAt);
}

class ChatRoomsCompanion extends UpdateCompanion<ChatRoomCache> {
  final Value<int> id;
  final Value<String> participant1;
  final Value<String> participant2;
  final Value<int> unreadCount;
  final Value<int?> lastMessageId;
  final Value<String?> productInfo;
  final Value<DateTime?> lastActivityTime;
  final Value<DateTime> updatedAt;
  const ChatRoomsCompanion({
    this.id = const Value.absent(),
    this.participant1 = const Value.absent(),
    this.participant2 = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.productInfo = const Value.absent(),
    this.lastActivityTime = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ChatRoomsCompanion.insert({
    this.id = const Value.absent(),
    required String participant1,
    required String participant2,
    this.unreadCount = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.productInfo = const Value.absent(),
    this.lastActivityTime = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : participant1 = Value(participant1),
        participant2 = Value(participant2);
  static Insertable<ChatRoomCache> custom({
    Expression<int>? id,
    Expression<String>? participant1,
    Expression<String>? participant2,
    Expression<int>? unreadCount,
    Expression<int>? lastMessageId,
    Expression<String>? productInfo,
    Expression<DateTime>? lastActivityTime,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (participant1 != null) 'participant1': participant1,
      if (participant2 != null) 'participant2': participant2,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (productInfo != null) 'product_info': productInfo,
      if (lastActivityTime != null) 'last_activity_time': lastActivityTime,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ChatRoomsCompanion copyWith(
      {Value<int>? id,
      Value<String>? participant1,
      Value<String>? participant2,
      Value<int>? unreadCount,
      Value<int?>? lastMessageId,
      Value<String?>? productInfo,
      Value<DateTime?>? lastActivityTime,
      Value<DateTime>? updatedAt}) {
    return ChatRoomsCompanion(
      id: id ?? this.id,
      participant1: participant1 ?? this.participant1,
      participant2: participant2 ?? this.participant2,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      productInfo: productInfo ?? this.productInfo,
      lastActivityTime: lastActivityTime ?? this.lastActivityTime,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (participant1.present) {
      map['participant1'] = Variable<String>(participant1.value);
    }
    if (participant2.present) {
      map['participant2'] = Variable<String>(participant2.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<int>(lastMessageId.value);
    }
    if (productInfo.present) {
      map['product_info'] = Variable<String>(productInfo.value);
    }
    if (lastActivityTime.present) {
      map['last_activity_time'] = Variable<DateTime>(lastActivityTime.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomsCompanion(')
          ..write('id: $id, ')
          ..write('participant1: $participant1, ')
          ..write('participant2: $participant2, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('productInfo: $productInfo, ')
          ..write('lastActivityTime: $lastActivityTime, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MessageQueueTable extends MessageQueue
    with TableInfo<$MessageQueueTable, MessageQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
      'chat_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxRetriesMeta =
      const VerificationMeta('maxRetries');
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
      'max_retries', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastRetryAtMeta =
      const VerificationMeta('lastRetryAt');
  @override
  late final GeneratedColumn<DateTime> lastRetryAt = GeneratedColumn<DateTime>(
      'last_retry_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chatId,
        content,
        messageType,
        retryCount,
        maxRetries,
        createdAt,
        lastRetryAt,
        status,
        errorMessage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_queue';
  @override
  VerificationContext validateIntegrity(Insertable<MessageQueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta,
          chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta));
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('max_retries')) {
      context.handle(
          _maxRetriesMeta,
          maxRetries.isAcceptableOrUnknown(
              data['max_retries']!, _maxRetriesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_retry_at')) {
      context.handle(
          _lastRetryAtMeta,
          lastRetryAt.isAcceptableOrUnknown(
              data['last_retry_at']!, _lastRetryAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageQueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      chatId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chat_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      maxRetries: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_retries'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_retry_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
    );
  }

  @override
  $MessageQueueTable createAlias(String alias) {
    return $MessageQueueTable(attachedDatabase, alias);
  }
}

class MessageQueueItem extends DataClass
    implements Insertable<MessageQueueItem> {
  final int id;
  final int chatId;
  final String content;
  final String messageType;
  final int retryCount;
  final int maxRetries;
  final DateTime createdAt;
  final DateTime? lastRetryAt;
  final String status;
  final String? errorMessage;
  const MessageQueueItem(
      {required this.id,
      required this.chatId,
      required this.content,
      required this.messageType,
      required this.retryCount,
      required this.maxRetries,
      required this.createdAt,
      this.lastRetryAt,
      required this.status,
      this.errorMessage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chat_id'] = Variable<int>(chatId);
    map['content'] = Variable<String>(content);
    map['message_type'] = Variable<String>(messageType);
    map['retry_count'] = Variable<int>(retryCount);
    map['max_retries'] = Variable<int>(maxRetries);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastRetryAt != null) {
      map['last_retry_at'] = Variable<DateTime>(lastRetryAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  MessageQueueCompanion toCompanion(bool nullToAbsent) {
    return MessageQueueCompanion(
      id: Value(id),
      chatId: Value(chatId),
      content: Value(content),
      messageType: Value(messageType),
      retryCount: Value(retryCount),
      maxRetries: Value(maxRetries),
      createdAt: Value(createdAt),
      lastRetryAt: lastRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRetryAt),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory MessageQueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageQueueItem(
      id: serializer.fromJson<int>(json['id']),
      chatId: serializer.fromJson<int>(json['chatId']),
      content: serializer.fromJson<String>(json['content']),
      messageType: serializer.fromJson<String>(json['messageType']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastRetryAt: serializer.fromJson<DateTime?>(json['lastRetryAt']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chatId': serializer.toJson<int>(chatId),
      'content': serializer.toJson<String>(content),
      'messageType': serializer.toJson<String>(messageType),
      'retryCount': serializer.toJson<int>(retryCount),
      'maxRetries': serializer.toJson<int>(maxRetries),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastRetryAt': serializer.toJson<DateTime?>(lastRetryAt),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  MessageQueueItem copyWith(
          {int? id,
          int? chatId,
          String? content,
          String? messageType,
          int? retryCount,
          int? maxRetries,
          DateTime? createdAt,
          Value<DateTime?> lastRetryAt = const Value.absent(),
          String? status,
          Value<String?> errorMessage = const Value.absent()}) =>
      MessageQueueItem(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        content: content ?? this.content,
        messageType: messageType ?? this.messageType,
        retryCount: retryCount ?? this.retryCount,
        maxRetries: maxRetries ?? this.maxRetries,
        createdAt: createdAt ?? this.createdAt,
        lastRetryAt: lastRetryAt.present ? lastRetryAt.value : this.lastRetryAt,
        status: status ?? this.status,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
      );
  MessageQueueItem copyWithCompanion(MessageQueueCompanion data) {
    return MessageQueueItem(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      content: data.content.present ? data.content.value : this.content,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      maxRetries:
          data.maxRetries.present ? data.maxRetries.value : this.maxRetries,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastRetryAt:
          data.lastRetryAt.present ? data.lastRetryAt.value : this.lastRetryAt,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageQueueItem(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('content: $content, ')
          ..write('messageType: $messageType, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastRetryAt: $lastRetryAt, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chatId, content, messageType, retryCount,
      maxRetries, createdAt, lastRetryAt, status, errorMessage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageQueueItem &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.content == this.content &&
          other.messageType == this.messageType &&
          other.retryCount == this.retryCount &&
          other.maxRetries == this.maxRetries &&
          other.createdAt == this.createdAt &&
          other.lastRetryAt == this.lastRetryAt &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage);
}

class MessageQueueCompanion extends UpdateCompanion<MessageQueueItem> {
  final Value<int> id;
  final Value<int> chatId;
  final Value<String> content;
  final Value<String> messageType;
  final Value<int> retryCount;
  final Value<int> maxRetries;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastRetryAt;
  final Value<String> status;
  final Value<String?> errorMessage;
  const MessageQueueCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.content = const Value.absent(),
    this.messageType = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastRetryAt = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  MessageQueueCompanion.insert({
    this.id = const Value.absent(),
    required int chatId,
    required String content,
    required String messageType,
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastRetryAt = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  })  : chatId = Value(chatId),
        content = Value(content),
        messageType = Value(messageType);
  static Insertable<MessageQueueItem> custom({
    Expression<int>? id,
    Expression<int>? chatId,
    Expression<String>? content,
    Expression<String>? messageType,
    Expression<int>? retryCount,
    Expression<int>? maxRetries,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastRetryAt,
    Expression<String>? status,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (content != null) 'content': content,
      if (messageType != null) 'message_type': messageType,
      if (retryCount != null) 'retry_count': retryCount,
      if (maxRetries != null) 'max_retries': maxRetries,
      if (createdAt != null) 'created_at': createdAt,
      if (lastRetryAt != null) 'last_retry_at': lastRetryAt,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  MessageQueueCompanion copyWith(
      {Value<int>? id,
      Value<int>? chatId,
      Value<String>? content,
      Value<String>? messageType,
      Value<int>? retryCount,
      Value<int>? maxRetries,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastRetryAt,
      Value<String>? status,
      Value<String?>? errorMessage}) {
    return MessageQueueCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      createdAt: createdAt ?? this.createdAt,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastRetryAt.present) {
      map['last_retry_at'] = Variable<DateTime>(lastRetryAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageQueueCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('content: $content, ')
          ..write('messageType: $messageType, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastRetryAt: $lastRetryAt, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $ChatRoomsTable chatRooms = $ChatRoomsTable(this);
  late final $MessageQueueTable messageQueue = $MessageQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [orders, chatMessages, chatRooms, messageQueue];
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
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  required int chatId,
  required int senderId,
  Value<int?> memberId,
  Value<int?> doctorId,
  required String content,
  required String messageType,
  required DateTime createTime,
  Value<bool> withdrawFlag,
  Value<bool?> readFlag,
  Value<String> status,
  Value<String?> metadata,
  Value<DateTime> localTimestamp,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  Value<int> chatId,
  Value<int> senderId,
  Value<int?> memberId,
  Value<int?> doctorId,
  Value<String> content,
  Value<String> messageType,
  Value<DateTime> createTime,
  Value<bool> withdrawFlag,
  Value<bool?> readFlag,
  Value<String> status,
  Value<String?> metadata,
  Value<DateTime> localTimestamp,
});

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chatId => $composableBuilder(
      column: $table.chatId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get doctorId => $composableBuilder(
      column: $table.doctorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createTime => $composableBuilder(
      column: $table.createTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get withdrawFlag => $composableBuilder(
      column: $table.withdrawFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get readFlag => $composableBuilder(
      column: $table.readFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localTimestamp => $composableBuilder(
      column: $table.localTimestamp,
      builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chatId => $composableBuilder(
      column: $table.chatId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get doctorId => $composableBuilder(
      column: $table.doctorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createTime => $composableBuilder(
      column: $table.createTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get withdrawFlag => $composableBuilder(
      column: $table.withdrawFlag,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get readFlag => $composableBuilder(
      column: $table.readFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localTimestamp => $composableBuilder(
      column: $table.localTimestamp,
      builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<int> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<int> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<int> get doctorId =>
      $composableBuilder(column: $table.doctorId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => column);

  GeneratedColumn<DateTime> get createTime => $composableBuilder(
      column: $table.createTime, builder: (column) => column);

  GeneratedColumn<bool> get withdrawFlag => $composableBuilder(
      column: $table.withdrawFlag, builder: (column) => column);

  GeneratedColumn<bool> get readFlag =>
      $composableBuilder(column: $table.readFlag, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get localTimestamp => $composableBuilder(
      column: $table.localTimestamp, builder: (column) => column);
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageCache,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageCache,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageCache>
    ),
    ChatMessageCache,
    PrefetchHooks Function()> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> chatId = const Value.absent(),
            Value<int> senderId = const Value.absent(),
            Value<int?> memberId = const Value.absent(),
            Value<int?> doctorId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> messageType = const Value.absent(),
            Value<DateTime> createTime = const Value.absent(),
            Value<bool> withdrawFlag = const Value.absent(),
            Value<bool?> readFlag = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<DateTime> localTimestamp = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            chatId: chatId,
            senderId: senderId,
            memberId: memberId,
            doctorId: doctorId,
            content: content,
            messageType: messageType,
            createTime: createTime,
            withdrawFlag: withdrawFlag,
            readFlag: readFlag,
            status: status,
            metadata: metadata,
            localTimestamp: localTimestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int chatId,
            required int senderId,
            Value<int?> memberId = const Value.absent(),
            Value<int?> doctorId = const Value.absent(),
            required String content,
            required String messageType,
            required DateTime createTime,
            Value<bool> withdrawFlag = const Value.absent(),
            Value<bool?> readFlag = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<DateTime> localTimestamp = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            chatId: chatId,
            senderId: senderId,
            memberId: memberId,
            doctorId: doctorId,
            content: content,
            messageType: messageType,
            createTime: createTime,
            withdrawFlag: withdrawFlag,
            readFlag: readFlag,
            status: status,
            metadata: metadata,
            localTimestamp: localTimestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageCache,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageCache,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageCache>
    ),
    ChatMessageCache,
    PrefetchHooks Function()>;
typedef $$ChatRoomsTableCreateCompanionBuilder = ChatRoomsCompanion Function({
  Value<int> id,
  required String participant1,
  required String participant2,
  Value<int> unreadCount,
  Value<int?> lastMessageId,
  Value<String?> productInfo,
  Value<DateTime?> lastActivityTime,
  Value<DateTime> updatedAt,
});
typedef $$ChatRoomsTableUpdateCompanionBuilder = ChatRoomsCompanion Function({
  Value<int> id,
  Value<String> participant1,
  Value<String> participant2,
  Value<int> unreadCount,
  Value<int?> lastMessageId,
  Value<String?> productInfo,
  Value<DateTime?> lastActivityTime,
  Value<DateTime> updatedAt,
});

class $$ChatRoomsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatRoomsTable> {
  $$ChatRoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get participant1 => $composableBuilder(
      column: $table.participant1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get participant2 => $composableBuilder(
      column: $table.participant2, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastMessageId => $composableBuilder(
      column: $table.lastMessageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productInfo => $composableBuilder(
      column: $table.productInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastActivityTime => $composableBuilder(
      column: $table.lastActivityTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ChatRoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatRoomsTable> {
  $$ChatRoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participant1 => $composableBuilder(
      column: $table.participant1,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participant2 => $composableBuilder(
      column: $table.participant2,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastMessageId => $composableBuilder(
      column: $table.lastMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productInfo => $composableBuilder(
      column: $table.productInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastActivityTime => $composableBuilder(
      column: $table.lastActivityTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatRoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatRoomsTable> {
  $$ChatRoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get participant1 => $composableBuilder(
      column: $table.participant1, builder: (column) => column);

  GeneratedColumn<String> get participant2 => $composableBuilder(
      column: $table.participant2, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => column);

  GeneratedColumn<int> get lastMessageId => $composableBuilder(
      column: $table.lastMessageId, builder: (column) => column);

  GeneratedColumn<String> get productInfo => $composableBuilder(
      column: $table.productInfo, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActivityTime => $composableBuilder(
      column: $table.lastActivityTime, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChatRoomsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatRoomsTable,
    ChatRoomCache,
    $$ChatRoomsTableFilterComposer,
    $$ChatRoomsTableOrderingComposer,
    $$ChatRoomsTableAnnotationComposer,
    $$ChatRoomsTableCreateCompanionBuilder,
    $$ChatRoomsTableUpdateCompanionBuilder,
    (
      ChatRoomCache,
      BaseReferences<_$AppDatabase, $ChatRoomsTable, ChatRoomCache>
    ),
    ChatRoomCache,
    PrefetchHooks Function()> {
  $$ChatRoomsTableTableManager(_$AppDatabase db, $ChatRoomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> participant1 = const Value.absent(),
            Value<String> participant2 = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<int?> lastMessageId = const Value.absent(),
            Value<String?> productInfo = const Value.absent(),
            Value<DateTime?> lastActivityTime = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ChatRoomsCompanion(
            id: id,
            participant1: participant1,
            participant2: participant2,
            unreadCount: unreadCount,
            lastMessageId: lastMessageId,
            productInfo: productInfo,
            lastActivityTime: lastActivityTime,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String participant1,
            required String participant2,
            Value<int> unreadCount = const Value.absent(),
            Value<int?> lastMessageId = const Value.absent(),
            Value<String?> productInfo = const Value.absent(),
            Value<DateTime?> lastActivityTime = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ChatRoomsCompanion.insert(
            id: id,
            participant1: participant1,
            participant2: participant2,
            unreadCount: unreadCount,
            lastMessageId: lastMessageId,
            productInfo: productInfo,
            lastActivityTime: lastActivityTime,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatRoomsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatRoomsTable,
    ChatRoomCache,
    $$ChatRoomsTableFilterComposer,
    $$ChatRoomsTableOrderingComposer,
    $$ChatRoomsTableAnnotationComposer,
    $$ChatRoomsTableCreateCompanionBuilder,
    $$ChatRoomsTableUpdateCompanionBuilder,
    (
      ChatRoomCache,
      BaseReferences<_$AppDatabase, $ChatRoomsTable, ChatRoomCache>
    ),
    ChatRoomCache,
    PrefetchHooks Function()>;
typedef $$MessageQueueTableCreateCompanionBuilder = MessageQueueCompanion
    Function({
  Value<int> id,
  required int chatId,
  required String content,
  required String messageType,
  Value<int> retryCount,
  Value<int> maxRetries,
  Value<DateTime> createdAt,
  Value<DateTime?> lastRetryAt,
  Value<String> status,
  Value<String?> errorMessage,
});
typedef $$MessageQueueTableUpdateCompanionBuilder = MessageQueueCompanion
    Function({
  Value<int> id,
  Value<int> chatId,
  Value<String> content,
  Value<String> messageType,
  Value<int> retryCount,
  Value<int> maxRetries,
  Value<DateTime> createdAt,
  Value<DateTime?> lastRetryAt,
  Value<String> status,
  Value<String?> errorMessage,
});

class $$MessageQueueTableFilterComposer
    extends Composer<_$AppDatabase, $MessageQueueTable> {
  $$MessageQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chatId => $composableBuilder(
      column: $table.chatId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastRetryAt => $composableBuilder(
      column: $table.lastRetryAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));
}

class $$MessageQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageQueueTable> {
  $$MessageQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chatId => $composableBuilder(
      column: $table.chatId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastRetryAt => $composableBuilder(
      column: $table.lastRetryAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));
}

class $$MessageQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageQueueTable> {
  $$MessageQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRetryAt => $composableBuilder(
      column: $table.lastRetryAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);
}

class $$MessageQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessageQueueTable,
    MessageQueueItem,
    $$MessageQueueTableFilterComposer,
    $$MessageQueueTableOrderingComposer,
    $$MessageQueueTableAnnotationComposer,
    $$MessageQueueTableCreateCompanionBuilder,
    $$MessageQueueTableUpdateCompanionBuilder,
    (
      MessageQueueItem,
      BaseReferences<_$AppDatabase, $MessageQueueTable, MessageQueueItem>
    ),
    MessageQueueItem,
    PrefetchHooks Function()> {
  $$MessageQueueTableTableManager(_$AppDatabase db, $MessageQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> chatId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> messageType = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastRetryAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
          }) =>
              MessageQueueCompanion(
            id: id,
            chatId: chatId,
            content: content,
            messageType: messageType,
            retryCount: retryCount,
            maxRetries: maxRetries,
            createdAt: createdAt,
            lastRetryAt: lastRetryAt,
            status: status,
            errorMessage: errorMessage,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int chatId,
            required String content,
            required String messageType,
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastRetryAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
          }) =>
              MessageQueueCompanion.insert(
            id: id,
            chatId: chatId,
            content: content,
            messageType: messageType,
            retryCount: retryCount,
            maxRetries: maxRetries,
            createdAt: createdAt,
            lastRetryAt: lastRetryAt,
            status: status,
            errorMessage: errorMessage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessageQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessageQueueTable,
    MessageQueueItem,
    $$MessageQueueTableFilterComposer,
    $$MessageQueueTableOrderingComposer,
    $$MessageQueueTableAnnotationComposer,
    $$MessageQueueTableCreateCompanionBuilder,
    $$MessageQueueTableUpdateCompanionBuilder,
    (
      MessageQueueItem,
      BaseReferences<_$AppDatabase, $MessageQueueTable, MessageQueueItem>
    ),
    MessageQueueItem,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$ChatRoomsTableTableManager get chatRooms =>
      $$ChatRoomsTableTableManager(_db, _db.chatRooms);
  $$MessageQueueTableTableManager get messageQueue =>
      $$MessageQueueTableTableManager(_db, _db.messageQueue);
}
