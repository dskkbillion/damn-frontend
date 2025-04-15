/// 服务器异常
class ServerException implements Exception {
  final String? message;

  ServerException({this.message});
}

/// 缓存异常
class CacheException implements Exception {}