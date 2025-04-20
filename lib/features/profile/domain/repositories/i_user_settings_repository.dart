import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_settings.dart';

/// 定义用户设置的数据访问接口
abstract class IUserSettingsRepository {
  /// 获取用户设置
  ///
  /// 返回 [UserSettings] 实体或 [Failure]
  Future<Either<Failure, UserSettings>> getUserSettings();

  /// 更新用户设置
  ///
  /// [data] 更新的设置数据
  /// 返回更新后的 [UserSettings] 实体或 [Failure]
  Future<Either<Failure, UserSettings>> updateUserSettings(UserSettingsUpdateData data);
}

/// 更新用户设置的数据类
class UserSettingsUpdateData {
  final NotificationSettings? notificationPreferences;
  final AccountSafetySettings? accountSafetySettings;
  final String? language;
  final ThemeMode? theme;

  UserSettingsUpdateData({
    this.notificationPreferences,
    this.accountSafetySettings,
    this.language,
    this.theme,
  });
}
