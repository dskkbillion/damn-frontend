import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_statistics_dtos.freezed.dart';
part 'seller_statistics_dtos.g.dart';

/// 升级统计数据DTO
@freezed
class SellerUpgradeStatisticsDto with _$SellerUpgradeStatisticsDto {
  const factory SellerUpgradeStatisticsDto({
    required int days,             // 目标天数
    required int orderNum,         // 目标订单数
    required double orderPrice,    // 目标订单金额
    required int totalDays,        // 当前天数
    required int totalOrderNum,    // 当前订单数
    required double totalOrderPrice, // 当前订单金额
  }) = _SellerUpgradeStatisticsDto;

  factory SellerUpgradeStatisticsDto.fromJson(Map<String, dynamic> json) => 
      _$SellerUpgradeStatisticsDtoFromJson(json);
}

/// 主要统计指标DTO
@freezed
class SellerIndexStatisticsDto with _$SellerIndexStatisticsDto {
  const factory SellerIndexStatisticsDto({
    required double totalEarnings,        // 总盈利
    required double thisMonthTotalEarnings, // 本月盈利
    required int totalOrderNum,           // 总订单数
    required int activeOrderNum,          // 活跃订单数
    required int pendingOrderNum,         // 待处理订单数
    required int receiptOrderNum,         // 回单订单数
    required int earlyTime,               // 最早时间
    required int latenessTime,            // 最晚时间
  }) = _SellerIndexStatisticsDto;

  factory SellerIndexStatisticsDto.fromJson(Map<String, dynamic> json) => 
      _$SellerIndexStatisticsDtoFromJson(json);
}

/// 百分比统计指标DTO
@freezed
class SellerPercentStatisticsDto with _$SellerPercentStatisticsDto {
  const factory SellerPercentStatisticsDto({
    required double heatPercent,      // 热度值
    required double recoverPercent,   // 回复率
    required double completePercent,  // 完成率
    required double goodPercent,      // 好评率
  }) = _SellerPercentStatisticsDto;

  factory SellerPercentStatisticsDto.fromJson(Map<String, dynamic> json) => 
      _$SellerPercentStatisticsDtoFromJson(json);
} 