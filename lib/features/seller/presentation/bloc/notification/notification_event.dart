import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationEvent {
  final NotificationType? type;
  final bool refresh;
  final bool loadMore;

  const FetchNotifications({
    this.type,
    this.refresh = false,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [type, refresh, loadMore];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  final NotificationType? type;

  const MarkAllNotificationsAsRead({this.type});

  @override
  List<Object?> get props => [type];
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class DeleteAllNotifications extends NotificationEvent {
  final NotificationType? type;

  const DeleteAllNotifications({this.type});

  @override
  List<Object?> get props => [type];
} 