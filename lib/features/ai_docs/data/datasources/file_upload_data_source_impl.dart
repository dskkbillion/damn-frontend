import 'dart:io';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

import '../../../../core/network/i_http_client.dart';
import 'i_file_upload_data_source.dart';
import 'exceptions.dart' as ds_exceptions; // DataSource specific exceptions

/// {@template file_upload_data_source_impl}
/// Implementation of [IFileUploadDataSource] using [IHttpClient].
/// {@endtemplate}
@LazySingleton(as: IFileUploadDataSource)
class FileUploadDataSourceImpl implements IFileUploadDataSource {
  final IHttpClient _httpClient;

  /// {@macro file_upload_data_source_impl}
  FileUploadDataSourceImpl(this._httpClient);

  // Helper to extract data or throw ServerException (can be shared or kept private)
  dynamic _handleResponse(Map<String, dynamic> responseData) {
    final int code = responseData['code'] ?? 500;
    final String message = responseData['message'] ?? responseData['msg'] ?? 'Unknown server error';
    if (code == 200) {
      return responseData['data'];
    } else {
      throw ds_exceptions.ServerException(message: message, statusCode: code);
    }
  }

  @override
  Future<String> uploadFile(File file) async {
    // Define the specific path for upload
    const String uploadPath = '/api/common/public/upload';
    // Get the backend base URL from environment variables
    final String? backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
      throw Exception('BACKEND_BASE_URL environment variable is not set');
    }

    // Construct the full URL
    final String fullUrl = backendBaseUrl + uploadPath;
    AppLogger.d("Uploading file to: $fullUrl"); // Log the full URL
    
    try {
      // Call postMultipart WITHOUT the fields parameter
      final response = await _httpClient.postMultipart(
        fullUrl, 
        file,
      );

      // 打印响应内容，便于调试
      AppLogger.d("File upload response: $response");

      // 处理响应
      final int code = response['code'] ?? 500;
      final dynamic data = response['data'];
      final String? message = response['message']?.toString() ?? response['msg']?.toString();

      if (code == 200 && data != null) {
        // 适配不同的响应格式
        if (data is Map) {
          // 尝试读取各种可能的URL字段名
          if (data['url'] is String) {
            return data['url'];
          } else if (data['file_url'] is String) {
            return data['file_url'];
          } else if (data['fileUrl'] is String) {
            return data['fileUrl'];
          } else if (data['path'] is String) {
            return data['path'];
          } else {
            // 如果找不到合适的字段，尝试寻找任何以url结尾的字段
            for (var key in data.keys) {
              if (key.toLowerCase().endsWith('url') && data[key] is String) {
                return data[key];
              }
            }
            
            // 打印所有字段，帮助调试
            AppLogger.d("Unable to find URL in data, available fields: ${data.keys.toList()}");
            throw ds_exceptions.ServerException(
              message: "File upload succeeded but couldn't locate URL in response",
              statusCode: code
            );
          }
        } else if (data is String && data.startsWith('http')) {
          // 如果data直接是个URL字符串
          return data;
        }
      }
      
      // 如果没有返回，则抛出异常
      throw ds_exceptions.ServerException(
        message: message ?? 'File upload failed: Invalid response format',
        statusCode: code
      );
    } on ds_exceptions.NetworkException catch (e) {
      AppLogger.d("NetworkException during file upload to $fullUrl: $e");
      throw ds_exceptions.NetworkException(message: "Network error during file upload: ${e.message}");
    } on ds_exceptions.ServerException catch (e) {
      AppLogger.d("ServerException during file upload to $fullUrl: $e");
      throw ds_exceptions.ServerException(
        message: "Server error during file upload: ${e.message}", 
        statusCode: e.statusCode
      );
    } catch (e) {
      AppLogger.d("Unexpected error during file upload to $fullUrl: $e");
      throw ds_exceptions.DataSourceException(message: "Unexpected error during file upload: ${e.toString()}");
    }
  }
} 