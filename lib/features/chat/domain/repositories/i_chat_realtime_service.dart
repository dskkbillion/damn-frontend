import '../entities/chat_enums.dart';

/// 入站消息DTO
///
/// 表示从WebSocket接收到的消息
class IncomingMessageDto {
  /// 消息类型（'chat', 'status', 'heartbeat', 'auth', 'error'等）
  final String type;
  
  /// 消息数据
  final Map<String, dynamic> data;
  
  /// 创建入站消息DTO
  const IncomingMessageDto({
    required this.type,
    required this.data,
  });
  
  /// 判断是否是心跳消息
  bool get isHeartbeat => type == 'heartbeat';
  
  /// 判断是否是认证消息
  bool get isAuth => type == 'auth';
  
  /// 判断是否是聊天消息
  bool get isChat => type == 'chat';
  
  /// 判断是否是状态消息
  bool get isStatus => type == 'status';
  
  /// 判断是否是错误消息
  bool get isError => type == 'error';
}

/// 出站消息DTO
///
/// 表示要通过WebSocket发送的消息
class OutgoingMessageDto {
  /// 消息类型（'chat', 'status', 'heartbeat', 'auth'等）
  final String type;
  
  /// 消息数据
  final Map<String, dynamic> data;
  
  /// 创建出站消息DTO
  const OutgoingMessageDto({
    required this.type,
    required this.data,
  });
  
  /// 创建心跳消息
  factory OutgoingMessageDto.heartbeat() {
    return const OutgoingMessageDto(
      type: 'heartbeat',
      data: {},
    );
  }
  
  /// 创建认证消息
  factory OutgoingMessageDto.auth(String token) {
    return OutgoingMessageDto(
      type: 'auth',
      data: {'token': token},
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
    };
  }
}

/// 聊天实时通信服务接口
///
/// 定义聊天实时通信所需的方法，负责WebSocket连接管理和消息传输
abstract class IChatRealtimeService {
  /// WebSocket连接管理
  
  /// 连接到WebSocket服务器
  ///
  /// [token] 用户认证令牌
  /// 
  /// 连接成功时完成，失败时抛出异常
  Future<void> connect(String token);
  
  /// 断开与WebSocket服务器的连接
  ///
  /// 断开成功时完成
  Future<void> disconnect();
  
  /// 启动心跳机制
  ///
  /// [interval] 心跳间隔
  Future<void> startHeartbeat(Duration interval);
  
  /// 停止心跳机制
  Future<void> stopHeartbeat();
  
  /// 尝试重新连接
  Future<void> reconnect();
  
  /// 设置连接超时时间
  ///
  /// [timeout] 超时时间
  Future<void> setConnectionTimeout(Duration timeout);
  
  /// 检查是否已连接
  bool get isConnected;
  
  /// 消息传输
  
  /// 发送消息
  ///
  /// [message] 要发送的消息
  Future<void> sendMessage(OutgoingMessageDto message);
  
  /// 发送心跳包
  Future<void> sendHeartbeat();
  
  /// 确认已接收消息
  ///
  /// [messageId] 要确认的消息ID
  Future<void> acknowledgeMessage(String messageId);
  
  /// 状态监听
  
  /// 接收实时消息流
  Stream<IncomingMessageDto> get incomingMessages;
  
  /// 连接状态流
  Stream<ConnectionStatus> get connectionStatus;
  
  /// 心跳状态流
  Stream<HeartbeatStatus> get heartbeatStatus;
  
  /// 网络状态流
  Stream<NetworkStatus> get networkStatus;
} 