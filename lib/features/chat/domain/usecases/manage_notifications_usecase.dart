import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 通知设置参数
class NotificationSettings {
  /// 会话ID
  final String sessionId;
  
  /// 是否静音通知
  final bool isMuted;
  
  /// 是否置顶会话
  final bool isPinned;

  const NotificationSettings({
    required this.sessionId,
    this.isMuted = false,
    this.isPinned = false,
  });
}

/// 管理消息通知用例
class ManageNotificationsUseCase {
  final IChatRepository _chatRepository;
  final IChatLocalCache _localCache;

  ManageNotificationsUseCase(this._chatRepository, this._localCache);

  /// 更新会话通知设置
  /// 
  /// [settings] 通知设置参数
  /// 返回更新后的会话或失败
  Future<Either<Failure, ChatSession>> updateNotificationSettings(
    NotificationSettings settings
  ) async {
    // 获取当前会话
    final sessionResult = await _chatRepository.getSessionDetail(settings.sessionId);
    
    return sessionResult.fold(
      (failure) => Left(failure),
      (session) async {
        // 创建更新后的会话对象
        final updatedSession = session.copyWith(
          muted: settings.isMuted,
          pinned: settings.isPinned,
        );
        
        // 更新本地会话缓存
        try {
          await _localCache.updateSessionSettings(
            settings.sessionId, 
            settings.isMuted, 
            settings.isPinned
          );
          return Right(updatedSession);
        } catch (e) {
          return Left(CacheFailure(message: '更新通知设置失败: ${e.toString()}'));
        }
      }
    );
  }

  /// 获取会话通知设置
  /// 
  /// [sessionId] 会话ID
  /// 返回通知设置参数或失败
  Future<Either<Failure, NotificationSettings>> getNotificationSettings(
    String sessionId
  ) async {
    // 获取当前会话
    final sessionResult = await _chatRepository.getSessionDetail(sessionId);
    
    return sessionResult.fold(
      (failure) => Left(failure),
      (session) {
        return Right(NotificationSettings(
          sessionId: sessionId,
          isMuted: session.muted,
          isPinned: session.pinned,
        ));
      }
    );
  }
  
  /// 批量更新通知设置
  /// 
  /// [settingsList] 多个会话的通知设置列表
  /// 返回成功数量或失败
  Future<Either<Failure, int>> batchUpdateSettings(
    List<NotificationSettings> settingsList
  ) async {
    int successCount = 0;
    
    for (var settings in settingsList) {
      final result = await updateNotificationSettings(settings);
      if (result.isRight()) {
        successCount++;
      }
    }
    
    if (successCount == 0 && settingsList.isNotEmpty) {
      return Left(CacheFailure(message: '批量更新通知设置失败'));
    }
    
    return Right(successCount);
  }
} 