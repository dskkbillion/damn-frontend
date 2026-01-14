import 'dart:async';

/// 聊天消息事件类，表示一个新的聊天消息通知
class ChatMessageEvent {
  /// 发送者名称
  final String senderName;
  
  /// 消息内容
  final String content;
  
  /// 发送者ID
  final String senderId;
  
  /// 聊天ID，用于导航到对应的聊天页面
  final String chatId;
  
  /// 发送者头像URL
  final String? avatarUrl;
  
  /// 构造函数
  ChatMessageEvent({
    required this.senderName,
    required this.content,
    required this.senderId,
    required this.chatId,
    this.avatarUrl,
  });
}

/// 评价提交成功事件，用于通知商品详情页刷新评论
class EvaluationSubmittedEvent {
  /// 商品ID
  final int productId;

  /// 订单ID
  final int orderId;

  /// 构造函数
  EvaluationSubmittedEvent({
    required this.productId,
    required this.orderId,
  });
}

/// 聊天列表更新事件类，用于通知聊天列表需要更新
class ChatListUpdateEvent {
  /// 聊天室ID
  final int chatId;

  /// 最新消息内容
  final String? lastMessage;

  /// 最新消息时间
  final DateTime? lastMessageTime;

  /// 未读消息数增量（可为负数表示减少）
  final int? unreadCountDelta;

  /// 是否重置未读数为0
  final bool resetUnread;

  /// 构造函数
  ChatListUpdateEvent({
    required this.chatId,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCountDelta,
    this.resetUnread = false,
  });
}

/// 事件总线单例类，负责全局消息事件的分发
class EventBus {
  /// 私有构造函数
  EventBus._();
  
  /// 单例实例
  static final EventBus _instance = EventBus._();
  
  /// 工厂构造函数返回单例
  factory EventBus() => _instance;
  
  /// 消息事件的广播控制器
  final _messageStreamController = StreamController<ChatMessageEvent>.broadcast();

  /// 聊天列表更新事件的广播控制器
  final _chatListUpdateStreamController = StreamController<ChatListUpdateEvent>.broadcast();

  /// 评价提交事件的广播控制器
  final _evaluationSubmittedStreamController = StreamController<EvaluationSubmittedEvent>.broadcast();

  /// 消息事件流
  Stream<ChatMessageEvent> get messageStream => _messageStreamController.stream;

  /// 聊天列表更新事件流
  Stream<ChatListUpdateEvent> get chatListUpdateStream => _chatListUpdateStreamController.stream;

  /// 评价提交事件流
  Stream<EvaluationSubmittedEvent> get evaluationSubmittedStream => _evaluationSubmittedStreamController.stream;

  /// 发送一个聊天消息事件
  void fireChatMessageEvent(ChatMessageEvent event) {
    _messageStreamController.add(event);
  }

  /// 发送一个聊天列表更新事件
  void fireChatListUpdateEvent(ChatListUpdateEvent event) {
    _chatListUpdateStreamController.add(event);
  }

  /// 发送一个评价提交成功事件
  void fireEvaluationSubmittedEvent(EvaluationSubmittedEvent event) {
    _evaluationSubmittedStreamController.add(event);
  }

  /// 关闭事件总线
  void dispose() {
    _messageStreamController.close();
    _chatListUpdateStreamController.close();
    _evaluationSubmittedStreamController.close();
  }
} 