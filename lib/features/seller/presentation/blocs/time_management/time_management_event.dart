part of 'time_management_bloc.dart';

/// 时间管理事件基类
abstract class TimeManagementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 加载时间设置事件
class LoadTimeSettings extends TimeManagementEvent {}

/// 更新在线状态事件
class UpdateOnlineStatus extends TimeManagementEvent {
  /// 新的在线状态
  final bool isOnline;

  /// 构造函数
  UpdateOnlineStatus(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
} 