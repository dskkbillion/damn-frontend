import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart'; // Import DioException if needed for error handling
import 'package:injectable/injectable.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
// import '../../../../core/platform/network_info.dart'; // 可选：用于检查网络状态
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/i_order_remote_data_source.dart';
import '../datasources/i_order_local_data_source.dart'; // Import LocalDataSource
import '../models/order_model.dart'; // 导入 OrderModel 以便调用 toEntity
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart' hide OrderModel;
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_requirements_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_evaluation_use_case.dart'; // If AddEvaluationParams is defined there
import '../../domain/entities/order_creation_result.dart';

/// 订单仓库接口的实现类。
@LazySingleton(as: IOrderRepository) // Add injectable annotation
class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDataSource remoteDataSource;
  final IOrderLocalDataSource localDataSource; // Add LocalDataSource dependency
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource, // Inject LocalDataSource
    required this.networkInfo,
  });

  /// 辅助函数，用于执行网络请求并处理通用错误。
  Future<Either<Failure, T>> _handleApiCall<T>(
      Future<T> Function() apiCall) async {
    // 可选：检查网络连接
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '网络未连接'));
    }
    try {
      final result = await apiCall();
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e); // 直接转发 ServerFailure
    } on DioException catch (e) {
      // Convert DioException to ServerFailure or a more specific NetworkFailure
      return Left(ServerFailure(message: e.message ?? 'Network Error'));
    } catch (e) {
      // 捕获其他可能的、未被 DataSource 处理的异常
      return Left(ServerFailure(message: 'Unexpected Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrderList({
    OrderStatus? status,
    String? keyword,
    required int page,
    required int limit,
    required String userRole,
  }) async {
    final int offset = (page - 1) * limit;
    final bool isFetchingAll = status == null;
    final String stateKey = status?.toJsonString() ?? 'all'; // Still useful for logging

    // 1. Try fetching from cache first
    final Either<Failure, List<Order>> cachedResult = isFetchingAll
        ? await localDataSource.getAllOrders(limit: limit, offset: offset)
        : await localDataSource.getOrdersByState(state: stateKey, limit: limit, offset: offset);
    
    // Use a flag to know if we returned cache
    bool returnedCache = false;
    Either<Failure, List<Order>>? resultToReturn;

    cachedResult.fold(
      (cacheFailure) {
        print('[OrderRepository] Cache miss or error for $stateKey page $page: $cacheFailure');
        // Don't return error yet, proceed to network fetch
      },
      (cachedOrders) {
        if (cachedOrders.isNotEmpty) {
           print('[OrderRepository] Cache hit for $stateKey page $page. Returning ${cachedOrders.length} orders from cache.');
           resultToReturn = Right(cachedOrders);
           returnedCache = true;
        } else {
          print('[OrderRepository] Cache hit for $stateKey page $page, but cache is empty.');
        }
      },
    );

    // If we have valid cache data, return it immediately (for faster UI response)
    // We will still fetch from network in the background to update cache.
    // Note: This simple implementation doesn't notify the UI about the network update.
    if (returnedCache && resultToReturn != null) {
        // Intentionally start network fetch *after* returning cache
        _fetchAndUpdateCache(status, keyword, page, limit, stateKey, userRole);
        return resultToReturn!;
    }

    // 2. If cache missed, empty, or failed, fetch from network
    print('[OrderRepository] Fetching $stateKey page $page from network...');
    try {
        print('[OrderRepository] Fetching order list from remote. Page: $page, Limit: $limit, Status: $status, Keyword: $keyword, Role: $userRole');
        final remoteOrders = await remoteDataSource.getOrderList(
          status: status,
          keyword: keyword,
          page: page,
          limit: limit,
          userRole: userRole,
        );
        final networkOrders = remoteOrders.map((model) => model.toEntity()).toList();
        print('[OrderRepository] Fetched ${networkOrders.length} orders from network for $stateKey page $page.');

        // 3. Cache the network response
        // We might want to clear cache for this state before inserting new page?
        // Or handle potential duplicates with insertOrReplace
        // For now, just insert/replace
        await localDataSource.cacheOrders(networkOrders);

        return Right(networkOrders);

    } on ServerFailure catch (e) {
        print('[OrderRepository] Network fetch failed for $stateKey page $page: $e');
        // If network fails AND we didn't return cache earlier, return the failure
        if (!returnedCache) {
           return Left(e);
        } else {
           // Network failed, but we already returned cache. Log error, but return the cached result.
           print('[OrderRepository] Network fetch failed, but cache was already returned. Suppressing network error.');
           return resultToReturn!; // Should not be null if returnedCache is true
        }
    } catch (e) {
        print('[OrderRepository] Unexpected error during network fetch for $stateKey page $page: $e');
         if (!returnedCache) {
            return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
         } else {
            print('[OrderRepository] Network fetch failed (unexpected), but cache was already returned. Suppressing error.');
            return resultToReturn!; 
         }
    }
  }

  // Helper function to fetch from network and update cache in the background
  // This is called when cache is hit and returned immediately
  Future<void> _fetchAndUpdateCache(
      OrderStatus? status, String? keyword, int page, int limit, String stateKey, String userRole) async {
     print('[OrderRepository] Background fetch starting for $stateKey page $page...');
      try {
        print('[OrderRepository] Fetching order list from remote. Page: $page, Limit: $limit, Status: $status, Keyword: $keyword, Role: $userRole');
        final remoteOrders = await remoteDataSource.getOrderList(
          status: status,
          keyword: keyword,
          page: page,
          limit: limit,
          userRole: userRole,
        );
        final networkOrders = remoteOrders.map((model) => model.toEntity()).toList();
        await localDataSource.cacheOrders(networkOrders);
        print('[OrderRepository] Background fetch and cache update successful for $stateKey page $page.');
      } catch (e) {
         print('[OrderRepository] Background fetch failed for $stateKey page $page: $e');
         // Log error, maybe implement retry or other strategy later
      }
  }

  @override
  Future<Either<Failure, Order>> getOrderDetail(int orderId) async {
     // TODO: Implement caching for OrderDetail based on strategy doc
     return _handleApiCall(() async {
       final orderModel = await remoteDataSource.getOrderDetail(orderId);
       return orderModel.toEntity();
     });
  }

  @override
  Future<Either<Failure, void>> cancelOrder(int orderId) async {
    // TODO: Consider cache invalidation on success
    return _handleApiCall(() => remoteDataSource.cancelOrder(orderId));
  }

  @override
  Future<Either<Failure, void>> confirmOrderReceipt(int orderId) async {
    return _handleApiCall(() => remoteDataSource.confirmOrderReceipt(orderId));
  }

  @override
  Future<Either<Failure, void>> deleteOrder(int orderId) async {
    final result = await _handleApiCall(() => remoteDataSource.deleteOrder(orderId));
    
    // 如果删除成功，清理本地缓存
    if (result.isRight()) {
      try {
        // 清理所有订单缓存，因为不知道删除的订单属于哪个状态
        await localDataSource.clearAllOrders();
        print('[OrderRepository] 删除订单成功，已清理所有本地缓存');
      } catch (e) {
        print('[OrderRepository] 清理缓存失败: $e');
        // 即使缓存清理失败，删除操作本身已经成功，所以不影响返回结果
      }
    }
    
    return result;
  }

  // --- Add Evaluation Repository Method ---
  @override
  Future<Either<Failure, void>> addEvaluation({
    required int orderItemId,
    required double score,
    required String content,
    required bool isAnonymous,
    required List<String> pictures,
  }) async {
    // TODO: Add network check if required
    try {
      await remoteDataSource.addEvaluation(
          orderItemId: orderItemId,
          score: score,
          content: content,
          isAnonymous: isAnonymous,
          pictures: pictures);
      return const Right(null);
    } on Exception catch (e) { // Catch generic Exception
      return Left(ServerFailure(message: '评价失败: ${e.toString()}')); // Use ServerFailure
    }
  }

  // --- Implement new repository methods ---

  @override
  Future<Either<Failure, void>> submitRequirements(
      SubmitRequirementsParams params) async {
    return _handleApiCall(() => remoteDataSource.submitRequirements(params));
  }

  @override
  Future<Either<Failure, void>> saveRequirementDraft(/* DraftParams params */) async {
    // This operation is intended for local storage.
    // The repository layer might interact with a local data source here,
    // but for now, as it's a local-only action, we can return success directly.
    // If a local data source for drafts exists, call it here.
    // Example: return _handleLocalCall(() => localDraftDataSource.saveDraft(params));
    print('[OrderRepositoryImpl] saveRequirementDraft called. Returning success as it\'s local.');
    return const Right(null); // Indicate success
  }

  // --- Seller action implementations ---

  @override
  Future<Either<Failure, void>> confirmOrderAcceptance(int orderId) async {
    // Optional: Add checks or logic before calling data source
    return _handleApiCall(() => remoteDataSource.confirmOrderAcceptance(orderId));
  }

  @override
  Future<Either<Failure, void>> addOrderDemand(AddOrderDemandParams params) async {
    return _handleApiCall(() => remoteDataSource.addOrderDemand(params));
  }

  @override
  Future<Either<Failure, void>> deliverOrder(DeliverOrderParams params) async {
    // Note: The files parameter type uncertainty is handled in DataSource
    return _handleApiCall(() => remoteDataSource.deliverOrder(params));
  }

  @override
  Future<Either<Failure, void>> deleteSellerOrderRecord(int orderId) async {
    // TODO: Consider cache invalidation on success if caching seller orders
    return _handleApiCall(() => remoteDataSource.deleteSellerOrderRecord(orderId));
  }

  @override
  Future<Either<Failure, void>> inviteEvaluation(int orderId) async {
    // DataSource currently throws UnimplementedError for this
    return _handleApiCall(() => remoteDataSource.inviteEvaluation(orderId));
  }

  @override
  Future<Either<Failure, OrderCreationResult>> createOrder({
    required int productId,
    required int variantId,
    required int quantity,
    required int sellerId,
    required double price,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '网络未连接'));
    }
    
    try {
      final result = await remoteDataSource.createOrder(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        sellerId: sellerId,
        price: price,
      );
      
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '创建订单失败'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
} 