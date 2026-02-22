import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_notification_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_unread_notification_count_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';

part 'notification_list_event.dart';
part 'notification_list_state.dart';

/// 通知列表Bloc
@injectable
class NotificationListBloc extends Bloc<NotificationListEvent, NotificationListState> {
  final GetSellerNotificationListUseCase _getSellerNotificationListUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllNotificationsAsReadUseCase;
  final GetUnreadNotificationCountUseCase _getUnreadNotificationCountUseCase;
  
  // 追踪当前页码
  int _currentPage = 1;
  static const int _pageSize = 10;

  /// 构造函数
  NotificationListBloc(
    this._getSellerNotificationListUseCase,
    this._markNotificationAsReadUseCase,
    this._markAllNotificationsAsReadUseCase,
    this._getUnreadNotificationCountUseCase,
  ) : super(NotificationListInitial()) {
    on<LoadNotificationList>(_onLoadNotificationList);
    on<ChangeNotificationType>(_onChangeNotificationType);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<GetUnreadNotificationCount>(_onGetUnreadNotificationCount);
  }

  /// 加载通知列表
  Future<void> _onLoadNotificationList(
    LoadNotificationList event,
    Emitter<NotificationListState> emit,
  ) async {
    // 重置页码或加载下一页
    if (event.refresh) {
      _currentPage = 1;
    } else if (state is NotificationListLoaded) {
      // 加载更多时增加页码
      _currentPage++;
    }

    // 如果是刷新或者首次加载，显示加载状态
    if (event.refresh || state is NotificationListInitial) {
      emit(NotificationListLoading());
    } else if (state is NotificationListLoaded) {
      // 如果是加载更多，显示加载更多状态
      final currentState = state as NotificationListLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    }

    // 处理"全部"类型的通知查询
    if (event.type == null) {
      // "全部"类型 - 分别加载每种通知类型并合并结果
      await _loadAllTypeNotifications(event, emit);
      return;
    }

    // 构建单一类型的查询参数
    final params = GetSellerNotificationListParams(
      messageType: event.type == NotificationType.order
          ? 'ORDER'
          : event.type == NotificationType.system
              ? 'SYSTEM'
              : event.type == NotificationType.message
                  ? 'MESSAGE'
                  : event.type == NotificationType.refund
                      ? 'REFUND'
                      : event.type == NotificationType.review
                          ? 'REVIEW'
                          : event.type == NotificationType.authentication
                              ? 'AUTHENTICATION'
                              : null,
      pageNum: _currentPage,
      pageSize: _pageSize,
    );

    // 调用用例获取通知列表
    final result = await _getSellerNotificationListUseCase(params);

    result.fold(
      (failure) {
        // 如果是加载更多失败，恢复页码
        if (!event.refresh && state is NotificationListLoaded) {
          _currentPage--;
        }
        
        // 处理失败情况
        if (state is NotificationListLoaded) {
          final currentState = state as NotificationListLoaded;
          emit(currentState.copyWith(
            error: failure.message,
            isLoadingMore: false,
          ));
        } else {
          emit(NotificationListError(failure.message));
        }
      },
      (notifications) {
        // 处理成功情况
        if (event.refresh || state is! NotificationListLoaded) {
          // 刷新或第一次加载，直接替换通知列表
          emit(NotificationListLoaded(
            notifications: notifications,
            currentType: event.type,
            hasMore: notifications.length >= _pageSize, // 如果返回的数据量等于页大小，则可能有更多数据
            unreadCount: null, // 待获取
            error: null,
            isLoadingMore: false,
          ));
        } else {
          // 加载更多，追加通知列表
          final currentState = state as NotificationListLoaded;
          final updatedNotifications = [...currentState.notifications, ...notifications];
          
          emit(NotificationListLoaded(
            notifications: updatedNotifications,
            currentType: event.type,
            hasMore: notifications.length >= _pageSize, // 如果返回的数据量等于页大小，则可能有更多数据
            unreadCount: currentState.unreadCount,
            error: null,
            isLoadingMore: false,
          ));
        }

        // 获取未读数量
        add(GetUnreadNotificationCount());
      },
    );
  }

