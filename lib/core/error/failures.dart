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
  const Failure();

  @override
  List<Object?> get props => [];
}

// General failures

/// Represents a failure originating from the server (e.g., API error responses).
class ServerFailure extends Failure {
  final String message;
  final int? statusCode;

  const ServerFailure({this.message = 'Server Failure', this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a failure related to network connectivity.
class NetworkFailure extends Failure {
    final String message;

    const NetworkFailure({this.message = 'Network Failure'});

    @override
    List<Object?> get props => [message];
}

/// Represents a failure originating from local cache operations.
class CacheFailure extends Failure {
  final String message;

  const CacheFailure({this.message = 'Cache Failure'});

   @override
  List<Object?> get props => [message];
}

/// Represents an unexpected failure during data processing or other operations.
class GeneralFailure extends Failure {
  final String message;

  const GeneralFailure({this.message = 'An unexpected error occurred'});

  @override
  List<Object?> get props => [message];
} 