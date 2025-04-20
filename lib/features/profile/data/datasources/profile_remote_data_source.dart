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
  Future<List<Map<String, dynamic>>> getLikedStories({
    int page = 1,
    int pageSize = 20,
  });

  /// 获取已保存的商品列表
  ///
  /// 可选参数：
  /// * [page] - 页码，默认为1
  /// * [pageSize] - 每页记录数，默认为20
  ///
  /// 如果服务器返回非200状态码，则抛出 [ServerException]
  Future<List<Map<String, dynamic>>> getSavedItems({
    int page = 1,
    int pageSize = 20,
  });
}

/// 远程数据源实现
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserProfileDto> getUserProfile() async {
    try {
      // Mock data for development
      await Future.delayed(const Duration(milliseconds: 800));
      return const UserProfileDto(
        userId: '12345',
        nickName: '张小花',
        avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        onlineFlag: true,
      );

      // Actual implementation would be:
      // final response = await dio.get('/api/user/profile');
      // if (response.statusCode == 200) {
      //   return UserProfileDto.fromJson(response.data);
      // } else {
      //   throw ServerException(
      //     message: response.data['message'] ?? '获取用户资料失败',
      //   );
      // }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserProfileDto> updateUserProfile({
    required String nickName,
    bool? onlineFlag,
  }) async {
    try {
      // Mock data for development
      await Future.delayed(const Duration(milliseconds: 800));
      return UserProfileDto(
        userId: '12345',
        nickName: nickName,
        avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        onlineFlag: onlineFlag ?? true,
      );

      // Actual implementation would be:
      // final response = await dio.put(
      //   '/api/user/profile',
      //   data: {
      //     'nickName': nickName,
      //     if (onlineFlag != null) 'onlineFlag': onlineFlag,
      //   },
      // );
      // if (response.statusCode == 200) {
      //   return UserProfileDto.fromJson(response.data);
      // } else {
      //   throw ServerException(
      //     message: response.data['message'] ?? '更新用户资料失败',
      //   );
      // }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadAvatar({required String imageFilePath}) async {
    try {
      // Mock data for development
      await Future.delayed(const Duration(milliseconds: 1200));
      return 'https://randomuser.me/api/portraits/women/33.jpg';

      // Actual implementation would be:
      // final formData = FormData.fromMap({
      //   'avatar': await MultipartFile.fromFile(imageFilePath),
      // });
      // final response = await dio.post(
      //   '/api/user/avatar',
      //   data: formData,
      // );
      // if (response.statusCode == 200) {
      //   return response.data['avatarUrl'];
      // } else {
      //   throw ServerException(
      //     message: response.data['message'] ?? '上传头像失败',
      //   );
      // }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WalletSummaryDto> getWalletSummary() async {
    try {
      // Mock data for development
      await Future.delayed(const Duration(milliseconds: 500));
      return const WalletSummaryDto(
        balance: 2345.67,
        pendingAmount: 123.45,
        totalIncome: 15678.90,
      );

      // Actual implementation would be:
      // final response = await dio.get('/api/wallet/summary');
      // if (response.statusCode == 200) {
      //   return WalletSummaryDto.fromJson(response.data);
      // } else {
      //   throw ServerException(
      //     message: response.data['message'] ?? '获取钱包信息失败',
      //   );
      // }
    } catch (e) {
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
      // Mock data for development
      await Future.delayed(const Duration(milliseconds: 700));

      // Generate some random transactions
      return List.generate(
        pageSize,
        (index) => TransactionDto(
          id: 'TR${10000 + index + (page - 1) * pageSize}',
          amount: (index % 2 == 0 ? 1 : -1) * ((index + 1) * 25 + 10.99),
          type: index % 2 == 0 ? 'income' : 'outcome',
          description: index % 2 == 0 ? '收到付款' : '购买商品',
          date: DateTime.now().subtract(Duration(days: index)),
          status: 'completed',
        ),
      );

      // Actual implementation would be:
      // final response = await dio.get(
      //   '/api/wallet/transactions',
      //   queryParameters: {
      //     'page': page,
      //     'pageSize': pageSize,
      //     if (startDate != null) 'startDate': startDate,
      //     if (endDate != null) 'endDate': endDate,
      //     'type': transactionType,
      //   },
      // );
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = response.data['transactions'];
      //   return data.map((item) => TransactionDto.fromJson(item)).toList();
      // } else {
      //   throw ServerException(
      //     message: response.data['message'] ?? '获取交易记录失败',
      //   );
      // }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLikedStories({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Mock data for development
      await Future.delayed(const Duration(milliseconds: 600));

      return List.generate(
        pageSize,
        (index) => {
          'id': 'ST${10000 + index + (page - 1) * pageSize}',
          'title': '有趣的故事 #${index + 1}',
          'coverUrl': 'https://picsum.photos/200/300?random=${index + 1}',
          'authorName': '作者 ${(index % 5) + 1}',
          'likeCount': (index + 1) * 10 + 5,
          'viewCount': (index + 1) * 100 + 50,
          'createdAt': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
        },
      );

      // Actual implementation would be:
      // final response = await dio.get(
      //   '/api/user/liked-stories',
      //   queryParameters: {
      //     'page': page,
      //     'pageSize': pageSize,
      //   },
      // );
      // if (response.statusCode == 200) {
      //   return List<Map<String, dynamic>>.from(response.data['stories']);
      // } else {
      //   throw ServerException(
      //     message: response.data['message'] ?? '获取收藏故事失败',
      //   );
      // }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Mock data for development
      await Future.delayed(const Duration(milliseconds: 550));

      return List.generate(
        pageSize,
        (index) => {
          'id': 'IT${10000 + index + (page - 1) * pageSize}',
          'title': '优质商品 #${index + 1}',
          'imageUrl': 'https://picsum.photos/200/200?random=${index + 10}',
          'price': (index + 1) * 99.99,
          'storeName': '商店 ${(index % 3) + 1}',
          'savedAt': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
        },
      );

      // Actual implementation would be:
      // final response = await dio.get(
      //   '/api/user/saved-items',
      //   queryParameters: {
      //     'page': page,
      //     'pageSize': pageSize,
      //   },
      // );
      // if (response.statusCode == 200) {
      //   return List<Map<String, dynamic>>.from(response.data['items']);
      // } else {
      //   throw ServerException(
      //     message: response.data['message'] ?? '获取收藏商品失败',
      //   );
      // }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

/// 服务器异常
class ServerException implements Exception {
  final String message;

  ServerException({this.message = 'Server error'});

  @override
  String toString() => 'ServerException: $message';
}
