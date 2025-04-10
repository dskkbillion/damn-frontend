import 'package:equatable/equatable.dart';

/// 连接状态枚举
enum ConnectionStatus {
  /// 已连接
  CONNECTED,
  /// 连接中
  CONNECTING,
  /// 已断开
  DISCONNECTED,
  /// 认证失败
  AUTH_FAILED,
  /// 连接错误
  CONNECTION_ERROR,
}

/// 心跳状态枚举
enum HeartbeatStatus {
  /// 正常
  NORMAL,
  /// 超时
  TIMEOUT,
  /// 心跳错误
  ERROR,
}

/// 网络状态枚举
enum NetworkStatus {
  /// 在线
  ONLINE,
  /// 离线
  OFFLINE,
  /// 不稳定
  UNSTABLE,
}

/// 服务端发来的消息DTO
class IncomingMessageDto extends Equatable {
  final String id;
  final String content;
  final String senderId;
  final String? sessionId;
  final String? type;
  final Map<String, dynamic> rawData;

  const IncomingMessageDto({
    required this.id,
    required this.content,
    required this.senderId,
    this.sessionId,
    this.type,
    required this.rawData,
  });

  @override
  List<Object?> get props => [id, content, senderId, sessionId, type, rawData];
}

/// 发送到服务端的消息DTO
class OutgoingMessageDto extends Equatable {
  final String id;
  final String content;
  final String receiverId;
  final String? type;
  final Map<String, dynamic> additionalData;

  const OutgoingMessageDto({
    required this.id,
    required this.content,
    required this.receiverId,
    this.type,
    this.additionalData = const {},
  });

  @override
  List<Object?> get props => [id, content, receiverId, type, additionalData];
}

/// 聊天实时服务接口
abstract class IChatRealtimeService {
  /// 连接实时消息服务
  /// 
  /// [token] 用户认证令牌
  Future<void> connect(String token);
  
  /// 断开实时消息服务
  Future<void> disconnect();
  
  /// 启动心跳保活
  /// 
  /// [interval] 心跳间隔
  Future<void> startHeartbeat(Duration interval);
  
  /// 停止心跳保活
  Future<void> stopHeartbeat();
  
  /// 重新连接
  Future<void> reconnect();
  
  /// 设置连接超时
  /// 
  /// [timeout] 超时时间
  Future<void> setConnectionTimeout(Duration timeout);
  
  /// 发送实时消息
  /// 
  /// [message] 要发送的消息
  Future<void> sendMessage(OutgoingMessageDto message);
  
  /// 发送心跳包
  Future<void> sendHeartbeat();
  
  /// 确认消息接收
  /// 
  /// [messageId] 消息ID
  Future<void> acknowledgeMessage(String messageId);
  
  /// 接收实时消息流
  Stream<IncomingMessageDto> get incomingMessages;
  
  /// 连接状态流
  Stream<ConnectionStatus> get connectionStatus;
  
  /// 心跳状态流
  Stream<HeartbeatStatus> get heartbeatStatus;
  
  /// 网络状态流
  Stream<NetworkStatus> get networkStatus;
} 