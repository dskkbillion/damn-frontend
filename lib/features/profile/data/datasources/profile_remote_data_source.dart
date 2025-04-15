import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../models/user_profile_dto.dart';
import '../models/wallet_summary_dto.dart';
import '../models/saved_item_dto.dart';
import '../models/liked_story_dto.dart';
import '../../domain/repositories/i_user_profile_repository.dart';

/// 远程数据源抽象接口
abstract class ProfileRemoteDataSource {
  /// 获取用户个人资料
  Future<UserProfileDto> getUserProfile();

  /// 更新用户个人资料
  Future<UserProfileDto> updateUserProfile(UserProfileUpdateData data);

  /// 上传用户头像
  Future<String> uploadAvatar(File imageFile);

  /// 获取钱包摘要信息
  Future<WalletSummaryDto> getWalletSummary();

  /// 获取用户收藏列表
  Future<List<SavedItemDto>> getSavedItems({
    required int page,
    required int pageSize,
  });

  /// 获取用户点赞笔记列表
  Future<List<LikedStoryDto>> getLikedStories({
    required int page,
    required int pageSize,
  });
}

/// 远程数据源实现
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserProfileDto> getUserProfile() async {
    try {
      final response = await dio.get('/api/user/member/profile');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return UserProfileDto.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '获取用户资料失败',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? '网络错误',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserProfileDto> updateUserProfile(UserProfileUpdateData data) async {
    try {
      final Map<String, dynamic> body = {};
      if (data.nickName != null) body['nickName'] = data.nickName;
      if (data.onlineFlag != null) body['onlineFlag'] = data.onlineFlag;

      final response = await dio.post(
        '/api/user/member/update',
        data: body,
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        return UserProfileDto.fromJson(responseData);
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '更新用户资料失败',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? '网络错误',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final fileExt = fileName.split('.').last.toLowerCase();

      // 创建 FormData 对象
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', fileExt),
        ),
        'type': 'avatar',
      });

      final response = await dio.post(
        '/api/common/public/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null && data['url'] != null) {
          return data['url'];
        } else {
          throw ServerException(message: '无效的上传响应');
        }
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '上传头像失败',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? '网络错误',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WalletSummaryDto> getWalletSummary() async {
    try {
      final response = await dio.get('/api/user/member/wallet/info');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return WalletSummaryDto.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '获取钱包摘要失败',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? '网络错误',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<SavedItemDto>> getSavedItems({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await dio.get(
        '/api/user/member/favorite/list',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['data']['list'] ?? [];
        return items.map((item) => SavedItemDto.fromJson(item)).toList();
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '获取收藏列表失败',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? '网络错误',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<LikedStoryDto>> getLikedStories({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await dio.get(
        '/api/user/member/liked/stories',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['data']['list'] ?? [];
        return items.map((item) => LikedStoryDto.fromJson(item)).toList();
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '获取点赞笔记列表失败',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? '网络错误',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

/// 服务器异常
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}
