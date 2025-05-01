import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/i_user_profile_repository.dart';

/// 更新用户的个人资料
@injectable
class UpdateUserProfileUseCase implements UseCase<UserProfile, UpdateUserProfileParams> {
  final IUserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateUserProfileParams params) {
    return repository.updateUserProfile(
      UserProfileUpdateData(
        nickName: params.nickName,
        onlineFlag: params.onlineFlag,
      ),
    );
  }
}

/// 更新用户资料的参数
class UpdateUserProfileParams extends Equatable {
  final String? nickName;
  final bool? onlineFlag;

  const UpdateUserProfileParams({
    this.nickName,
    this.onlineFlag,
  });

  @override
  List<Object?> get props => [nickName, onlineFlag];
}
