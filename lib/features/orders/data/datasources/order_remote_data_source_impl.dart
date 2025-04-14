import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart'; // Import injectable
import 'dart:convert'; // Import jsonDecode

import '../../../../core/error/failures.dart'; // 使用 failures.dart
import '../../domain/entities/order_status.dart';
import '../models/order_model.dart';
import 'i_order_remote_data_source.dart';
import '../../domain/repositories/i_order_repository.dart';

/// 订单远程数据源的实现类。
@LazySingleton(as: IOrderRemoteDataSource) // Add injectable annotation
class OrderRemoteDataSourceImpl implements IOrderRemoteDataSource {
  // final Dio dio; // REMOVED: Direct Dio dependency
  final CoreDioClient coreDioClient; // CHANGED: Depend on CoreDioClient

  // OrderRemoteDataSourceImpl({required this.dio}); // REMOVED
  OrderRemoteDataSourceImpl({required this.coreDioClient}); // CHANGED

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
  }) async {
    final Map<String, dynamic> params = {
      'pageNum': page,
      'pageSize': limit,
      'type': 'buyer', // 假设总是查询买家订单
    };

    // (Based on API doc/example provided by user) - CORRECTED MAPPING using 'states' array
    if (status != null) {
      switch (status) {
        case OrderStatus.awaitingPayment:
          // params['state'] = 'awaitingPayment';
          params['states'] = ['awaitingPayment']; // Use states array
          break;
        case OrderStatus.awaitingSubmission:
          // params['state'] = 'awaitingSubmission'; 
          params['states'] = ['awaitingSubmission']; // Use states array
          break;
        case OrderStatus.buyAwaitingSubmission:
          // params['state'] = 'buyAwaitingSubmission'; 
          params['states'] = ['buyAwaitingSubmission']; // Use states array
          break;
        case OrderStatus.awaitingStart:
          // params['state'] = 'awaitingStart'; 
          params['states'] = ['awaitingStart']; // Use states array
           break; 
        case OrderStatus.awaitingDelivery:
          // params['state'] = 'awaitingDelivery'; 
          params['states'] = ['awaitingDelivery']; // Use states array
          break;
        case OrderStatus.awaitingConfirmation:
          // params['state'] = 'awaitingConfirmation'; 
          params['states'] = ['awaitingConfirmation']; // Use states array
          break;
        case OrderStatus.sellerSupplementaryMaterials:
          // params['state'] = 'sellerSupplementaryMaterials'; 
          params['states'] = ['sellerSupplementaryMaterials']; // Use states array
           break;
        case OrderStatus.applyForRefuse:
          // params['state'] = 'applyForRefuse'; 
          params['states'] = ['applyForRefuse']; // Use states array
           break;   
        case OrderStatus.canceled:
          // params['state'] = 'canceled'; 
          params['states'] = ['canceled']; // Use states array
           break;              
        case OrderStatus.awaitingEvaluation: 
        case OrderStatus.orderCompleted: // Keep grouping for '待评价' tab
          params['states'] = ['awaitingEvaluation', 'orderCompleted'];
          break;
        case OrderStatus.afterSale:
        case OrderStatus.AfterSaleRejection:
        case OrderStatus.applyingForMediation: // Keep grouping for '售后中' tab
          params['states'] = [
            "afterSale",
            "AfterSaleRejection",
            "applyingForMediation"
          ];
          break;
        case OrderStatus.unknown: // Represents '全部' tab
          // No state or states parameter needed for 'All'
          break;
      }
    }
    // Keyword handling remains the same
    if (keyword != null && keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }
    
    // REMOVED check for conflicting state/states as we now only use states
    // if (params.containsKey('states') && params.containsKey('state')) { ... }

    try {
      // CHANGED: Use coreDioClient.post
      final response = await coreDioClient.post(
        _listEndpoint,
        data: params,
      );

      if (response.statusCode == 200 && response.data != null) {
        // **DEBUG: Print response.data type and value**
        print('[OrderRemoteDataSource] DEBUG: response.data Type: ${response.data.runtimeType}');
        print('[OrderRemoteDataSource] DEBUG: response.data Value: ${response.data}');

        Map<String, dynamic>? dataMap;
        
        // Try to ensure we have a Map<String, dynamic>
        if (response.data is Map<String, dynamic>) {
            dataMap = response.data as Map<String, dynamic>;
        } else if (response.data is String) {
            try {
                dataMap = jsonDecode(response.data as String) as Map<String, dynamic>?;
                print('[OrderRemoteDataSource] INFO: response.data was a String, successfully decoded to Map.');
            } catch (e) {
                 print('[OrderRemoteDataSource] ERROR: response.data was a String, but failed to decode as JSON Map: $e');
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
              print("[OrderRemoteDataSource] Successfully decoded/obtained Map, but 'rows' field is null or not a list. Returning empty list."); 
              return [];
            }
        } else {
            print('[OrderRemoteDataSource] ERROR: Could not obtain a valid Map<String, dynamic> from response.data. Returning empty list.');
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
         print('[OrderRemoteDataSourceImpl] cancelOrder successful (Code: ${response.data['code']}).');
         return;
      } else {
        final errorMsg = response.data?['msg'] ?? 'Failed to cancel order (Unknown error)';
        final errorCode = response.data?['code'] ?? response.statusCode;
        print('[OrderRemoteDataSourceImpl] cancelOrder failed. Code: $errorCode, Msg: $errorMsg');
        throw ServerFailure(message: errorMsg);
      }
    } on DioException catch (e) {
      print('[OrderRemoteDataSourceImpl] cancelOrder DioException: ${e.toString()}');
      throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
      print('[OrderRemoteDataSourceImpl] cancelOrder unexpected error: ${e.toString()}');
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
         print('[OrderRemoteDataSourceImpl] confirmOrderReceipt successful (Code: ${response.data['code']}).');
         return;
      } else {
        final errorMsg = response.data?['msg'] ?? 'Failed to confirm order receipt (Unknown error)';
        final errorCode = response.data?['code'] ?? response.statusCode;
        print('[OrderRemoteDataSourceImpl] confirmOrderReceipt failed. Code: $errorCode, Msg: $errorMsg');
        throw ServerFailure(message: errorMsg);
      }
    } on DioException catch (e) {
      print('[OrderRemoteDataSourceImpl] confirmOrderReceipt DioException: ${e.toString()}');
      throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
       print('[OrderRemoteDataSourceImpl] confirmOrderReceipt unexpected error: ${e.toString()}');
        if (e is ServerFailure) { rethrow; }
      throw ServerFailure(message: 'An unexpected error occurred in confirmOrderReceipt: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOrder(int orderId) async {
    // API Doc says POST, query parameter is 'orderId' (string?)
     const String _deleteEndpoint = '/api/shop/order/delete';
    try {
      final response = await coreDioClient.post(
        _deleteEndpoint,
        queryParameters: {'orderId': orderId.toString()}, // Send as string to be safe?
        data: {}, // Sending empty data as body might be needed for POST
      );
      
      // Check BUSINESS code from response body
      if (response.statusCode == 200 && response.data != null && response.data['code'] == 200) {
         print('[OrderRemoteDataSourceImpl] deleteOrder successful (Code: ${response.data['code']}).');
         return;
      } else {
        final errorMsg = response.data?['msg'] ?? 'Failed to delete order (Unknown error)';
        final errorCode = response.data?['code'] ?? response.statusCode;
        print('[OrderRemoteDataSourceImpl] deleteOrder failed. Code: $errorCode, Msg: $errorMsg');
        throw ServerFailure(message: errorMsg);
      }
    } on DioException catch (e) {
      print('[OrderRemoteDataSourceImpl] deleteOrder DioException: ${e.toString()}');
       throw ServerFailure(
          message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
      print('[OrderRemoteDataSourceImpl] deleteOrder unexpected error: ${e.toString()}');
       if (e is ServerFailure) { rethrow; }
      throw ServerFailure(message: 'An unexpected error occurred in deleteOrder: ${e.toString()}');
    }
  }

  // --- Add Evaluation Method ---
  @override
  Future<void> addEvaluation({
    // required String orderId, // Keep commented out
    required int orderItemId,
    required double score,
    required String content,
    required bool isAnonymous,
    required List<String> pictures,
  }) async {
    final Map<String, dynamic> requestData = {
      'orderItemId': orderItemId,
      'score': score,
      'content': content,
      'isAnonymous': isAnonymous ? 1 : 0, // Assuming API expects 0/1
      'pictures': pictures, // Assuming API accepts a list of strings
    };
    try {
      final response = await coreDioClient.post(_addEvaluationEndpoint, data: requestData);
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
  Future<void> submitRequirements({
    required String orderId,
    required int productId,
    required List<Map<String, String>> feature,
    required List<String> attachmentPaths,
  }) async {
    const String _submitRequirementsEndpoint = '/api/project/orderMaterials/add';
    try {
      // Construct the request body based on API/RN code analysis
      final data = {
        'orderId': int.tryParse(orderId) ?? 0,
        'productId': productId,
        'feature': feature,
        'files': attachmentPaths,
      };

      print('[OrderRemoteDataSourceImpl] submitRequirements called:');
      print('  Endpoint: $_submitRequirementsEndpoint');
      print('  Data: $data');

      // CHANGED: Use coreDioClient.post
      final response = await coreDioClient.post(
        _submitRequirementsEndpoint,
        data: data,
      );

      // CORRECTED: Check BUSINESS code from response body
      if (response.statusCode == 200 && response.data != null && response.data['code'] == 200) {
         print('[OrderRemoteDataSourceImpl] submitRequirements successful (Code: ${response.data['code']}).');
         return;
      } else {
        final errorMsg = response.data?['msg'] ?? 'Failed to submit requirements (Unknown error)';
        final errorCode = response.data?['code'] ?? response.statusCode;
        print('[OrderRemoteDataSourceImpl] submitRequirements failed. Code: $errorCode, Msg: $errorMsg');
        throw ServerFailure(message: errorMsg);
      }
    } on DioException catch (e) {
       print('[OrderRemoteDataSourceImpl] submitRequirements failed: ${e.toString()}');
      throw ServerFailure(
        message: e.response?.data?['msg'] ?? e.message ?? 'Network error');
    } catch (e) {
       print('[OrderRemoteDataSourceImpl] submitRequirements unexpected error: ${e.toString()}');
      throw ServerFailure(message: 'An unexpected error occurred in submitRequirements: ${e.toString()}');
    }
  }

  @override
  Future<void> saveRequirementDraft(/* DraftParams params */) async {
    // This operation is now intended to be handled locally (e.g., SharedPreferences).
    // No remote API call is defined for saving drafts.
    print('[OrderRemoteDataSource] WARN: saveRequirementDraft called, but it should be handled locally.');
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
    // API endpoint for inviting evaluation is not confirmed yet.
    print('[OrderRemoteDataSource] ERROR: inviteEvaluation called, but API endpoint is unknown.');
    throw UnimplementedError('API endpoint for inviting evaluation is not implemented.');
    // Or return Left(ServerFailure(...)) immediately if preferred
  }
} 