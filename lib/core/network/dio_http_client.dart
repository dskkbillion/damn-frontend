import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'dart:io'; // For File
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http; // Import http package

import 'i_http_client.dart';
import '../error/exceptions.dart'; // Assuming exceptions are in core/error

// Configure base URL
const String _baseUrl = 'http://47.113.230.11:5102'; // Set the actual base URL

@LazySingleton(as: IHttpClient) // Use LazySingleton or Singleton based on needs
class DioHttpClient implements IHttpClient {
  late final Dio _dio;
  // Add an http client for SSE
  late final http.Client _httpClientForSse;

  DioHttpClient() {
    final options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15), // Example timeout
      receiveTimeout: const Duration(seconds: 15),
      // TODO: Add headers like Content-Type, Authorization etc. if needed globally
      // headers: {
      //   HttpHeaders.contentTypeHeader: 'application/json',
      // },
    );
    _dio = Dio(options);

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true)); // Enable logging
    // _dio.interceptors.add(AuthInterceptor()); // Example auth interceptor
    // _dio.interceptors.add(ErrorInterceptor()); // Example error interceptor

    // Initialize the http client
    _httpClientForSse = http.Client();
  }

  // --- Dispose the http client --- 
  // (Alternatively, manage lifecycle with GetIt dispose method if using injectable)
  void dispose() { 
    _httpClientForSse.close();
    print("DioHttpClient disposed, SSE client closed.");
    // Dio doesn't require explicit close unless using adapters that need it.
  }

  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error during GET: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error during POST: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> postMultipart(
    String pathOrUrl, // Changed parameter name to reflect it can be full URL
    File file,
   {String fileField = 'file',
    Map<String, String>? fields} // Keep fields param in case needed elsewhere
  ) async {
     try {
       final fileName = file.path.split(Platform.pathSeparator).last;
       
       // --- Prepare FormData --- 
       final formData = FormData.fromMap({
         fileField: await MultipartFile.fromFile(file.path, filename: fileName),
         ...?fields, 
       });

       // --- Prepare Headers --- 
       // TODO: Replace hardcoded token and version with dynamic values
       const String hardcodedAuthToken = 'eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjMwZmZjY2YxLWFjNDUtNGM3OS04MjJiLTliNzM0MDZjZjdkYiJ9.g0FkPdnBuvpsirksABX04FrQLTjn-qgbLwRE9QLJOW6Df5syAdTGLn0IhpUYMDRaefbFQ49MWnL5wYUMRtMuiQ';
       const String hardcodedVersion = '100'; 

       final options = Options(
          headers: {
             'clienttype': '1',
             'client': 'android', 
             'version': hardcodedVersion, 
             'Authorization': hardcodedAuthToken, 
             // Dio usually handles Content-Type for FormData automatically
             // 'Content-Type': 'multipart/form-data; boundary=...', 
             // Other headers like User-Agent, Host, Connection are often handled by Dio
          },
          // Ensure followRedirects is handled appropriately if needed, 
          // but since we provide full URL, it might not be relevant here.
          // followRedirects: false, 
          // receiveDataWhenStatusError: true,
       );
       // --- End Headers --- 

       // Use pathOrUrl directly (could be base+path or full URL)
       final response = await _dio.post(pathOrUrl, data: formData, options: options); 
       return _handleResponse(response);
     } on DioException catch (e) {
        throw _handleDioError(e);
     } catch (e) {
       throw ServerException(message: 'Unexpected error during Multipart POST: ${e.toString()}');
     }
  }

  // --- Implement postAndStream using http package --- 
  @override
  Stream<String> postAndStream(String path, {Map<String, dynamic>? data}) async* { // Use async* for stream generation
    final url = Uri.parse('$_baseUrl$path');
    final request = http.Request('POST', url);

    // Set headers (add Auth later if needed)
    request.headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=utf-8';
    // request.headers[HttpHeaders.acceptHeader] = 'text/event-stream'; // Usually needed for SSE
    // TODO: Add Authorization header if required
    // request.headers[HttpHeaders.authorizationHeader] = 'Bearer YOUR_TOKEN'; 

    if (data != null) {
      request.body = jsonEncode(data); // Encode body as JSON string
    }
    
    print("[HttpClient - SSE] Sending POST request to $url");
    print("[HttpClient - SSE] Body: ${request.body}");

    try {
      final streamedResponse = await _httpClientForSse.send(request);
      
      print("[HttpClient - SSE] Received response status: ${streamedResponse.statusCode}");

      if (streamedResponse.statusCode == 200) {
        // Decode the stream using UTF8 and yield each line/event
        await for (final chunkBytes in streamedResponse.stream) {
           try {
             // Assuming UTF8 encoding, adjust if different
             final chunkString = utf8.decode(chunkBytes);
             print("[HttpClient - SSE] Received chunk: $chunkString");
             yield chunkString; // Yield the raw SSE chunk string
           } catch (e) {
              print("[HttpClient - SSE] Error decoding chunk: $e");
              // Decide how to handle decoding error, maybe yield an error event?
              yield 'event: error\ndata: { "message": "Error decoding stream chunk" }\n\n';
           }
        }
         print("[HttpClient - SSE] Stream finished.");
      } else {
        // Handle non-200 status code for the initial stream request
        final responseBody = await streamedResponse.stream.bytesToString();
        print("[HttpClient - SSE] Error response body: $responseBody");
        throw ServerException(
            statusCode: streamedResponse.statusCode,
            message: 'Failed to initiate stream: ${streamedResponse.reasonPhrase} - $responseBody',
        );
      }
    } catch (e, stacktrace) {
       print("[HttpClient - SSE] Error sending request or reading stream: $e");
       print(stacktrace);
       // Throw or yield an error event, depending on desired behavior
       // Throwing for now to indicate failure to establish/read stream
       throw ServerException(message: 'Network error during streaming: ${e.toString()}');
    }
  }

  // --- Helper Methods --- 

  Map<String, dynamic> _handleResponse(Response response) {
    // Basic response handling, assuming API returns JSON with status indication
    // TODO: Adapt this based on your actual API response structure
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
       if (response.data is Map<String, dynamic>) {
         // Assuming your API wraps data, e.g., { "code": 200, "message": "Success", "data": {...} }
         // Or maybe it returns the data directly
         return response.data;
       } else {
          // Handle cases where response is not JSON or has unexpected format
          return {'data': response.data}; // Or throw an exception
       }
    } else {
      // Throw a ServerException for non-2xx responses
      throw ServerException(
         statusCode: response.statusCode,
         message: response.data?['message'] ?? response.statusMessage ?? 'Unknown server error',
      );
    }
  }

  ServerException _handleDioError(DioException error) {
    String errorMessage;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = "Connection timeout";
        break;
      case DioExceptionType.badResponse:
        // Try to get message from response data, fallback to status message
        errorMessage = error.response?.data?['message'] ?? error.response?.statusMessage ?? "Invalid response from server";
        break;
      case DioExceptionType.cancel:
        errorMessage = "Request cancelled";
        break;
      case DioExceptionType.connectionError:
         errorMessage = "Connection error, please check your internet connection";
         break;
      case DioExceptionType.badCertificate:
         errorMessage = "Bad certificate";
         break;
      case DioExceptionType.unknown:
      default:
        errorMessage = "An unexpected network error occurred";
        break;
    }
     print("[DioError] Path: ${error.requestOptions.path}, Status: $statusCode, Type: ${error.type}, Message: $errorMessage, Data: ${error.response?.data}");
    return ServerException(statusCode: statusCode, message: errorMessage);
  }
} 