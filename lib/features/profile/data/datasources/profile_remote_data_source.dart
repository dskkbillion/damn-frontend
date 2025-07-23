// import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/transaction_dto.dart';
import '../models/user_profile_dto.dart';
import '../models/wallet_summary_dto.dart';
import '../models/saved_item_dto.dart';
import '../models/liked_story_dto.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/image_compress_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/wallet_summary.dart';

/// 远程数据源抽象接口
abstract class ProfileRemoteDataSource {
  /// 获取用户个人资料
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<UserProfileDto> getUserProfile();

  /// 更新用户个人资料
  ///
  /// 可选参数：
  /// * [nickName] - 新的昵称
  /// * [avatar] - 新的头像URL
  /// * [onlineFlag] - 新的在线状态
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<UserProfileDto> updateUserProfile({
    String? nickName,  // 改为可选参数
    String? avatar,    // 添加头像参数
    bool? onlineFlag,
  });

  /// 上传用户头像
  ///
  /// 必需参数：
  /// * [imageFilePath] - 图片文件路径
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<String> uploadAvatar({required String imageFilePath});

  /// 获取钱包摘要信息
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<WalletSummaryDto> getWalletSummary();

  /// 获取钱包交易记录
  ///
  /// 可选参数：
  /// * [page] - 页码，默认为1
  /// * [pageSize] - 每页记录数，默认为20
  /// * [startDate] - 开始日期，格式为YYYY-MM-DD
  /// * [endDate] - 结束日期，格式为YYYY-MM-DD
  /// * [transactionType] - 交易类型，可选值：'income', 'outcome', 'all'(默认)
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<List<TransactionDto>> getWalletTransactions({
    required int page,
    required int pageSize,
    String? startDate,
    String? endDate,
    required String transactionType,
  });

  /// 获取已收藏的故事列表
  ///
  /// 可选参数：
  /// * [page] - 页码，默认为1
  /// * [pageSize] - 每页记录数，默认为20
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<List<SavedItemDto>> getSavedItems({
    int page = 1,
    int pageSize = 20,
  });

  /// 获取已点赞的故事列表
  ///
  /// 可选参数：
  /// * [page] - 页码，默认为1
  /// * [pageSize] - 每页记录数，默认为20
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<List<LikedStoryDto>> getLikedStories({
    int page = 1,
    int pageSize = 20,
  });
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});
}

