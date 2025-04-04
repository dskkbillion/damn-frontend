import 'package:injectable/injectable.dart';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_file_upload_repository.dart';

/// {@template upload_file_usecase}
/// Use case for uploading a file.
/// Takes a local file and returns the URL of the uploaded file.
/// {@endtemplate}
@lazySingleton
class UploadFileUseCase implements UseCase<String, UploadFileParams> {
  final IFileUploadRepository repository;

  /// {@macro upload_file_usecase}
  UploadFileUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadFileParams params) async {
    // More validation could happen here (e.g., file size limits)
    return await repository.uploadFile(params.file);
  }
}

/// {@template upload_file_params}
/// Parameters required for uploading a file.
/// {@endtemplate}
class UploadFileParams extends Equatable {
  final File file;

  /// {@macro upload_file_params}
  const UploadFileParams({required this.file});

  @override
  List<Object?> get props => [file];
} 