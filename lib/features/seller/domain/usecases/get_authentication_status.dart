import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';

/// 获取认证状态列表用例
@injectable
class GetAuthenticationStatus implements UseCase<List<SellerAuthenticationInfo>, NoParams> {
  final ISellerRepository _repository;

  /// 构造函数
  GetAuthenticationStatus(this._repository);

  @override
  Future<Either<Failure, List<SellerAuthenticationInfo>>> call(NoParams params) {
    return _repository.getAuthenticationStatus();
  }
}

/// 不需要参数
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
} 