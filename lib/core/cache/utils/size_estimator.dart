import 'dart:convert';

/// 对象大小估算器
/// 
/// 用于估算各种对象在内存中的大小
class SizeEstimator {
  /// 估算对象大小（字节）
  static int estimate(dynamic value) {
    if (value == null) return 0;
    
    // 基础类型
    if (value is String) {
      // UTF-16 编码，每个字符2字节 + 对象开销
      return value.length * 2 + 24;
    } else if (value is int) {
      return 8 + 16; // 64位整数 + 对象开销
    } else if (value is double) {
      return 8 + 16; // 64位浮点数 + 对象开销
    } else if (value is bool) {
      return 1 + 16; // 布尔值 + 对象开销
    }
    
    // 集合类型
    else if (value is List) {
      // 列表开销 + 每个元素的大小
      int size = 24; // 列表对象开销
      for (final item in value) {
        size += estimate(item) + 8; // 元素 + 引用
      }
      return size;
    } else if (value is Map) {
      // Map开销 + 每个键值对的大小
      int size = 32; // Map对象开销
      value.forEach((key, val) {
        size += estimate(key) + estimate(val) + 16; // 键值对 + 引用
      });
      return size;
    } else if (value is Set) {
      // Set开销 + 每个元素的大小
      int size = 32; // Set对象开销
      for (final item in value) {
        size += estimate(item) + 8; // 元素 + 引用
      }
      return size;
    }
    
    // 尝试序列化估算
    try {
      final json = jsonEncode(value);
      return json.length * 2; // JSON字符串长度的2倍作为估算
    } catch (e) {
      // 无法序列化的对象，返回默认估算值
      return 1024; // 1KB
    }
  }
  
  /// 格式化大小显示
  static String formatSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
  
  /// 批量估算
  static int estimateList<T>(List<T> items) {
    return items.fold(0, (sum, item) => sum + estimate(item));
  }
  
  /// 估算Map
  static int estimateMap<K, V>(Map<K, V> map) {
    int size = 32; // Map基础开销
    map.forEach((key, value) {
      size += estimate(key) + estimate(value) + 16;
    });
    return size;
  }
}