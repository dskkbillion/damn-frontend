/// 缓存统计信息
class CacheStats {
  /// 命中次数
  int hitCount = 0;
  
  /// 未命中次数
  int missCount = 0;
  
  /// 淘汰次数
  int evictionCount = 0;
  
  /// 当前缓存项数量
  int itemCount = 0;
  
  /// 当前缓存大小（字节）
  int sizeInBytes = 0;

  /// 命中率
  double get hitRate {
    final total = hitCount + missCount;
    return total == 0 ? 0.0 : hitCount / total;
  }
  
  /// 记录命中
  void recordHit() => hitCount++;
  
  /// 记录未命中
  void recordMiss() => missCount++;
  
  /// 记录淘汰
  void recordEviction() => evictionCount++;
  
  /// 更新项数量
  void updateItemCount(int count) => itemCount = count;
  
  /// 更新大小
  void updateSize(int size) => sizeInBytes = size;

  /// 转换为JSON格式
  Map<String, dynamic> toJson() => {
        'hitCount': hitCount,
        'missCount': missCount,
        'evictionCount': evictionCount,
        'itemCount': itemCount,
        'sizeInBytes': sizeInBytes,
        'sizeInMB': (sizeInBytes / 1024 / 1024).toStringAsFixed(2),
        'hitRate': '${(hitRate * 100).toStringAsFixed(2)}%',
      };
      
  /// 重置统计
  void reset() {
    hitCount = 0;
    missCount = 0;
    evictionCount = 0;
    // 注意：不重置 itemCount 和 sizeInBytes，这些应该由缓存管理器维护
  }
}