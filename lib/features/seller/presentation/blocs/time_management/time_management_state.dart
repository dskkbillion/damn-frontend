part of 'time_management_bloc.dart';

/// 时间管理状态基类
abstract class TimeManagementState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 初始状态
class TimeManagementInitial extends TimeManagementState {}

/// 加载中状态
class TimeManagementLoading extends TimeManagementState {}

/// 更新中状态
class TimeManagementUpdating extends TimeManagementState {
  /// 当前正在更新的设置
  final TimeSettings settings;

  /// 构造函数
  TimeManagementUpdating(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// 加载完成状态
class TimeManagementLoaded extends TimeManagementState {
  /// 时间设置数据
  final TimeSettings settings;

  /// 构造函数
  TimeManagementLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// 错误状态
class TimeManagementError extends TimeManagementState {
  /// 错误信息
  final String message;

  /// 构造函数
  TimeManagementError(this.message);

  @override
  List<Object> get props => [message];
} 