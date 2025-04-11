import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart'; // Import injectable

import '../../../../core/error/failures.dart'; // 使用 failures.dart
import '../../domain/entities/order_status.dart';
import '../models/order_model.dart';
import 'i_order_remote_data_source.dart';

/// 订单远程数据源的实现类。
@LazySingleton(as: IOrderRemoteDataSource) // Add injectable annotation
class OrderRemoteDataSourceImpl implements IOrderRemoteDataSource {
  final Dio dio; // 注入 Dio 实例

  OrderRemoteDataSourceImpl({required this.dio});

  // --- API Endpoints --- (根据 RN 代码分析确定)
  final String _listEndpoint = '/api/shop/order/list';
  final String _detailEndpoint = '/api/shop/order/detail';
  final String _cancelEndpoint = '/api/shop/order/cancel';
  final String _receiptEndpoint = '/api/shop/order/receipt'; // 确认收货 (API Doc)
  final String _deleteEndpoint = '/api/shop/order/delete';
  final String _addEvaluationEndpoint = '/api/shop/evaluate/add'; // 新增

  @override
  Future<List<OrderModel>> getOrderList({
    OrderStatus? status,
    String? keyword,
    required int page,
    required int limit,
  }) async {
    final Map<String, dynamic> params = {
      'pageNum': page,
      'pageSize': limit,
      'type': 'buyer', // 假设总是查询买家订单
    };

    // 映射 OrderStatus 枚举到 API 需要的字符串状态
    // (基于 RN `orderActions.ts` 中的逻辑)
    if (status != null) {
      switch (status) {
        case OrderStatus.awaitingPayment:
          params['state'] = 'awaitingPayment';
          break;
        case OrderStatus.awaitingSubmission:
        case OrderStatus.buyAwaitingSubmission:
        case OrderStatus.awaitingStart:
        case OrderStatus.awaitingDelivery:
        case OrderStatus.awaitingConfirmation:
        case OrderStatus.sellerSupplementaryMaterials:
        case OrderStatus.applyForRefuse:
        case OrderStatus.canceled: // 假设处理中包含取消？需要确认
          // RN 代码中处理中状态的逻辑较复杂，这里简化处理，具体实现需细化
          if (status == OrderStatus.awaitingSubmission ||
              status == OrderStatus.buyAwaitingSubmission ||
              status == OrderStatus.awaitingStart ||
              status == OrderStatus.awaitingDelivery ||
              status == OrderStatus.awaitingConfirmation ||
              status == OrderStatus.sellerSupplementaryMaterials ||
              status == OrderStatus.applyForRefuse ||
              status == OrderStatus.canceled) {
            params['states'] = [
              "awaitingSubmission",
              "buyAwaitingSubmission",
              "awaitingStart",
              "awaitingDelivery",
              "awaitingConfirmation",
              "sellerSupplementaryMaterials",
              "applyForRefuse",
              "canceled",
            ]; // "处理中" 状态对应的数组
          } else {
            // 对于其他状态，如果 API 支持，可以单独传递
             params['state'] = status.toJsonString();
          }
          break;
        case OrderStatus.awaitingEvaluation:
        case OrderStatus.orderCompleted:
          params['states'] = ['awaitingEvaluation', 'orderCompleted']; // 已完成/待评价
          break;
        case OrderStatus.afterSale:
        case OrderStatus.AfterSaleRejection:
        case OrderStatus.applyingForMediation:
          params['states'] = [
            "afterSale",
            "AfterSaleRejection",
            "applyingForMediation"
          ]; // 售后
          break;
        case OrderStatus.unknown:
          // 查询全部时，不传递 state/states 参数
          if (keyword != null && keyword.isNotEmpty) {
            params['keyword'] = keyword;
          }
          break;
      }
    } else {
      // status 为 null, 查询全部
      if (keyword != null && keyword.isNotEmpty) {
        params['keyword'] = keyword;
      }
    }

    try {
      final response = await dio.post(
        _listEndpoint,
        data: params,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data['data'];
        // Use null-aware operators for safer access and type checking
        final List<dynamic>? orderListJson = responseData?['list'] as List<dynamic>?;

        if (orderListJson != null) {
          // If list is present and is a list, map it
          return orderListJson
              .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          // If 'data' is null, 'list' is missing, or 'list' is not a List, return empty.
          print('[OrderRemoteDataSource] Response format issue or empty list. Returning empty list.');
          return [];
        }
      } else {
        throw ServerFailure(
            message: response.data?['msg'] ?? 'Failed to load order list',
            // statusCode: response.statusCode // ServerFailure 当前定义不含 statusCode
            );
      }
    } on DioException catch (e) {
      throw ServerFailure(
          message: e.message ?? 'Network error',
          // statusCode: e.response?.statusCode
          );
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderDetail(int orderId) async {
    try {
      final response = await dio.get(
        _detailEndpoint,
        queryParameters: {'id': orderId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data['data'];
        if (responseData != null && responseData is Map<String, dynamic>) {
          return OrderModel.fromJson(responseData);
        } else {
          throw ServerFailure(message: 'Invalid response format from server.');
        }
      } else {
        throw ServerFailure(
            message: response.data?['msg'] ?? 'Failed to load order detail',
            // statusCode: response.statusCode
            );
      }
    } on DioException catch (e) {
      throw ServerFailure(
          message: e.message ?? 'Network error',
          // statusCode: e.response?.statusCode
          );
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelOrder(int orderId) async {
    // API Doc says GET, query parameter is 'orderId'
    const String _cancelEndpoint = '/api/shop/order/cancel'; // Corrected path
    try {
      final response = await dio.get(
        _cancelEndpoint,
        queryParameters: {'orderId': orderId}, // Use correct query parameter name
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerFailure(
            message: response.data?['msg'] ?? 'Failed to cancel order',
            // statusCode: response.statusCode // Removed if not supported
            );
      }
    } on DioException catch (e) {
      throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error',
          // statusCode: e.response?.statusCode // Removed if not supported
          );
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> confirmOrderReceipt(int orderId) async {
    // API Doc says GET, query parameter is 'orderId'
    const String _receiptEndpoint = '/api/shop/order/complete'; // Corrected path
    try {
      final response = await dio.get(
        _receiptEndpoint, // Use correct endpoint
        queryParameters: {'orderId': orderId}, // Use correct query parameter name
      );
      // Check for 200 or 204 No Content
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerFailure(
            message: response.data?['msg'] ?? 'Failed to confirm order receipt',
            // statusCode: response.statusCode // Removed if not supported
            );
      }
    } on DioException catch (e) {
      throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error',
          // statusCode: e.response?.statusCode // Removed if not supported
          );
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOrder(int orderId) async {
    // API Doc says POST, query parameter is 'orderId'
     const String _deleteEndpoint = '/api/shop/order/delete'; // Corrected path
    try {
      final response = await dio.post(
        _deleteEndpoint,
        queryParameters: {'orderId': orderId}, // Use correct query parameter name
        // POST usually requires a body, but API doc doesn't specify one for delete.
        // Send empty body if required, or adjust if backend needs specific body.
        data: {}, // Sending empty data as body might be needed for POST
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
         throw ServerFailure(
            message: response.data?['msg'] ?? 'Failed to delete order',
            // statusCode: response.statusCode // Removed if not supported
            );
      }
    } on DioException catch (e) {
       throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error',
          // statusCode: e.response?.statusCode // Removed if not supported
          );
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- Add Evaluation Method ---
  @override
  Future<void> addEvaluation({
    required String orderId,
    required int orderItemId,
    required double score,
    required String content,
    required bool isAnonymous,
    required List<String> pictures, // Expecting URLs from upload service
  }) async {
    const String _addEvaluationEndpoint = '/api/shop/evaluate/add';
    try {
      // Construct the request body based on API/RN code analysis
      final data = {
        'orderId': int.tryParse(orderId) ?? 0, // API might expect int
        // API/RN doesn't seem to use orderItemId directly in the body
        // The evaluation might be linked via orderId and potentially the first item implicitly
        // Or it might evaluate multiple items in a list structure (doc was unclear)
        // Let's assume for now it's linked via orderId and the structure matches RN:
        'score': score,
        'remark': content,
        'images': pictures, // Pass the image URLs
        'anonumityFlag': isAnonymous, // Match RN naming 'anonumityFlag'
        // TODO: Clarify with backend if orderItemId or a list structure is needed
      };

      print('[OrderRemoteDataSourceImpl] addEvaluation called:');
      print('  Endpoint: $_addEvaluationEndpoint');
      print('  Data: $data');

      final response = await dio.post(
        _addEvaluationEndpoint,
        data: data, // Send data in the request body
      );

      // Check for successful response (e.g., 200 OK)
      // The API doc doesn't specify success payload, assume 200/204 is success
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw ServerFailure(
          message: response.data?['msg'] ?? 'Failed to submit evaluation',
          // statusCode: response.statusCode // Removed
        );
      }
      print('[OrderRemoteDataSourceImpl] addEvaluation successful.');

    } on DioException catch (e) {
      print('[OrderRemoteDataSourceImpl] addEvaluation failed: ${e.toString()}');
      throw ServerFailure(
        message: e.response?.data?['msg'] ?? e.message ?? 'Network error',
        // statusCode: e.response?.statusCode // Removed
      );
    } catch (e) {
       print('[OrderRemoteDataSourceImpl] addEvaluation unexpected error: ${e.toString()}');
      throw ServerFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- Implement new data source methods (placeholders) ---

  @override
  Future<void> submitRequirements({
    required String orderId,
    required int productId,
    required List<Map<String, String>> feature,
    required List<String> attachmentPaths, // Expecting URLs
  }) async {
    const String _submitRequirementsEndpoint = '/api/project/orderMaterials/add';
    try {
      // Construct the request body based on API/RN code analysis
      final data = {
        'orderId': int.tryParse(orderId) ?? 0, // API might expect int
        'productId': productId,
        'feature': feature, // Pass the list of question/answer maps
        'files': attachmentPaths, // Pass the file URLs
      };

      print('[OrderRemoteDataSourceImpl] submitRequirements called:');
      print('  Endpoint: $_submitRequirementsEndpoint');
      print('  Data: $data');

      final response = await dio.post(
        _submitRequirementsEndpoint,
        data: data,
      );

      // Check for successful response
       if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw ServerFailure(
          message: response.data?['msg'] ?? 'Failed to submit requirements',
          // statusCode: response.statusCode // Removed
        );
      }
       print('[OrderRemoteDataSourceImpl] submitRequirements successful.');

    } on DioException catch (e) {
       print('[OrderRemoteDataSourceImpl] submitRequirements failed: ${e.toString()}');
      throw ServerFailure(
        message: e.response?.data?['msg'] ?? e.message ?? 'Network error',
        // statusCode: e.response?.statusCode // Removed
      );
    } catch (e) {
       print('[OrderRemoteDataSourceImpl] submitRequirements unexpected error: ${e.toString()}');
      throw ServerFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
} 