import 'package:equatable/equatable.dart';

/// 卖家统计模块事件基类
abstract class SellerStatisticsEvent extends Equatable {
  const SellerStatisticsEvent();
  
  @override
  List<Object?> get props => [];
}

/// 加载卖家统计数据事件
class LoadSellerStatistics extends SellerStatisticsEvent {
  const LoadSellerStatistics();
}

/// 刷新卖家统计数据事件
class RefreshSellerStatistics extends SellerStatisticsEvent {
  const RefreshSellerStatistics();
} 