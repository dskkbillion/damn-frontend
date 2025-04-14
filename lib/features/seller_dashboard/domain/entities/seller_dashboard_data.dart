import 'package:equatable/equatable.dart';

/// Represents the consolidated data for the Seller Dashboard.
class SellerDashboardData extends Equatable {
  final int heatPercent;
  final int recoverPercent;
  final int completePercent;
  final int goodPercent;
  final int days; // Target days for upgrade
  final int orderNum; // Target order number for upgrade
  final int orderPrice; // Target order price for upgrade
  final int totalDays; // Current progress days for upgrade
  final int upgradeProgressOrderCount; // Current progress order count for upgrade (from /upgradeLevel)
  final int totalOrderPrice; // Current progress order price for upgrade
  final int totalEarnings;
  final int thisMonthTotalEarnings;
  final int overallTotalOrderCount; // Overall total order count (from /index)
  final int activeOrderNum;
  final int pendingOrderNum;
  final int receiptOrderNum;
  final int earlyTime; // Time related, treat as integer for now
  final int latenessTime; // Time related, treat as integer for now

  const SellerDashboardData({
    required this.heatPercent,
    required this.recoverPercent,
    required this.completePercent,
    required this.goodPercent,
    required this.days,
    required this.orderNum,
    required this.orderPrice,
    required this.totalDays,
    required this.upgradeProgressOrderCount,
    required this.totalOrderPrice,
    required this.totalEarnings,
    required this.thisMonthTotalEarnings,
    required this.overallTotalOrderCount,
    required this.activeOrderNum,
    required this.pendingOrderNum,
    required this.receiptOrderNum,
    required this.earlyTime,
    required this.latenessTime,
  });

  @override
  List<Object?> get props => [
        heatPercent,
        recoverPercent,
        completePercent,
        goodPercent,
        days,
        orderNum,
        orderPrice,
        totalDays,
        upgradeProgressOrderCount,
        totalOrderPrice,
        totalEarnings,
        thisMonthTotalEarnings,
        overallTotalOrderCount,
        activeOrderNum,
        pendingOrderNum,
        receiptOrderNum,
        earlyTime,
        latenessTime,
      ];
} 