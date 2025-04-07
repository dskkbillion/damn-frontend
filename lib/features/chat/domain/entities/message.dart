import 'package:equatable/equatable.dart';

import 'chat_enums.dart';
import 'chat_error.dart';

/// 聊天消息实体类
///
/// 表示一条聊天消息，包含发送者、接收者、内容和各种状态信息
/// 消息对象应该是不可变的，任何状态更新都需要创建新的消息对象
class Message extends Equatable {
  /// 消息唯一标识符
  final String id;
  
  /// 消息所属的会话ID
  final String sessionId;
  
  /// 消息内容
  final String content;
  
  /// 发送者ID
  final String senderId;
  
  /// 发送者类型 (用户、系统等)
  final MessageSenderType senderType;
  
  /// 消息来源
  final MessageSourceType messageSource;
  
  /// 接收者ID
  final String receiverId;
  
  /// 接收者类型
  final MessageReceiverType receiverType;
  
  /// 消息发送/接收时间
  final DateTime timestamp;
  
  /// 消息当前状态
  final MessageStatus status;
  
  /// 消息类型 (文本、图片等)
  final MessageType type;
  
  /// 消息同步状态
  final MessageSyncStatus syncStatus;
  
  /// 重试次数 (用于发送失败的消息)
  final int retryCount;
  
  /// 错误信息 (如果发送失败)
  final ChatError? error;
  
  /// 父消息ID (对于回复类消息)
  final String? parentMessageId;
  
  /// 其他元数据，如附件URL等
  final Map<String, dynamic>? metadata;

  /// 创建一个消息实体
  /// 
  /// 所有的参数都是必须的，除了[error]、[retryCount]、[parentMessageId]和[metadata]
  const Message({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.senderId,
    required this.senderType,
    required this.messageSource,
    required this.receiverId,
    required this.receiverType,
    required this.timestamp,
    required this.status,
    required this.type,
    required this.syncStatus,
    this.retryCount = 0,
    this.error,
    this.parentMessageId,
    this.metadata,
  });

  /// 创建文本消息
  /// 
  /// 用于创建简单的文本消息对象
  factory Message.text({
    required String id,
    required String sessionId,
    required String content,
    required String senderId,
    required MessageSenderType senderType,
    required String receiverId,
    required MessageReceiverType receiverType,
    DateTime? timestamp,
    MessageStatus status = MessageStatus.SENDING,
    MessageSyncStatus syncStatus = MessageSyncStatus.PENDING,
    String? parentMessageId,
  }) {
    return Message(
      id: id,
      sessionId: sessionId,
      content: content,
      senderId: senderId,
      senderType: senderType,
      messageSource: MessageSourceType.USER,
      receiverId: receiverId,
      receiverType: receiverType,
      timestamp: timestamp ?? DateTime.now(),
      status: status,
      type: MessageType.TEXT,
      syncStatus: syncStatus,
      parentMessageId: parentMessageId,
    );
  }

  /// 创建图片消息
  /// 
  /// [imageUrl] 图片的URL，将存储在metadata中
  factory Message.image({
    required String id,
    required String sessionId,
    required String senderId,
    required MessageSenderType senderType,
    required String receiverId,
    required MessageReceiverType receiverType,
    required String imageUrl,
    String? thumbnailUrl,
    int? width,
    int? height,
    DateTime? timestamp,
    MessageStatus status = MessageStatus.SENDING,
    MessageSyncStatus syncStatus = MessageSyncStatus.PENDING,
    String? parentMessageId,
  }) {
    return Message(
      id: id,
      sessionId: sessionId,
      content: 'image',
      senderId: senderId,
      senderType: senderType,
      messageSource: MessageSourceType.USER,
      receiverId: receiverId,
      receiverType: receiverType,
      timestamp: timestamp ?? DateTime.now(),
      status: status,
      type: MessageType.IMAGE,
      syncStatus: syncStatus,
      parentMessageId: parentMessageId,
      metadata: {
        'imageUrl': imageUrl,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
      },
    );
  }

  /// 创建音频消息
  /// 
  /// [audioUrl] 音频的URL，将存储在metadata中
  /// [duration] 音频时长（秒）
  factory Message.audio({
    required String id,
    required String sessionId,
    required String senderId,
    required MessageSenderType senderType,
    required String receiverId,
    required MessageReceiverType receiverType,
    required String audioUrl,
    int? duration,
    DateTime? timestamp,
    MessageStatus status = MessageStatus.SENDING,
    MessageSyncStatus syncStatus = MessageSyncStatus.PENDING,
    String? parentMessageId,
  }) {
    return Message(
      id: id,
      sessionId: sessionId,
      content: 'audio',
      senderId: senderId,
      senderType: senderType,
      messageSource: MessageSourceType.USER,
      receiverId: receiverId,
      receiverType: receiverType,
      timestamp: timestamp ?? DateTime.now(),
      status: status,
      type: MessageType.AUDIO,
      syncStatus: syncStatus,
      parentMessageId: parentMessageId,
      metadata: {
        'audioUrl': audioUrl,
        if (duration != null) 'duration': duration,
      },
    );
  }

