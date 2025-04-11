/// Represents errors originating from the remote API server.
class ServerException implements Exception {
  final String? message; // Optional message from the server
  final int? statusCode; // Optional HTTP status code

  ServerException({this.message, this.statusCode});

  @override
  String toString() {
    return 'ServerException(message: $message, statusCode: $statusCode)';
  }
}

/// Represents errors occurring during local cache operations.
class CacheException implements Exception {}

// You might already have Failure classes here or in failures.dart
// class NetworkException implements Exception {} // For general network issues 