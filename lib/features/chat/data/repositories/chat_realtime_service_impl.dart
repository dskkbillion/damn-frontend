import 'dart:async';

import '../../domain/entities/chat_enums.dart';
import '../../domain/repositories/i_chat_realtime_service.dart';
import '../datasources/chat_websocket_data_source.dart';

/// 聊天实时服务实现
///
/// 实现IChatRealtimeService接口，包装WebSocket数据源
class ChatRealtimeServiceImpl implements IChatRealtimeService {
  final ChatWebSocketDataSource _webSocketDataSource;
  
  /// 创建一个聊天实时服务实现
  ///
  /// [webSocketDataSource] WebSocket数据源
  ChatRealtimeServiceImpl({
    required ChatWebSocketDataSource webSocketDataSource,
  }) : _webSocketDataSource = webSocketDataSource;
  
  @override
  Future<void> connect(String token) async {
    await _webSocketDataSource.connect(token);
  }
  
  @override
  Future<void> disconnect() async {
    await _webSocketDataSource.disconnect();
  }
  
  @override
  Future<void> startHeartbeat(Duration interval) async {
    await _webSocketDataSource.startHeartbeat(interval);
  }
  
  @override
  Future<void> stopHeartbeat() async {
    _webSocketDataSource.stopHeartbeat();
  }
  
  @override
  Future<void> reconnect() async {
    await _webSocketDataSource.reconnect();
  }
  
  @override
  Future<void> setConnectionTimeout(Duration timeout) async {
    _webSocketDataSource.setConnectionTimeout(timeout);
  }
  
  @override
  bool get isConnected => _webSocketDataSource.isConnected;
  
  @override
  Future<void> sendMessage(OutgoingMessageDto message) async {
    await _webSocketDataSource.sendMessage(message);
  }
  
  @override
  Future<void> sendHeartbeat() async {
    await _webSocketDataSource.sendHeartbeat();
  }
  
  @override
  Future<void> acknowledgeMessage(String messageId) async {
    await _webSocketDataSource.acknowledgeMessage(messageId);
  }
  
  @override
  Stream<IncomingMessageDto> get incomingMessages => 
      _webSocketDataSource.incomingMessages;
  
  @override
  Stream<ConnectionStatus> get connectionStatus => 
      _webSocketDataSource.connectionStatus;
  
  @override
  Stream<HeartbeatStatus> get heartbeatStatus => 
      _webSocketDataSource.heartbeatStatus;
  
  @override
  Stream<NetworkStatus> get networkStatus => 
      _webSocketDataSource.networkStatus;
      
  /// 释放资源
  void dispose() {
    _webSocketDataSource.dispose();
  }
}