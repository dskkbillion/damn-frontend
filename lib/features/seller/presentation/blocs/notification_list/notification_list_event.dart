part of 'notification_list_bloc.dart';

/// 通知列表事件基类
abstract class NotificationListEvent extends Equatable {
  /// 构造函数
  const NotificationListEvent();

  @override
  List<Object?> get props => [];
}

/// 加载通知列表事件
class LoadNotificationList extends NotificationListEvent {
  /// 通知类型 (null 表示全部)
  final NotificationType? type;
  
  /// 是否刷新
  final bool refresh;

  /// 构造函数
  const LoadNotificationList({
    this.type,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [type, refresh];
}

/// 切换通知类型事件
class ChangeNotificationType extends NotificationListEvent {
  /// 通知类型 (null 表示全部)
  final NotificationType? type;

  /// 构造函数
  const ChangeNotificationType({
    this.type,
  });

  @override
  List<Object?> get props => [type];
}

/// 标记通知为已读事件
class MarkNotificationAsRead extends NotificationListEvent {
  /// 通知ID
  final String notificationId;

  /// 构造函数
  const MarkNotificationAsRead({
    required this.notificationId,
  });

  @override
  List<Object?> get props => [notificationId];
}

/// 标记所有通知为已读事件
class MarkAllNotificationsAsRead extends NotificationListEvent {
  /// 通知类型
  final NotificationType? type;

  /// 构造函数
  const MarkAllNotificationsAsRead({
    this.type,
  });

  @override
  List<Object?> get props => [type];
}

/// 获取未读通知数量事件
class GetUnreadNotificationCount extends NotificationListEvent {} 