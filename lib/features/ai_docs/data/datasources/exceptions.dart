/// Exception thrown when the server returns an error response (e.g., 4xx, 5xx).
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({this.message = 'An error occurred on the server.', this.statusCode});

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

/// Exception thrown when there is a network connectivity issue.
class NetworkException implements Exception {
   final String message;
   NetworkException({this.message = 'Network error occurred.'});
   @override
  String toString() => 'NetworkException(message: $message)';
}

/// Exception for unexpected errors during data source operations.
class DataSourceException implements Exception {
  final String message;
  DataSourceException({this.message = 'An unexpected error occurred in the data source.'});
   @override
  String toString() => 'DataSourceException(message: $message)';
} 