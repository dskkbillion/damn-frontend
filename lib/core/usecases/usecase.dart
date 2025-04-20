import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// {@template usecase}
/// Base class for UseCases in the application.
///
/// Defines a standard way to execute a use case, typically involving a call method.
/// [Type] represents the return type of the use case (the success type).
/// [Params] represents the parameters required to execute the use case.
/// {@endtemplate}
abstract class UseCase<Type, Params> {
  /// Executes the use case.
  ///
  /// Returns an [Either] containing either a [Failure] or the expected [Type].
  Future<Either<Failure, Type>> call(Params params);
}

/// A specific implementation for use cases that don't require parameters.
abstract class UseCaseWithoutParams<Type> {
  /// Executes the use case without parameters.
  Future<Either<Failure, Type>> call();
}

/// {@template noparams}
/// A helper class representing the absence of parameters for a use case.
/// {@endtemplate}
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
} 