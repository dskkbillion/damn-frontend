import 'dart:io';
import 'package:injectable/injectable.dart';

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
    const String path = '/api/common/public/upload';
    
    try {
      // Call the dedicated multipart upload method from IHttpClient
      // The implementation of postMultipart in IHttpClient is responsible
      // for setting the correct content type.
      final response = await _httpClient.postMultipart(
        path,
        file,
        // fileField: 'file' // Assuming 'file' is the default or API specific field name
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
      print("NetworkException during file upload: $e");
      throw ds_exceptions.NetworkException(message: "Network error during file upload: ${e.message}");
    } on ds_exceptions.ServerException catch (e) {
      print("ServerException during file upload: $e");
      throw ds_exceptions.ServerException(
        message: "Server error during file upload: ${e.message}", 
        statusCode: e.statusCode
      );
    } catch (e) {
      print("Unexpected error during file upload: $e");
      throw ds_exceptions.DataSourceException(message: "Unexpected error during file upload: ${e.toString()}");
    }
  }
} 