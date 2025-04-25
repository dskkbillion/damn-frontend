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

/// 导航到通知列表页面事件
class NavigateToNotifications extends SellerHomeEvent {
  const NavigateToNotifications();
}

/// 导航到聊天列表页面事件
class NavigateToChat extends SellerHomeEvent {
  const NavigateToChat();
}

/// 导航到商品管理页面事件
class NavigateToProducts extends SellerHomeEvent {
  const NavigateToProducts();
}

/// 导航到售后管理页面事件
class NavigateToAfterSales extends SellerHomeEvent {
  const NavigateToAfterSales();
}

/// 导航到店铺设置页面事件
class NavigateToStoreSettings extends SellerHomeEvent {
  const NavigateToStoreSettings();
}

/// 导航到认证管理页面事件
class NavigateToAuthentication extends SellerHomeEvent {
  const NavigateToAuthentication();
}

/// 导航到时间管理页面事件
class NavigateToTimeManagement extends SellerHomeEvent {
  const NavigateToTimeManagement();
}

/// 导航到自动回复设置页面事件
class NavigateToAutoReply extends SellerHomeEvent {
  const NavigateToAutoReply();
}