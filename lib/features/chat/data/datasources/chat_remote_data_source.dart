import 'package:dio/dio.dart';

import '../models/chat_session_dto.dart';
import '../models/message_dto.dart';
import '../models/user_dto.dart';

/// 聊天远程数据源接口
///
/// 定义与聊天API交互的方法
abstract class IChatRemoteDataSource {
  /// 获取用户的会话列表
  Future<List<ChatSessionDto>> getChatSessions();
  
  /// 获取指定会话的详情
  Future<ChatSessionDto> getSessionDetail(String sessionId);
  
  /// 创建新的聊天会话
  Future<ChatSessionDto> createSession(String targetUserId);
  
  /// 标记会话为已读
  Future<void> markSessionAsRead(String sessionId);
  
  /// 更新会话状态
  Future<void> updateSessionStatus(String sessionId, String status);
  
  /// 删除会话
  Future<void> deleteSession(String sessionId);
  
  /// 获取会话历史消息
  Future<List<MessageDto>> getMessages(
    String sessionId,
    String? beforeMessageId,
    int limit,
  );
  
  /// 发送消息
  Future<MessageDto> sendMessage(MessageDto message);
  
  /// 撤回消息
  Future<void> revokeMessage(String messageId);
  
  /// 删除消息
  Future<void> deleteMessage(String messageId);
  
  /// 获取用户信息
  Future<UserDto> getUserInfo(String userId);
  
  /// 获取多个用户信息
  Future<List<UserDto>> getBatchUserInfo(List<String> userIds);
  
  /// 批量获取指定时间之后的消息
  Future<List<MessageDto>> batchLoadMessages(
    String sessionId,
    String fromTimestamp,
    int limit,
  );
  
  /// 搜索消息
  Future<List<MessageDto>> searchMessages(
    String query, {
    String? sessionId,
  });
}

/// 聊天远程数据源实现
///
/// 使用Dio HTTP客户端与API交互
class ChatRemoteDataSource implements IChatRemoteDataSource {
  final Dio _dio;
  final String _baseUrl;
  
  /// 创建一个聊天远程数据源
  ///
  /// [dio] Dio HTTP客户端实例
  /// [baseUrl] API基础URL
  ChatRemoteDataSource({
    required Dio dio,
    required String baseUrl,
  }) : _dio = dio, _baseUrl = baseUrl;
  
  @override
  Future<List<ChatSessionDto>> getChatSessions() async {
    try {
      final response = await _dio.get('$_baseUrl/sessions');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => ChatSessionDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('获取会话列表失败: $e');
    }
  }
  
  @override
  Future<ChatSessionDto> getSessionDetail(String sessionId) async {
    try {
      final response = await _dio.get('$_baseUrl/sessions/$sessionId');
      return ChatSessionDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('获取会话详情失败: $e');
    }
  }
  
  @override
  Future<ChatSessionDto> createSession(String targetUserId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/sessions',
        data: {'target_user_id': targetUserId},
      );
      return ChatSessionDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('创建会话失败: $e');
    }
  }
  
  @override
  Future<void> markSessionAsRead(String sessionId) async {
    try {
      await _dio.put(
        '$_baseUrl/sessions/$sessionId/read',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('标记会话已读失败: $e');
    }
  }
  
  @override
  Future<void> updateSessionStatus(String sessionId, String status) async {
    try {
      await _dio.put(
        '$_baseUrl/sessions/$sessionId/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('更新会话状态失败: $e');
    }
  }
  
  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await _dio.delete('$_baseUrl/sessions/$sessionId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('删除会话失败: $e');
    }
  }
  
  @override
  Future<List<MessageDto>> getMessages(
    String sessionId,
    String? beforeMessageId,
    int limit,
  ) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit.toString(),
      };
      
      if (beforeMessageId != null) {
        queryParams['before_message_id'] = beforeMessageId;
      }
      
      final response = await _dio.get(
        '$_baseUrl/sessions/$sessionId/messages',
        queryParameters: queryParams,
      );
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MessageDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('获取消息列表失败: $e');
    }
  }
  
  @override
  Future<MessageDto> sendMessage(MessageDto message) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/messages',
        data: message.toJson(),
      );
      return MessageDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('发送消息失败: $e');
    }
  }
  
  @override
  Future<void> revokeMessage(String messageId) async {
    try {
      await _dio.put(
        '$_baseUrl/messages/$messageId/revoke',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('撤回消息失败: $e');
    }
  }
  
  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _dio.delete('$_baseUrl/messages/$messageId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('删除消息失败: $e');
    }
  }
  
  @override
  Future<UserDto> getUserInfo(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/users/$userId');
      return UserDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }
  
  @override
  Future<List<UserDto>> getBatchUserInfo(List<String> userIds) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/users',
        queryParameters: {'ids': userIds.join(',')},
      );
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => UserDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('批量获取用户信息失败: $e');
    }
  }
  
  @override
  Future<List<MessageDto>> batchLoadMessages(
    String sessionId,
    String fromTimestamp,
    int limit,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/sessions/$sessionId/sync',
        queryParameters: {
          'from_timestamp': fromTimestamp,
          'limit': limit.toString(),
        },
      );
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MessageDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('同步消息失败: $e');
    }
  }
  
  @override
  Future<List<MessageDto>> searchMessages(
    String query, {
    String? sessionId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'q': query};
      
      if (sessionId != null) {
        queryParams['session_id'] = sessionId;
      }
      
      final response = await _dio.get(
        '$_baseUrl/messages/search',
        queryParameters: queryParams,
      );
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MessageDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('搜索消息失败: $e');
    }
  }
  
  /// 处理Dio错误
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('网络请求超时');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? '未知错误';
        return Exception('服务器返回错误 ($statusCode): $message');
      case DioExceptionType.cancel:
        return Exception('请求被取消');
      default:
        return Exception('网络错误: ${e.message}');
    }
  }
} 