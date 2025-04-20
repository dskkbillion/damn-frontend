// import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../models/transaction_dto.dart';
import '../models/user_profile_dto.dart';
import '../models/wallet_summary_dto.dart';
import '../models/saved_item_dto.dart';
import '../models/liked_story_dto.dart';
import '../../domain/repositories/i_user_profile_repository.dart';

/// 远程数据源抽象接口
abstract class ProfileRemoteDataSource {
  /// 获取用户个人资料
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<UserProfileDto> getUserProfile();

  /// 更新用户个人资料
  ///
  /// 必需参数：
  /// * [nickName] - 新的昵称
  /// * [onlineFlag] - 新的在线状态
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<UserProfileDto> updateUserProfile({
    required String nickName,
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
    int page = 1,
    int pageSize = 20,
    String? startDate,
    String? endDate,
    String transactionType = 'all',
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
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  final String token;
  final String userId;

  ProfileRemoteDataSourceImpl({
    required this.dio,
    required this.token,
    required this.userId,
  }) {
    // 添加认证token到请求头
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  Future<UserProfileDto> getUserProfile() async {
    try {
      final response = await dio.get('/api/user/profile');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] == 200 && data['data'] != null) {
          return UserProfileDto.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? '获取用户信息失败',
            statusCode: data['code'],
          );
        }
      } else {
        throw ServerException(
          message: '获取用户信息失败，状态码: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserProfileDto> updateUserProfile({
    required String nickName,
    bool? onlineFlag,
  }) async {
    try {
      final data = {
        'nickName': nickName,
        if (onlineFlag != null) 'onlineFlag': onlineFlag,
      };

      final response = await dio.put('/api/user/profile', data: data);

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['code'] == 200 && responseData['data'] != null) {
          return UserProfileDto.fromJson(responseData['data']);
        } else {
          throw ServerException(
            message: responseData['message'] ?? '更新用户信息失败',
            statusCode: responseData['code'],
          );
        }
      } else {
        throw ServerException(
          message: '更新用户信息失败，状态码: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadAvatar({required String imageFilePath}) async {
    try {
      final file = File(imageFilePath);

      if (!await file.exists()) {
        throw ServerException(message: '文件不存在: $imageFilePath');
      }

      final fileName = imageFilePath.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      // 确定文件类型
      String contentType;
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        default:
          contentType = 'application/octet-stream';
      }

      // 创建FormData对象
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFilePath,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      });

      final response = await dio.post(
        '/api/user/avatar',
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['code'] == 200 && responseData['data'] != null) {
          return responseData['data']['avatarUrl'] ?? '';
        } else {
          throw ServerException(
            message: responseData['message'] ?? '上传头像失败',
            statusCode: responseData['code'],
          );
        }
      } else {
        throw ServerException(
          message: '上传头像失败，状态码: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WalletSummaryDto> getWalletSummary() async {
    try {
      final response = await dio.get('/api/wallet/summary');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] == 200 && data['data'] != null) {
          return WalletSummaryDto.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? '获取钱包信息失败',
            statusCode: data['code'],
          );
        }
      } else {
        throw ServerException(
          message: '获取钱包信息失败，状态码: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<TransactionDto>> getWalletTransactions({
    int page = 1,
    int pageSize = 20,
    String? startDate,
    String? endDate,
    String transactionType = 'all',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': pageSize.toString(),
        'type': transactionType,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      };

      final response = await dio.get(
        '/api/wallet/transactions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] == 200 && data['data'] != null && data['data']['list'] != null) {
          final List<dynamic> transactionsList = data['data']['list'];
          return transactionsList
              .map((json) => TransactionDto.fromJson(json))
              .toList();
        } else {
          throw ServerException(
            message: data['message'] ?? '获取交易记录失败',
            statusCode: data['code'],
          );
        }
      } else {
        throw ServerException(
          message: '获取交易记录失败，状态码: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<SavedItemDto>> getSavedItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    // API实现待定
    throw UnimplementedError('getSavedItems API尚未实现');
  }

  @override
  Future<List<LikedStoryDto>> getLikedStories({
    int page = 1,
    int pageSize = 20,
  }) async {
    // API实现待定
    throw UnimplementedError('getLikedStories API尚未实现');
  }
}
