import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import table definitions
import 'tables/orders_table.dart';
import 'tables/chat_tables.dart';
// import 'daos/order_dao.dart'; // Remove DAO import

part 'app_database.g.dart'; // Drift will generate this file

@DriftDatabase(
  tables: [Orders, ChatMessages, ChatRooms, MessageQueue],
  // daos: [OrderDao], // Remove DAO from annotation
)
class AppDatabase extends _$AppDatabase {
  // Define the database version (important for migrations)
  static const int dbVersion = 2;

  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => dbVersion;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add chat tables in version 2
          await m.createTable(chatMessages);
          await m.createTable(chatRooms);
          await m.createTable(messageQueue);
        }
      },
    );
  }

  // --- Add methods directly from OrderDao --- 

  // Get all orders
  Future<List<OrderCache>> getAllOrders() => select(orders).get();

  // Watch all orders 
  Stream<List<OrderCache>> watchAllOrders() => select(orders).watch();

  // Get orders by state with pagination
  Future<List<OrderCache>> getOrdersByState(String state, int limit, int offset) {
    return (select(orders)
          ..where((tbl) => tbl.state.equals(state))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]) 
          ..limit(limit, offset: offset))
        .get();
  }

  // Watch orders by state
  Stream<List<OrderCache>> watchOrdersByState(String state) {
    return (select(orders)
          ..where((tbl) => tbl.state.equals(state))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  // --- Add method for getting all orders (paginated) --- 
  Future<List<OrderCache>> getAllOrdersPaginated(int limit, int offset) {
    return (select(orders)
          // No state filter here
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]) 
          ..limit(limit, offset: offset))
        .get();
  }

  // Insert a single order cache entry
  Future<int> insertOrder(OrderCache order) => into(orders).insert(order, mode: InsertMode.insertOrReplace);

  // Insert multiple orders
  Future<void> insertOrders(List<OrderCache> orderList) async {
    await batch((batch) {
      batch.insertAll(orders, orderList, mode: InsertMode.insertOrReplace);
    });
  }

  // Delete orders by state
  Future<int> deleteOrdersByState(String state) {
    return (delete(orders)..where((tbl) => tbl.state.equals(state))).go();
  }

  // Delete all orders
  Future<int> deleteAllOrders() => delete(orders).go();
  
  // --- Chat-related methods ---
  
  // Chat Messages
  Future<List<ChatMessageCache>> getChatMessages(int chatId, {int limit = 50, int offset = 0}) {
    return (select(chatMessages)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createTime, mode: OrderingMode.desc)])
          ..limit(limit, offset: offset))
        .get();
  }
  
  Stream<List<ChatMessageCache>> watchChatMessages(int chatId) {
    return (select(chatMessages)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createTime, mode: OrderingMode.asc)]))
        .watch();
  }
  
  Future<int> insertChatMessage(ChatMessageCache message) {
    return into(chatMessages).insert(message, mode: InsertMode.insertOrReplace);
  }
  
  Future<void> insertChatMessages(List<ChatMessageCache> messages) async {
    await batch((batch) {
      batch.insertAll(chatMessages, messages, mode: InsertMode.insertOrReplace);
    });
  }
  
  Future<int> updateMessageStatus(int messageId, String status) {
    return (update(chatMessages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .write(ChatMessagesCompanion(status: Value(status)));
  }
  
  Future<int> markMessageAsWithdrawn(int messageId) {
    return (update(chatMessages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .write(const ChatMessagesCompanion(withdrawFlag: Value(true)));
  }
  
  // Chat Rooms
  Future<List<ChatRoomCache>> getChatRooms() {
    return (select(chatRooms)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.lastActivityTime, mode: OrderingMode.desc)]))
        .get();
  }
  
  Stream<List<ChatRoomCache>> watchChatRooms() {
    return (select(chatRooms)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.lastActivityTime, mode: OrderingMode.desc)]))
        .watch();
  }
  
  Future<ChatRoomCache?> getChatRoom(int chatId) {
    return (select(chatRooms)..where((tbl) => tbl.id.equals(chatId))).getSingleOrNull();
  }
  
  Future<int> insertChatRoom(ChatRoomCache room) {
    return into(chatRooms).insert(room, mode: InsertMode.insertOrReplace);
  }
  
  Future<void> insertChatRooms(List<ChatRoomCache> rooms) async {
    await batch((batch) {
      batch.insertAll(chatRooms, rooms, mode: InsertMode.insertOrReplace);
    });
  }
  
  Future<int> updateChatRoomUnreadCount(int chatId, int unreadCount) {
    return (update(chatRooms)
          ..where((tbl) => tbl.id.equals(chatId)))
        .write(ChatRoomsCompanion(
          unreadCount: Value(unreadCount),
          updatedAt: Value(DateTime.now()),
        ));
  }
  
  // Message Queue
  Future<List<MessageQueueItem>> getPendingMessages() {
    return (select(messageQueue)
          ..where((tbl) => tbl.status.equals('pending'))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.asc)]))
        .get();
  }
  
  Stream<List<MessageQueueItem>> watchPendingMessages() {
    return (select(messageQueue)
          ..where((tbl) => tbl.status.equals('pending'))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.asc)]))
        .watch();
  }
  
  Future<int> addToMessageQueue(MessageQueueCompanion item) {
    return into(messageQueue).insert(item);
  }
  
  Future<int> updateQueueItemStatus(int itemId, String status, {String? errorMessage}) {
    return (update(messageQueue)
          ..where((tbl) => tbl.id.equals(itemId)))
        .write(MessageQueueCompanion(
          status: Value(status),
          lastRetryAt: Value(DateTime.now()),
          errorMessage: errorMessage != null ? Value(errorMessage) : const Value.absent(),
        ));
  }
  
  Future<int> incrementQueueItemRetry(int itemId) async {
    final item = await (select(messageQueue)..where((tbl) => tbl.id.equals(itemId))).getSingleOrNull();
    if (item != null) {
      final newRetryCount = item.retryCount + 1;
      final status = newRetryCount >= item.maxRetries ? 'failed' : 'pending';
      return (update(messageQueue)
            ..where((tbl) => tbl.id.equals(itemId)))
          .write(MessageQueueCompanion(
            retryCount: Value(newRetryCount),
            status: Value(status),
            lastRetryAt: Value(DateTime.now()),
          ));
    }
    return 0;
  }
  
  Future<int> deleteQueueItem(int itemId) {
    return (delete(messageQueue)..where((tbl) => tbl.id.equals(itemId))).go();
  }
  
  Future<int> clearFailedQueueItems() {
    return (delete(messageQueue)..where((tbl) => tbl.status.equals('failed'))).go();
  }
}

// Function to open the database connection
LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_db.sqlite'));
    print('[AppDatabase] Database file path: ${file.path}');
    return NativeDatabase.createInBackground(file);
  });
} 