import 'package:equatable/equatable.dart';

/// 卖家自动回复设置
class AutoReplySettings extends Equatable {
  /// 是否启用自动回复
  final bool isEnabled;
  
  /// 自动回复内容
  final String? content;

  const AutoReplySettings({
    required this.isEnabled,
    this.content,
  });

  @override
  List<Object?> get props => [isEnabled, content];
  
  /// 创建默认设置
  factory AutoReplySettings.defaultSettings() {
    return const AutoReplySettings(
      isEnabled: false,
      content: null,
    );
  }
  
  /// 创建启用了的设置
  factory AutoReplySettings.enabled(String content) {
    return AutoReplySettings(
      isEnabled: true,
      content: content,
    );
  }
  
  /// 创建禁用了的设置
  factory AutoReplySettings.disabled() {
    return const AutoReplySettings(
      isEnabled: false,
      content: null,
    );
  }
  
  /// 转换为API参数格式
  Map<String, dynamic> toJson() {
    return {
      'recoverFlag': isEnabled,
      if (content != null) 'recoverContent': content,
    };
  }
} 