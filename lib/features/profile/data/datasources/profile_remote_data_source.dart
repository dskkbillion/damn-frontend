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
@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage storage;

  ProfileRemoteDataSourceImpl({required this.dio, required this.storage});

  @override
  Future<UserProfileDto> getUserProfile() async {
    try {
      final commonUserId = await storage.read(key: 'common_user_id');
      if (commonUserId == null || commonUserId.isEmpty) {
        throw ServerException(message: '无法获取通用用户 ID', statusCode: 401);
      }

      final path = '/api/member/profile/$commonUserId';
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
    required String nickName,
    bool? onlineFlag,
  }) async {
    try {
      final userId = await storage.read(key: 'user_id');
      if (userId == null || userId.isEmpty) {
        throw ServerException(message: '无法获取用户 ID', statusCode: 401);
      }

      final requestData = {
        'nickName': nickName,
        if (onlineFlag != null) 'onlineFlag': onlineFlag,
      };
      final response = await dio.post('/api/member/profile/$userId', data: requestData);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('code') && responseData['code'] == 200 && responseData['data'] != null) {
          if (responseData['data'] != null) {
            return UserProfileDto.fromJson(responseData['data']);
          } else {
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
      final userId = await storage.read(key: 'user_id');
      if (userId == null || userId.isEmpty) {
        throw ServerException(message: '无法获取用户 ID', statusCode: 401);
      }

      final file = File(imageFilePath);
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType("image", fileName.split('.').last),
        ),
      });

      final response = await dio.post('/api/member/profile/$userId/avatar', data: formData);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('code') && responseData['code'] == 200 && responseData['data']?['url'] != null) {
          return responseData['data']['url'];
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
      throw ServerException(message: e.message ?? '网络请求失败', statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WalletSummaryDto> getWalletSummary() async {
    try {
      final response = await dio.get('/api/user/member/wallet/info');

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
    int page = 1,
    int pageSize = 20,
    String? startDate,
    String? endDate,
    String transactionType = 'all',
  }) async {
    try {
      final queryParams = {
        'pageNum': page,
        'pageSize': pageSize,
        'type': transactionType == 'all' ? null : transactionType,
        'beginTime': startDate,
        'endTime': endDate,
      };
      queryParams.removeWhere((key, value) => value == null);

      final response = await dio.get('/api/user/member/wallet/record/page', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('code') && data['code'] == 200 && data['data']?['list'] != null) {
          final List<dynamic> transactionsList = data['data']['list'];
          return transactionsList
              .map((json) => TransactionDto.fromJson(json))
              .toList();
        } else {
          throw ServerException(
            message: (data is Map<String, dynamic> ? data['msg'] : null) ?? '获取交易记录失败',
            statusCode: (data is Map<String, dynamic> ? data['code'] : null),
          );
        }
      } else {
        throw ServerException(
          message: '获取交易记录失败，状态码: ${response.statusCode}',
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
