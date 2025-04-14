import 'dart:io';

import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../repositories/i_chat_repository.dart';

/// 上传文件用例。
class UploadFileUseCase {
  final IChatRepository _repository;

  UploadFileUseCase(this._repository);

  /// 调用此 UseCase 上传文件。
  /// [params] 包含要上传的文件和可选的进度回调。
  /// 成功时返回文件的 URL。
  /// 失败时返回 `Left(Failure)`。
  Future<Either<Failure, String>> call(UploadFileParams params) {
    return _repository.uploadFile(params.file, onProgress: params.onProgress);
  }
}

/// UploadFileUseCase 的参数
class UploadFileParams {
  final File file;
  final Function(double)? onProgress;

  UploadFileParams({required this.file, this.onProgress});
} 