import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

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

/// {@template noparams}
/// A helper class representing the absence of parameters for a use case.
/// {@endtemplate}
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
} 