/// 用户资料远程数据源实现
@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage storage;
  final ImageCompressService imageCompressService;

  ProfileRemoteDataSourceImpl({
    required this.dio,
    required this.storage,
    required this.imageCompressService,
  });

  @override
  Future<UserProfileDto> getUserProfile() async {
    try {
      final path = '/api/member/info';
      print('Requesting user profile from: $path');

      final response = await dio.get(path);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('code') && data['code'] == 200 && data['data'] != null) {
          try {
            return UserProfileDto.fromJson(data['data']);
          } catch (e) {
            print("Error parsing UserProfileDto: $e");
            throw ServerException(message: "解析用户信息失败: ${e.toString()}");
          }
        } else {
          throw ServerException(
            message: (data is Map<String, dynamic> ? data['msg'] : null) ?? '获取用户信息失败(业务错误)',
            statusCode: (data is Map<String, dynamic> ? data['code'] : null),
          );
        }
      } else {
        throw ServerException(
          message: '获取用户信息失败，HTTP 状态码: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print("DioException in getUserProfile: ${e.response?.data}");
      throw ServerException(message: e.message ?? '网络请求失败', statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      print("Unexpected error in getUserProfile: $e");
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserProfileDto> updateUserProfile({
    String? nickName,  // 改为可选参数
    String? avatar,    // 添加头像参数
    bool? onlineFlag,
  }) async {
    try {
      final userId = await storage.read(key: 'user_id');
      if (userId == null || userId.isEmpty) {
        throw ServerException(message: '无法获取用户 ID', statusCode: 401);
      }

      final requestData = <String, dynamic>{};
      
      if (nickName != null) requestData['nickName'] = nickName;
      if (avatar != null) requestData['avatar'] = avatar;
      if (onlineFlag != null) requestData['onlineFlag'] = onlineFlag;
      
      // 使用后端的 /api/member/modify 接口
      final response = await dio.post('/api/member/modify', data: requestData);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('code') && responseData['code'] == 200) {
          // 检查是否返回了用户数据
          if (responseData['data'] != null && responseData['data'] is Map<String, dynamic>) {
            return UserProfileDto.fromJson(responseData['data']);
          } else {
            // 如果只返回成功消息，重新获取用户信息
            print('Update successful but no user data returned, fetching latest profile...');
            return await getUserProfile();
          }
        } else {
          throw ServerException(
            message: (responseData is Map<String, dynamic> ? responseData['msg'] : null) ?? '更新用户信息失败',
            statusCode: (responseData is Map<String, dynamic> ? responseData['code'] : null),
          );
        }
      } else {
        throw ServerException(
          message: '更新用户信息失败，状态码: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '网络请求失败', statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadAvatar({required String imageFilePath}) async {
    try {
      final file = File(imageFilePath);
      
      // 先压缩图片
      print('[ProfileRemoteDataSourceImpl] 开始压缩头像图片...');
      final compressedFile = await imageCompressService.compressAvatar(file);
      
      if (compressedFile == null) {
        throw ServerException(message: '图片压缩失败');
      }
      
      // 检查压缩后的文件大小
      final compressedSize = await compressedFile.length();
      print('[ProfileRemoteDataSourceImpl] 压缩后文件大小: ${_formatFileSize(compressedSize)}');
      
      // 如果压缩后仍然很大，进一步压缩到5MB以下
      File finalFile = compressedFile;
      if (compressedSize > 5 * 1024 * 1024) {
        print('[ProfileRemoteDataSourceImpl] 文件仍然较大，进一步压缩...');
        final furtherCompressed = await imageCompressService.compressToMaxSize(
          compressedFile,
          maxSizeBytes: 5 * 1024 * 1024, // 5MB
          maxWidth: 512,
          maxHeight: 512,
        );
        
        if (furtherCompressed != null) {
          finalFile = furtherCompressed;
          final finalSize = await finalFile.length();
          print('[ProfileRemoteDataSourceImpl] 最终文件大小: ${_formatFileSize(finalSize)}');
        }
      }
      
      // 创建FormData
      String fileName = 'avatar.jpg'; // 统一使用jpg格式
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          finalFile.path,
          filename: fileName,
          contentType: MediaType("image", "jpeg"),
        ),
      });

      // 使用正确的文件上传接口
      final response = await dio.post('/api/common/public/upload', data: formData);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && 
            responseData.containsKey('code') && 
            responseData['code'] == 200 && 
            responseData['data'] != null) {
          // 根据实际API响应结构获取图片URL
          final data = responseData['data'];
          if (data is Map<String, dynamic> && data.containsKey('url')) {
            return data['url'];
          } else if (data is String) {
            return data; // 如果直接返回URL字符串
          } else {
            throw ServerException(message: '上传响应格式错误');
          }
        } else {
          throw ServerException(
            message: (responseData is Map<String, dynamic> ? responseData['msg'] : null) ?? '上传头像失败',
            statusCode: (responseData is Map<String, dynamic> ? responseData['code'] : null),
          );
        }
      } else {
        throw ServerException(
          message: '上传头像失败，状态码: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // 提供更详细的错误信息
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException(message: '上传超时，请检查网络连接或尝试压缩图片');
      } else if (e.response?.statusCode == 413) {
        throw ServerException(message: '图片文件过大，请选择较小的图片');
      } else if (e.response?.statusCode == 415) {
        throw ServerException(message: '不支持的图片格式，请选择JPG或PNG格式');
      } else {
        throw ServerException(message: e.message ?? '网络请求失败', statusCode: e.response?.statusCode);
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
  
  /// 格式化文件大小显示
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  @override
  Future<WalletSummaryDto> getWalletSummary() async {
    try {
      // 尝试获取用户ID
      final userId = await storage.read(key: 'user_id');
      final commonUserId = await storage.read(key: 'common_user_id');
      final actualUserId = commonUserId ?? userId;
      
      // 更新API路径为正确的路径
      final response = await dio.get('/api/member/balance/info');
      
      // 打印调试信息
      print('Requesting wallet info from: /api/member/balance/info');
      print('Available user IDs - userId: $userId, commonUserId: $commonUserId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('code') && data['code'] == 200 && data['data'] != null) {
          return WalletSummaryDto.fromJson(data['data']);
        } else {
          throw ServerException(
            message: (data is Map<String, dynamic> ? data['msg'] : null) ?? '获取钱包信息失败',
            statusCode: (data is Map<String, dynamic> ? data['code'] : null),
          );
        }
      } else {
        throw ServerException(
          message: '获取钱包信息失败，状态码: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '网络请求失败', statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<TransactionDto>> getWalletTransactions({
    required int page,
    required int pageSize,
    String? startDate,
    String? endDate,
    required String transactionType,
  }) async {
    try {
      // 构建查询参数
      final queryParams = {
        'pageNum': page.toString(), // 使用pageNum而不是page
        'pageSize': pageSize.toString(),
      };

      if (startDate != null) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate;
      }
      if (transactionType != 'all') {
        queryParams['type'] = transactionType;
      }

      // 临时返回模拟数据，因为API不存在
      print('交易记录API未实现，返回模拟数据');
      // 延迟1秒模拟网络请求
      await Future.delayed(const Duration(seconds: 1));
      
      // 返回空列表，表示暂无交易记录
      return [];
      
      // 注释掉错误的API调用代码
      /*
      final response = await dio.get(
        '/api/member/balance/record/page',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && 
            responseData.containsKey('code') && 
            responseData['code'] == 200 && 
            responseData['data'] != null) {
          
          final data = responseData['data'];
          if (data is Map<String, dynamic> && 
              data.containsKey('rows') && 
              data['rows'] is List) {
            final transactionsList = data['rows'] as List;
          return transactionsList
              .map((json) => TransactionDto.fromJson(json))
              .toList();
          }
        }
      }
      
      // 如果没有有效的响应数据，返回空列表
      return [];
      */
    } catch (e) {
      print('获取交易记录失败: $e');
      throw ServerException(
        message: '获取交易记录失败: $e',
        statusCode: e is DioException ? e.response?.statusCode : null,
      );
    }
  }

  @override
  Future<List<SavedItemDto>> getSavedItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    throw UnimplementedError('getSavedItems API尚未实现');
  }

  @override
  Future<List<LikedStoryDto>> getLikedStories({
    int page = 1,
    int pageSize = 20,
  }) async {
    throw UnimplementedError('getLikedStories API尚未实现');
  }
}
