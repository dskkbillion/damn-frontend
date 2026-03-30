import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_statistics_dtos.freezed.dart';
part 'seller_statistics_dtos.g.dart';

/// 升级统计数据DTO
@freezed
class SellerUpgradeStatisticsDto with _$SellerUpgradeStatisticsDto {
  const factory SellerUpgradeStatisticsDto({
    @Default(0) int days,             // 目标天数
    @Default(0) int orderNum,         // 目标订单数
    @Default(0.0) double orderPrice,  // 目标订单金额
    @Default(0) int totalDays,        // 当前天数
    @Default(0) int totalOrderNum,    // 当前订单数
    @Default(0.0) double totalOrderPrice, // 当前订单金额
  }) = _SellerUpgradeStatisticsDto;

  factory SellerUpgradeStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$SellerUpgradeStatisticsDtoFromJson(json);
}

/// 主要统计指标DTO
@freezed
class SellerIndexStatisticsDto with _$SellerIndexStatisticsDto {
  const factory SellerIndexStatisticsDto({
    @Default(0.0) double totalEarnings,        // 总盈利
    @Default(0.0) double thisMonthTotalEarnings, // 本月盈利
    @Default(0) int totalOrderNum,           // 总订单数
    @Default(0) int activeOrderNum,          // 活跃订单数
    @Default(0) int pendingOrderNum,         // 待处理订单数
    @Default(0) int receiptOrderNum,         // 回单订单数
    @Default(0) int earlyTime,               // 最早时间
    @Default(0) int latenessTime,            // 最晚时间
  }) = _SellerIndexStatisticsDto;

  factory SellerIndexStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$SellerIndexStatisticsDtoFromJson(json);
}

/// 百分比统计指标DTO
@freezed
class SellerPercentStatisticsDto with _$SellerPercentStatisticsDto {
  const factory SellerPercentStatisticsDto({
    @Default(0.0) double heatPercent,      // 热度值
    @Default(0.0) double recoverPercent,   // 回复率
    @Default(0.0) double completePercent,  // 完成率
    @Default(0.0) double goodPercent,      // 好评率
  }) = _SellerPercentStatisticsDto;

  factory SellerPercentStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$SellerPercentStatisticsDtoFromJson(json);
}
