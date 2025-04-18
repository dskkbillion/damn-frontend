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

/// Represents errors related to network connectivity.
class NetworkException implements Exception {
  final String? message; // Optional message describing the network issue
  NetworkException({this.message});

   @override
  String toString() {
    return 'NetworkException(message: $message)';
  }
}

/// Represents errors originating from data sources (local or remote) 
/// that are not specific server, network, or cache errors.
class DataSourceException implements Exception {
  final String message;
  DataSourceException(this.message);

  @override
  String toString() {
    return 'DataSourceException(message: $message)';
  }
}

// You might already have Failure classes here or in failures.dart
// class NetworkException implements Exception {} // For general network issues 
