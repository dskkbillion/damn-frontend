import 'dart:io';

import 'package:dio/dio.dart'; // Import Dio
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import ServerException
import 'package:injectable/injectable.dart'; // Add injectable import

// Correct import for Interface using package path
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_file_remote_data_source.dart';

// Create Dio instance with proper base URL from environment
// TODO: This should be injected via DI instead of created here
final _dio = Dio(BaseOptions(
  baseUrl: () {
    final url = dotenv.env['BACKEND_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('BACKEND_BASE_URL environment variable is not set');
    }
    return url;
  }(),
));
// NOTE: Configure interceptors (auth, logging)

// @LazySingleton(as: IFileRemoteDataSource) // Add injectable annotation
class FileRemoteDataSourceImpl implements IFileRemoteDataSource {
  final Dio dio; // Inject Dio

  FileRemoteDataSourceImpl({required this.dio}); // Constructor injection

  @override
  Future<String> uploadFile(File file) async {
    final uploadPath = '/api/common/public/upload'; // Define path clearly
    final targetUrl = dio.options.baseUrl + uploadPath;
    print("[API Call] Uploading file: ${file.path} to $targetUrl"); // Log full target URL

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      final response = await dio.post(
        uploadPath, // Use the defined path
        data: formData,
        // Let Dio handle multipart Content-Type
        onSendProgress: (int sent, int total) {
           if (total > 0) { // Avoid division by zero
              // print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
           }
        },
      );

      // Manually check response data and parse safely
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseData = response.data;
          // Use the robust code check helper
          if (_isSuccessCode(responseData['code'])) { 
             // Check for 'data' field containing the url, as per API doc example
             final dynamic dataField = responseData['data'];
             if (dataField is Map<String, dynamic> && dataField['url'] is String) {
                 print("[API Call] File upload successful. URL: ${dataField['url']}");
                 return dataField['url'] as String;
             } else {
                print("API Error (upload): Successful code but 'data.url' field is missing or invalid. Response: $responseData");
                throw ServerException(message: "Invalid response format after upload (missing URL)", statusCode: response.statusCode);
             }
          } else {
             // Handle business error code from server
             final errorMessage = responseData['msg']?.toString() ?? 'File upload failed (server logic)';
             final errorCode = responseData['code']?.toString();
             print("API Business Error (upload): $errorMessage, Code: $errorCode, Status: ${response.statusCode}");
             throw ServerException(message: errorMessage, statusCode: response.statusCode); // Keep original status for context
          }
      } else {
         // Handle non-200 status or unexpected response type
         print("API Error (upload): Unexpected status ${response.statusCode} or data type ${response.data?.runtimeType}. Response: ${response.data}");
         throw ServerException(message: "Server returned unexpected status or data format during upload", statusCode: response.statusCode);
      }

    } on DioException catch (e) {
      // Handle Dio/network errors
      print("DioException uploading file: ${e.message}, Type: ${e.type}, Response: ${e.response?.data}");
      // Provide more specific error messages based on DioErrorType if needed
      String failureMessage = e.message ?? "Network error uploading file";
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout) {
          failureMessage = "Network timeout, please try again later";
      } else if (e.type == DioExceptionType.connectionError) {
          // This might catch the 'Connection reset by peer'
          failureMessage = "Cannot connect to server, please check your network connection";
      }
      throw ServerException(message: failureMessage, statusCode: e.response?.statusCode);
    } catch (e, stacktrace) {
      // Handle other unexpected errors (e.g., during FormData creation)
      print("Unexpected error during uploadFile: $e\n$stacktrace");
      throw ServerException(message: "Unexpected error while processing file upload"); // Generic internal error message
    }
  }

   // Helper to check if the API code indicates success (handles int 200 or String '200')
  // Ensure this helper exists or copy it from ChatRemoteDataSourceImpl if needed
  bool _isSuccessCode(dynamic codeValue) {
    return (codeValue == 200) || (codeValue is String && codeValue == '200');
  }
} 