  /// 创建系统消息
  factory Message.system({
    required String id,
    required String sessionId,
    required String content,
    required String receiverId,
    DateTime? timestamp,
  }) {
    return Message(
      id: id,
      sessionId: sessionId,
      content: content,
      senderId: 'system',
      senderType: MessageSenderType.SYSTEM,
      messageSource: MessageSourceType.SYSTEM_NOTIFICATION,
      receiverId: receiverId,
      receiverType: MessageReceiverType.USER,
      timestamp: timestamp ?? DateTime.now(),
      status: MessageStatus.DELIVERED,
      type: MessageType.SYSTEM,
      syncStatus: MessageSyncStatus.SYNCED,
    );
  }

  /// 创建从AI分发的消息
  factory Message.fromAI({
    required String id,
    required String sessionId,
    required String content,
    required String receiverId,
    DateTime? timestamp,
    MessageStatus status = MessageStatus.DELIVERED,
  }) {
    return Message(
      id: id,
      sessionId: sessionId,
      content: content,
      senderId: 'ai',
      senderType: MessageSenderType.SYSTEM,
      messageSource: MessageSourceType.AI_DISTRIBUTION,
      receiverId: receiverId,
      receiverType: MessageReceiverType.USER,
      timestamp: timestamp ?? DateTime.now(),
      status: status,
      type: MessageType.TEXT,
      syncStatus: MessageSyncStatus.SYNCED,
    );
  }

  /// 创建此消息的副本，但部分字段替换为新值
  Message copyWith({
    String? id,
    String? sessionId,
    String? content,
    String? senderId,
    MessageSenderType? senderType,
    MessageSourceType? messageSource,
    String? receiverId,
    MessageReceiverType? receiverType,
    DateTime? timestamp,
    MessageStatus? status,
    MessageType? type,
    MessageSyncStatus? syncStatus,
    int? retryCount,
    ChatError? error,
    String? parentMessageId,
    Map<String, dynamic>? metadata,
    bool clearError = false,
  }) {
    return Message(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      messageSource: messageSource ?? this.messageSource,
      receiverId: receiverId ?? this.receiverId,
      receiverType: receiverType ?? this.receiverType,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      error: clearError ? null : error ?? this.error,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 根据当前消息创建一个带有发送失败状态的新副本
  Message withSendFailure(ChatError error) {
    return copyWith(
      status: MessageStatus.FAILED,
      syncStatus: MessageSyncStatus.FAILED,
      error: error,
      retryCount: retryCount + 1,
    );
  }

  /// 根据当前消息创建一个带有发送中状态的新副本
  Message withResendStatus() {
    return copyWith(
      status: MessageStatus.SENDING,
      syncStatus: MessageSyncStatus.PENDING,
      clearError: true,
    );
  }

  /// 根据当前消息创建一个带有发送成功状态的新副本
  Message withSentStatus({String? newId}) {
    return copyWith(
      id: newId ?? id,
      status: MessageStatus.SENT,
      syncStatus: MessageSyncStatus.SYNCED,
      clearError: true,
    );
  }

  /// 根据当前消息创建一个带有已送达状态的新副本
  Message withDeliveredStatus() {
    return copyWith(
      status: MessageStatus.DELIVERED,
      clearError: true,
    );
  }

  /// 根据当前消息创建一个带有已读状态的新副本
  Message withReadStatus() {
    return copyWith(
      status: MessageStatus.READ,
      clearError: true,
    );
  }

  /// 判断消息是否是本地用户发送的
  bool get isFromLocalUser => senderType == MessageSenderType.USER;

  /// 判断消息是否已发送成功
  bool get isDelivered => status == MessageStatus.DELIVERED || status == MessageStatus.READ;

  /// 判断消息是否已被读取
  bool get isRead => status == MessageStatus.READ;

  /// 判断消息是否发送失败
  bool get isFailed => status == MessageStatus.FAILED;
  
  /// 判断消息是否可以重试发送
  bool get canRetry => isFailed && (error?.canRetry ?? true);

  /// 判断消息是否是图片
  bool get isImage => type == MessageType.IMAGE;

  /// 判断消息是否是音频
  bool get isAudio => type == MessageType.AUDIO;

  /// 判断消息是否是系统消息
  bool get isSystem => type == MessageType.SYSTEM;
  
  /// 获取图片URL（如果消息类型是图片）
  String? get imageUrl => isImage ? metadata?['imageUrl'] as String? : null;
  
  /// 获取音频URL（如果消息类型是音频）
  String? get audioUrl => isAudio ? metadata?['audioUrl'] as String? : null;

  @override
  List<Object?> get props => [
    id,
    sessionId,
    content,
    senderId,
    senderType,
    messageSource,
    receiverId,
    receiverType,
    timestamp,
    status,
    type,
    syncStatus,
    retryCount,
    error,
    parentMessageId,
    metadata,
  ];
} 