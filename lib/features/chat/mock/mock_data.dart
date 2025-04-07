import '../domain/entities/chat_enums.dart';
import '../domain/entities/chat_session.dart';
import '../domain/entities/message.dart';
import '../domain/entities/user.dart';

/// 聊天模块的模拟数据
///
/// 提供测试和预览环境下的模拟数据
class MockChatData {
  /// 用户列表
  final List<Map<String, dynamic>> users = [
    {
      'id': 'user_1',
      'displayName': '张三',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'isOnline': true,
    },
    {
      'id': 'user_2',
      'displayName': '李四',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'isOnline': false,
    },
    {
      'id': 'user_3',
      'displayName': '王五',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
      'isOnline': true,
    },
    {
      'id': 'user_4',
      'displayName': '赵六',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/4.jpg',
      'isOnline': false,
    },
  ];

  /// 会话列表
  final List<ChatSession> sessions = [];

  /// 消息列表，按会话ID分组
  final Map<String, List<Message>> messages = {};

  MockChatData() {
    _initMockData();
  }

  /// 初始化模拟数据
  void _initMockData() {
    // 创建会话
    final session1 = ChatSession(
      id: 'session_1',
      title: '张三',
      currentUserId: 'current_user',
      targetUserId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isPinned: true,
      isMuted: false,
      lastMessage: null, // 稍后设置
    );

    final session2 = ChatSession(
      id: 'session_2',
      title: '李四',
      currentUserId: 'current_user',
      targetUserId: 'user_2',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      isPinned: false,
      isMuted: true,
      lastMessage: null, // 稍后设置
    );

    final session3 = ChatSession(
      id: 'session_3',
      title: '王五',
      currentUserId: 'current_user',
      targetUserId: 'user_3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isPinned: false,
      isMuted: false,
      lastMessage: null, // 稍后设置
    );

    final session4 = ChatSession(
      id: 'session_4',
      title: '赵六',
      currentUserId: 'current_user',
      targetUserId: 'user_4',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      unreadCount: 5,
      isPinned: false,
      isMuted: false,
      lastMessage: null, // 稍后设置
    );

    sessions.addAll([session1, session2, session3, session4]);

    // 创建张三的消息
    final messages1 = <Message>[];
    messages1.add(Message(
      id: 'msg_1_1',
      sessionId: 'session_1',
      senderId: 'user_1',
      content: '你好，最近在忙什么？',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages1.add(Message(
      id: 'msg_1_2',
      sessionId: 'session_1',
      senderId: 'current_user',
      content: '在研发一个新的APP，你呢？',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 50)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages1.add(Message(
      id: 'msg_1_3',
      sessionId: 'session_1',
      senderId: 'user_1',
      content: '我在准备下周的演讲',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 30)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages1.add(Message(
      id: 'msg_1_4',
      sessionId: 'session_1',
      senderId: 'user_1',
      content: 'https://randomuser.me/api/portraits/men/1.jpg',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      status: MessageStatus.read,
      type: MessageType.image,
      currentUserId: 'current_user',
    ));
    
    messages1.add(Message(
      id: 'msg_1_5',
      sessionId: 'session_1',
      senderId: 'user_1',
      content: '看看我的新照片',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      status: MessageStatus.delivered,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages1.add(Message(
      id: 'msg_1_6',
      sessionId: 'session_1',
      senderId: 'user_1',
      content: '你觉得怎么样？',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      status: MessageStatus.delivered,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));

    // 创建李四的消息
    final messages2 = <Message>[];
    messages2.add(Message(
      id: 'msg_2_1',
      sessionId: 'session_2',
      senderId: 'current_user',
      content: '李四，项目进展如何了？',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages2.add(Message(
      id: 'msg_2_2',
      sessionId: 'session_2',
      senderId: 'user_2',
      content: '进展顺利，已经完成了70%',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 12)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages2.add(Message(
      id: 'msg_2_3',
      sessionId: 'session_2',
      senderId: 'current_user',
      content: '太好了，下周能完成吗？',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 11)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages2.add(Message(
      id: 'msg_2_4',
      sessionId: 'session_2',
      senderId: 'user_2',
      content: '没问题，下周五前一定完成',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));

    // 创建王五的消息
    final messages3 = <Message>[];
    messages3.add(Message(
      id: 'msg_3_1',
      sessionId: 'session_3',
      senderId: 'user_3',
      content: '周末有空一起打球吗？',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages3.add(Message(
      id: 'msg_3_2',
      sessionId: 'session_3',
      senderId: 'current_user',
      content: '这周末恐怕不行，要加班',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 23)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages3.add(Message(
      id: 'msg_3_3',
      sessionId: 'session_3',
      senderId: 'user_3',
      content: '没关系，下次再约',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));

    // 创建赵六的消息
    final messages4 = <Message>[];
    messages4.add(Message(
      id: 'msg_4_1',
      sessionId: 'session_4',
      senderId: 'user_4',
      content: '明天的会议推迟到下午3点',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages4.add(Message(
      id: 'msg_4_2',
      sessionId: 'session_4',
      senderId: 'current_user',
      content: '好的，我已记下了',
      timestamp: DateTime.now().subtract(const Duration(hours: 23)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages4.add(Message(
      id: 'msg_4_3',
      sessionId: 'session_4',
      senderId: 'user_4',
      content: '会议的议程我已经发到你邮箱了',
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      status: MessageStatus.read,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages4.add(Message(
      id: 'msg_4_4',
      sessionId: 'session_4',
      senderId: 'user_4',
      content: '请准备好你的项目报告',
      timestamp: DateTime.now().subtract(const Duration(hours: 15)),
      status: MessageStatus.delivered,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));
    
    messages4.add(Message(
      id: 'msg_4_5',
      sessionId: 'session_4',
      senderId: 'user_4',
      content: '需要提前5分钟入会',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      status: MessageStatus.delivered,
      type: MessageType.text,
      currentUserId: 'current_user',
    ));

    // 添加消息到消息列表
    messages['session_1'] = messages1;
    messages['session_2'] = messages2;
    messages['session_3'] = messages3;
    messages['session_4'] = messages4;

    // 更新最后一条消息
    sessions[0] = sessions[0].copyWith(lastMessage: messages1.last);
    sessions[1] = sessions[1].copyWith(lastMessage: messages2.last);
    sessions[2] = sessions[2].copyWith(lastMessage: messages3.last);
    sessions[3] = sessions[3].copyWith(lastMessage: messages4.last);
  }
} 