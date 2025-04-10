import 'package:equatable/equatable.dart';

/// {@template failure}
/// A base class for representing failures in the application.
///
/// Failures are typically used with the Either type from dartz package
/// to represent operations that can fail.
/// {@endtemplate}
abstract class Failure extends Equatable {
  /// {@macro failure}
  // If you want Failures to have a default message or properties, define them here.
  // const Failure([List properties = const <dynamic>[]]);
  final String message;
  final String code;

  const Failure({
    required this.message,
    required this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// General failures

/// Represents a failure originating from the server (e.g., API error responses).
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String code = 'SERVER_ERROR',
  }) : super(message: message, code: code);
}

/// Represents a failure related to network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String code = 'NETWORK_ERROR',
  }) : super(message: message, code: code);
}

/// Represents a failure originating from local cache operations.
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String code = 'CACHE_ERROR',
  }) : super(message: message, code: code);
}

/// Represents an unexpected failure during data processing or other operations.
class GeneralFailure extends Failure {
  const GeneralFailure({
    String message = 'An unexpected error occurred',
    String code = 'GENERAL_ERROR',
  }) : super(message: message, code: code);
}

/// 聊天错误
class ChatFailure extends Failure {
  const ChatFailure({
    required String message,
    required String code,
  }) : super(message: message, code: code);
}

/// 未授权错误
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    required String message,
    String code = 'UNAUTHORIZED',
  }) : super(message: message, code: code);
}

/// 无效输入错误
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({
    required String message,
    String code = 'INVALID_INPUT',
  }) : super(message: message, code: code);
} 