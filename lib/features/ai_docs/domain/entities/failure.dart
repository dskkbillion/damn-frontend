import 'package:equatable/equatable.dart';

/// {@template failure}
/// A base class for representing failures in the domain layer.
/// {@endtemplate}
abstract class Failure extends Equatable {
  /// {@macro failure}
  const Failure({this.message = 'An unexpected error occurred.'});

  /// The error message associated with the failure.
  final String message;

  @override
  List<Object> get props => [message];
}

/// Represents a failure originating from the server.
class ServerFailure extends Failure {
  /// Creates a server failure with an optional error [message].
  const ServerFailure({super.message = 'A server error occurred.'});
}

/// Represents a failure originating from the local cache.
class CacheFailure extends Failure {
  /// Creates a cache failure with an optional error [message].
  const CacheFailure({super.message = 'A cache error occurred.'});
}

/// Represents a failure related to network connectivity.
class NetworkFailure extends Failure {
  /// Creates a network failure with an optional error [message].
  const NetworkFailure({super.message = 'No internet connection.'});
}

/// Represents a failure due to invalid input data.
class InvalidInputFailure extends Failure {
  /// Creates an invalid input failure with a specific error [message].
  const InvalidInputFailure({required String message}) : super(message: message);
} 