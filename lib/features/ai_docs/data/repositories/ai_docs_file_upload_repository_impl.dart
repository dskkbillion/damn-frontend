import 'dart:io';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core Error Handling
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import core exceptions
import 'package:dskk_flutter_refactor/core/error/failures.dart';

// Domain Layer
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';

// Data Layer
import '../datasources/i_file_upload_data_source.dart'; // 引入数据源接口
import '../datasources/exceptions.dart' as ds_exceptions; // 导入数据源特定异常

/// {@template ai_docs_file_upload_repository_impl}
/// AI文档模块专用的文件上传仓库实现。
/// 实现了[IFileUploadRepository]接口，提供文件上传功能。
/// {@endtemplate}
@LazySingleton(as: IFileUploadRepository)
class AiDocsFileUploadRepositoryImpl implements IFileUploadRepository {
  final IFileUploadDataSource _dataSource;

  /// {@macro ai_docs_file_upload_repository_impl}
  AiDocsFileUploadRepositoryImpl({required IFileUploadDataSource dataSource}) 
      : _dataSource = dataSource;

  // 错误处理辅助方法
  Future<Either<Failure, T>> _tryCatch<T>(
    Future<T> Function() action,
  ) async {
    try {
      final result = await action();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '文件上传服务器错误')); 
    } on NetworkException {
      return const Left(NetworkFailure(message: '网络连接失败，无法上传文件')); 
    } on CacheException {
      return const Left(CacheFailure(message: '文件上传缓存错误')); 
    } on ds_exceptions.ServerException catch (e) {
      AppLogger.d('[AiDocs] 服务器异常: ${e.message}');
      return Left(ServerFailure(message: e.message ?? '文件上传服务器错误', code: e.statusCode?.toString())); 
    } on ds_exceptions.NetworkException catch (e) {
      AppLogger.d('[AiDocs] 网络异常: ${e.message}');
      return Left(NetworkFailure(message: e.message ?? '网络连接失败，无法上传文件')); 
    } on ds_exceptions.DataSourceException catch (e) { 
      AppLogger.d('[AiDocs] 数据源异常: ${e.message}');
      return Left(GeneralFailure(message: '文件上传数据源错误: ${e.message}')); 
    } catch (e, stacktrace) {
      AppLogger.d('[AiDocs] 未预期异常: $e\n$stacktrace');
      return Left(GeneralFailure(message: '文件上传过程中发生未预期错误: ${e.toString()}')); 
    }
  }

  @override
  Future<Either<Failure, String>> uploadFile(File file) async {
    // 基本验证（检查文件是否存在）
    if (!await file.exists()) {
      return Left(GeneralFailure(message: '文件不存在: ${file.path}')); 
    }
    
    // 文件大小检查
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) { // 10MB上限
      return Left(GeneralFailure(message: '文件大小超过限制: ${fileSize / (1024 * 1024)}MB，最大允许10MB')); 
    }
    
    AppLogger.d('[AiDocs] 开始上传文件: ${file.path}, 大小: ${fileSize / 1024}KB');
    
    return _tryCatch<String>(() async {
      return await _dataSource.uploadFile(file);
    });
  }
} 