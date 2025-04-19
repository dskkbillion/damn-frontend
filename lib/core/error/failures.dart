import 'package:equatable/equatable.dart';

/// 代表应用中可能发生的通用失败情况的基类。
/// 使用 Equatable 以方便比较。
abstract class Failure extends Equatable {
  final String message;

  /// {@macro failure}
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// 表示服务器相关的错误 (例如, API 调用失败, 5xx 错误)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required String message, this.statusCode})
      : super(message: message);

  @override
  List<Object?> get props => [message, statusCode];
}

/// 表示本地缓存相关的错误 (例如, 读取/写入 SharedPreferences 失败)
class CacheFailure extends Failure {
  const CacheFailure({required String message})
      : super(message: message);
}

/// 表示认证相关的错误
class AuthFailure extends Failure {
  final String message;
  AuthFailure(this.message) : super(message: message);
}

/// 表示网络连接错误
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Network connection failed'})
      : super(message: message);
}

/// 表示一个简单的、通用的失败情况，通常只包含一个错误消息。
class SimpleFailure extends Failure {
  final String message;
  /*const*/ SimpleFailure(this.message) : super(message: message); // Removed const
}

/// 表示一个通用的、未指定类型的失败情况。
class GeneralFailure extends Failure {
  final String message;
  GeneralFailure({required this.message}) : super(message: message); // Removed const
}

/// Represents a failure during input validation.
class ValidationFailure extends Failure {
  const ValidationFailure({required String message})
      : super(message: message);
}

/// Represents an authentication-specific failure (e.g., invalid credentials, expired token).
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required String message})
      : super(message: message);
}

/// Represents an unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({String message = 'An unknown error occurred'})
      : super(message: message);
}

// 未来可以根据需要添加其他特定的 Failure 类型，例如：
// class NetworkFailure extends Failure {}
// class AuthenticationFailure extends Failure {} 
