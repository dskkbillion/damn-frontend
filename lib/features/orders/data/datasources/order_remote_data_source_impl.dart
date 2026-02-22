import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart'; // Import injectable
import 'dart:convert'; // Import jsonDecode
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/failures.dart'; // 使用 failures.dart
import '../../domain/entities/order_status.dart';
import '../models/order_model.dart';
import 'i_order_remote_data_source.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../domain/entities/order_creation_result.dart';
import '../../domain/usecases/submit_requirements_use_case.dart';

/// 订单远程数据源的实现类。
@LazySingleton(as: IOrderRemoteDataSource) // Add injectable annotation
class OrderRemoteDataSourceImpl implements IOrderRemoteDataSource {
  // final Dio dio; // REMOVED: Direct Dio dependency
  final CoreDioClient coreDioClient; // CHANGED: Depend on CoreDioClient
  final FlutterSecureStorage secureStorage;

  // OrderRemoteDataSourceImpl({required this.dio}); // REMOVED
  OrderRemoteDataSourceImpl({
    required this.coreDioClient,
    required this.secureStorage,
  }); // CHANGED

  // --- API Endpoints --- (根据 RN 代码分析确定)
  final String _listEndpoint = '/api/shop/order/list';
  final String _detailEndpoint = '/api/shop/order/detail';
  final String _cancelEndpoint = '/api/shop/order/cancel';
  final String _receiptEndpoint = '/api/shop/order/complete'; // Corrected path
  final String _deleteEndpoint = '/api/shop/order/delete';
  final String _addEvaluationEndpoint = '/api/shop/evaluate/add'; // 新增
  final String _submitRequirementsEndpoint = '/api/project/orderMaterials/add'; // Added endpoint

