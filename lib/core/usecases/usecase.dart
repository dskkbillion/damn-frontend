import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// 定义 Use Case 的通用契约。
///
/// [Type] 是 Use Case 成功执行时返回的数据类型。
/// [Params] 是执行 Use Case 所需的输入参数类型。
/// 如果 Use Case 不需要参数，可以使用 [NoParams]。
abstract class UseCase<Type, Params> {
  /// 执行 Use Case 的核心方法。
  Future<Either<Failure, Type>> call(Params params);
}

/// 用于表示 Use Case 不需要任何输入参数的情况。
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
} 