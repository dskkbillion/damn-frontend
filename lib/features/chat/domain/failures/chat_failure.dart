import 'package:equatable/equatable.dart';

/// 聊天模块的失败基类
///
/// 所有与聊天功能相关的失败类型均继承自此类
abstract class ChatFailure extends Equatable {
  final String message;
  
  const ChatFailure({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// 服务器错误
///
/// 当服务器返回错误响应或处理请求出错时使用
class ServerFailure extends ChatFailure {
  final int? statusCode;
  
  const ServerFailure({
    required String message,
    this.statusCode,
  }) : super(message: message);
  
  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// 网络错误
///
/// 当网络连接失败或超时时使用
class NetworkFailure extends ChatFailure {
  const NetworkFailure({required String message}) : super(message: message);
}

/// 缓存错误
///
/// 当本地数据读写失败时使用
class CacheFailure extends ChatFailure {
  const CacheFailure({required String message}) : super(message: message);
}

/// 消息发送失败
///
/// 当消息发送到服务器失败时使用
class MessageSendFailure extends ChatFailure {
  final String messageId;
  
  const MessageSendFailure({
    required this.messageId,
    required String message,
  }) : super(message: message);
  
  @override
  List<Object> get props => [message, messageId];
}

/// WebSocket连接失败
///
/// 当实时通信连接失败时使用
class WebSocketFailure extends ChatFailure {
  final bool canRetry;
  
  const WebSocketFailure({
    required String message,
    this.canRetry = true,
  }) : super(message: message);
  
  @override
  List<Object> get props => [message, canRetry];
}

/// 认证失败
///
/// 当用户认证失败时使用
class AuthFailure extends ChatFailure {
  const AuthFailure({required String message}) : super(message: message);
}

/// 格式错误
///
/// 当数据格式不正确时使用
class FormatFailure extends ChatFailure {
  const FormatFailure({required String message}) : super(message: message);
}

/// 未找到资源
///
/// 当请求的资源不存在时使用
class NotFoundFailure extends ChatFailure {
  const NotFoundFailure({required String message}) : super(message: message);
}

/// 权限错误
///
/// 当用户没有足够权限时使用
class PermissionFailure extends ChatFailure {
  const PermissionFailure({required String message}) : super(message: message);
}

/// 未预期的错误
///
/// 当发生未明确分类的错误时使用
class UnexpectedFailure extends ChatFailure {
  final Object? error;
  
  const UnexpectedFailure({
    required String message,
    this.error,
  }) : super(message: message);
  
  @override
  List<Object> get props => [message, if (error != null) error.toString()];
} 