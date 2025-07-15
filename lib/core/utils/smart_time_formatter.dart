import 'package:intl/intl.dart';

class SmartTimeFormatter {
  /// 将时间戳转换为智能显示的相对时间
  static String formatToRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    // 1分钟内
    if (difference.inMinutes < 1) {
      return '刚刚';
    }
    
    // 1-60分钟
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    }
    
    // 1-2小时
    if (difference.inHours <= 2) {
      return '${difference.inHours}小时前';
    }
    
    // 今天较早
    if (DateFormat('yyyy-MM-dd').format(timestamp) == DateFormat('yyyy-MM-dd').format(now)) {
      return '今天 ${DateFormat('HH:mm').format(timestamp)}';
    }
    
    // 昨天
    final yesterday = now.subtract(const Duration(days: 1));
    if (DateFormat('yyyy-MM-dd').format(timestamp) == DateFormat('yyyy-MM-dd').format(yesterday)) {
      return '昨天 ${DateFormat('HH:mm').format(timestamp)}';
    }
    
    // 前天
    final dayBeforeYesterday = now.subtract(const Duration(days: 2));
    if (DateFormat('yyyy-MM-dd').format(timestamp) == DateFormat('yyyy-MM-dd').format(dayBeforeYesterday)) {
      return '前天 ${DateFormat('HH:mm').format(timestamp)}';
    }
    
    // 本年内（跳过本周内逻辑）
    if (timestamp.year == now.year) {
      return '${DateFormat('MM月dd日 HH:mm').format(timestamp)}';
    }
    
    // 更久
    return '${DateFormat('yyyy年MM月dd日 HH:mm').format(timestamp)}';
  }
  
  /// 判断是否需要显示时间分隔符
  static bool shouldShowTimeSeparator(DateTime? lastTimestamp, DateTime currentTimestamp) {
    if (lastTimestamp == null) return true;
    
    // 如果时间间隔超过5分钟，或者跨天了，则显示分隔符
    final timeDiff = currentTimestamp.difference(lastTimestamp);
    final isDifferentDay = DateFormat('yyyy-MM-dd').format(lastTimestamp) != 
                          DateFormat('yyyy-MM-dd').format(currentTimestamp);
    
    return timeDiff.inMinutes >= 5 || isDifferentDay;
  }
} 