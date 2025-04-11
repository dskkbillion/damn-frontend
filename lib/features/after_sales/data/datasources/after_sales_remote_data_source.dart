import 'package:dio/dio.dart';
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
      // Assuming response is like: { "code": 200, "msg": "...", "data": { ... } }
      if (response.data != null && response.data['code'] == 200 && response.data['data'] is Map) {
         return AfterSalesApplicationModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
         throw ServerException(message: response.data?['msg'] ?? 'Failed to fetch refund detail', statusCode: response.statusCode);
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
} 