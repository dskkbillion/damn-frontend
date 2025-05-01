import 'dart:io'; // For File type

/// {@template i_http_client}
/// Abstract interface for an HTTP client.
///
/// This allows injecting different HTTP client implementations (e.g., Dio, http)
/// or mock clients for testing.
/// Implementations should handle base URL, headers (like Authorization), and
/// potentially common error handling/wrapping.
/// {@endtemplate}
abstract class IHttpClient {
  /// 执行GET请求
  ///
  /// [endpoint] 接口路径
  /// [queryParams] 可选的查询参数
  ///
  /// 返回响应数据
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams});

  /// 执行POST请求
  ///
  /// [endpoint] 接口路径
  /// [body] 请求体数据
  ///
  /// 返回响应数据
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body});
  
  /// 执行PUT请求
  ///
  /// [endpoint] 接口路径
  /// [body] 请求体数据
  ///
  /// 返回响应数据
  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body});
  
  /// 执行DELETE请求
  ///
  /// [endpoint] 接口路径
  ///
  /// 返回响应数据
  Future<dynamic> delete(String endpoint);

  /// Performs a POST request with multipart/form-data, typically for file uploads.
  ///
  /// [path]: The endpoint path.
  /// [file]: The file to upload.
  /// [fileField]: The name of the form field for the file (defaults to 'file').
  /// [fields]: Optional additional form fields.
  /// Returns the parsed JSON response body as Map<String, dynamic>.
  /// Throws [NetworkException] or [ServerException] on failure.
  Future<Map<String, dynamic>> postMultipart(
    String path,
    File file,
   {String fileField = 'file', 
    Map<String, String>? fields}
  );

  /// Sends a POST request and returns the response body as a stream of strings.
  /// 
  /// Suitable for Server-Sent Events (SSE) or other streaming endpoints.
  /// The returned stream emits raw string data chunks from the response body.
  /// Error handling for the stream itself (connection issues during streaming)
  /// should be handled by the consumer of the stream.
  Stream<String> postAndStream(String path, {Map<String, dynamic>? body});

  // TODO: Add methods for PUT, DELETE, and potentially streaming requests (SSE)
  // How SSE is handled might depend on the chosen HTTP client library.
  // For Dio, libraries like 'dio_sse' exist, or custom adapters are needed.
  // For this interface, we might need a specific `stream` method or handle it
  // within the concrete implementation if the library integrates differently.
} 