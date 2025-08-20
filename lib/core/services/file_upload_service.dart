import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../error/failures.dart';

/// 文件上传结果
class FileUploadResult {
  final String url;
  final String fileName;

  FileUploadResult({
    required this.url,
    required this.fileName,
  });

  factory FileUploadResult.fromJson(Map<String, dynamic> json) {
    // 处理不同的响应格式
    // 有些接口返回 url 和 fileName
    // 有些接口可能返回其他字段名
    return FileUploadResult(
      url: json['url'] as String? ?? json['fileUrl'] as String? ?? '',
      fileName: json['fileName'] as String? ?? json['name'] as String? ?? 'file',
    );
  }
}

/// 文件上传服务接口
abstract class IFileUploadService {
  /// 上传单个文件
  Future<Either<Failure, FileUploadResult>> uploadFile(String filePath);
  
  /// 上传单个文件（带进度回调）
  Future<Either<Failure, FileUploadResult>> uploadFileWithProgress(
    String filePath,
    Function(double progress)? onProgress,
  );
  
  /// 上传多个文件
  Future<Either<Failure, List<FileUploadResult>>> uploadFiles(List<String> filePaths);
}

/// 文件上传服务实现
@LazySingleton(as: IFileUploadService)
class FileUploadService implements IFileUploadService {
  final Dio _dio;

  FileUploadService(this._dio);

  @override
  Future<Either<Failure, FileUploadResult>> uploadFile(String filePath) async {
    return uploadFileWithProgress(filePath, null);
  }

  @override
  Future<Either<Failure, FileUploadResult>> uploadFileWithProgress(
    String filePath,
    Function(double progress)? onProgress,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(ClientFailure(message: '文件不存在: $filePath'));
      }

      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/common/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60), // 60秒发送超时
          receiveTimeout: const Duration(seconds: 60), // 60秒接收超时
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            final progress = sent / total;
            onProgress(progress);
          }
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['code'] == 200 && data['data'] != null) {
          return Right(FileUploadResult.fromJson(data['data']));
        } else {
          return Left(ServerFailure(message: data['msg'] ?? '文件上传失败'));
        }
      } else {
        return Left(ServerFailure(message: '文件上传失败'));
      }
    } on DioException catch (e) {
      print('文件上传失败: ${e.message}');
      return Left(NetworkFailure(message: e.message ?? '网络错误'));
    } catch (e) {
      print('文件上传出错: $e');
      return Left(UnknownFailure(message: '文件上传出错: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FileUploadResult>>> uploadFiles(List<String> filePaths) async {
    try {
      final List<MultipartFile> files = [];
      
      for (final filePath in filePaths) {
        final file = File(filePath);
        if (!await file.exists()) {
          return Left(ClientFailure(message: '文件不存在: $filePath'));
        }
        
        final fileName = filePath.split('/').last;
        files.add(await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ));
      }

      final formData = FormData.fromMap({
        'files': files,
      });

      final response = await _dio.post(
        '/common/uploads',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60), // 60秒发送超时
          receiveTimeout: const Duration(seconds: 60), // 60秒接收超时
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['code'] == 200) {
          // 解析返回的多个文件信息
          final urls = (data['urls'] as String).split(',');
          final fileNames = (data['fileNames'] as String).split(',');
          
          final results = <FileUploadResult>[];
          for (int i = 0; i < urls.length && i < fileNames.length; i++) {
            results.add(FileUploadResult(
              url: urls[i],
              fileName: fileNames[i],
            ));
          }
          
          return Right(results);
        } else {
          return Left(ServerFailure(message: data['msg'] ?? '文件上传失败'));
        }
      } else {
        return Left(ServerFailure(message: '文件上传失败'));
      }
    } on DioException catch (e) {
      print('文件上传失败: ${e.message}');
      return Left(NetworkFailure(message: e.message ?? '网络错误'));
    } catch (e) {
      print('文件上传出错: $e');
      return Left(UnknownFailure(message: '文件上传出错: $e'));
    }
  }
}