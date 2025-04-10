import 'dart:io';
import 'package:injectable/injectable.dart';
import 'i_http_client.dart';
import 'dart:convert';
import '../../features/chat/data/models/chat_message_model.dart';
import '../../features/chat/data/models/chat_session_model.dart';
import '../../features/chat/data/models/models.dart';
import '../../features/chat/data/datasources/chat_api_constants.dart';

/// A mock implementation of IHttpClient for testing and development.
///
/// Returns predefined successful responses or throws exceptions based on the URL path.
// @Injectable(as: IHttpClient)
class MockHttpClient implements IHttpClient {

  @override
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 处理聊天会话列表请求
    if (endpoint.contains('/chat/list') || endpoint == ChatApiConstants.chatList) {
      return {
        'code': 200,
        'msg': 'success',
        'data': {
          'list': _getMockSessions(),
          'total': 3
        }
      };
    } 
    // 处理会话详情请求
    else if (endpoint.contains('/chat/get') || endpoint.contains(ChatApiConstants.chatDetail)) {
      String sessionId = '1';
      if (queryParams != null && queryParams.containsKey('id')) {
        sessionId = queryParams['id'];
      } else if (endpoint.contains('?id=')) {
        sessionId = endpoint.split('?id=')[1];
      }
      
      return {
        'code': 200,
        'msg': 'success',
        'data': _getMockSessions().firstWhere(
          (session) => session['id'] == sessionId,
          orElse: () => _getMockSessions()[0]
        )
      };
    }
    // 处理消息列表请求 (虽然实际上应该是POST)
    else if (endpoint.contains('/message/list')) {
      String sessionId = '1';
      if (queryParams != null && queryParams.containsKey('conversation_id')) {
        sessionId = queryParams['conversation_id'];
      }
      
      return {
        'code': 200,
        'msg': 'success',
        'data': {
          'list': _getMockMessages(sessionId),
          'total': _getMockMessages(sessionId).length
        }
      };
    }
    
