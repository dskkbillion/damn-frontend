import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import '../entities/seller_statistics.dart';

/// 卖家统计数据仓库接口
abstract class ISellerStatisticsRepository {
  /// 获取升级统计数据
  Future<Either<Failure, SellerUpgradeStatistics>> getUpgradeStatistics();
  
  /// 获取主要指标统计数据
  Future<Either<Failure, SellerIndexStatistics>> getIndexStatistics();
  
  /// 获取百分比统计数据
  Future<Either<Failure, SellerPercentStatistics>> getPercentStatistics();
} 