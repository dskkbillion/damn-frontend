/// Base class for all custom exceptions in the application.
class AppException implements Exception {
  final String? message;
  final StackTrace? stackTrace;

  const AppException([this.message, this.stackTrace]);

  @override
  String toString() {
    String result = 'AppException';
    if (message != null) result = '$result: $message';
    // if (stackTrace != null) result = '$result\n$stackTrace'; // Optional: include stacktrace
    return result;
  }
}

/// Exception thrown when a server error occurs (e.g., 4xx, 5xx status codes).
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({String? message, this.statusCode, StackTrace? stackTrace})
      : super(message ?? 'Server Error', stackTrace);

   @override
  String toString() {
     String result = 'ServerException';
     if (statusCode != null) result = '$result (StatusCode: $statusCode)';
     if (message != null && message != 'Server Error') result = '$result: $message';
     return result;
  }
}

/// Exception thrown when parsing data (e.g., JSON) fails.
class ParsingException extends AppException {
  const ParsingException({String? message, StackTrace? stackTrace})
      : super(message ?? 'Data Parsing Error', stackTrace);
}

/// Exception related to cache operations.
class CacheException extends AppException {
   const CacheException({String? message, StackTrace? stackTrace})
      : super(message ?? 'Cache Error', stackTrace);
}

/// Exception related to network connectivity issues.
class NetworkException extends AppException {
   const NetworkException({String? message, StackTrace? stackTrace})
      : super(message ?? 'Network Connectivity Error', stackTrace);
}

/// Exception related to authentication issues (e.g., invalid token, failed login).
class AuthenticationException extends AppException {
  const AuthenticationException({String? message, StackTrace? stackTrace})
      : super(message ?? 'Authentication Error', stackTrace);
}

// Add other specific exception types as needed

// You can add other custom exception types here if needed, e.g.:
// class CacheException implements Exception {}
// class NetworkException implements Exception {} 