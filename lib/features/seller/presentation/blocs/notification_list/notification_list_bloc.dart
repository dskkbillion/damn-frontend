import 'package:flutter_bloc/flutter_bloc.dart';
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
    // 如果是刷新或者首次加载，显示加载状态
    if (event.refresh || state is NotificationListInitial) {
      emit(NotificationListLoading());
    } else if (state is NotificationListLoaded) {
      // 如果是加载更多，显示加载更多状态
      final currentState = state as NotificationListLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    }

    // 构建参数
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
    );

    // 调用用例获取通知列表
    final result = await _getSellerNotificationListUseCase(params);

    result.fold(
      (failure) {
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
        emit(NotificationListLoaded(
          notifications: notifications,
          currentType: event.type,
          hasMore: notifications.length >= 20, // 假设每页20条
          unreadCount: null, // 待获取
          error: null,
          isLoadingMore: false,
        ));

        // 获取未读数量
        add(GetUnreadNotificationCount());
      },
    );
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
      
      // 更新当前类型并重新加载
      emit(currentState.copyWith(currentType: event.type));
      add(LoadNotificationList(type: event.type, refresh: true));
    } else {
      // 如果当前不是已加载状态，直接加载新类型
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