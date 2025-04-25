part of 'auto_reply_bloc.dart';

/// 自动回复事件基类
abstract class AutoReplyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 加载自动回复设置事件
class LoadAutoReplySettings extends AutoReplyEvent {}

/// 更新自动回复启用状态事件
class UpdateAutoReplyEnabled extends AutoReplyEvent {
  /// 是否启用
  final bool isEnabled;

  /// 构造函数
  UpdateAutoReplyEnabled(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

/// 更新自动回复内容事件
class UpdateAutoReplyContent extends AutoReplyEvent {
  /// 回复内容
  final String content;

  /// 构造函数
  UpdateAutoReplyContent(this.content);

  @override
  List<Object?> get props => [content];
} 