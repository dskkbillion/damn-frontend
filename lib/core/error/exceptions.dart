class ServerException implements Exception {
  final int? statusCode;
  final String message;

  ServerException({this.statusCode, required this.message});

  @override
  String toString() {
    return 'ServerException(statusCode: $statusCode, message: $message)';
  }
}

/// Exception indicating a failure during cache operations.
class CacheException implements Exception {
    final String message;
    CacheException({this.message = "Cache Error"});

     @override
    String toString() => 'CacheException: $message';
}

/// Exception indicating an authentication failure (e.g., 401 Unauthorized).
class UnauthenticatedException implements Exception {
    final String message;
    UnauthenticatedException({this.message = "Authentication Required"});

     @override
    String toString() => 'UnauthenticatedException: $message';
}

// You can add other custom exception types here if needed, e.g.:
// class NetworkException implements Exception {}
