import '../models/seller_statistics_dtos.dart';

/// 卖家统计数据源接口
abstract class ISellerStatisticsDataSource {
  /// 获取升级统计数据
  Future<SellerUpgradeStatisticsDto> getUpgradeStatistics();
  
  /// 获取主要指标统计数据
  Future<SellerIndexStatisticsResponseDto> getIndexStatistics();
  
  /// 获取百分比统计数据
  Future<SellerPercentStatisticsDto> getPercentStatistics();
} 
