import 'dart:io';
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
    final String message = responseData['message'] ?? 'Unknown server error';
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
    final String backendBaseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://fallback-backend-url'; // Provide a fallback

    // Construct the full URL
    final String fullUrl = backendBaseUrl + uploadPath;
    print("Uploading file to: $fullUrl"); // Log the full URL
    
    try {
      // Call postMultipart WITHOUT the fields parameter
      final response = await _httpClient.postMultipart(
        fullUrl, 
        file,
      );

      // Assuming the response structure is { "code": 200, "data": { "file_url": "..." } }
      // Add proper error handling based on _handleResponse or similar logic
      final int code = response['code'] ?? 500;
      final dynamic data = response['data'];
      final String? message = response['message']?.toString();

      if (code == 200 && data != null && data['file_url'] is String) {
        return data['file_url'];
      } else {
        // Use extracted message or a default
        throw ds_exceptions.ServerException(
          message: message ?? 'File upload failed: Invalid response format',
          statusCode: code
        );
      }
    } on ds_exceptions.NetworkException catch (e) {
      print("NetworkException during file upload to $fullUrl: $e");
      throw ds_exceptions.NetworkException(message: "Network error during file upload: ${e.message}");
    } on ds_exceptions.ServerException catch (e) {
      print("ServerException during file upload to $fullUrl: $e");
      throw ds_exceptions.ServerException(
        message: "Server error during file upload: ${e.message}", 
        statusCode: e.statusCode
      );
    } catch (e) {
      print("Unexpected error during file upload to $fullUrl: $e");
      throw ds_exceptions.DataSourceException(message: "Unexpected error during file upload: ${e.toString()}");
    }
  }
} 