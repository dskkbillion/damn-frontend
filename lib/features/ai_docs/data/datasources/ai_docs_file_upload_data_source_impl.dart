import 'dart:io';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/network/i_http_client.dart';
import 'i_file_upload_data_source.dart';
import 'exceptions.dart' as ds_exceptions;

/// {@template ai_docs_file_upload_data_source_impl}
/// AI文档模块专用的文件上传数据源实现。
/// 使用[IHttpClient]进行文件上传操作。
/// {@endtemplate}
@LazySingleton(as: IFileUploadDataSource)
class AiDocsFileUploadDataSourceImpl implements IFileUploadDataSource {
  final IHttpClient _httpClient;

  /// {@macro ai_docs_file_upload_data_source_impl}
  AiDocsFileUploadDataSourceImpl(this._httpClient);

  @override
  Future<String> uploadFile(File file) async {
    // 定义上传路径
    const String uploadPath = '/api/common/public/upload';
    // 从环境变量获取后端基础URL
    final String? backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
      throw Exception('BACKEND_BASE_URL environment variable is not set');
    }

    // 构造完整URL
    final String fullUrl = backendBaseUrl + uploadPath;
    AppLogger.d("[AiDocs] 上传文件到: $fullUrl，文件大小: ${await file.length() / 1024} KB");
    
    try {
      // 调用postMultipart上传文件
      final response = await _httpClient.postMultipart(
        fullUrl, 
        file,
      );

      // 打印响应内容，便于调试
      AppLogger.d("[AiDocs] 文件上传响应: $response");

      // 处理响应
      final int code = response['code'] ?? 500;
      final dynamic data = response['data'];
      final String? message = response['message']?.toString() ?? response['msg']?.toString();

      if (code == 200 && data != null) {
        // 适配不同的响应格式
        if (data is Map) {
          // 尝试读取各种可能的URL字段名
          if (data['url'] is String) {
            return data['url'];
          } else if (data['file_url'] is String) {
            return data['file_url'];
          } else if (data['fileUrl'] is String) {
            return data['fileUrl'];
          } else if (data['path'] is String) {
            return data['path'];
          } else {
            // 如果找不到合适的字段，尝试寻找任何以url结尾的字段
            for (var key in data.keys) {
              if (key.toLowerCase().endsWith('url') && data[key] is String) {
                return data[key];
              }
            }
            
            // 打印所有字段，帮助调试
            AppLogger.d("[AiDocs] 无法在响应中找到URL，可用字段: ${data.keys.toList()}");
            throw ds_exceptions.ServerException(
              message: "文件上传成功但无法从响应中找到URL",
              statusCode: code
            );
          }
        } else if (data is String && data.startsWith('http')) {
          // 如果data直接是个URL字符串
          return data;
        }
      }
      
      // 如果没有返回，则抛出异常
      throw ds_exceptions.ServerException(
        message: message ?? '文件上传失败: 无效的响应格式',
        statusCode: code
      );
    } on ds_exceptions.NetworkException catch (e) {
      AppLogger.d("[AiDocs] 上传文件网络异常: $e");
      throw ds_exceptions.NetworkException(message: "文件上传网络错误: ${e.message}");
    } on ds_exceptions.ServerException catch (e) {
      AppLogger.d("[AiDocs] 上传文件服务器异常: $e");
      throw ds_exceptions.ServerException(
        message: "文件上传服务器错误: ${e.message}", 
        statusCode: e.statusCode
      );
    } catch (e) {
      AppLogger.d("[AiDocs] 上传文件未预期异常: $e");
      throw ds_exceptions.DataSourceException(message: "文件上传未预期错误: ${e.toString()}");
    }
  }
} 