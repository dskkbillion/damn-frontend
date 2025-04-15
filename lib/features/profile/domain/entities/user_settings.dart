import 'package:equatable/equatable.dart';

/// 通知设置细节
class NotificationSettings extends Equatable {
  /// 是否允许推送通知
  final bool allowPushNotifications;

  /// 是否接收新消息通知
  final bool notifyNewMessages;

  /// 是否接收订单更新通知
  final bool notifyOrderUpdates;

  /// 是否接收促销活动通知
  final bool notifyPromotions;

  /// 创建 NotificationSettings 实例
  const NotificationSettings({
    required this.allowPushNotifications,
    required this.notifyNewMessages,
    required this.notifyOrderUpdates,
    required this.notifyPromotions,
  });

  @override
  List<Object> get props => [
    allowPushNotifications,
    notifyNewMessages,
    notifyOrderUpdates,
    notifyPromotions,
  ];
}

/// 账户安全设置细节
class AccountSafetySettings extends Equatable {
  /// 是否已绑定手机号
  final bool isPhoneBound;

  /// 是否已绑定邮箱
  final bool isEmailBound;

  /// 是否开启二次验证
  final bool twoFactorEnabled;

  /// 创建 AccountSafetySettings 实例
  const AccountSafetySettings({
    required this.isPhoneBound,
    required this.isEmailBound,
    required this.twoFactorEnabled,
  });

  @override
  List<Object> get props => [
    isPhoneBound,
    isEmailBound,
    twoFactorEnabled,
  ];
}

/// 主题设置枚举
enum ThemeMode {
  light,
  dark,
  system,
}

/// 应用相关的用户偏好设置
class UserSettings extends Equatable {
  /// 用户唯一标识
  final String userId;

  /// 通知设置
  final NotificationSettings? notificationPreferences;

  /// 账户安全设置
  final AccountSafetySettings? accountSafetySettings;

  /// 应用语言偏好
  final String? language;

  /// 应用主题偏好
  final ThemeMode? theme;

  /// 创建 UserSettings 实例
  const UserSettings({
    required this.userId,
    this.notificationPreferences,
    this.accountSafetySettings,
    this.language,
    this.theme,
  });

  @override
  List<Object?> get props => [
    userId,
    notificationPreferences,
    accountSafetySettings,
    language,
    theme,
  ];
}
