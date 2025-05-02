import 'package:equatable/equatable.dart';

/// 升级统计数据实体
class SellerUpgradeStatistics extends Equatable {
  final int days;             // 目标天数
  final int orderNum;         // 目标订单数
  final double orderPrice;    // 目标订单金额
  final int totalDays;        // 当前天数
  final int totalOrderNum;    // 当前订单数
  final double totalOrderPrice; // 当前订单金额
  
  const SellerUpgradeStatistics({
    required this.days,
    required this.orderNum,
    required this.orderPrice,
    required this.totalDays,
    required this.totalOrderNum,
    required this.totalOrderPrice,
  });
  
  @override
  List<Object?> get props => [days, orderNum, orderPrice, totalDays, totalOrderNum, totalOrderPrice];
}

/// 主要统计指标实体
class SellerIndexStatistics extends Equatable {
  final double totalEarnings;        // 总盈利
  final double thisMonthTotalEarnings; // 本月盈利
  final int totalOrderNum;           // 总订单数
  final int activeOrderNum;          // 活跃订单数
  final int pendingOrderNum;         // 待处理订单数
  final int receiptOrderNum;         // 回单订单数
  final int earlyTime;               // 最早时间
  final int latenessTime;            // 最晚时间
  
  const SellerIndexStatistics({
    required this.totalEarnings,
    required this.thisMonthTotalEarnings,
    required this.totalOrderNum,
    required this.activeOrderNum,
    required this.pendingOrderNum,
    required this.receiptOrderNum,
    required this.earlyTime,
    required this.latenessTime,
  });
  
  @override
  List<Object?> get props => [totalEarnings, thisMonthTotalEarnings, totalOrderNum, activeOrderNum, pendingOrderNum, receiptOrderNum, earlyTime, latenessTime];
}

/// 百分比统计指标实体
class SellerPercentStatistics extends Equatable {
  final double heatPercent;      // 热度值
  final double recoverPercent;   // 回复率
  final double completePercent;  // 完成率
  final double goodPercent;      // 好评率
  
  const SellerPercentStatistics({
    required this.heatPercent,
    required this.recoverPercent,
    required this.completePercent,
    required this.goodPercent,
  });
  
  @override
  List<Object?> get props => [heatPercent, recoverPercent, completePercent, goodPercent];
} 