import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core Error Handling
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import core exceptions
import 'package:dskk_flutter_refactor/core/error/failures.dart';

// Domain Layer
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';

// Data Layer
import '../datasources/i_file_upload_data_source.dart'; // Corrected import path/filename

/// {@template file_upload_repository_impl}
/// Implementation of [IFileUploadRepository].
/// {@endtemplate}
@LazySingleton(as: IFileUploadRepository)
class FileUploadRepositoryImpl implements IFileUploadRepository {
  final IFileUploadDataSource _dataSource; // Corrected type and name

  /// {@macro file_upload_repository_impl}
  // Corrected constructor type and parameter name
  FileUploadRepositoryImpl({required IFileUploadDataSource dataSource}) 
      : _dataSource = dataSource;

  // Reusing a similar try-catch helper for consistency
  Future<Either<Failure, T>> _tryCatch<T>(
    Future<T> Function() action,
  ) async {
    try {
      final result = await action();
      return Right(result);
    } on ServerException catch (e) {
      // Corrected: Use ServerFailure from core and provide default message
      return Left(ServerFailure(message: e.message ?? '文件上传服务器错误')); 
    } on NetworkException {
      // Corrected: Use NetworkFailure from core
      return Left(NetworkFailure(message: '网络连接失败，无法上传文件')); 
    } on CacheException {
      // Corrected: Add message
      return Left(CacheFailure(message: '文件上传缓存错误')); 
    } on DataSourceException catch (e) { // Assuming DataSourceException exists in core
      print('DataSourceException in FileUploadRepository: ${e.message}');
      // Corrected: Use GeneralFailure
      return Left(GeneralFailure(message: 'File upload data source error: ${e.message}')); 
    } catch (e, stacktrace) {
      print('Unexpected error in FileUploadRepository: $e\n$stacktrace');
      // Corrected: Use GeneralFailure
      return Left(GeneralFailure(message: 'An unexpected error occurred during file upload: ${e.toString()}')); 
    }
  }

  @override
  Future<Either<Failure, String>> uploadFile(File file) async {
    // Basic validation (e.g., check if file exists)
    if (!await file.exists()) {
      // Corrected: Use GeneralFailure
      return Left(GeneralFailure(message: 'File does not exist: ${file.path}')); 
    }
    
    return _tryCatch<String>(() async {
      // Use the corrected data source field
      return await _dataSource.uploadFile(file);
    });
  }
} 