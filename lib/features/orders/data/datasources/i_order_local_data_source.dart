import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';

// Interface for accessing cached order data locally
abstract class IOrderLocalDataSource {
  /// Retrieves a paginated list of cached orders for a given state.
  /// 
  /// Returns [List<Order>] on success or [CacheFailure] on error.
  Future<Either<Failure, List<Order>>> getOrdersByState(
      {required String state, required int limit, required int offset});

  /// Retrieves a paginated list of all cached orders.
  /// 
  /// Returns [List<Order>] on success or [CacheFailure] on error.
  Future<Either<Failure, List<Order>>> getAllOrders(
      {required int limit, required int offset});

  /// Caches a list of orders.
  /// 
  /// Replaces existing orders with the same ID.
  Future<void> cacheOrders(List<Order> orders);

  /// Clears cached orders for a specific state.
  Future<void> clearOrdersByState(String state);

  /// Clears all cached orders.
  Future<void> clearAllOrders();
} 