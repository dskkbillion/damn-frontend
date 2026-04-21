import 'package:equatable/equatable.dart';

/// 代表应用中可能发生的通用失败情况的基类。
/// 使用 Equatable 以方便比较。
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  /// {@macro failure}
  const Failure({
    required this.message,
    this.statusCode,
  });

  // Subclasses should override props if they have properties to compare
  @override
  List<Object?> get props => [message, statusCode];
}

/// 表示服务器相关的错误 (例如, API 调用失败, 5xx 错误)
class ServerFailure extends Failure {
  final String? code;

  const ServerFailure({
    required super.message,
    super.statusCode,
    this.code,
  });

  @override
  List<Object?> get props => [message, code, statusCode];

  @override
  String toString() => 'ServerFailure(message: $message, code: $code, statusCode: $statusCode)';
}

/// 表示网络连接错误
class NetworkFailure extends Failure {
  final String? code;

  const NetworkFailure({
    required super.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() => 'NetworkFailure(message: $message, code: $code)';
}

/// 表示本地缓存相关的错误 (例如, 读取/写入 SharedPreferences 失败)
class CacheFailure extends Failure {
  final String? code;

  const CacheFailure({
    required super.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'CacheFailure(message: $message, code: $code)';
}

/// 表示认证相关的错误
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// 表示一个简单的、通用的失败情况，通常只包含一个错误消息。
class SimpleFailure extends Failure {
  const SimpleFailure(String message) : super(message: message);
}

/// 表示一个通用的、未指定类型的失败情况。
class GeneralFailure extends Failure {
  final String code;

  const GeneralFailure({
    required super.message,
    this.code = 'GENERAL_ERROR',
  });

  @override
  List<Object?> get props => [message, code];
}

/// Represents a failure during input validation.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// 聊天错误
class ChatFailure extends Failure {
  final String code;

  const ChatFailure({
    required this.code,
    super.message = 'Chat Error'
  });

  @override
  List<Object?> get props => [message, code];
}

/// 未授权错误
class UnauthorizedFailure extends Failure {
  final String code;

  const UnauthorizedFailure({
    this.code = 'UNAUTHORIZED',
    super.message = 'Unauthorized'
  });

  @override
  List<Object?> get props => [message, code];
}

/// 无效输入错误
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({super.message = 'Invalid Input'});
}

/// Represents a generic failure when no specific type is identified.
class GenericFailure extends Failure {
  const GenericFailure({super.message = 'Generic Error'});
}

/// Represents a specific authentication failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message = 'Authentication Failed'});
}

/// Represents a client-side error
class ClientFailure extends Failure {
  const ClientFailure({super.message = 'Client Error / Invalid Input'});
}

/// Represents a failure when a requested resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found'});
}

/// Represents an unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred'});
}

/// 支付错误
class PaymentFailure extends Failure {
  const PaymentFailure({
    required super.message,
    super.statusCode,
  });
}
