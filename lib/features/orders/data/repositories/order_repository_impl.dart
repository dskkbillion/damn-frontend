import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart'; // Import DioException if needed for error handling
import 'package:injectable/injectable.dart' hide Order;

import '../../../../core/error/failures.dart';
// import '../../../../core/platform/network_info.dart'; // 可选：用于检查网络状态
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/i_order_remote_data_source.dart';
import '../models/order_model.dart'; // 导入 OrderModel 以便调用 toEntity

/// 订单仓库接口的实现类。
@LazySingleton(as: IOrderRepository) // Add injectable annotation
class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // 可选的网络状态检查器

  OrderRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  /// 辅助函数，用于执行网络请求并处理通用错误。
  Future<Either<Failure, T>> _handleApiCall<T>(
      Future<T> Function() apiCall) async {
    // 可选：检查网络连接
    // if (!await networkInfo.isConnected) {
    //   return Left(NetworkFailure()); // 假设定义了 NetworkFailure
    // }
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
  }) async {
    return _handleApiCall(() async {
      final orderModels = await remoteDataSource.getOrderList(
        status: status,
        keyword: keyword,
        page: page,
        limit: limit,
      );
      return orderModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, Order>> getOrderDetail(int orderId) async {
     return _handleApiCall(() async {
       final orderModel = await remoteDataSource.getOrderDetail(orderId);
       return orderModel.toEntity();
     });
  }

  @override
  Future<Either<Failure, void>> cancelOrder(int orderId) async {
    return _handleApiCall(() => remoteDataSource.cancelOrder(orderId));
  }

  @override
  Future<Either<Failure, void>> confirmOrderReceipt(int orderId) async {
    return _handleApiCall(() => remoteDataSource.confirmOrderReceipt(orderId));
  }

  @override
  Future<Either<Failure, void>> deleteOrder(int orderId) async {
    return _handleApiCall(() => remoteDataSource.deleteOrder(orderId));
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
  Future<Either<Failure, void>> submitRequirements({
    required String orderId,
    required int productId,
    required List<Map<String, String>> feature,
    required List<String> attachmentPaths,
  }) async {
    // TODO: Add network check if required
    try {
      print('[OrderRepositoryImpl] Calling remoteDataSource.submitRequirements');
      await remoteDataSource.submitRequirements(
          orderId: orderId,
          productId: productId,
          feature: feature,
          attachmentPaths: attachmentPaths
      );
      return const Right(null);
    } on Exception catch (e) { // Catch generic Exception
      return Left(ServerFailure(message: '提交要求失败: ${e.toString()}')); // Use ServerFailure
    }
  }
} 