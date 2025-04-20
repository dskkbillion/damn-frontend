import 'package:equatable/equatable.dart';

/// {@template failure}
/// A base class for representing failures in the application.
///
/// Failures are typically used with the Either type from dartz package
/// to represent operations that can fail.
/// {@endtemplate}
abstract class Failure extends Equatable {
  /// {@macro failure}
  // If you want Failures to always have a message, make it required
  final String message;

  const Failure({this.message = 'An unexpected error occurred'});

  // Subclasses should override props if they have properties to compare
  @override
  List<Object?> get props => [message];
}

// General failures

/// Represents a failure originating from the server (e.g., API error responses).
class ServerFailure extends Failure {
  final String? code;
  const ServerFailure({String message = 'Server Error', this.code}) : super(message: message);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'ServerFailure(message: $message, code: $code)';
}

/// Represents a failure related to network connectivity.
class NetworkFailure extends Failure {
  final String? code;
  const NetworkFailure({String message = 'Network Error', this.code}) : super(message: message);
}

/// Represents a failure originating from local cache operations.
class CacheFailure extends Failure {
  final String? code;
  const CacheFailure({String message = 'Cache Error', this.code}) : super(message: message);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'CacheFailure(message: $message, code: $code)';
}

/// Represents an unexpected failure during data processing or other operations.
class GeneralFailure extends Failure {
  final String code;
  const GeneralFailure({
    this.code = 'GENERAL_ERROR',
  }) : super(message: 'An unexpected error occurred');

  @override
  List<Object?> get props => [message, code];
}

/// 聊天错误
class ChatFailure extends Failure {
  final String code;
  const ChatFailure({
    required this.code,
  }) : super(message: 'Chat Error');

  @override
  List<Object?> get props => [message, code];
}

/// 未授权错误
class UnauthorizedFailure extends Failure {
  final String code;
  const UnauthorizedFailure({
    this.code = 'UNAUTHORIZED',
  }) : super(message: 'Unauthorized');

  @override
  List<Object?> get props => [message, code];
}

/// 无效输入错误
class InvalidInputFailure extends Failure {
  const InvalidInputFailure() : super(message: 'Invalid Input');
}

/// Represents a generic failure when no specific type is identified.
class GenericFailure extends Failure {
  const GenericFailure() : super(message: 'Generic Error');
}

// Specific failures (can add more as needed)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure() : super(message: 'Authentication Failed');
}

class ClientFailure extends Failure {
  const ClientFailure() : super(message: 'Client Error / Invalid Input');
} 