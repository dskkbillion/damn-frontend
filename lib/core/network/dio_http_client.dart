import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'dart:io'; // For File
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http; // Import http package
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:dskk_flutter_refactor/core/config/region_config.dart';

import 'i_http_client.dart';
import '../error/exceptions.dart'; // Assuming exceptions are in core/error

@LazySingleton(as: IHttpClient) // Use LazySingleton or Singleton based on needs
class DioHttpClient implements IHttpClient {
  late final Dio _dio;
  // Add an http client for SSE
  late final http.Client _httpClientForSse;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final String _baseUrl;

  DioHttpClient() {
    // 动态获取模型服务URL
    // 先尝试从RegionConfig获取，如果还没初始化则使用环境变量
    try {
      _baseUrl = RegionConfig.modelBaseUrl;
      print("使用区域配置的模型服务URL: $_baseUrl");
    } catch (e) {
      // 如果RegionConfig还没初始化，回退到环境变量
      _baseUrl = dotenv.env['MODEL_BASE_URL'] ?? 'http://47.113.230.11:5107';
      print("使用环境变量的MODEL_BASE_URL: $_baseUrl");
    }
    
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
    _dio.interceptors.add(LogInterceptor(
        requestBody: true, responseBody: true)); // Enable logging
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

  // 获取认证令牌
  Future<String?> _getAuthToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      print('Error reading token from secure storage: $e');
      return null;
    }
  }

  @override
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error during GET: ${e.toString()}');
    }
  }

  @override
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error during POST: ${e.toString()}');
    }
  }

  @override
  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final response = await _dio.put(endpoint, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error during PUT: ${e.toString()}');
    }
  }

  @override
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error during DELETE: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, // Using endpoint parameter name for consistency
    File file,
    {String fileField = 'file', 
    Map<String, String>? fields}
  ) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final fileSize = await file.length();
      print("正在上传文件: $fileName, 大小: ${fileSize / 1024} KB, 目标: $endpoint");
      
      // --- Prepare FormData --- 
      final formData = FormData.fromMap({
        fileField: await MultipartFile.fromFile(file.path, filename: fileName),
        ...?fields, 
      });

      // --- 获取实际令牌 --- 
      final String? authToken = await _getAuthToken();
      const String version = '100';

      // 设置更长的超时时间，特别是针对大文件上传
      final options = Options(
        headers: {
          'clienttype': '1',
          'client': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'unknown',
          'version': version,
          if (authToken != null && authToken.isNotEmpty)
            'Authorization': 'Bearer $authToken',
        },
        // 增加上传超时时间 - 更长的超时时间
        sendTimeout: const Duration(seconds: 120),     // 2分钟发送超时
        receiveTimeout: const Duration(seconds: 120),  // 2分钟接收超时
      );
      // --- End Headers --- 

      // 创建一个带有超时设置的临时Dio实例，避免影响其他请求
      final uploadDio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120), // 2分钟接收超时
        sendTimeout: const Duration(seconds: 120),    // 2分钟发送超时
      ));
      
      // 添加详细的日志拦截器，记录上传进度
      uploadDio.interceptors.add(LogInterceptor(
        requestBody: true, 
        responseBody: true,
        requestHeader: true,
        responseHeader: true
      ));
      
      // 添加进度记录器
      final cancelToken = CancelToken();
      final response = await uploadDio.post(
        endpoint, 
        data: formData, 
        options: options,
        cancelToken: cancelToken,
        onSendProgress: (sent, total) {
          if (total != -1) {
            final progress = (sent / total * 100).toStringAsFixed(2);
            print('文件上传进度: $progress% ($sent/$total bytes)');
          }
        }
      );
      
      print("文件上传完成: 状态码=${response.statusCode}");
      return _handleResponse(response);
    } on DioException catch (e) {
      print("文件上传DioException: 类型=${e.type}, 消息=${e.message}");
      print("请求信息: ${e.requestOptions.uri}, 方法=${e.requestOptions.method}");
      print("响应状态: ${e.response?.statusCode}, 数据=${e.response?.data}");
      throw _handleDioError(e);
    } catch (e) {
      print("文件上传异常: ${e.runtimeType} - ${e.toString()}");
      throw ServerException(message: 'Unexpected error during Multipart POST: ${e.toString()}');
    }
  }

  // --- Implement postAndStream using http package ---
  @override
  Stream<String> postAndStream(String path,
      {Map<String, dynamic>? body}) async* {
    // Use async* for stream generation
    
    // 确保path中不含http前缀
    if (path.startsWith('http')) {
      throw ServerException(message: 'Path不应包含完整URL，只需包含路径部分');
    }
    
    // 确保_baseUrl不含末尾斜杠，path不含开头斜杠，再拼接，避免双斜杠问题
    String baseUrl = _baseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    String pathWithoutLeadingSlash = path;
    if (path.startsWith('/')) {
      pathWithoutLeadingSlash = path.substring(1);
    }
    
    final url = Uri.parse('$baseUrl/$pathWithoutLeadingSlash');
    print("[HttpClient - SSE] 完整URL: $url");
    
    final request = http.Request('POST', url);

    // Set headers (add Auth later if needed)
    request.headers[HttpHeaders.contentTypeHeader] =
        'application/json; charset=utf-8';
    // request.headers[HttpHeaders.acceptHeader] = 'text/event-stream'; // Usually needed for SSE
    // TODO: Add Authorization header if required
    // request.headers[HttpHeaders.authorizationHeader] = 'Bearer YOUR_TOKEN';

    if (body != null) {
      request.body = jsonEncode(body); // Encode body as JSON string
    }

    print("[HttpClient - SSE] Sending POST request to $url");
    print("[HttpClient - SSE] Body: ${request.body}");

    try {
      final streamedResponse = await _httpClientForSse.send(request);

      print(
          "[HttpClient - SSE] Received response status: ${streamedResponse.statusCode}");

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
          message:
              'Failed to initiate stream (${streamedResponse.statusCode}): ${streamedResponse.reasonPhrase} - $responseBody',
        );
      }
    } catch (e, stacktrace) {
      print("[HttpClient - SSE] Error sending request or reading stream: $e");
      print(stacktrace);
      throw ServerException(
          message: 'Network error during streaming: ${e.toString()}');
    }
  }

  // --- Helper Methods ---

  dynamic _handleResponse(Response response) { // Return dynamic as API might not always return Map
    // Basic response handling, assuming API returns JSON with status indication
    // TODO: Adapt this based on your actual API response structure
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      // Just return the data directly, let the DataSource parse it
      return response.data;
    } else {
      // Throw a ServerException for non-2xx responses
      String? message;
      if (response.data is Map<String, dynamic> && response.data['message'] != null) {
        message = response.data['message'];
      } else {
        message = response.statusMessage ?? 'Unknown server error';
      }
      throw ServerException(
        statusCode: response.statusCode,
        message: message,
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
        if (error.response?.data is Map<String, dynamic>) {
          // 优先使用msg字段（后端常用），然后是message字段
          errorMessage = error.response!.data['msg']?.toString() ?? 
                        error.response!.data['message']?.toString() ??
                        error.response?.statusMessage ?? 
                        "Invalid response from server";
        } else if (error.response?.data is String) {
          // 如果响应是字符串，直接使用
          errorMessage = error.response!.data;
        } else {
          errorMessage = error.response?.statusMessage ?? "Invalid response from server";
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = "Request cancelled";
        break;
      case DioExceptionType.connectionError:
        errorMessage =
            "Connection error, please check your internet connection";
        break;
      case DioExceptionType.badCertificate:
        errorMessage = "Bad certificate";
        break;
      case DioExceptionType.unknown:
      default:
        errorMessage = "An unexpected network error occurred";
        if (error.error is SocketException) {
           errorMessage = "Network connectivity issue";
        }
        break;
    }
    print(
        "[DioError] Path: ${error.requestOptions.path}, Status: $statusCode, Type: ${error.type}, Message: $errorMessage, Data: ${error.response?.data}");
    return ServerException(
        message: '${statusCode != null ? '$statusCode: ' : ''}$errorMessage');
  }

  // 实现获取Dio实例的方法
  @override
  Dio getDioInstance() {
    return _dio;
  }
}
