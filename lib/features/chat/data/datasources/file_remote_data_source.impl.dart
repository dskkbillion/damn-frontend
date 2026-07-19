import 'dart:io';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import 'package:dio/dio.dart'; // Import Dio
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import ServerException
// Add injectable import

// Correct import for Interface using package path
import 'package:dskk_flutter_refactor/features/chat/data/constants/chat_api_endpoints.dart';
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
    const uploadPath = ChatApiEndpoints.uploadFile; // Define path clearly
    AppLogger.d("[API Call] Uploading file; local path and target URL omitted");

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
          if (total > 0) {
            // Avoid division by zero
            // AppLogger.d('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
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
            AppLogger.d("[API Call] File upload successful; URL omitted");
            return dataField['url'] as String;
          } else {
            AppLogger.d(
                "API Error (upload): Successful code but data.url is missing or invalid; response omitted");
            throw ServerException(
                message: "Invalid response format after upload (missing URL)",
                statusCode: response.statusCode);
          }
        } else {
          // Handle business error code from server
          final errorMessage = responseData['msg']?.toString() ??
              'File upload failed (server logic)';
          final errorCode = responseData['code']?.toString();
          AppLogger.d(
              "API Business Error (upload): code=$errorCode, status=${response.statusCode}; message omitted");
          throw ServerException(
              message: errorMessage,
              statusCode:
                  response.statusCode); // Keep original status for context
        }
      } else {
        // Handle non-200 status or unexpected response type
        AppLogger.d(
            "API Error (upload): Unexpected status ${response.statusCode} or data type ${response.data?.runtimeType}; response omitted");
        throw ServerException(
            message:
                "Server returned unexpected status or data format during upload",
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      // Handle Dio/network errors
      AppLogger.d(
          "DioException uploading file: type=${e.type}, status=${e.response?.statusCode}; details omitted");
      // Provide more specific error messages based on DioErrorType if needed
      String failureMessage = e.message ?? "Network error uploading file";
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        failureMessage = "Network timeout, please try again later";
      } else if (e.type == DioExceptionType.connectionError) {
        // This might catch the 'Connection reset by peer'
        failureMessage =
            "Cannot connect to server, please check your network connection";
      }
      throw ServerException(
          message: failureMessage, statusCode: e.response?.statusCode);
    } catch (e) {
      // Handle other unexpected errors (e.g., during FormData creation)
      AppLogger.d("Unexpected error during uploadFile: ${e.runtimeType}");
      throw ServerException(
          message:
              "Unexpected error while processing file upload"); // Generic internal error message
    }
  }

  // Helper to check if the API code indicates success (handles int 200 or String '200')
  // Ensure this helper exists or copy it from ChatRemoteDataSourceImpl if needed
  bool _isSuccessCode(dynamic codeValue) {
    return (codeValue == 200) || (codeValue is String && codeValue == '200');
  }
}
