import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'chat_api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// 聊天远程数据源接口
abstract class ChatRemoteDataSource {
  /// 获取会话列表
  Future<List<ChatSessionDto>> getChatSessions();
  
  /// 获取会话详情
  Future<ChatSessionDto> getSessionDetail(String sessionId);
  
  /// 创建会话
  Future<ChatSessionDto> createSession(String targetUserId, {MessageDto? initialMessage});
  
  /// 标记会话为已读
  Future<void> markSessionAsRead(String sessionId);
  
  /// 删除会话
  Future<void> deleteSession(String sessionId);
  
  /// 获取消息历史
  Future<List<MessageDto>> getMessages(String sessionId, {String? beforeMessageId, int limit = 20});
  
  /// 发送消息
  Future<MessageDto> sendMessage(MessageDto message);
  
  /// 撤回消息
  Future<void> revokeMessage(String messageId);
  
  /// 删除消息
  Future<void> deleteMessage(String messageId);
}

/// 聊天远程数据源实现
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  
  ChatRemoteDataSourceImpl({required this.client});
  
  /// 通用API请求处理
  Future<dynamic> _request(String url, {String method = 'GET', Map<String, dynamic>? body}) async {
    final uri = Uri.parse(url);
    http.Response response;
    
    try {
      if (method == 'GET') {
        response = await client.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        response = await client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body ?? {}),
        );
      }
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw ServerException(
          message: 'Server error with status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to connect to server: ${e.toString()}',
      );
    }
  }
  
  @override
  Future<List<ChatSessionDto>> getChatSessions() async {
    final jsonData = await _request(
      ChatApiConstants.chatList,
      method: 'POST',
    );
    
    if (jsonData['code'] == 200 && jsonData['data'] != null) {
      final List<dynamic> sessionsList = jsonData['data']['list'] ?? [];
      return sessionsList.map((json) => ChatSessionDto.fromJson(json)).toList();
    } else {
      throw ServerException(
        message: jsonData['msg'] ?? 'Failed to get chat sessions',
        statusCode: jsonData['code'],
      );
    }
  }
  
  @override
  Future<ChatSessionDto> getSessionDetail(String sessionId) async {
    final jsonData = await _request(
      '${ChatApiConstants.chatDetail}?id=$sessionId',
    );
    
    if (jsonData['code'] == 200 && jsonData['data'] != null) {
      return ChatSessionDto.fromJson(jsonData['data']);
    } else {
      throw ServerException(
        message: jsonData['msg'] ?? 'Failed to get session detail',
        statusCode: jsonData['code'],
      );
    }
  }
  
  @override
  Future<ChatSessionDto> createSession(String targetUserId, {MessageDto? initialMessage}) async {
    final body = {
      'target_user_id': targetUserId,
    };
    
    final jsonData = await _request(
      ChatApiConstants.addChat,
      method: 'POST',
      body: body,
    );
    
    if (jsonData['code'] == 200 && jsonData['data'] != null) {
      final session = ChatSessionDto.fromJson(jsonData['data']);
      
      // 如果有初始消息，立即发送
      if (initialMessage != null) {
        await sendMessage(initialMessage);
      }
      
      return session;
    } else {
      throw ServerException(
        message: jsonData['msg'] ?? 'Failed to create session',
        statusCode: jsonData['code'],
      );
    }
  }
  
  @override
  Future<void> markSessionAsRead(String sessionId) async {
    // 实现标记会话为已读的API调用
    // 注意：这可能需要根据实际API调整
    final body = {
      'session_id': sessionId,
    };
    
    final jsonData = await _request(
      '${ChatApiConstants.baseUrl}/chat/markAsRead',
      method: 'POST',
      body: body,
    );
    
    if (jsonData['code'] != 200) {
      throw ServerException(
        message: jsonData['msg'] ?? 'Failed to mark session as read',
        statusCode: jsonData['code'],
      );
    }
  }
  
  @override
  Future<void> deleteSession(String sessionId) async {
    final body = {
      'id': sessionId,
    };
    
    final jsonData = await _request(
      '${ChatApiConstants.baseUrl}/chat/delete',
      method: 'POST',
      body: body,
    );
    
    if (jsonData['code'] != 200) {
      throw ServerException(
        message: jsonData['msg'] ?? 'Failed to delete session',
        statusCode: jsonData['code'],
      );
    }
  }
  
  @override
  Future<List<MessageDto>> getMessages(String sessionId, {String? beforeMessageId, int limit = 20}) async {
    final body = {
      'conversation_id': sessionId,
      'limit': limit,
    };
    
    if (beforeMessageId != null) {
      body['before_message_id'] = beforeMessageId;
    }
    
    final jsonData = await _request(
      ChatApiConstants.messageList,
      method: 'POST',
      body: body,
    );
    
    if (jsonData['code'] == 200 && jsonData['data'] != null) {
      final List<dynamic> messagesList = jsonData['data']['list'] ?? [];
      return messagesList.map((json) => MessageDto.fromJson(json)).toList();
    } else {
      throw ServerException(
        message: jsonData['msg'] ?? 'Failed to get messages',
        statusCode: jsonData['code'],
      );
    }
  }
  
  @override
  Future<MessageDto> sendMessage(MessageDto message) async {
    final body = message.toJson();
    
    final jsonData = await _request(
      ChatApiConstants.addMessage,
      method: 'POST',
      body: body,
    );
    
    if (jsonData['code'] == 200 && jsonData['data'] != null) {
      return MessageDto.fromJson(jsonData['data']);
    } else {
      throw ServerException(
        message: jsonData['msg'] ?? 'Failed to send message',
        statusCode: jsonData['code'],
      );
    }
  }
  
  @override
  Future<void> revokeMessage(String messageId) async {
    final body = {
      'id': messageId,
    };
    
    final jsonData = await _request(
      ChatApiConstants.withdrawMessage,
      method: 'POST',
      body: body,
    );
    
    if (jsonData['code'] != 200) {
      throw ServerException(
        message: jsonData['msg'] ?? 'Failed to revoke message',
        statusCode: jsonData['code'],
      );
    }
  }
  
  @override
  Future<void> deleteMessage(String messageId) async {
    final body = {
      'id': messageId,
    };
    
    final jsonData = await _request(
      ChatApiConstants.deleteMessage,
      method: 'POST',
      body: body,
    );
    
    if (jsonData['code'] != 200) {
      throw ServerException(
        message: jsonData['msg'] ?? 'Failed to delete message',
        statusCode: jsonData['code'],
      );
    }
  }
} 