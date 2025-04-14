import 'package:dio/dio.dart'; // Assuming usage of dio
import 'dart:convert'; // Not needed if dio handles json automatically

import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import '../models/index_data_dto.dart';
import '../models/percent_data_dto.dart';
import '../models/upgrade_level_data_dto.dart';
import 'seller_dashboard_remote_data_source.dart';

abstract class SellerDashboardRemoteDataSource {
  /// Calls the POST /api/project/statistics/percent endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<PercentDataDto> getPercentData({required String token});

  /// Calls the POST /api/project/statistics/upgradeLevel endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<UpgradeLevelDataDto> getUpgradeLevelData({required String token});

  /// Calls the POST /api/project/statistics/index endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<IndexDataDto> getIndexData({required String token});
}

// --- Concrete Implementation ---

class SellerDashboardRemoteDataSourceImpl implements SellerDashboardRemoteDataSource {
  final Dio client; // Inject Dio client
  // Base URL should be configured in the injected Dio client's options

  SellerDashboardRemoteDataSourceImpl({required this.client});

  // Helper function for POST requests
  Future<T> _postRequest<T>(
    String path, // Relative path (e.g., /api/project/statistics/percent)
    String token,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // Dio client should have baseUrl configured. It automatically prepends it.
    try {
      final response = await client.post(
        path, // Use relative path
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'clienttype': '1',
            'client': 'flutter',
            'version': '100',
          },
        ),
        // data: {}, // Add body data if needed
      );

      if (response.data != null && response.data['data'] is Map<String, dynamic>) {
         try {
            return fromJson(response.data['data'] as Map<String, dynamic>);
         } catch (e, s) {
            print("Parsing Error for $path: $e\n$s");
            throw ParsingException(message: "Failed to parse response for $path", stackTrace: s);
         }
      } else {
         print("Invalid response structure for $path: ${response.data}");
         throw ParsingException(message: "Invalid response structure for $path");
      }

    } on DioException catch (e, s) {
      print("DioError for $path: ${e.message}\n${e.response?.data}\n$s");
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: e.message, stackTrace: s);
      }
      throw ServerException(
        statusCode: e.response?.statusCode,
        message: e.response?.data?['msg']?.toString() ?? e.message,
        stackTrace: s,
      );
    } catch (e, s) {
      print("Unexpected Error for $path: $e\n$s");
      throw AppException(e.toString(), s);
    }
  }

  @override
  Future<PercentDataDto> getPercentData({required String token}) async {
    return await _postRequest(
      '/api/project/statistics/percent',
      token,
      PercentDataDto.fromJson,
    );
  }

  @override
  Future<UpgradeLevelDataDto> getUpgradeLevelData({required String token}) async {
     return await _postRequest(
      '/api/project/statistics/upgradeLevel',
      token,
      UpgradeLevelDataDto.fromJson,
    );
  }

  @override
  Future<IndexDataDto> getIndexData({required String token}) async {
     return await _postRequest(
      '/api/project/statistics/index',
      token,
      IndexDataDto.fromJson,
    );
  }
} 