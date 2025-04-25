part of 'auto_reply_bloc.dart';

/// 自动回复状态基类
abstract class AutoReplyState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 初始状态
class AutoReplyInitial extends AutoReplyState {}

/// 加载中状态
class AutoReplyLoading extends AutoReplyState {}

/// 更新中状态
class AutoReplyUpdating extends AutoReplyState {
  /// 当前正在更新的设置
  final AutoReplySettings settings;

  /// 构造函数
  AutoReplyUpdating(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// 加载完成状态
class AutoReplyLoaded extends AutoReplyState {
  /// 自动回复设置数据
  final AutoReplySettings settings;

  /// 构造函数
  AutoReplyLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// 错误状态
class AutoReplyError extends AutoReplyState {
  /// 错误信息
  final String message;

  /// 构造函数
  AutoReplyError(this.message);

  @override
  List<Object> get props => [message];
} 