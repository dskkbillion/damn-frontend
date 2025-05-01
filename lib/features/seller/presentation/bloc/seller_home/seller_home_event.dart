import 'package:equatable/equatable.dart';

/// 卖家主页/仪表盘事件基类
abstract class SellerHomeEvent extends Equatable {
  const SellerHomeEvent();

  @override
  List<Object> get props => [];
}

/// 加载仪表盘数据事件
class LoadDashboardData extends SellerHomeEvent {
  /// 是否强制刷新
  final bool forceRefresh;

  const LoadDashboardData({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

/// 刷新仪表盘数据事件
class RefreshDashboardData extends SellerHomeEvent {
  const RefreshDashboardData();
}

/// 导航到订单列表页面事件
class NavigateToOrders extends SellerHomeEvent {
  /// 订单类型 (待处理、已完成、已取消等)
  final String? orderType;
  
  const NavigateToOrders({this.orderType});
  
  @override
  List<Object> get props => [orderType ?? ''];
}

/// 导航到聊天列表页面事件
class NavigateToChat extends SellerHomeEvent {
  const NavigateToChat();
}