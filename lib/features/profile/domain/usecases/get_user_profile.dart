import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/i_user_profile_repository.dart';

/// 获取当前用户的个人资料
@lazySingleton
class GetUserProfileUseCase implements UseCase<UserProfile, NoParams> {
  final IUserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) {
    return repository.getUserProfile();
  }
}
