import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';

/// 卖家仪表盘收入数据DTO
class SellerIncomeDataDto {
  /// 总收入
  final double? total;
  
  /// 今日收入
  final double? today;
  
  /// 待结算收入
  final double? pending;

  SellerIncomeDataDto({
    this.total,
    this.today,
    this.pending,
  });

  /// 从JSON构造
  factory SellerIncomeDataDto.fromJson(Map<String, dynamic> json) {
    return SellerIncomeDataDto(
      total: json['totalIncome'] != null 
          ? double.tryParse(json['totalIncome'].toString()) ?? 0.0 
          : 0.0,
      today: json['todayIncome'] != null 
          ? double.tryParse(json['todayIncome'].toString()) ?? 0.0 
          : 0.0,
      pending: json['pendingIncome'] != null 
          ? double.tryParse(json['pendingIncome'].toString()) ?? 0.0 
          : 0.0,
    );
  }

  /// 转换为领域实体
  SellerIncomeData toEntity() {
    return SellerIncomeData(
      total: total ?? 0.0,
      today: today ?? 0.0,
      pending: pending ?? 0.0,
    );
  }
}

/// 卖家仪表盘订单数据DTO
class SellerOrdersDataDto {
  /// 总订单数
  final int? total;
  
  /// 待处理订单数
  final int? pending;
  
  /// 已完成订单数
  final int? completed;
  
  /// 已取消订单数
  final int? canceled;

  SellerOrdersDataDto({
    this.total,
    this.pending,
    this.completed,
    this.canceled,
  });

  /// 从JSON构造
  factory SellerOrdersDataDto.fromJson(Map<String, dynamic> json) {
    return SellerOrdersDataDto(
      total: json['totalOrders'],
      pending: json['pendingOrders'],
      completed: json['completedOrders'],
      canceled: json['canceledOrders'],
    );
  }

  /// 转换为领域实体
  SellerOrdersData toEntity() {
    return SellerOrdersData(
      total: total ?? 0,
      pending: pending ?? 0,
      completed: completed ?? 0,
      canceled: canceled ?? 0,
    );
  }
}

/// 卖家周收入数据项DTO
class WeeklyIncomeItemDto {
  /// 日期
  final String? date;
  
  /// 金额
  final double? amount;

  WeeklyIncomeItemDto({
    this.date,
    this.amount,
  });

  /// 从JSON构造
  factory WeeklyIncomeItemDto.fromJson(Map<String, dynamic> json) {
    return WeeklyIncomeItemDto(
      date: json['date'],
      amount: json['amount'] != null 
          ? double.tryParse(json['amount'].toString()) ?? 0.0 
          : 0.0,
    );
  }

  /// 转换为领域实体
  WeeklyIncomeItem toEntity() {
    return WeeklyIncomeItem(
      date: date ?? '',
      amount: amount ?? 0.0,
    );
  }
}

/// 卖家统计数据DTO
class SellerStatisticsDto {
  /// 周收入数据
  final List<dynamic>? weeklyIncome;

  SellerStatisticsDto({
    this.weeklyIncome,
  });

  /// 从JSON构造
  factory SellerStatisticsDto.fromJson(Map<String, dynamic> json) {
    return SellerStatisticsDto(
      weeklyIncome: json['weeklyIncome'] as List<dynamic>?,
    );
  }

  /// 转换为领域实体
  SellerStatistics toEntity() {
    List<WeeklyIncomeItem> weeklyIncomeItems = [];
    
    if (weeklyIncome != null && weeklyIncome!.isNotEmpty) {
      weeklyIncomeItems = weeklyIncome!
          .map((item) => WeeklyIncomeItemDto.fromJson(item as Map<String, dynamic>).toEntity())
          .toList();
    }
    
    return SellerStatistics(
      weeklyIncome: weeklyIncomeItems,
    );
  }
}

/// 卖家仪表盘通知数据DTO
class SellerNotificationsDataDto {
  /// 未读通知数
  final int? unread;

  SellerNotificationsDataDto({
    this.unread,
  });

  /// 从JSON构造
  factory SellerNotificationsDataDto.fromJson(Map<String, dynamic> json) {
    return SellerNotificationsDataDto(
      unread: json['unreadNotifications'],
    );
  }

  /// 转换为领域实体
  SellerNotificationsData toEntity() {
    return SellerNotificationsData(
      unread: unread ?? 0,
    );
  }
}

/// 卖家仪表盘数据DTO
class SellerDashboardDataDto {
  /// API返回的原始数据
  final Map<String, dynamic> data;

  SellerDashboardDataDto({
    required this.data,
  });

  /// 从JSON构造
  factory SellerDashboardDataDto.fromJson(Map<String, dynamic> json) {
    return SellerDashboardDataDto(
      data: json['data'] as Map<String, dynamic>,
    );
  }

  /// 转换为领域实体
  SellerDashboardData toEntity() {
    final incomeDto = SellerIncomeDataDto.fromJson(data);
    final ordersDto = SellerOrdersDataDto.fromJson(data);
    final notificationsDto = SellerNotificationsDataDto.fromJson(data);
    final statisticsDto = SellerStatisticsDto.fromJson(data);
    
    return SellerDashboardData(
      income: incomeDto.toEntity(),
      orders: ordersDto.toEntity(),
      rating: data['rating'] != null 
          ? double.tryParse(data['rating'].toString()) ?? 0.0 
          : 0.0,
      notifications: notificationsDto.toEntity(),
      statistics: statisticsDto.toEntity(),
    );
  }
} 