  /// 加载所有类型的通知(用于"全部"标签)
  Future<void> _loadAllTypeNotifications(
    LoadNotificationList event,
    Emitter<NotificationListState> emit,
  ) async {
    // 需要加载的消息类型列表
    final messageTypes = [
      'SYSTEM',   // 系统通知
      'ORDER',    // 订单通知
      'MESSAGE',  // 消息通知
      'REFUND',   // 售后通知
      'REVIEW',   // 评价通知
      'AUTHENTICATION', // 认证通知
    ];

    // 合并所有类型的通知
    List<SellerNotification> allNotifications = [];
    String? errorMessage;

    // 分别加载每种类型的通知
    for (final messageType in messageTypes) {
      final params = GetSellerNotificationListParams(
        messageType: messageType,
        pageNum: 1,  // 始终从第一页加载
        pageSize: _pageSize,
      );

      final result = await _getSellerNotificationListUseCase(params);
      
      result.fold(
        (failure) {
          // 记录错误，但继续加载其他类型
          errorMessage = failure.message;
          AppLogger.d('加载[$messageType]类型通知失败: ${failure.message}');
        },
        (notifications) {
          // 添加到合并列表
          allNotifications.addAll(notifications);
        },
      );
    }

    // 按时间排序，最新的在前面
    allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 截取需要的数量，避免列表过长
    if (allNotifications.length > _pageSize) {
      allNotifications = allNotifications.sublist(0, _pageSize);
    }

    // 根据当前状态，决定是替换还是追加
    if (event.refresh || state is! NotificationListLoaded) {
      emit(NotificationListLoaded(
        notifications: allNotifications,
        currentType: null, // 全部类型
        hasMore: allNotifications.length >= _pageSize,
        unreadCount: null,
        error: errorMessage,
        isLoadingMore: false,
      ));
    } else {
      // 对于"全部"类型，暂不支持加载更多，每次都重新加载
      final currentState = state as NotificationListLoaded;
      emit(currentState.copyWith(
        notifications: allNotifications, 
        error: errorMessage,
        isLoadingMore: false
      ));
    }

    // 获取未读数量
    add(GetUnreadNotificationCount());
  }

  /// 切换通知类型
  void _onChangeNotificationType(
    ChangeNotificationType event,
    Emitter<NotificationListState> emit,
  ) {
    // 如果当前已加载状态
    if (state is NotificationListLoaded) {
      final currentState = state as NotificationListLoaded;
      
      // 如果类型与当前相同，不需处理
      if (currentState.currentType == event.type) {
        return;
      }
      
      // 重置页码
      _currentPage = 1;
      
      // 更新当前类型并重新加载
      final NotificationListLoaded newState = currentState.copyWith(currentType: event.type);
      emit(newState);
      add(LoadNotificationList(type: event.type, refresh: true));
    } else {
      // 如果当前不是已加载状态，直接加载新类型
      _currentPage = 1;
      add(LoadNotificationList(type: event.type, refresh: true));
    }
  }

  /// 标记通知为已读
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationListState> emit,
  ) async {
    // 确保当前状态为已加载状态
    if (state is! NotificationListLoaded) {
      return;
    }

    final currentState = state as NotificationListLoaded;
    
    // 在本地将通知标记为已读
    final updatedNotifications = currentState.notifications.map((notification) {
      if (notification.notificationId == event.notificationId) {
        return notification.markAsRead();
      }
      return notification;
    }).toList();
    
    emit(currentState.copyWith(notifications: updatedNotifications));

    // 调用API将通知标记为已读
    final params = MarkNotificationAsReadParams(
      notificationId: event.notificationId,
    );
    
    final result = await _markNotificationAsReadUseCase(params);
    
    result.fold(
      (failure) {
        // 标记失败，提示错误，但不改变UI状态
        emit(currentState.copyWith(error: failure.message));
      },
      (success) {
        // 标记成功，更新未读数量
        add(GetUnreadNotificationCount());
      },
    );
  }

  /// 标记所有通知为已读
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationListState> emit,
  ) async {
    // 确保当前状态为已加载状态
    if (state is! NotificationListLoaded) {
      return;
    }

    final currentState = state as NotificationListLoaded;
    
    // 在本地将所有通知标记为已读
    final updatedNotifications = currentState.notifications.map((notification) {
      return notification.isRead ? notification : notification.markAsRead();
    }).toList();
    
    emit(currentState.copyWith(notifications: updatedNotifications));

    // 构建参数
    final params = MarkAllNotificationsAsReadParams(
      messageTypes: event.type == NotificationType.order
          ? 'ORDER'
          : event.type == NotificationType.system
              ? 'SYSTEM'
              : event.type == NotificationType.message
                  ? 'MESSAGE'
                  : event.type == NotificationType.refund
                      ? 'REFUND'
                      : event.type == NotificationType.review
                          ? 'REVIEW'
                          : event.type == NotificationType.authentication
                              ? 'AUTHENTICATION'
                              : null,
    );
    
    // 调用API将所有通知标记为已读
    final result = await _markAllNotificationsAsReadUseCase(params);
    
    result.fold(
      (failure) {
        // 标记失败，提示错误，但不改变UI状态
        emit(currentState.copyWith(error: failure.message));
      },
      (success) {
        // 标记成功，更新未读数量
        add(GetUnreadNotificationCount());
      },
    );
  }

  /// 获取未读通知数量
  Future<void> _onGetUnreadNotificationCount(
    GetUnreadNotificationCount event,
    Emitter<NotificationListState> emit,
  ) async {
    // 确保当前状态为已加载状态
    if (state is! NotificationListLoaded) {
      return;
    }

    final currentState = state as NotificationListLoaded;
    
    // 调用用例获取未读数量
    final result = await _getUnreadNotificationCountUseCase(NoParams());
    
    result.fold(
      (failure) {
        // 获取失败，不更改未读数量
      },
      (count) {
        // 获取成功，更新未读数量
        emit(currentState.copyWith(unreadCount: count));
      },
    );
  }
} 