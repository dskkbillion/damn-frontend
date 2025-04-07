import 'package:equatable/equatable.dart';

/// 聊天错误实体类
///
/// 用于在消息发送失败时携带错误信息
class ChatError extends Equatable {
  /// 错误代码
  final String code;
  
  /// 错误消息
  final String message;
  
  /// 是否可以重试
  final bool canRetry;
  
  /// 创建时间
  final DateTime timestamp;
  
  /// 创建一个聊天错误实体
  /// 
  /// [code] 错误代码，通常来自服务器响应
  /// [message] 错误消息
  /// [canRetry] 是否可以重试此操作，默认为true
  /// [timestamp] 错误发生时间，默认为当前时间
  const ChatError({
    required this.code,
    required this.message,
    this.canRetry = true,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// 创建网络错误
  factory ChatError.network(String message) {
    return ChatError(
      code: 'NETWORK_ERROR',
      message: message,
      canRetry: true,
    );
  }
  
  /// 创建服务器错误
  factory ChatError.server(String message, {String? statusCode}) {
    return ChatError(
      code: statusCode ?? 'SERVER_ERROR',
      message: message,
      canRetry: true,
    );
  }
  
  /// 创建认证错误
  factory ChatError.auth(String message) {
    return ChatError(
      code: 'AUTH_ERROR',
      message: message,
      canRetry: false,
    );
  }
  
  /// 创建超时错误
  factory ChatError.timeout(String message) {
    return ChatError(
      code: 'TIMEOUT',
      message: message,
      canRetry: true,
    );
  }
  
  /// 创建未知错误
  factory ChatError.unknown({String? message}) {
    return ChatError(
      code: 'UNKNOWN_ERROR',
      message: message ?? '发生未知错误',
      canRetry: true,
    );
  }
  
  /// 创建此错误的副本，但部分字段替换为新值
  ChatError copyWith({
    String? code,
    String? message,
    bool? canRetry,
    DateTime? timestamp,
  }) {
    return ChatError(
      code: code ?? this.code,
      message: message ?? this.message,
      canRetry: canRetry ?? this.canRetry,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  @override
  List<Object> get props => [code, message, canRetry, timestamp];
} 