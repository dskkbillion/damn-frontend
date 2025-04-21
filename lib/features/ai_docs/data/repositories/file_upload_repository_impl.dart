import 'dart:io';

import 'package:dartz/dartz.dart';
// import '../datasources/i_file_upload_remote_data_source.dart'; // Keep import for type checking

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/i_file_upload_repository.dart';

/// {@template file_upload_repository_impl}
/// Implementation of [IFileUploadRepository].
/// {@endtemplate}
// Temporarily comment out injectable annotation to avoid build errors
// @LazySingleton(as: IFileUploadRepository)
class FileUploadRepositoryImpl implements IFileUploadRepository {
  final IFileUploadRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  /// {@macro file_upload_repository_impl}
  FileUploadRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> uploadFile(File file, {String? fileTypeHint}) async {
    if (await networkInfo.isConnected) {
      try {
        final fileUrl = await remoteDataSource.uploadFile(file, fileTypeHint: fileTypeHint);
        return Right(fileUrl);
      } on ServerException catch (e) {
         // Map ServerException to ServerFailure
         return Left(ServerFailure(message: e.message, code: e.statusCode)); // Use statusCode
      } on Exception catch (e) {
         // Handle other potential exceptions (e.g., file system errors before upload)
         print('uploadFile Unexpected Exception: $e');
         return Left(ServerFailure(message: e.toString())); // Or a more specific Failure
      }
    } else {
       return Left(const NetworkFailure()); // Use NetworkFailure
    }
  }
} 