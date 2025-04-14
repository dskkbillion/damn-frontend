import 'package:equatable/equatable.dart';

/// {@template failure}
/// A base class for representing failures in the application.
///
/// Failures are typically used with the Either type from dartz package
/// to represent operations that can fail.
/// {@endtemplate}
abstract class Failure extends Equatable {
  /// {@macro failure}
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

// General failures

/// Represents a failure originating from the server (e.g., API error responses).
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required String message, this.statusCode})
      : super(message: message);

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a failure related to network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

/// Represents a failure originating from local cache operations.
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

/// Represents a failure during authentication or authorization.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required String message}) : super(message: message);
}

/// Represents a failure during data parsing (e.g., JSON deserialization).
class ParsingFailure extends Failure {
  const ParsingFailure({required String message}) : super(message: message);
}

/// Represents an unexpected failure not covered by other specific types.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required String message}) : super(message: message);
} 