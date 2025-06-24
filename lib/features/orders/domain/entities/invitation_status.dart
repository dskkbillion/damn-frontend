import 'package:equatable/equatable.dart';

/// 邀请评价状态实体
class InvitationStatus extends Equatable {
  /// 订单ID
  final int orderId;
  
  /// 今日邀请次数
  final int todayInviteCount;
  
  /// 总邀请次数
  final int totalInviteCount;
  
  /// 上次邀请时间
  final DateTime? lastInviteTime;
  
  /// 是否已达到今日限制（3次）
  bool get hasReachedTodayLimit => todayInviteCount >= 3;
  
  /// 是否今日已邀请
  bool get hasInvitedToday => lastInviteTime != null && 
    lastInviteTime!.toLocal().day == DateTime.now().day &&
    lastInviteTime!.toLocal().month == DateTime.now().month &&
    lastInviteTime!.toLocal().year == DateTime.now().year;

  const InvitationStatus({
    required this.orderId,
    this.todayInviteCount = 0,
    this.totalInviteCount = 0,
    this.lastInviteTime,
  });

  InvitationStatus copyWith({
    int? orderId,
    int? todayInviteCount,
    int? totalInviteCount,
    DateTime? lastInviteTime,
  }) {
    return InvitationStatus(
      orderId: orderId ?? this.orderId,
      todayInviteCount: todayInviteCount ?? this.todayInviteCount,
      totalInviteCount: totalInviteCount ?? this.totalInviteCount,
      lastInviteTime: lastInviteTime ?? this.lastInviteTime,
    );
  }

  /// 增加邀请次数
  InvitationStatus incrementCount() {
    final now = DateTime.now();
    final isToday = hasInvitedToday;
    
    return copyWith(
      todayInviteCount: isToday ? todayInviteCount + 1 : 1,
      totalInviteCount: totalInviteCount + 1,
      lastInviteTime: now,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    todayInviteCount,
    totalInviteCount,
    lastInviteTime,
  ];
} 