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

/// Exception indicating a failure during cache operations.
class CacheException implements Exception {
    final String message;
    CacheException({this.message = "Cache Error"});

     @override
    String toString() => 'CacheException: $message';
}

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

/// Exception indicating an authentication failure (e.g., 401 Unauthorized).
class UnauthenticatedException implements Exception {
    final String message;
    UnauthenticatedException({this.message = "Authentication Required"});

     @override
    String toString() => 'UnauthenticatedException: $message';
}