    // 默认响应
    throw Exception('未模拟的GET端点: $endpoint');
  }

  @override
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 发送消息
    if (endpoint.contains('/message/add') || endpoint == ChatApiConstants.messageAdd) {
      final messageContent = body['content'] as String? ?? '';
      final sessionId = body['conversation_id'] as String? ?? '1';
      
      final message = _postMockMessage(sessionId, messageContent);
      
      return {
        'code': 200,
        'msg': 'success',
        'data': message
      };
    }
    // 获取消息列表
    else if (endpoint.contains('/message/list') || endpoint == ChatApiConstants.messageList) {
      final sessionId = body['conversation_id'] as String? ?? '1';
      final limit = body['limit'] as int? ?? 20;
      final beforeMessageId = body['before_message_id'] as String?;
      
      // 模拟分页
      var messages = _getMockMessages(sessionId);
      if (beforeMessageId != null) {
        final index = messages.indexWhere((m) => m['id'] == beforeMessageId);
        if (index != -1 && index < messages.length - 1) {
          messages = messages.sublist(index + 1);
        }
      }
      
      // 限制返回数量
      if (messages.length > limit) {
        messages = messages.sublist(0, limit);
      }
      
      return {
        'code': 200,
        'msg': 'success',
        'data': {
          'list': messages,
          'total': messages.length
        }
      };
    }
    // 创建聊天会话
    else if (endpoint.contains('/chat/addChat') || endpoint == ChatApiConstants.addChat) {
      final targetUserId = body['target_user_id'] as String? ?? 'user123';
      
      final session = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': '新建会话 $targetUserId',
        'last_message': '开始聊天吧',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'unread_count': 0,
        'user_id': targetUserId
      };
      
      return {
        'code': 200,
        'msg': 'success',
        'data': session
      };
    }
    // 标记会话已读
    else if (endpoint.contains('/chat/markAsRead')) {
      return {
        'code': 200,
        'msg': 'success',
        'data': null
      };
    }
    // 删除会话
    else if (endpoint.contains('/chat/delete')) {
      return {
        'code': 200,
        'msg': 'success',
        'data': null
      };
    }
    // 撤回消息
    else if (endpoint.contains('/message/withdraw')) {
      return {
        'code': 200,
        'msg': 'success',
        'data': null
      };
    }
    // 删除消息
    else if (endpoint.contains('/message/delete')) {
      return {
        'code': 200,
        'msg': 'success',
        'data': null
      };
    }
    // 处理聊天列表请求（有些接口可能用POST而不是GET）
    else if (endpoint.contains('/chat/list') || endpoint == ChatApiConstants.chatList) {
      return {
        'code': 200,
        'msg': 'success',
        'data': {
          'list': _getMockSessions(),
          'total': 3
        }
      };
    }
    
    // 默认响应
    throw Exception('未模拟的POST端点: $endpoint');
  }

  @override
  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 所有PUT请求返回成功
    return {
      'code': 200,
      'msg': 'success',
      'data': null
    };
  }

  @override
  Future<dynamic> delete(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 所有DELETE请求返回成功
    return {
      'code': 200,
      'msg': 'success',
      'data': null
    };
  }

  /// 模拟获取聊天会话列表
  List<Map<String, dynamic>> _getMockSessions() {
    return [
      {
        'id': '1',
        'title': '日常生活助手',
        'last_message': '今天天气真不错',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        'unread_count': 0,
        'user_id': 'system'
      },
      {
        'id': '2',
        'title': '编程助手',
        'last_message': '如何使用Flutter实现聊天应用？',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        'unread_count': 2,
        'user_id': 'system'
      },
      {
        'id': '3',
        'title': '旅行规划师',
        'last_message': '推荐一下日本东京的旅游路线',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        'unread_count': 0,
        'user_id': 'system'
      }
    ];
  }

  /// 模拟获取聊天消息列表
  List<Map<String, dynamic>> _getMockMessages(String sessionId) {
    if (sessionId == '1') {
      return [
        {
          'id': '101',
          'conversation_id': '1',
          'content': '你好，有什么我可以帮助你的吗？',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
          'sender_id': 'system',
          'role': 'assistant',
          'receiver_id': 'user1',
          'type': 'text'
        },
        {
          'id': '102',
          'conversation_id': '1',
          'content': '今天天气怎么样？',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)).millisecondsSinceEpoch,
          'sender_id': 'user1',
          'role': 'user',
          'receiver_id': 'system',
          'type': 'text'
        },
        {
          'id': '103',
          'conversation_id': '1',
          'content': '今天天气真不错，阳光明媚，温度适宜。',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)).millisecondsSinceEpoch,
          'sender_id': 'system',
          'role': 'assistant',
          'receiver_id': 'user1',
          'type': 'text'
        }
      ];
    } else if (sessionId == '2') {
      return [
        {
          'id': '201',
          'conversation_id': '2',
          'content': '我是编程助手，有什么编程问题我可以帮你解决？',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)).millisecondsSinceEpoch,
          'sender_id': 'system',
          'role': 'assistant',
          'receiver_id': 'user1',
          'type': 'text'
        },
        {
          'id': '202',
          'conversation_id': '2',
          'content': '如何使用Flutter实现聊天应用？',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1)).millisecondsSinceEpoch,
          'sender_id': 'user1',
          'role': 'user',
          'receiver_id': 'system',
          'type': 'text'
        },
        {
          'id': '203',
          'conversation_id': '2',
          'content': '要实现Flutter聊天应用，你需要以下步骤：\n1. 设计数据模型\n2. 实现UI界面\n3. 集成WebSocket或其他实时通信技术\n4. 添加消息存储功能\n\n你想了解哪一部分的详细实现？',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, minutes: 30)).millisecondsSinceEpoch,
          'sender_id': 'system',
          'role': 'assistant',
          'receiver_id': 'user1',
          'type': 'text'
        }
      ];
    } else if (sessionId == '3') {
      return [
        {
          'id': '301',
          'conversation_id': '3',
          'content': '你好，我是旅行规划师，可以帮你规划旅行行程。',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 5)).millisecondsSinceEpoch,
          'sender_id': 'system',
          'role': 'assistant',
          'receiver_id': 'user1',
          'type': 'text'
        },
        {
          'id': '302',
          'conversation_id': '3',
          'content': '推荐一下日本东京的旅游路线',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 3)).millisecondsSinceEpoch,
          'sender_id': 'user1',
          'role': 'user',
          'receiver_id': 'system',
          'type': 'text'
        },
        {
          'id': '303',
          'conversation_id': '3',
          'content': '东京推荐5天行程：\n第1天：浅草寺、晴空塔\n第2天：上野公园、秋叶原\n第3天：新宿、涩谷\n第4天：东京迪士尼\n第5天：银座、台场\n\n这个路线安排紧凑，覆盖了东京主要景点。',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 2)).millisecondsSinceEpoch,
          'sender_id': 'system',
          'role': 'assistant',
          'receiver_id': 'user1',
          'type': 'text'
        }
      ];
    } else {
      // 默认返回空消息列表
      return [];
    }
  }

  /// 模拟发送消息
  Map<String, dynamic> _postMockMessage(String sessionId, String content) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final messageId = 'msg_${now}';
    
    // 创建新消息
    final newMessage = {
      'id': messageId,
      'conversation_id': sessionId,
      'content': content,
      'timestamp': now,
      'sender_id': 'user1', // 当前用户ID
      'role': 'user',
      'receiver_id': 'system',
      'type': 'text'
    };
    
    // 模拟系统自动回复（根据会话类型生成不同回复）
    Future.delayed(const Duration(seconds: 1), () {
      // 这里不做任何实际处理，因为这只是模拟而不是实际存储
      // 系统回复逻辑会在获取消息时模拟
    });
    
    return newMessage;
  }

  @override
  Future<Map<String, dynamic>> postMultipart(String endpoint, {
    required Map<String, dynamic> fields,
    required Map<String, File> files,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 模拟上传图片消息
    if (endpoint.contains('/message/uploadImage') || endpoint.contains('/upload')) {
      final sessionId = fields['conversation_id'] as String? ?? '1';
      
      return {
        'code': 200,
        'msg': 'success',
        'data': {
          'id': 'img_${DateTime.now().millisecondsSinceEpoch}',
          'conversation_id': sessionId,
          'content': 'https://example.com/images/mock_image.jpg',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'sender_id': 'user1',
          'role': 'user',
          'receiver_id': 'system',
          'type': 'image'
        }
      };
    }
    
    // 默认响应
    throw Exception('未模拟的文件上传端点: $endpoint');
  }
  
  @override
  Future<Stream<Map<String, dynamic>>> postAndStream(String endpoint, {required Map<String, dynamic> body}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 模拟流式响应
    if (endpoint.contains('/chat/stream')) {
      return Stream.periodic(const Duration(milliseconds: 100), (count) {
        if (count >= 10) {
          return {'done': true, 'content': ''};
        }
        return {
          'done': false, 
          'content': '这是第${count + 1}个流式消息片段。'
        };
      }).take(11);
    }
    
    // 默认响应
    throw Exception('未模拟的流式请求端点: $endpoint');
  }
} 