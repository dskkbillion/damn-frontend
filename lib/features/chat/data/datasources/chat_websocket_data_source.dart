import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:rxdart/rxdart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/chat_enums.dart';
import '../../domain/repositories/i_chat_realtime_service.dart';

/// WebSocket数据源
///
/// 负责WebSocket连接的建立、维护和消息传输
class ChatWebSocketDataSource {
  final String _baseUrl;
  
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  final _connectionStatusController = BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.DISCONNECTED);
  final _heartbeatStatusController = BehaviorSubject<HeartbeatStatus>.seeded(HeartbeatStatus.STOPPED);
  final _networkStatusController = BehaviorSubject<NetworkStatus>.seeded(NetworkStatus.DISCONNECTED);
  final _incomingMessagesController = PublishSubject<IncomingMessageDto>();
  
  String? _authToken;
  Duration _connectionTimeout = const Duration(seconds: 10);
  int _reconnectAttempts = 0;
  bool _isReconnecting = false;
  
  /// 创建一个WebSocket数据源
  ///
  /// [baseUrl] WebSocket服务器URL
  ChatWebSocketDataSource({
    required String baseUrl,
  }) : _baseUrl = baseUrl {
    // 初始化网络状态监听
    Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
    // 初始检查网络状态
    _checkConnectivity();
  }
  
  /// 连接到WebSocket服务器
  ///
  /// [token] 用户认证令牌
  Future<void> connect(String token) async {
    if (_channel != null) {
      await disconnect();
    }
    
    _authToken = token;
    _connectionStatusController.add(ConnectionStatus.CONNECTING);
    
    try {
      // 创建WebSocket连接
      _channel = WebSocketChannel.connect(
        Uri.parse('$_baseUrl?token=$token'),
      );
      
      // 设置连接超时
      final completer = Completer<void>();
      final timeout = Timer(_connectionTimeout, () {
        if (!completer.isCompleted) {
          completer.completeError('连接超时');
        }
      });
      
      // 监听WebSocket消息
      _channel!.stream.listen(
        (data) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          
          // 处理收到的消息
          _handleMessage(data);
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
          _handleError(error);
        },
        onDone: () {
          _handleDisconnect();
        },
      );
      
      // 等待连接成功或超时
      await completer.future.then((_) {
        _connectionStatusController.add(ConnectionStatus.CONNECTED);
        _reconnectAttempts = 0;
        timeout.cancel();
      }).catchError((error) {
        timeout.cancel();
        throw Exception('WebSocket连接失败: $error');
      });
      
      // 发送认证消息
      await sendMessage(OutgoingMessageDto.auth(token));
      
    } catch (e) {
      _connectionStatusController.add(ConnectionStatus.CONNECTION_FAILED);
      throw Exception('WebSocket连接失败: $e');
    }
  }
  
  /// 断开WebSocket连接
  Future<void> disconnect() async {
    stopHeartbeat();
    
    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
    }
    
    _connectionStatusController.add(ConnectionStatus.DISCONNECTED);
  }
  
  /// 启动心跳机制
  Future<void> startHeartbeat(Duration interval) async {
    stopHeartbeat();
    
    _heartbeatTimer = Timer.periodic(interval, (_) {
      sendHeartbeat();
    });
    
    _heartbeatStatusController.add(HeartbeatStatus.ACTIVE);
  }
  
  /// 停止心跳机制
  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _heartbeatStatusController.add(HeartbeatStatus.STOPPED);
  }
  
  /// 发送心跳包
  Future<void> sendHeartbeat() async {
    try {
      await sendMessage(OutgoingMessageDto.heartbeat());
      _heartbeatStatusController.add(HeartbeatStatus.ACTIVE);
    } catch (e) {
      _heartbeatStatusController.add(HeartbeatStatus.FAILED);
    }
  }
  
  /// 发送消息
  Future<void> sendMessage(OutgoingMessageDto message) async {
    if (_channel == null || _connectionStatusController.value != ConnectionStatus.CONNECTED) {
      throw Exception('WebSocket未连接');
    }
    
    try {
      final jsonStr = jsonEncode(message.toJson());
      _channel!.sink.add(jsonStr);
    } catch (e) {
      throw Exception('发送消息失败: $e');
    }
  }
  
  /// 确认接收消息
  Future<void> acknowledgeMessage(String messageId) async {
    try {
      await sendMessage(OutgoingMessageDto(
        type: 'ack',
        data: {'message_id': messageId},
      ));
    } catch (e) {
      throw Exception('确认消息失败: $e');
    }
  }
  
  /// 重新连接
  Future<void> reconnect() async {
    if (_isReconnecting) return;
    
    _isReconnecting = true;
    _reconnectAttempts++;
    
    // 指数退避重连策略
    final backoffDuration = Duration(
      seconds: _calculateBackoffSeconds(_reconnectAttempts),
    );
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(backoffDuration, () async {
      if (_authToken != null) {
        try {
          await connect(_authToken!);
          _isReconnecting = false;
        } catch (e) {
          _isReconnecting = false;
          // 连接失败，会在handleDisconnect中再次触发重连
        }
      }
    });
  }
  
  /// 设置连接超时时间
  void setConnectionTimeout(Duration timeout) {
    _connectionTimeout = timeout;
  }
  
  /// 获取连接状态
  bool get isConnected => 
      _channel != null && _connectionStatusController.value == ConnectionStatus.CONNECTED;
  
  /// 连接状态流
  Stream<ConnectionStatus> get connectionStatus => _connectionStatusController.stream;
  
  /// 心跳状态流
  Stream<HeartbeatStatus> get heartbeatStatus => _heartbeatStatusController.stream;
  
  /// 网络状态流
  Stream<NetworkStatus> get networkStatus => _networkStatusController.stream;
  
  /// 接收消息流
  Stream<IncomingMessageDto> get incomingMessages => _incomingMessagesController.stream;
  
  /// 处理接收到的消息
  void _handleMessage(dynamic rawData) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawData);
      final message = IncomingMessageDto(
        type: data['type'],
        data: data['data'],
      );
      
      _incomingMessagesController.add(message);
      
      // 如果是认证响应，检查认证结果
      if (message.isAuth) {
        final success = message.data['success'] ?? false;
        if (!success) {
          _connectionStatusController.add(ConnectionStatus.AUTH_FAILED);
        }
      }
    } catch (e) {
      print('解析消息失败: $e');
    }
  }
  
  /// 处理错误
  void _handleError(dynamic error) {
    print('WebSocket错误: $error');
    _connectionStatusController.add(ConnectionStatus.CONNECTION_FAILED);
  }
  
  /// 处理断开连接
  void _handleDisconnect() {
    _channel = null;
    
    if (_connectionStatusController.value != ConnectionStatus.DISCONNECTED) {
      _connectionStatusController.add(ConnectionStatus.DISCONNECTED);
      
      // 如果不是主动断开连接，尝试重连
      if (_networkStatusController.value == NetworkStatus.CONNECTED && _authToken != null) {
        reconnect();
      }
    }
  }
  
  /// 处理网络连接变化
  void _handleConnectivityChange(ConnectivityResult result) {
    _checkConnectivity();
    
    // 如果网络恢复且WebSocket断开，尝试重连
    if (_networkStatusController.value == NetworkStatus.CONNECTED && 
        _connectionStatusController.value != ConnectionStatus.CONNECTED && 
        _authToken != null) {
      reconnect();
    }
  }
  
  /// 检查网络连接状态
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    final hasConnection = result != ConnectivityResult.none;
    
    _networkStatusController.add(
      hasConnection ? NetworkStatus.CONNECTED : NetworkStatus.DISCONNECTED
    );
  }
  
  /// 计算退避时间（秒）
  int _calculateBackoffSeconds(int attempt) {
    // 最大30秒，指数退避
    return attempt > 5 ? 30 : (1 << attempt);
  }
  
  /// 释放资源
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    disconnect();
    
    _connectionStatusController.close();
    _heartbeatStatusController.close();
    _networkStatusController.close();
    _incomingMessagesController.close();
  }
} 