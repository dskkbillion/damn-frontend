class ServerException implements Exception {
  final int? statusCode;
  final String message;

  ServerException({this.statusCode, required this.message});

  @override
  String toString() {
    return 'ServerException(statusCode: $statusCode, message: $message)';
  }
}

// You can add other custom exception types here if needed, e.g.:
// class CacheException implements Exception {}
// class NetworkException implements Exception {} 