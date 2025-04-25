import 'package:equatable/equatable.dart';

/// 星期枚举
enum WeekDay {
  /// 星期一
  monday(1, '星期一'),
  
  /// 星期二
  tuesday(2, '星期二'),
  
  /// 星期三
  wednesday(3, '星期三'),
  
  /// 星期四
  thursday(4, '星期四'),
  
  /// 星期五
  friday(5, '星期五'),
  
  /// 星期六
  saturday(6, '星期六'),
  
  /// 星期日
  sunday(7, '星期日');

  /// 星期几数值 (1-7)
  final int value;
  
  /// 星期显示名称
  final String displayName;

  const WeekDay(this.value, this.displayName);

  /// 从值获取枚举
  static WeekDay fromValue(int value) {
    return WeekDay.values.firstWhere(
      (day) => day.value == value,
      orElse: () => WeekDay.monday,
    );
  }
}

/// 时间段
class TimeSlot extends Equatable {
  /// 星期几
  final WeekDay weekDay;
  
  /// 开始时间 (24小时制，格式：HH:mm)
  final String startTime;
  
  /// 结束时间 (24小时制，格式：HH:mm)
  final String endTime;

  const TimeSlot({
    required this.weekDay,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [weekDay, startTime, endTime];
  
  /// 检查时间段是否有效 (开始时间早于结束时间)
  bool get isValid {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return start.compareTo(end) < 0;
  }
  
  /// 解析时间字符串为分钟数
  int _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }
}

/// 卖家时间设置
class TimeSettings extends Equatable {
  /// 卖家是否在线
  final bool isOnline;
  
  /// 可用时间段列表
  final List<TimeSlot>? availableTimeSlots;

  const TimeSettings({
    required this.isOnline,
    this.availableTimeSlots,
  });

  @override
  List<Object?> get props => [isOnline, availableTimeSlots];
  
  /// 创建默认设置 (在线)
  factory TimeSettings.defaultSettings() {
    return const TimeSettings(
      isOnline: true,
    );
  }
  
  /// 创建在线状态设置
  factory TimeSettings.online() {
    return const TimeSettings(
      isOnline: true,
    );
  }
  
  /// 创建离线状态设置
  factory TimeSettings.offline() {
    return const TimeSettings(
      isOnline: false,
    );
  }
  
  /// 转换为API参数格式 (在线/离线状态)
  Map<String, dynamic> toJson() {
    return {
      'onlineFlag': isOnline,
    };
  }
}

/// 时间设置更新数据
class TimeSettingsData extends Equatable {
  /// 是否在线
  final bool? isOnline;
  
  /// 可用时间段列表
  final List<TimeSlot>? availableTimeSlots;

  const TimeSettingsData({
    this.isOnline,
    this.availableTimeSlots,
  });

  @override
  List<Object?> get props => [isOnline, availableTimeSlots];
  
  /// 转换为API参数格式
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (isOnline != null) {
      data['onlineFlag'] = isOnline;
    }
    
    // 当API支持时间段设置时，添加相关字段
    // if (availableTimeSlots != null && availableTimeSlots!.isNotEmpty) {
    //   data['timeSlots'] = availableTimeSlots!.map((slot) => {
    //     'weekDay': slot.weekDay.value,
    //     'startTime': slot.startTime,
    //     'endTime': slot.endTime,
    //   }).toList();
    // }
    
    return data;
  }
} 