import 'dart:io';

import 'package:dio/dio.dart'; // Import Dio
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import ServerException
import 'package:injectable/injectable.dart'; // Import injectable

// Correct import for Interface using package path
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_file_remote_data_source.dart';

// TODO: Inject Dio instance properly via DI
// For now, creating a basic instance here for simplicity
// Ensure base URL matches your API gateway
final _dio = Dio(BaseOptions(baseUrl: "http://app.duoshaokankan.com/prod-api")); 
// NOTE: Configure interceptors (auth, logging)

@LazySingleton(as: IFileRemoteDataSource) // Add annotation
class FileRemoteDataSourceImpl implements IFileRemoteDataSource {
  final Dio dio; // Inject Dio

  FileRemoteDataSourceImpl({required this.dio}); // Constructor injection

  @override
  Future<String> uploadFile(File file) async {
    print("[API Call] Uploading file: ${file.path}");
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      final response = await dio.post(
        '/api/common/public/upload', // Use correct API endpoint
        data: formData,
        options: Options(
          headers: {
            // Add any specific headers needed for file upload if required
            // e.g., 'Content-Type': 'multipart/form-data' is usually handled by Dio
          },
        ),
        onSendProgress: (int sent, int total) {
          // Optional: print progress
          // print('$sent/$total');
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200 && response.data['url'] != null) {
         // Assuming the URL is directly under the 'url' key based on typical API design
        return response.data['url'] as String;
      } else {
        // Handle API error response
        final errorMessage = response.data?['msg'] ?? 'File upload failed';
         print("API Error uploading file: $errorMessage, Code: ${response.data?['code']}, Status: ${response.statusCode}");
        throw ServerException(message: errorMessage, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      // Handle network or Dio specific errors
       print("DioException uploading file: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error uploading file", statusCode: e.response?.statusCode);
    } catch (e) {
      // Handle unexpected errors
      print("Unexpected error uploading file: $e");
      throw ServerException(message: "An unexpected error occurred during file upload");
    }
  }
} 