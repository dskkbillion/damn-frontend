import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/common_user.dart';
import '../repositories/i_favorites_repository.dart';

/// 关注卖家用例
class FollowSellerUseCase implements UseCase<void, CommonUser> {
  final IFavoritesRepository repository;

  /// 构造函数
  const FollowSellerUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CommonUser user) async {
    return await repository.followSeller(user);
  }
}