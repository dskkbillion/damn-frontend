part of 'notification_list_bloc.dart';

/// 通知列表状态基类
abstract class NotificationListState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 初始状态
class NotificationListInitial extends NotificationListState {}

/// 加载中状态
class NotificationListLoading extends NotificationListState {}

/// 加载失败状态
class NotificationListError extends NotificationListState {
  /// 错误消息
  final String message;

  /// 构造函数
  NotificationListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 加载完成状态
class NotificationListLoaded extends NotificationListState {
  /// 通知列表
  final List<SellerNotification> notifications;
  
  /// 当前通知类型 (null 表示全部)
  final NotificationType? currentType;
  
  /// 是否还有更多数据
  final bool hasMore;
  
  /// 未读通知数量
  final int? unreadCount;
  
  /// 错误信息
  final String? error;
  
  /// 是否正在加载更多
  final bool isLoadingMore;

  /// 构造函数
  NotificationListLoaded({
    required this.notifications,
    this.currentType,
    required this.hasMore,
    this.unreadCount,
    this.error,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    notifications,
    currentType,
    hasMore,
    unreadCount,
    error,
    isLoadingMore,
  ];

  /// 复制构造函数
  NotificationListLoaded copyWith({
    List<SellerNotification>? notifications,
    NotificationType? currentType,
    bool? hasMore,
    int? unreadCount,
    String? error,
    bool? isLoadingMore,
  }) {
    return NotificationListLoaded(
      notifications: notifications ?? this.notifications,
      currentType: currentType != null ? currentType : this.currentType,
      hasMore: hasMore ?? this.hasMore,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
} 