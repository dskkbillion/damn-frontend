import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_user_profile_repository.dart';

/// 上传用户头像
class UploadAvatarUseCase implements UseCase<String, UploadAvatarParams> {
  final IUserProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadAvatarParams params) {
    return repository.uploadAvatar(params.imageFile);
  }
}

/// 上传头像的参数
class UploadAvatarParams extends Equatable {
  final File imageFile;

  const UploadAvatarParams({
    required this.imageFile,
  });

  @override
  List<Object?> get props => [imageFile];
}
