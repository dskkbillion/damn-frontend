import 'package:dartz/dartz.dart' hide Order;
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:drift/drift.dart'; // Import drift exceptions if needed
import 'package:injectable/injectable.dart' hide Order; // Hide Order from injectable
import 'dart:convert'; // Import jsonDecode

import '../../../../core/database/app_database.dart'; // Import AppDatabase
// import '../../../../core/database/daos/order_dao.dart'; // Remove DAO import
import '../../../../core/database/database_extensions.dart'; // Import the mapping extension
import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart'; // Import OrderStatus
import 'i_order_local_data_source.dart';

@LazySingleton(as: IOrderLocalDataSource) // Register as lazy singleton
class OrderLocalDataSourceImpl implements IOrderLocalDataSource {
  final AppDatabase _appDatabase; // Depend on AppDatabase
  // late final OrderDao _orderDao; // Remove DAO field

  OrderLocalDataSourceImpl({required AppDatabase appDatabase}) : _appDatabase = appDatabase;
      // _orderDao = _appDatabase.orderDao; // Remove DAO initialization
  

  @override
  Future<Either<Failure, List<Order>>> getOrdersByState(
      {required String state, required int limit, required int offset}) async {
    try {
      // Call method directly on AppDatabase instance
      final cachedOrders = await _appDatabase.getOrdersByState(state, limit, offset);
      // Map OrderCache list to Order list using the extension method
      final orders = cachedOrders.map((cache) => cache.toEntity()).toList();
      AppLogger.d('[OrderLocalDataSource] Loaded ${orders.length} orders from cache for state: $state');
      return Right(orders);
    } catch (e) {
      AppLogger.d('[OrderLocalDataSource] Error getting orders from cache: $e');
      return Left(CacheFailure(message: '获取订单缓存失败'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getAllOrders(
      {required int limit, required int offset}) async {
    try {
      // Call the new paginated method on AppDatabase instance
      final cachedOrders = await _appDatabase.getAllOrdersPaginated(limit, offset);
      // Map OrderCache list to Order list using the extension method
      final orders = cachedOrders.map((cache) => cache.toEntity()).toList();
      AppLogger.d('[OrderLocalDataSource] Loaded ${orders.length} orders from cache (all states).');
      return Right(orders);
    } catch (e) {
      AppLogger.d('[OrderLocalDataSource] Error getting all orders from cache: $e');
      return Left(CacheFailure(message: '获取所有订单缓存失败'));
    }
  }

  @override
  Future<void> cacheOrders(List<Order> orders) async {
    try {
      // Map Order list to OrderCache list before inserting
      final orderCaches = orders.map((order) => _mapOrderToOrderCache(order)).toList();
      // Call method directly on AppDatabase instance
      await _appDatabase.insertOrders(orderCaches);
      AppLogger.d('[OrderLocalDataSource] Cached ${orderCaches.length} orders.');
    } catch (e) {
      AppLogger.d('[OrderLocalDataSource] Error caching orders: $e');
      // Depending on requirements, might want to throw or log differently
    }
  }

  @override
  Future<void> clearOrdersByState(String state) async {
    try {
      // Call method directly on AppDatabase instance
      final count = await _appDatabase.deleteOrdersByState(state);
      AppLogger.d('[OrderLocalDataSource] Cleared $count cached orders for state: $state');
    } catch (e) {
      AppLogger.d('[OrderLocalDataSource] Error clearing orders by state: $e');
    }
  }

  @override
  Future<void> clearAllOrders() async {
     try {
      // Call method directly on AppDatabase instance
      final count = await _appDatabase.deleteAllOrders();
      AppLogger.d('[OrderLocalDataSource] Cleared $count cached orders (all).');
    } catch (e) {
      AppLogger.d('[OrderLocalDataSource] Error clearing all orders: $e');
    }
  }

  // Helper function to map Order entity to OrderCache data class
  OrderCache _mapOrderToOrderCache(Order order) {
    // Ensure state is non-null before converting, provide default if necessary
    final stateString = order.state?.toJsonString() ?? OrderStatus.unknown.toJsonString(); 
    return OrderCache(
        id: order.id,
        orderSn: order.orderSn,
        state: stateString, // Use the ensured non-null string
        firstItemName: order.items.isNotEmpty ? order.items.first.productName ?? '' : '', 
        firstItemImage: order.items.isNotEmpty ? order.items.first.imageUrl ?? '' : '',
        totalPrice: order.priceSummary.payPrice.toStringAsFixed(2), // Store payPrice as string
        createdAt: order.createdAt);
  }
} 