  @override
  Future<List<OrderModel>> getOrderList({
    OrderStatus? status,
    String? keyword,
    required int page,
    required int limit,
    required String userRole,
  }) async {
    final Map<String, dynamic> params = {
      'pageNum': page,
      'pageSize': limit,
      'type': userRole,
    };

    // Add status parameter if status filter is provided and not 'unknown' (All)
    if (status != null && status != OrderStatus.unknown) {
      // 直接使用订单状态的枚举值，与后端保持一致
      params['state'] = status.name;  // 使用枚举的name属性获取字符串值
      
      // 添加调试日志
      AppLogger.d('[OrderRemoteDataSource] Mapping status: ${status.name} -> state: ${params['state']}');
    }
    // Keyword handling remains the same
    if (keyword != null && keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }
    
    // REMOVED check for conflicting state/states as we now only use states
    // if (params.containsKey('states') && params.containsKey('state')) { ... }

    // 添加调试日志
    AppLogger.d('[OrderRemoteDataSource] getOrderList called with params: $params');

    try {
      // CHANGED: Use coreDioClient.post
      final response = await coreDioClient.post(
        _listEndpoint,
        data: params,
      );

      // 添加响应日志
      AppLogger.d('[OrderRemoteDataSource] Response status: ${response.statusCode}');
      AppLogger.d('[OrderRemoteDataSource] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        // **DEBUG: Print response.data type and value**
        AppLogger.d('[OrderRemoteDataSource] DEBUG: response.data Type: ${response.data.runtimeType}');
        AppLogger.d('[OrderRemoteDataSource] DEBUG: response.data Value: ${response.data}');

        Map<String, dynamic>? dataMap;
        
        // Try to ensure we have a Map<String, dynamic>
        if (response.data is Map<String, dynamic>) {
            dataMap = response.data as Map<String, dynamic>;
        } else if (response.data is String) {
            try {
                dataMap = jsonDecode(response.data as String) as Map<String, dynamic>?;
                AppLogger.d('[OrderRemoteDataSource] INFO: response.data was a String, successfully decoded to Map.');
            } catch (e) {
                 AppLogger.d('[OrderRemoteDataSource] ERROR: response.data was a String, but failed to decode as JSON Map: $e');
            }
        }

        if (dataMap != null) {
            final List<dynamic>? orderListJson = dataMap['rows'] as List<dynamic>?; // Access rows from the ensured map

            if (orderListJson != null) {
              return orderListJson
                  .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
                  .toList();
            } else {
              // Use double quotes for the outer string to allow inner single quotes
              AppLogger.d("[OrderRemoteDataSource] Successfully decoded/obtained Map, but 'rows' field is null or not a list. Returning empty list."); 
              return [];
            }
        } else {
            AppLogger.d('[OrderRemoteDataSource] ERROR: Could not obtain a valid Map<String, dynamic> from response.data. Returning empty list.');
            return [];
        }
      } else {
        throw ServerFailure(
            message: response.data?['msg'] ?? 'Failed to load order list');
      }
    } on DioException catch (e) {
      // CoreDioClient already handles DioException logging/wrapping via interceptors?
      // Consider if specific handling is still needed here or rely on interceptor/Repository level.
      // For now, keep similar handling but message might be redundant if interceptor logs.
      throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
      // Catching other exceptions that might occur before/after the Dio call within this method
      throw ServerFailure(message: 'An unexpected error occurred in getOrderList: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderDetail(int orderId) async {
    try {
      // CHANGED: Use coreDioClient.get
      final response = await coreDioClient.get(
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
            message: response.data?['msg'] ?? 'Failed to load order detail');
      }
    } on DioException catch (e) {
      throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred in getOrderDetail: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelOrder(int orderId) async {
    // API Doc says GET, query parameter is 'orderId' (string?)
    const String _cancelEndpoint = '/api/shop/order/cancel';
    try {
      final response = await coreDioClient.get(
        _cancelEndpoint,
        queryParameters: {'orderId': orderId.toString()}, // Send as string to be safe?
      );
      
      // Check BUSINESS code from response body
      if (response.statusCode == 200 && response.data != null && response.data['code'] == 200) {
         AppLogger.d('[OrderRemoteDataSourceImpl] cancelOrder successful (Code: ${response.data['code']}).');
         return;
      } else {
        final errorMsg = response.data?['msg'] ?? 'Failed to cancel order (Unknown error)';
        final errorCode = response.data?['code'] ?? response.statusCode;
        AppLogger.d('[OrderRemoteDataSourceImpl] cancelOrder failed. Code: $errorCode, Msg: $errorMsg');
        throw ServerFailure(message: errorMsg);
      }
    } on DioException catch (e) {
      AppLogger.d('[OrderRemoteDataSourceImpl] cancelOrder DioException: ${e.toString()}');
      throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
      AppLogger.d('[OrderRemoteDataSourceImpl] cancelOrder unexpected error: ${e.toString()}');
       if (e is ServerFailure) { rethrow; }
      throw ServerFailure(message: 'An unexpected error occurred in cancelOrder: ${e.toString()}');
    }
  }

  @override
  Future<void> confirmOrderReceipt(int orderId) async {
    // API Doc says GET, query parameter is 'orderId' (string?)
    const String _receiptEndpoint = '/api/shop/order/complete'; // Correct path
    try {
      final response = await coreDioClient.get(
        _receiptEndpoint, 
        queryParameters: {'orderId': orderId.toString()}, // Send as string to be safe?
      );
      
      // Check BUSINESS code from response body
      if (response.statusCode == 200 && response.data != null && response.data['code'] == 200) {
         AppLogger.d('[OrderRemoteDataSourceImpl] confirmOrderReceipt successful (Code: ${response.data['code']}).');
         return;
      } else {
        final errorMsg = response.data?['msg'] ?? 'Failed to confirm order receipt (Unknown error)';
        final errorCode = response.data?['code'] ?? response.statusCode;
        AppLogger.d('[OrderRemoteDataSourceImpl] confirmOrderReceipt failed. Code: $errorCode, Msg: $errorMsg');
        throw ServerFailure(message: errorMsg);
      }
    } on DioException catch (e) {
      AppLogger.d('[OrderRemoteDataSourceImpl] confirmOrderReceipt DioException: ${e.toString()}');
      throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
       AppLogger.d('[OrderRemoteDataSourceImpl] confirmOrderReceipt unexpected error: ${e.toString()}');
        if (e is ServerFailure) { rethrow; }
      throw ServerFailure(message: 'An unexpected error occurred in confirmOrderReceipt: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOrder(int orderId) async {
    // API Doc says POST, query parameter is 'orderId' (string?)
     const String _deleteEndpoint = '/api/shop/order/delete';
    AppLogger.d('[OrderRemoteDataSourceImpl] 开始删除订单: $orderId');
    
    try {
      final response = await coreDioClient.post(
        _deleteEndpoint,
        queryParameters: {'orderId': orderId.toString()}, // Send as string to be safe?
        data: {}, // Sending empty data as body might be needed for POST
      );
      
      AppLogger.d('[OrderRemoteDataSourceImpl] 删除订单API响应: statusCode=${response.statusCode}, data=${response.data}');
      
      // Check BUSINESS code from response body
      if (response.statusCode == 200 && response.data != null && response.data['code'] == 200) {
         AppLogger.d('[OrderRemoteDataSourceImpl] deleteOrder successful (Code: ${response.data['code']}).');
         return;
      } else {
        final errorMsg = response.data?['msg'] ?? 'Failed to delete order (Unknown error)';
        final errorCode = response.data?['code'] ?? response.statusCode;
        AppLogger.d('[OrderRemoteDataSourceImpl] deleteOrder failed. Code: $errorCode, Msg: $errorMsg');
        throw ServerFailure(message: errorMsg);
      }
    } on DioException catch (e) {
      AppLogger.d('[OrderRemoteDataSourceImpl] deleteOrder DioException: ${e.toString()}');
      AppLogger.d('[OrderRemoteDataSourceImpl] DioException response: ${e.response?.data}');
       throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
      AppLogger.d('[OrderRemoteDataSourceImpl] deleteOrder unexpected error: ${e.toString()}');
       if (e is ServerFailure) { rethrow; }
      throw ServerFailure(message: 'An unexpected error occurred in deleteOrder: ${e.toString()}');
    }
  }

  // --- Add Evaluation Method ---
  @override
  Future<void> addEvaluation({
    required int orderId,
    required double score,
    required String content,
    required bool isAnonymous,
    required List<String> pictures,
  }) async {
    final Map<String, dynamic> requestData = {
      'orderId': orderId,
      'score': score,
      'remark': content,  // 后端字段名是remark，不是content
      'anonymityFlag': isAnonymous,  // 后端字段名是anonymityFlag，不是isAnonymous
      'images': pictures,  // 后端字段名可能是images而不是pictures
    };

    AppLogger.d('[评价API] 请求数据: $requestData');

    try {
      final response = await coreDioClient.post(_addEvaluationEndpoint, data: requestData);
      AppLogger.d('[评价API] 响应: ${response.data}');
      if (response.statusCode != 200 || (response.data != null && response.data['code'] != 200)) {
        throw ServerFailure(message: response.data?['msg'] ?? 'Failed to add evaluation');
      }
      // Success
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data?['msg'] ?? e.message ?? 'Network error adding evaluation');
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred adding evaluation: ${e.toString()}');
    }
  }

  // --- Implement new data source methods (placeholders) ---

  @override
  Future<void> submitRequirements(SubmitRequirementsParams params) async {
    const String _submitRequirementsEndpoint = '/api/project/orderMaterials/add';
    try {
      // Construct the request body based on API/RN code analysis
      final data = {
        'orderId': params.orderId,
        'productId': params.productId,
        'feature': params.feature,
        'files': params.attachmentPaths,
      };

      AppLogger.d('[OrderRemoteDataSourceImpl] submitRequirements called:');
      AppLogger.d('  Endpoint: $_submitRequirementsEndpoint');
      AppLogger.d('  Data: $data');

      // CHANGED: Use coreDioClient.post
      final response = await coreDioClient.post(
        _submitRequirementsEndpoint,
        data: data,
      );

      // CORRECTED: Check BUSINESS code from response body
      if (response.statusCode == 200 && response.data != null && response.data['code'] == 200) {
         AppLogger.d('[OrderRemoteDataSourceImpl] submitRequirements successful (Code: ${response.data['code']}).');
         return;
      } else {
        final errorMsg = response.data?['msg'] ?? 'Failed to submit requirements (Unknown error)';
        final errorCode = response.data?['code'] ?? response.statusCode;
        AppLogger.d('[OrderRemoteDataSourceImpl] submitRequirements failed. Code: $errorCode, Msg: $errorMsg');
        throw ServerFailure(message: errorMsg);
      }
    } on DioException catch (e) {
       AppLogger.d('[OrderRemoteDataSourceImpl] submitRequirements failed: ${e.toString()}');
      throw ServerFailure(
        message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
       AppLogger.d('[OrderRemoteDataSourceImpl] submitRequirements unexpected error: ${e.toString()}');
      throw ServerFailure(message: 'An unexpected error occurred in submitRequirements: ${e.toString()}');
    }
  }

  @override
  Future<void> saveRequirementDraft(/* DraftParams params */) async {
    // This operation is now intended to be handled locally (e.g., SharedPreferences).
    // No remote API call is defined for saving drafts.
    AppLogger.d('[OrderRemoteDataSource] WARN: saveRequirementDraft called, but it should be handled locally.');
    // Optionally throw an error or return success immediately if no action needed here
    // throw UnsupportedError('Saving requirement drafts is handled locally.');
    return Future.value(); // Or return normally if the interface expects a Future<void>
  }

  // --- Seller specific action implementations ---

  @override
  Future<void> confirmOrderAcceptance(int orderId) async {
    const String endpoint = '/api/shop/order/verify'; // Confirmed from RN code
    final String url = '$endpoint?orderId=$orderId'; // Append orderId as query param
    try {
      final response = await coreDioClient.post(
        url,
        data: {}, // Empty body as confirmed from RN code
      );
      // Assuming standard wrapper { code: 200, msg: "...", data: null }
      if (response.statusCode != 200 || (response.data != null && response.data['code'] != 200)) {
        throw ServerFailure(message: response.data?['msg'] ?? 'Failed to confirm order acceptance');
      }
      // Success, no data expected
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data?['msg'] ?? e.message ?? 'Network error confirming order');
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred confirming order: ${e.toString()}');
    }
  }

  @override
  Future<void> addOrderDemand(AddOrderDemandParams params) async {
    const String endpoint = '/api/project/orderDemand/add';
    try {
      final requestData = {
        'orderId': params.orderId,
        'type': params.type, // "refuse" or "material"
        'reasonValue': params.reasonValue,
        'reasonLabel': params.reasonLabel,
        'remarks': params.remarks,
        // Files are not part of this API according to the doc
      };
      final response = await coreDioClient.post(endpoint, data: requestData);

      if (response.statusCode != 200 || (response.data != null && response.data['code'] != 200)) {
        throw ServerFailure(message: response.data?['msg'] ?? 'Failed to add order demand');
      }
      // Success
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data?['msg'] ?? e.message ?? 'Network error adding order demand');
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred adding order demand: ${e.toString()}');
    }
  }

  @override
  Future<void> deliverOrder(DeliverOrderParams params) async {
    const String endpoint = '/api/project/orderDelivery/add';
    try {
      // !! IMPORTANT: API doc says 'files' is string, RN code uses string[].
      //    Assuming string[] is correct based on RN, needs backend confirmation.
      //    If API expects comma-separated string, adjust here:
      //    'files': params.files.join(',')
      final requestData = {
        'orderId': params.orderId,
        'content': params.content,
        'files': params.files, // Sending as array, confirm with backend!
        'deliverySn': params.deliverySn,
        'deliveryCompany': params.deliveryCompany,
      };
      final response = await coreDioClient.post(endpoint, data: requestData);

      if (response.statusCode != 200 || (response.data != null && response.data['code'] != 200)) {
        throw ServerFailure(message: response.data?['msg'] ?? 'Failed to deliver order');
      }
      // Success
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data?['msg'] ?? e.message ?? 'Network error delivering order');
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred delivering order: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSellerOrderRecord(int orderId) async {
    const String endpoint = '/api/shop/order/sellerDelete';
    final String url = '$endpoint?orderId=$orderId';
    try {
      final response = await coreDioClient.post(
        url,
        data: {}, // Empty body
      );
      if (response.statusCode != 200 || (response.data != null && response.data['code'] != 200)) {
        // API doc example shows empty data object {} on success, code is likely in wrapper
        throw ServerFailure(message: response.data?['msg'] ?? 'Failed to delete seller order record');
      }
      // Success
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data?['msg'] ?? e.message ?? 'Network error deleting seller order');
    } catch (e) {
      throw ServerFailure(message: 'An unexpected error occurred deleting seller order: ${e.toString()}');
    }
  }

  @override
  Future<void> inviteEvaluation(int orderId) async {
    const String endpoint = '/api/shop/evaluate/invite';
    try {
      final response = await coreDioClient.post(
        endpoint,
        queryParameters: {'orderId': orderId.toString()},
        data: {}, // Empty body as per API requirements
      );
      
      // Check BUSINESS code from response body
      if (response.statusCode == 200 && response.data != null && response.data['code'] == 200) {
         AppLogger.d('[OrderRemoteDataSourceImpl] inviteEvaluation successful (Code: ${response.data['code']}).');
         return;
      } else {
        final errorMsg = response.data?['msg'] ?? 'Failed to invite evaluation (Unknown error)';
        final errorCode = response.data?['code'] ?? response.statusCode;
        AppLogger.d('[OrderRemoteDataSourceImpl] inviteEvaluation failed. Code: $errorCode, Msg: $errorMsg');
        throw ServerFailure(message: errorMsg);
      }
    } on DioException catch (e) {
      AppLogger.d('[OrderRemoteDataSourceImpl] inviteEvaluation DioException: ${e.toString()}');
      throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error inviting evaluation');
    } catch (e) {
      AppLogger.d('[OrderRemoteDataSourceImpl] inviteEvaluation unexpected error: ${e.toString()}');
      if (e is ServerFailure) { rethrow; }
      throw ServerFailure(message: 'An unexpected error occurred inviting evaluation: ${e.toString()}');
    }
  }

  @override
  Future<OrderCreationResult> createOrder({
    required int productId,
    required int variantId,
    required int quantity,
    required int sellerId,
    required double price,
  }) async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      
      final response = await coreDioClient.post(
        '/api/shop/order/create',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'tenantId': sellerId, // 添加卖家ID（tenantId）
          'couponId': null, // 优惠券ID，可为null
          'remark': '通过应用下单',
          'items': [
            {
              'productId': productId,
              'variantId': variantId,
              'quantity': quantity,
            }
          ],
          'addressId': null, // 收货地址ID，可为null
          'groupId': null, // 拼团ID，可为null  
          'activityType': 'product', // 活动类型：product
          'referrerId': null, // 邀请人ID，可为null
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['code'] == 200) {
          // 根据实际API响应格式调整数据解析
          final orderData = data['data'];
          return OrderCreationResult(
            orderId: (orderData['id'] ?? orderData['orderId']).toString(), // 转换为字符串类型
            orderInfo: orderData['orderInfo'] ?? 'order_${orderData['id']}', // 生成订单信息
            totalAmount: double.tryParse(orderData['payPrice']?.toString() ?? orderData['totalPrice']?.toString() ?? '0') ?? 0.0,
          );
        } else {
          throw ServerFailure(
            message: data['msg'] ?? data['message'] ?? '创建订单失败',
            statusCode: data['code'],
          );
        }
      } else {
        throw ServerFailure(
          message: '服务器错误：${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerFailure) {
        rethrow;
      }
      
      throw ServerFailure(
        message: '创建订单失败: $e',
        statusCode: 500,
      );
    }
  }
} 