import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_statistics.dart';

/// 卖家统计模块状态基类
abstract class SellerStatisticsState extends Equatable {
  const SellerStatisticsState();
  
  @override
  List<Object?> get props => [];
}

/// 初始状态
class SellerStatisticsInitial extends SellerStatisticsState {
  const SellerStatisticsInitial();
}

/// 加载中状态
class SellerStatisticsLoading extends SellerStatisticsState {
  const SellerStatisticsLoading();
}

/// 加载完成状态
class SellerStatisticsLoaded extends SellerStatisticsState {
  final SellerUpgradeStatistics upgradeStats;
  final SellerIndexStatistics indexStats;
  final SellerPercentStatistics percentStats;
  
  const SellerStatisticsLoaded({
    required this.upgradeStats,
    required this.indexStats,
    required this.percentStats,
  });
  
  @override
  List<Object?> get props => [upgradeStats, indexStats, percentStats];
}

/// 错误状态
class SellerStatisticsError extends SellerStatisticsState {
  final Failure failure;
  
  const SellerStatisticsError({required this.failure});
  
  @override
  List<Object?> get props => [failure];
} 