import 'package:dartz/dartz.dart' hide Order;
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dio/dio.dart'; // Import DioException if needed for error handling
import 'package:injectable/injectable.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
// import '../../../../core/platform/network_info.dart'; // 可选：用于检查网络状态
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_materials.dart';
import '../../domain/entities/order_delivery.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/i_order_remote_data_source.dart';
import '../datasources/i_order_local_data_source.dart'; // Import LocalDataSource
import '../datasources/i_order_materials_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/submit_requirements_use_case.dart';
import '../../domain/entities/order_creation_result.dart';
import 'package:dskk_flutter_refactor/core/config/app_config.dart';
import 'package:dskk_flutter_refactor/features/orders/data/datasources/simple_mock_order_data_source.dart';
import 'package:dskk_flutter_refactor/core/services/file_upload_service.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';

/// 订单仓库接口的实现类。
@LazySingleton(as: IOrderRepository) // Add injectable annotation
class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDataSource remoteDataSource;
  final IOrderLocalDataSource localDataSource; // Add LocalDataSource dependency
  final IOrderMaterialsRemoteDataSource materialsDataSource;
  final NetworkInfo networkInfo;
  final IFileUploadService fileUploadService;
  final ISecureStorageRepository secureStorage; // 添加安全存储依赖

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource, // Inject LocalDataSource
    required this.materialsDataSource,
    required this.networkInfo,
    required this.fileUploadService,
    required this.secureStorage, // 注入安全存储
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
    int? productId,
    required int page,
    required int limit,
    required String userRole,
    bool forceRefresh = false,
  }) async {
    // 如果启用了模拟数据模式，直接返回模拟数据
    if (AppConfig.useMockData) {
      try {
        final allMockOrders = SimpleMockOrderDataSource.getAllMockOrders();
        
        // 根据状态筛选
        List<Order> filteredOrders = status == null 
            ? allMockOrders 
            : allMockOrders.where((order) => order.state == status).toList();
        
        // 根据关键词筛选
        if (keyword != null && keyword.isNotEmpty) {
          filteredOrders = filteredOrders.where((order) =>
            order.orderSn.contains(keyword) ||
            order.items.any((item) => item.productName.contains(keyword))
          ).toList();
        }
        if (productId != null) {
          filteredOrders = filteredOrders.where((order) =>
            order.items.any((item) => item.productId == productId)
          ).toList();
        }
        
        // 根据用户角色筛选（如果需要）
        // 这里假设所有模拟数据都适用于买家和卖家
        
        // 分页处理
        final int startIndex = (page - 1) * limit;
        final int endIndex = startIndex + limit;
        
        final paginatedOrders = filteredOrders.length > startIndex
            ? filteredOrders.sublist(
                startIndex, 
                endIndex > filteredOrders.length ? filteredOrders.length : endIndex
              )
            : <Order>[];
        
        return Right(paginatedOrders);
      } catch (e) {
        return Left(ServerFailure(message: '获取模拟数据失败: ${e.toString()}'));
      }
    }
    
    // 原有的真实数据获取逻辑
    final int offset = (page - 1) * limit;
    final bool isFetchingAll = status == null;
    final String stateKey = productId != null
        ? '${status?.toJsonString() ?? 'all'}-product-$productId'
        : (status?.toJsonString() ?? 'all'); // Still useful for logging

    if (productId != null) {
      AppLogger.d('[OrderRepository] Product scoped query detected, bypassing cache for productId=$productId.');
      return _fetchFromNetwork(status, keyword, productId, page, limit, stateKey, userRole);
    }

    // 如果强制刷新，直接从网络获取
    if (forceRefresh) {
      AppLogger.d('[OrderRepository] Force refresh requested, skipping cache for $stateKey page $page.');
      return _fetchFromNetwork(status, keyword, productId, page, limit, stateKey, userRole);
    }

    // 1. Try fetching from cache first
    final Either<Failure, List<Order>> cachedResult = isFetchingAll
        ? await localDataSource.getAllOrders(limit: limit, offset: offset)
        : await localDataSource.getOrdersByState(state: stateKey, limit: limit, offset: offset);
    
    // Use a flag to know if we returned cache
    bool returnedCache = false;
    Either<Failure, List<Order>>? resultToReturn;

    cachedResult.fold(
      (cacheFailure) {
        AppLogger.d('[OrderRepository] Cache miss or error for $stateKey page $page: $cacheFailure');
        // Don't return error yet, proceed to network fetch
      },
      (cachedOrders) {
        if (cachedOrders.isNotEmpty) {
           AppLogger.d('[OrderRepository] Cache hit for $stateKey page $page. Returning ${cachedOrders.length} orders from cache.');
           resultToReturn = Right(cachedOrders);
           returnedCache = true;
        } else {
          AppLogger.d('[OrderRepository] Cache hit for $stateKey page $page, but cache is empty.');
        }
      },
    );

    // If we have valid cache data, return it immediately (for faster UI response)
    // We will still fetch from network in the background to update cache.
    // Note: This simple implementation doesn't notify the UI about the network update.
    if (returnedCache && resultToReturn != null) {
        // Intentionally start network fetch *after* returning cache
        _fetchAndUpdateCache(status, keyword, productId, page, limit, stateKey, userRole);
        return resultToReturn!;
    }

    // 2. If cache missed, empty, or failed, fetch from network
    AppLogger.d('[OrderRepository] Fetching $stateKey page $page from network...');
    try {
        AppLogger.d('[OrderRepository] Fetching order list from remote. Page: $page, Limit: $limit, Status: $status, Keyword: $keyword, Role: $userRole');
        final remoteOrders = await remoteDataSource.getOrderList(
          status: status,
          keyword: keyword,
          productId: productId,
          page: page,
          limit: limit,
          userRole: userRole,
        );
        final networkOrders = remoteOrders.map((model) => model.toEntity()).toList();
        AppLogger.d('[OrderRepository] Fetched ${networkOrders.length} orders from network for $stateKey page $page.');

        // 【数据防护】验证和过滤订单列表，确保只返回属于当前用户的订单
        final filteredOrders = await _filterOrdersByUserRole(networkOrders, userRole);
        AppLogger.d('[OrderRepository] Filtered to ${filteredOrders.length} orders after validation.');

        // 3. Cache the filtered response
        // We might want to clear cache for this state before inserting new page?
        // Or handle potential duplicates with insertOrReplace
        // For now, just insert/replace
        await localDataSource.cacheOrders(filteredOrders);

        return Right(filteredOrders);

    } on ServerFailure catch (e) {
        AppLogger.d('[OrderRepository] Network fetch failed for $stateKey page $page: $e');
        // If network fails AND we didn't return cache earlier, return the failure
        if (!returnedCache) {
           return Left(e);
        } else {
           // Network failed, but we already returned cache. Log error, but return the cached result.
           AppLogger.d('[OrderRepository] Network fetch failed, but cache was already returned. Suppressing network error.');
           return resultToReturn!; // Should not be null if returnedCache is true
        }
    } catch (e) {
        AppLogger.d('[OrderRepository] Unexpected error during network fetch for $stateKey page $page: $e');
         if (!returnedCache) {
            return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
         } else {
            AppLogger.d('[OrderRepository] Network fetch failed (unexpected), but cache was already returned. Suppressing error.');
            return resultToReturn!; 
         }
    }
  }

  // Helper function to fetch from network (used for force refresh)
  Future<Either<Failure, List<Order>>> _fetchFromNetwork(
    OrderStatus? status,
    String? keyword,
    int? productId,
    int page,
    int limit,
    String stateKey,
    String userRole,
  ) async {
    try {
      AppLogger.d('[OrderRepository] Fetching order list from remote. Page: $page, Limit: $limit, Status: $status, Keyword: $keyword, Role: $userRole');
      final remoteOrders = await remoteDataSource.getOrderList(
        status: status,
        keyword: keyword,
        productId: productId,
        page: page,
        limit: limit,
        userRole: userRole,
      );
      final networkOrders = remoteOrders.map((model) => model.toEntity()).toList();
      AppLogger.d('[OrderRepository] Fetched ${networkOrders.length} orders from network for $stateKey page $page.');

      // 【数据防护】验证和过滤订单列表
      final filteredOrders = await _filterOrdersByUserRole(networkOrders, userRole);
      AppLogger.d('[OrderRepository] Filtered to ${filteredOrders.length} orders after validation.');

      // Cache the filtered response
      await localDataSource.cacheOrders(filteredOrders);

      return Right(filteredOrders);
    } on ServerFailure catch (e) {
      AppLogger.d('[OrderRepository] Network fetch failed for $stateKey page $page: $e');
      return Left(e);
    } catch (e) {
      AppLogger.d('[OrderRepository] Unexpected error during network fetch for $stateKey page $page: $e');
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  // Helper function to fetch from network and update cache in the background
  // This is called when cache is hit and returned immediately
  Future<void> _fetchAndUpdateCache(
      OrderStatus? status, String? keyword, int? productId, int page, int limit, String stateKey, String userRole) async {
     AppLogger.d('[OrderRepository] Background fetch starting for $stateKey page $page...');
      try {
        AppLogger.d('[OrderRepository] Fetching order list from remote. Page: $page, Limit: $limit, Status: $status, Keyword: $keyword, Role: $userRole');
        final remoteOrders = await remoteDataSource.getOrderList(
          status: status,
          keyword: keyword,
          productId: productId,
          page: page,
          limit: limit,
          userRole: userRole,
        );
        final networkOrders = remoteOrders.map((model) => model.toEntity()).toList();

        // 【数据防护】验证和过滤订单列表
        final filteredOrders = await _filterOrdersByUserRole(networkOrders, userRole);
        AppLogger.d('[OrderRepository] Background fetch filtered to ${filteredOrders.length} orders after validation.');

        await localDataSource.cacheOrders(filteredOrders);
        AppLogger.d('[OrderRepository] Background fetch and cache update successful for $stateKey page $page.');
      } catch (e) {
         AppLogger.d('[OrderRepository] Background fetch failed for $stateKey page $page: $e');
         // Log error, maybe implement retry or other strategy later
      }
  }

  /// 根据用户角色过滤订单列表，确保数据安全性
  /// 防止后端返回不属于当前用户的订单
  Future<List<Order>> _filterOrdersByUserRole(
    List<Order> orders,
    String userRole,
  ) async {
    try {
      final currentUserId = await secureStorage.getUserId();
      if (currentUserId == null) {
        AppLogger.d('[OrderRepository] Warning: Current user ID is null, returning empty list');
        return [];
      }

      return orders.where((order) {
        if (userRole == 'buyer') {
          // 买家视角：只保留 buyerId 匹配的订单
          final matches = order.buyer?.id == currentUserId;
          if (!matches) {
            AppLogger.d('[OrderRepository] Filtered out order ${order.id}: buyerId=${order.buyer?.id} != currentUserId=$currentUserId');
          }
          return matches;
        } else if (userRole == 'seller') {
          // 卖家视角：只保留 tenantId 匹配的订单
          final matches = order.tenant?.id == currentUserId;
          if (!matches) {
            AppLogger.d('[OrderRepository] Filtered out order ${order.id}: tenantId=${order.tenant?.id} != currentUserId=$currentUserId');
          }
          return matches;
        }
        return false;
      }).toList();
    } catch (e) {
      AppLogger.d('[OrderRepository] Error filtering orders: $e');
      return []; // 出错时返回空列表，确保安全
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderDetail(int orderId) async {
     AppLogger.d('[OrderRepository] getOrderDetail called for orderId: $orderId, useMockData: ${AppConfig.useMockData}');
     // 如果启用了模拟数据模式，从模拟数据中查找
     if (AppConfig.useMockData) {
       AppLogger.d('[OrderRepository] Using mock data for order detail');
       try {
         final allMockOrders = SimpleMockOrderDataSource.getAllMockOrders();
         AppLogger.d('[OrderRepository] Available mock order IDs: ${allMockOrders.map((o) => o.id).toList()}');
         final order = allMockOrders.firstWhere(
           (o) => o.id == orderId,
           orElse: () => throw Exception('未找到订单 ID: $orderId (可用ID: ${allMockOrders.map((o) => o.id).toList()})'),
         );
         AppLogger.d('[OrderRepository] Found mock order: ${order.id} - ${order.orderSn}');
         AppLogger.d('[OrderRepository] Order items: ${order.items.length}');
         AppLogger.d('[OrderRepository] Order status: ${order.state}');
         AppLogger.d('[OrderRepository] Order price: ${order.priceSummary.payPrice}');
         return Right(order);
       } catch (e) {
         AppLogger.d('[OrderRepository] Mock order not found: $e');
         return Left(ServerFailure(message: '获取模拟订单详情失败: ${e.toString()}'));
       }
     }
     
     // 原有的真实数据获取逻辑
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
        AppLogger.d('[OrderRepository] 删除订单成功，已清理所有本地缓存');
      } catch (e) {
        AppLogger.d('[OrderRepository] 清理缓存失败: $e');
        // 即使缓存清理失败，删除操作本身已经成功，所以不影响返回结果
      }
    }
    
    return result;
  }

  // --- Add Evaluation Repository Method ---
  @override
  Future<Either<Failure, void>> addEvaluation({
    required int orderId,
    required double score,
    required String content,
    required bool isAnonymous,
    required List<String> pictures,
  }) async {
    // TODO: Add network check if required
    try {
      await remoteDataSource.addEvaluation(
          orderId: orderId,
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
  Future<Either<Failure, void>> submitRequirements(SubmitRequirementsParams params) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: '网络未连接'));
    }

    try {
      // 1. 先上传附件文件（如果有）
      List<String> uploadedFileUrls = [];
      
      if (params.attachmentPaths.isNotEmpty) {
        AppLogger.d('[OrderRepositoryImpl] Uploading ${params.attachmentPaths.length} files...');
        
        // 上传所有文件
        final uploadResult = await fileUploadService.uploadFiles(params.attachmentPaths);
        
        return uploadResult.fold(
          (failure) {
            AppLogger.d('[OrderRepositoryImpl] File upload failed: $failure');
            return Left(failure);
          },
          (uploadResults) async {
            // 提取上传后的文件URL
            uploadedFileUrls = uploadResults.map((result) => result.url).toList();
            AppLogger.d('[OrderRepositoryImpl] Files uploaded successfully: $uploadedFileUrls');
            
            // 2. 调用远程数据源提交材料（包含上传后的文件URL）
            final updatedParams = SubmitRequirementsParams(
              orderId: params.orderId,
              productId: params.productId,
              feature: params.feature,
              attachmentPaths: uploadedFileUrls, // 使用上传后的URL
            );
            
            return _handleApiCall(() => remoteDataSource.submitRequirements(updatedParams));
          },
        );
      } else {
        // 没有附件，直接提交
        AppLogger.d('[OrderRepositoryImpl] No files to upload, submitting requirements directly');
        return _handleApiCall(() => remoteDataSource.submitRequirements(params));
      }
    } catch (e) {
      AppLogger.d('[OrderRepositoryImpl] submitRequirements error: $e');
      return Left(UnknownFailure(message: '提交材料失败: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRequirementDraft(/* DraftParams params */) async {
    // This operation is intended for local storage.
    // The repository layer might interact with a local data source here,
    // but for now, as it's a local-only action, we can return success directly.
    // If a local data source for drafts exists, call it here.
    // Example: return _handleLocalCall(() => localDraftDataSource.saveDraft(params));
    AppLogger.d('[OrderRepositoryImpl] saveRequirementDraft called. Returning success as it\'s local.');
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
    int? chatRoomId,
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
        chatRoomId: chatRoomId,
      );
      
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '创建订单失败'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderMaterials>>> getOrderMaterials(int orderId) async {
    return _handleApiCall(() async {
      final materialModels = await materialsDataSource.getOrderMaterials(orderId);
      return materialModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<OrderDelivery>>> getOrderDeliveries(int orderId) async {
    return _handleApiCall(() async {
      final deliveryModels = await materialsDataSource.getOrderDeliveries(orderId);
      return deliveryModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, OrderMaterials>> getOrderMaterialById(int materialId) async {
    return _handleApiCall(() async {
      final materialModel = await materialsDataSource.getOrderMaterialById(materialId);
      return materialModel.toEntity();
    });
  }

  @override
  Future<Either<Failure, OrderDelivery>> getOrderDeliveryById(int deliveryId) async {
    return _handleApiCall(() async {
      final deliveryModel = await materialsDataSource.getOrderDeliveryById(deliveryId);
      return deliveryModel.toEntity();
    });
  }
} 
