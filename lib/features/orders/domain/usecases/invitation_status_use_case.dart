import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../entities/invitation_status.dart';
import '../repositories/i_order_repository.dart';

/// 邀请状态管理用例
@injectable
class InvitationStatusUseCase {
  final IOrderRepository _orderRepository;
  final SharedPreferences _prefs;

  InvitationStatusUseCase(this._orderRepository, this._prefs);

  /// 获取订单的邀请状态
  Future<InvitationStatus> getInvitationStatus(int orderId) async {
    final key = 'invitation_status_$orderId';
    final data = _prefs.getString(key);
    
    if (data != null) {
      try {
        final parts = data.split('|');
        if (parts.length >= 3) {
          final todayCount = int.parse(parts[0]);
          final totalCount = int.parse(parts[1]);
          final lastTimeStr = parts[2];
          final lastTime = lastTimeStr.isNotEmpty ? DateTime.parse(lastTimeStr) : null;
          
          // 检查是否跨天，如果跨天则重置今日计数
          if (lastTime != null) {
            final now = DateTime.now();
            final lastDate = DateTime(lastTime.year, lastTime.month, lastTime.day);
            final today = DateTime(now.year, now.month, now.day);
            
            if (lastDate.isBefore(today)) {
              // 跨天了，重置今日计数
              final resetStatus = InvitationStatus(
                orderId: orderId,
                todayInviteCount: 0,
                totalInviteCount: totalCount,
                lastInviteTime: lastTime,
              );
              await _saveInvitationStatus(resetStatus);
              return resetStatus;
            }
          }
          
          return InvitationStatus(
            orderId: orderId,
            todayInviteCount: todayCount,
            totalInviteCount: totalCount,
            lastInviteTime: lastTime,
          );
        }
      } catch (e) {
        print('[InvitationStatusUseCase] Error parsing saved data: $e');
      }
    }
    
    // 返回默认状态
    return InvitationStatus(orderId: orderId);
  }

  /// 检查是否可以邀请评价
  Future<Either<Failure, bool>> canInviteEvaluation(int orderId) async {
    final status = await getInvitationStatus(orderId);
    
    if (status.hasReachedTodayLimit) {
      return Left(ServerFailure(message: '今日邀请次数已达上限（3次），请明天再试'));
    }
    
    return const Right(true);
  }

  /// 执行邀请评价操作
  Future<Either<Failure, String>> inviteEvaluation(int orderId) async {
    // 先检查是否可以邀请
    final canInviteResult = await canInviteEvaluation(orderId);
    if (canInviteResult.isLeft()) {
      return canInviteResult.fold((failure) => Left(failure), (_) => Left(ServerFailure(message: '未知错误')));
    }

    // 调用API邀请
    final result = await _orderRepository.inviteEvaluation(orderId);
    
    return result.fold(
      (failure) {
        // 处理后端返回的特定错误
        if (failure is ServerFailure) {
          final message = failure.message ?? '';
          if (message.contains('已邀请') || message.contains('重复')) {
            return Left(ServerFailure(message: '今日已邀请过该订单，请勿重复邀请'));
          } else if (message.contains('限制') || message.contains('上限')) {
            return Left(ServerFailure(message: '邀请次数已达上限，请明天再试'));
          }
        }
        return Left(failure);
      },
      (_) async {
        // 邀请成功，更新本地状态
        final currentStatus = await getInvitationStatus(orderId);
        final newStatus = currentStatus.incrementCount();
        await _saveInvitationStatus(newStatus);
        
        final remainingCount = 3 - newStatus.todayInviteCount;
        if (remainingCount > 0) {
          return Right('邀请成功！今日还可邀请 $remainingCount 次');
        } else {
          return const Right('邀请成功！今日邀请次数已用完');
        }
      },
    );
  }

  /// 保存邀请状态到本地
  Future<void> _saveInvitationStatus(InvitationStatus status) async {
    final key = 'invitation_status_${status.orderId}';
    final data = '${status.todayInviteCount}|${status.totalInviteCount}|${status.lastInviteTime?.toIso8601String() ?? ''}';
    await _prefs.setString(key, data);
  }

  /// 获取邀请状态的显示文本
  Future<String> getInvitationStatusText(int orderId) async {
    final status = await getInvitationStatus(orderId);
    
    if (status.hasReachedTodayLimit) {
      return '今日已邀请 ${status.todayInviteCount}/3 次';
    } else if (status.hasInvitedToday) {
      return '今日已邀请 ${status.todayInviteCount}/3 次';
    } else {
      return '可邀请评价';
    }
  }
} 