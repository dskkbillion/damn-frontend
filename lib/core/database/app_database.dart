import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import table definitions
import 'tables/orders_table.dart';
// import 'daos/order_dao.dart'; // Remove DAO import

part 'app_database.g.dart'; // Drift will generate this file

@DriftDatabase(
  tables: [Orders],
  // daos: [OrderDao], // Remove DAO from annotation
)
class AppDatabase extends _$AppDatabase {
  // Define the database version (important for migrations)
  static const int dbVersion = 1;

  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => dbVersion;

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