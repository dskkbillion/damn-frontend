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
  /// Performs a POST request.
  ///
  /// [path] The endpoint path (relative to the base URL).
  /// [data] The request body (typically a Map<String, dynamic>).
  ///
  /// Returns the JSON response body as a Map<String, dynamic>.
  /// Throws specific exceptions (e.g., from `exceptions.dart` or underlying
  /// client like DioException) on network or server errors.
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data});

  /// Performs a GET request.
  ///
  /// [path] The endpoint path.
  /// [queryParameters] Optional query parameters.
  ///
  /// Returns the JSON response body as a Map<String, dynamic>.
  /// Throws specific exceptions on errors.
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters});

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
  Stream<String> postAndStream(String path, {Map<String, dynamic>? data});

  // TODO: Add methods for PUT, DELETE, and potentially streaming requests (SSE)
  // How SSE is handled might depend on the chosen HTTP client library.
  // For Dio, libraries like 'dio_sse' exist, or custom adapters are needed.
  // For this interface, we might need a specific `stream` method or handle it
  // within the concrete implementation if the library integrates differently.
} 