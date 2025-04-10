import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/repositories/chat_realtime_service.dart';
import 'chat_api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// 聊天WebSocket服务实现
class ChatWebSocketServiceImpl implements IChatRealtimeService {
  WebSocketChannel? _channel;
  final String _commonUserId;
  
  // 流控制器
  final _messageController = StreamController<IncomingMessageDto>.broadcast();
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();
  final _heartbeatStatusController = StreamController<HeartbeatStatus>.broadcast();
  final _networkStatusController = StreamController<NetworkStatus>.broadcast();
  
  // 心跳相关
  Timer? _heartbeatTimer;
  int _missedHeartbeats = 0;
  static const int _maxMissedHeartbeats = 3;
  
  // 重连相关
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;
  
  // 连接状态
  ConnectionStatus _status = ConnectionStatus.DISCONNECTED;
  
  // 网络状态监听
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  
  ChatWebSocketServiceImpl(this._commonUserId) {
    // 初始化网络监听
    _initNetworkMonitoring();
  }
  
  /// 初始化网络状态监听
  void _initNetworkMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _networkStatusController.add(NetworkStatus.OFFLINE);
        if (_status == ConnectionStatus.CONNECTED) {
          _disconnect();
          _status = ConnectionStatus.DISCONNECTED;
          _connectionStatusController.add(_status);
        }
      } else {
        _networkStatusController.add(NetworkStatus.ONLINE);
        if (_status == ConnectionStatus.DISCONNECTED) {
          reconnect();
        }
      }
    });
  }
  
  @override
  Future<void> connect(String token) async {
    if (_status == ConnectionStatus.CONNECTED || _status == ConnectionStatus.CONNECTING) {
      return;
    }
    
    _status = ConnectionStatus.CONNECTING;
    _connectionStatusController.add(_status);
    
    try {
      final wsUrl = ChatApiConstants.getWebSocketUrl(_commonUserId);
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // 监听连接
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          _status = ConnectionStatus.DISCONNECTED;
          _connectionStatusController.add(_status);
          _scheduleReconnect();
        },
        onError: (error) {
          _status = ConnectionStatus.CONNECTION_ERROR;
          _connectionStatusController.add(_status);
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
      
      // 发送认证消息
      await _sendAuthMessage(token);
      
    } catch (e) {
      _status = ConnectionStatus.CONNECTION_ERROR;
      _connectionStatusController.add(_status);
      _scheduleReconnect();
      throw ServerException(message: 'Failed to connect to WebSocket: $e');
    }
  }
  
  /// 发送认证消息
  Future<void> _sendAuthMessage(String token) async {
    if (_channel != null) {
      try {
        final authMessage = {
          'type': 'auth',
          'token': token,
        };
        
        _channel!.sink.add(json.encode(authMessage));
        
        // 认证成功后才视为连接成功
        _status = ConnectionStatus.CONNECTED;
        _connectionStatusController.add(_status);
        
        // 重置重连计数
        _reconnectAttempts = 0;
      } catch (e) {
        _status = ConnectionStatus.AUTH_FAILED;
        _connectionStatusController.add(_status);
        throw ServerException(message: 'Failed to authenticate WebSocket: $e');
      }
    }
  }
  
  /// 处理接收到的消息
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = json.decode(message);
      
      // 重置心跳计数
      _missedHeartbeats = 0;
      
      // 根据消息类型处理
      final String type = data['type'] ?? '';
      
      if (type == 'auth_response') {
        // 处理认证响应
        final bool success = data['success'] ?? false;
        if (!success) {
          _status = ConnectionStatus.AUTH_FAILED;
          _connectionStatusController.add(_status);
        } else {
          _status = ConnectionStatus.CONNECTED;
          _connectionStatusController.add(_status);
        }
      } else if (type == 'heartbeat_response') {
        // 处理心跳响应
        _heartbeatStatusController.add(HeartbeatStatus.NORMAL);
      } else if (type == 'message') {
        // 处理普通消息
        final incomingMessage = IncomingMessageDto(
          id: data['id'] ?? '',
          content: data['content'] ?? '',
          senderId: data['sender_id'] ?? '',
          sessionId: data['conversation_id'],
          type: data['message_type'],
          rawData: data,
        );
        
        _messageController.add(incomingMessage);
      }
    } catch (e) {
      // 消息解析错误
      print('Failed to parse WebSocket message: $e');
    }
  }
  
  @override
  Future<void> disconnect() async {
    await _disconnect();
    
    // 清理资源
    _connectivitySubscription.cancel();
    _messageController.close();
    _connectionStatusController.close();
    _heartbeatStatusController.close();
    _networkStatusController.close();
  }
  
  /// 内部断开连接方法
  Future<void> _disconnect() async {
    stopHeartbeat();
    
    if (_channel != null) {
      try {
        await _channel!.sink.close(status.normalClosure);
      } catch (e) {
        print('Error closing WebSocket: $e');
      }
      _channel = null;
    }
    
    _status = ConnectionStatus.DISCONNECTED;
    _connectionStatusController.add(_status);
  }
  
  @override
  Future<void> startHeartbeat(Duration interval) async {
    stopHeartbeat();
    
    _heartbeatTimer = Timer.periodic(interval, (timer) {
      sendHeartbeat();
      
      // 增加未收到心跳响应的计数
      _missedHeartbeats++;
      
      if (_missedHeartbeats >= _maxMissedHeartbeats) {
        _heartbeatStatusController.add(HeartbeatStatus.TIMEOUT);
        reconnect();
      }
    });
  }
  
  @override
  Future<void> stopHeartbeat() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
  
  @override
  Future<void> sendHeartbeat() async {
    if (_channel != null && _status == ConnectionStatus.CONNECTED) {
      try {
        final heartbeatMessage = {
          'type': 'heartbeat',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _channel!.sink.add(json.encode(heartbeatMessage));
      } catch (e) {
        _heartbeatStatusController.add(HeartbeatStatus.ERROR);
        print('Error sending heartbeat: $e');
      }
    }
  }
  
  @override
  Future<void> reconnect() async {
    if (_status == ConnectionStatus.CONNECTING) {
      return;
    }
    
    await _disconnect();
    
    // 如果超过最大重连次数，停止重连
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _status = ConnectionStatus.CONNECTION_ERROR;
      _connectionStatusController.add(_status);
      return;
    }
    
    // 使用指数退避策略
    final backoffDuration = Duration(seconds: _calculateBackoff(_reconnectAttempts));
    await Future.delayed(backoffDuration);
    
    // 尝试重连
    try {
      await connect('<TOKEN_PLACEHOLDER>'); // 实际应用中应从安全存储获取token
      _reconnectAttempts = 0; // 连接成功后重置计数
    } catch (e) {
      _reconnectAttempts++;
      _scheduleReconnect();
    }
  }
  
  /// 计算指数退避时间
  int _calculateBackoff(int attempt) {
    return attempt >= 6 ? 30 : (1 << attempt); // 最大30秒
  }
  
  /// 安排重连
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    
    if (_reconnectAttempts < _maxReconnectAttempts) {
      final backoffDuration = Duration(seconds: _calculateBackoff(_reconnectAttempts));
      _reconnectTimer = Timer(backoffDuration, () {
        reconnect();
      });
    }
  }
  
  @override
  Future<void> setConnectionTimeout(Duration timeout) async {
    // 实现连接超时设置
    // 注意：WebSocket实现可能需要根据底层库调整
  }
  
  @override
  Future<void> sendMessage(OutgoingMessageDto message) async {
    if (_channel != null && _status == ConnectionStatus.CONNECTED) {
      try {
        final messageData = {
          'type': 'message',
          ...message.toJson(),
        };
        
        _channel!.sink.add(json.encode(messageData));
      } catch (e) {
        throw ServerException(message: 'Failed to send WebSocket message: $e');
      }
    } else {
      throw ServerException(message: 'WebSocket not connected');
    }
  }
  
  @override
  Future<void> acknowledgeMessage(String messageId) async {
    if (_channel != null && _status == ConnectionStatus.CONNECTED) {
      try {
        final ackMessage = {
          'type': 'ack',
          'message_id': messageId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _channel!.sink.add(json.encode(ackMessage));
      } catch (e) {
        print('Error acknowledging message: $e');
      }
    }
  }
  
  @override
  Stream<IncomingMessageDto> get incomingMessages => _messageController.stream;
  
  @override
  Stream<ConnectionStatus> get connectionStatus => _connectionStatusController.stream;
  
  @override
  Stream<HeartbeatStatus> get heartbeatStatus => _heartbeatStatusController.stream;
  
  @override
  Stream<NetworkStatus> get networkStatus => _networkStatusController.stream;
} 