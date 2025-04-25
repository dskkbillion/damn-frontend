import 'package:equatable/equatable.dart';

/// 卖家仪表盘收入数据
class SellerIncomeData extends Equatable {
  /// 总收入
  final double total;
  
  /// 今日收入
  final double today;
  
  /// 待结算收入
  final double pending;

  const SellerIncomeData({
    required this.total,
    required this.today,
    required this.pending,
  });

  @override
  List<Object?> get props => [total, today, pending];
}

/// 卖家仪表盘订单数据
class SellerOrdersData extends Equatable {
  /// 总订单数
  final int total;
  
  /// 待处理订单数
  final int pending;
  
  /// 已完成订单数
  final int completed;
  
  /// 已取消订单数
  final int canceled;

  const SellerOrdersData({
    required this.total,
    required this.pending,
    required this.completed,
    required this.canceled,
  });

  @override
  List<Object?> get props => [total, pending, completed, canceled];
}

/// 卖家周收入数据项
class WeeklyIncomeItem extends Equatable {
  /// 日期
  final String date;
  
  /// 金额
  final double amount;

  const WeeklyIncomeItem({
    required this.date,
    required this.amount,
  });

  @override
  List<Object?> get props => [date, amount];
}

/// 卖家统计数据
class SellerStatistics extends Equatable {
  /// 周收入数据
  final List<WeeklyIncomeItem> weeklyIncome;

  const SellerStatistics({
    required this.weeklyIncome,
  });

  @override
  List<Object?> get props => [weeklyIncome];
}

/// 卖家仪表盘通知数据
class SellerNotificationsData extends Equatable {
  /// 未读通知数
  final int unread;

  const SellerNotificationsData({
    required this.unread,
  });

  @override
  List<Object?> get props => [unread];
}

/// 卖家仪表盘数据
class SellerDashboardData extends Equatable {
  /// 收入数据
  final SellerIncomeData income;
  
  /// 订单数据
  final SellerOrdersData orders;
  
  /// 评分
  final double rating;
  
  /// 通知数据
  final SellerNotificationsData notifications;
  
  /// 统计数据
  final SellerStatistics statistics;

  const SellerDashboardData({
    required this.income,
    required this.orders,
    required this.rating,
    required this.notifications,
    required this.statistics,
  });

  @override
  List<Object?> get props => [income, orders, rating, notifications, statistics];
} 