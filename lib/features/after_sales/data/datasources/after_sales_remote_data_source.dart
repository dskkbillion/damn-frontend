import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/core_dio_client.dart'; // Add new import
import '../../../../core/utils/data_mapper.dart'; // For parsing the apply response ID
import '../../domain/repositories/i_after_sales_repository.dart'; // For Params
import '../models/after_sales_application_model.dart';
import 'i_after_sales_remote_data_source.dart';

@LazySingleton(as: IAfterSalesRemoteDataSource)
class AfterSalesRemoteDataSource implements IAfterSalesRemoteDataSource {
  final CoreDioClient _dioClient; // Use new field

  // API endpoints (consider moving these to a constants file)
  final String _applyEndpoint = '/api/shop/order-refund/apply';
  final String _listEndpoint = '/api/shop/order-refund/list';
  final String _detailEndpoint = '/api/shop/order-refund/detail'; // Base path
  final String _cancelEndpoint = '/api/shop/order-refund/cancel';
  final String _deleteEndpoint = '/api/shop/order-refund/delete';

  AfterSalesRemoteDataSource(this._dioClient);

  @override
  Future<int> applyForAfterSales(ApplyAfterSalesParams params) async {
    final requestData = {
      'orderItemId': params.orderItemId,
      'memberType': 'buyer', // Hardcoded as per analysis
      'auditType': 'seller', // Hardcoded as per analysis
      'refundReason': params.refundReason,
      'refundExplain': params.refundExplain,
      'refundType': params.refundType,
      if (params.refundImage != null && params.refundImage!.isNotEmpty)
        'refundImage': params.refundImage,
      // 'refundPrice' is intentionally omitted based on analysis
    };

    try {
      final response = await _dioClient.post(_applyEndpoint, data: requestData);
      // Assuming successful response structure is like: { "code": 200, "msg": "...", "data": <refund_id> }
      // Adjust parsing based on actual API response structure for AjaxResult
      if (response.data != null && response.data['code'] == 200 && response.data['data'] != null) {
         return DataMapper.toInt(response.data['data']); // Extract the ID
      } else {
         throw ServerException(message: response.data?['msg'] ?? 'Failed to apply for refund', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      // Handle Dio specific errors (timeout, connection, etc.)
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    } catch (e) {
      // Handle other unexpected errors
       throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<List<AfterSalesApplicationModel>> getAfterSalesList(
      GetAfterSalesListParams params) async {
    final queryParameters = {
      'page': params.page,
      'pageSize': params.pageSize,
      if (params.stateFilter != null) 'refundState': params.stateFilter,
      // Add other potential query params based on OrderRefundQuery if needed
    };

    try {
      // API doc says POST for list, confirm this is correct
      final response = await _dioClient.post(_listEndpoint, data: queryParameters);
      // Assuming response is like: { "code": 200, "msg": "...", "data": { "rows": [...] } } or similar (e.g. TableDataInfo)
      // Adjust parsing based on actual API response
      if (response.data != null && response.data['code'] == 200 && response.data['data']?['rows'] is List) {
         final List<dynamic> results = response.data['data']['rows'];
         return results
             .map((json) => AfterSalesApplicationModel.fromJson(json as Map<String, dynamic>))
             .toList();
      } else {
         throw ServerException(message: response.data?['msg'] ?? 'Failed to fetch refund list', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    } catch (e) {
       throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<AfterSalesApplicationModel> getAfterSalesDetail(int refundId) async {
     final queryParameters = {'id': refundId}; // API doc uses 'id' query param

    try {
       // API doc says GET for detail
      final response = await _dioClient.get(_detailEndpoint, queryParameters: queryParameters);
      
      AppLogger.d('[AfterSalesRemoteDataSource] getAfterSalesDetail response: ${response.data}');
      
      // Check if response has data field
      if (response.data != null && response.data['code'] == 200) {
        final responseData = response.data['data'];
        
        if (responseData == null) {
          // No data field means the record doesn't exist or was deleted
          throw ServerException(
            message: '售后申请不存在或已被删除 (ID: $refundId)', 
            statusCode: 404
          );
        }
        
        if (responseData is Map) {
          return AfterSalesApplicationModel.fromJson(responseData as Map<String, dynamic>);
        } else {
          throw ServerException(
            message: '服务器返回数据格式错误', 
            statusCode: response.statusCode
          );
        }
      } else {
        throw ServerException(
          message: response.data?['msg'] ?? 'Failed to fetch refund detail', 
          statusCode: response.statusCode
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    } catch (e) {
       throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelAfterSales(int refundId) async {
     // RN code used POST, API doc says GET with query param. Let's follow API doc.
     // If POST is needed, change _dioClient.get to _dioClient.post and adjust params
     final queryParameters = {'refundId': refundId};

    try {
      // API Doc shows GET for cancel? This seems odd. Assuming POST based on RN/convention.
      // final response = await _dioClient.get(_cancelEndpoint, queryParameters: queryParameters);
       final response = await _dioClient.post(_cancelEndpoint, data: queryParameters); // Using POST as likely correct
      // Assuming response is like: { "code": 200, "msg": "..." }
      if (response.data == null || response.data['code'] != 200) {
         throw ServerException(message: response.data?['msg'] ?? 'Failed to cancel refund', statusCode: response.statusCode);
      }
      // No data to return on success
    } on DioException catch (e) {
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    } catch (e) {
       throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

   @override
  Future<void> deleteAfterSales(List<int> refundIds) async {
      // API doc shows body is array of integers
      final requestData = refundIds;

    try {
      final response = await _dioClient.post(_deleteEndpoint, data: requestData);
       // Assuming response is like: { "code": 200, "msg": "..." }
      if (response.data == null || response.data['code'] != 200) {
         throw ServerException(message: response.data?['msg'] ?? 'Failed to delete refund', statusCode: response.statusCode);
      }
       // No data to return on success
    } on DioException catch (e) {
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    } catch (e) {
       throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<int?> getRefundIdByOrderId(int orderId) async {
    try {
      // Use list API to find refund record by order ID
      // We can use a large page size to get all records and filter by order ID
      final queryParameters = {
        'page': 1,
        'pageSize': 1000, // Large page size to ensure we get the record
      };

      final response = await _dioClient.post(_listEndpoint, data: queryParameters);
      
      AppLogger.d('[AfterSalesRemoteDataSource] getRefundIdByOrderId response: ${response.data}');
      
      if (response.data != null && response.data['code'] == 200) {
        // Check if 'rows' exists directly in response.data (not nested under 'data')
        List<dynamic> results = [];
        if (response.data['rows'] is List) {
          results = response.data['rows'];
        } else if (response.data['data']?['rows'] is List) {
          results = response.data['data']['rows'];
        }
        
        AppLogger.d('[AfterSalesRemoteDataSource] Found ${results.length} refund records');
        
        // Find the refund record that matches the order ID
        for (final json in results) {
          final refundData = json as Map<String, dynamic>;
          AppLogger.d('[AfterSalesRemoteDataSource] Checking refund record: orderId=${refundData['orderId']}, looking for=$orderId');
          if (refundData['orderId'] == orderId) {
            final refundId = refundData['id'] as int?;
            AppLogger.d('[AfterSalesRemoteDataSource] Found matching refund ID: $refundId for order ID: $orderId');
            return refundId;
          }
        }
        
        AppLogger.d('[AfterSalesRemoteDataSource] No matching refund found for order ID: $orderId');
        // No matching refund found for this order ID
        return null;
      } else {
        throw ServerException(message: response.data?['msg'] ?? 'Failed to fetch refund list', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  ServerException _createServerException(Response response, String defaultMessage) {
    if (response.data != null && response.data['msg'] != null && response.data['msg'].isNotEmpty) {
      return ServerException(message: response.data['msg'], statusCode: response.statusCode);
    } else {
      return ServerException(message: defaultMessage, statusCode: response.statusCode);
    }
  }
} 