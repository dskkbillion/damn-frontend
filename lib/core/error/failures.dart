import 'package:equatable/equatable.dart';

/// 代表应用中可能发生的通用失败情况的基类。
/// 使用 Equatable 以方便比较。
abstract class Failure extends Equatable {
  final String message;

  /// {@macro failure}
  const Failure({this.message = 'An unexpected error occurred'});

  // Subclasses should override props if they have properties to compare
  @override
  List<Object?> get props => [message];
}

/// 表示服务器相关的错误 (例如, API 调用失败, 5xx 错误)
class ServerFailure extends Failure {
  final String? code;
  final int? statusCode;

  const ServerFailure({
    String message = 'Server Error', 
    this.code, 
    this.statusCode
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code, statusCode];

  @override
  String toString() => 'ServerFailure(message: $message, code: $code, statusCode: $statusCode)';
}

/// 表示网络连接错误
class NetworkFailure extends Failure {
  final String? code;
  const NetworkFailure({
    String message = 'Network connection failed', 
    this.code
  }) : super(message: message);
  
  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() => 'NetworkFailure(message: $message, code: $code)';
}

/// 表示本地缓存相关的错误 (例如, 读取/写入 SharedPreferences 失败)
class CacheFailure extends Failure {
  final String? code;
  const CacheFailure({
    String message = 'Cache Error', 
    this.code
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'CacheFailure(message: $message, code: $code)';
}

/// 表示认证相关的错误
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}

/// 表示一个简单的、通用的失败情况，通常只包含一个错误消息。
class SimpleFailure extends Failure {
  const SimpleFailure(String message) : super(message: message);
}

/// 表示一个通用的、未指定类型的失败情况。
class GeneralFailure extends Failure {
  final String code;
  const GeneralFailure({
    this.code = 'GENERAL_ERROR',
    String message = 'An unexpected error occurred'
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code];
}

/// Represents a failure during input validation.
class ValidationFailure extends Failure {
  const ValidationFailure({required String message})
      : super(message: message);
}

/// 聊天错误
class ChatFailure extends Failure {
  final String code;
  const ChatFailure({
    required this.code,
    String message = 'Chat Error'
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code];
}

/// 未授权错误
class UnauthorizedFailure extends Failure {
  final String code;
  const UnauthorizedFailure({
    this.code = 'UNAUTHORIZED',
    String message = 'Unauthorized'
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code];
}

/// 无效输入错误
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({String message = 'Invalid Input'}) : super(message: message);
}

/// Represents a generic failure when no specific type is identified.
class GenericFailure extends Failure {
  const GenericFailure({String message = 'Generic Error'}) : super(message: message);
}

/// Represents a specific authentication failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String message = 'Authentication Failed'}) : super(message: message);
}

/// Represents a client-side error
class ClientFailure extends Failure {
  const ClientFailure({String message = 'Client Error / Invalid Input'}) : super(message: message);
}

/// Represents a failure when a requested resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({String message = 'Resource not found'}) : super(message: message);
}

/// Represents an unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({String message = 'An unknown error occurred'})
      : super(message: message);
}
