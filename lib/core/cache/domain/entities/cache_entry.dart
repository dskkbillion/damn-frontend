/// 缓存项实体
class CacheEntry<T> {
  /// 缓存的值
  final T value;
  
  /// 创建时间
  final DateTime createTime;
  
  /// 生存时间
  final Duration? ttl;
  
  /// 最后访问时间
  DateTime lastAccessTime;
  
  /// 访问次数
  int accessCount;
  
  /// 缓存项大小（字节）
  final int? sizeInBytes;

  CacheEntry({
    required this.value,
    required this.createTime,
    this.ttl,
    this.sizeInBytes,
  })  : lastAccessTime = createTime,
        accessCount = 0;

  /// 是否已过期
  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(createTime) > ttl!;
  }

  /// 访问缓存项
  void access() {
    lastAccessTime = DateTime.now();
    accessCount++;
  }
  
  /// 获取剩余生存时间
  Duration? get remainingTTL {
    if (ttl == null) return null;
    final elapsed = DateTime.now().difference(createTime);
    final remaining = ttl! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}