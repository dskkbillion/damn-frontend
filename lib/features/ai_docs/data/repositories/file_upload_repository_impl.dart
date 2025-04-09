import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_file_upload_repository.dart';
import '../datasources/exceptions.dart';
import '../datasources/i_file_upload_data_source.dart';

/// {@template file_upload_repository_impl}
/// Implementation of [IFileUploadRepository].
/// {@endtemplate}
@LazySingleton(as: IFileUploadRepository)
class FileUploadRepositoryImpl implements IFileUploadRepository {
  final IFileUploadDataSource dataSource;
  // final INetworkInfo networkInfo; // Optional for connectivity check

  /// {@macro file_upload_repository_impl}
  FileUploadRepositoryImpl({required this.dataSource});

  // Reusing a similar try-catch helper for consistency
  Future<Either<Failure, T>> _tryCatch<T>(
    Future<T> Function() action,
  ) async {
    // Optional: Check network connectivity first
    // if (!await networkInfo.isConnected) {
    //   return Left(NetworkFailure(message: 'No internet connection'));
    // }
    try {
      final result = await action();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on DataSourceException catch (e) {
      print('DataSourceException in FileUploadRepository: ${e.message}');
      return Left(UnknownFailure(message: 'File upload data source error: ${e.message}'));
    } catch (e, stacktrace) {
      print('Unexpected error in FileUploadRepository: $e\n$stacktrace');
      return Left(UnknownFailure(message: 'An unexpected error occurred during file upload: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadFile(File file) async {
    // Basic validation (e.g., check if file exists)
    if (!await file.exists()) {
      return Left(ValidationFailure(message: 'File does not exist: ${file.path}'));
    }

    return _tryCatch<String>(() async {
      return await dataSource.uploadFile(file);
    });
  }
}
