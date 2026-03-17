import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'dart:convert';
import 'dart:io'; // For Platform check

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/events/event_bus.dart'; // 导入事件总线
import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart'; // Import DTO
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For platform check
import 'package:injectable/injectable.dart'; // Add injectable import

import 'i_chat_web_socket_data_source.dart'; // Import interface

enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
  error,
}

@LazySingleton(as: IChatWebSocketDataSource)
class ChatWebSocketDataSourceImpl implements IChatWebSocketDataSource {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Timer? _heartbeatTimer;
  String? _token; // Store token for authentication
  String? _commonUserId; // Store user ID for connection URL
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = const Duration(seconds: 5);
  bool _isConnected = false; // 连接状态标志

  final StreamController<ChatMessageDto> _messageStreamController = StreamController.broadcast();
  final StreamController<ConnectionStatus> _connectionStatusController = StreamController.broadcast();

  @override
  Stream<ChatMessageDto> get messageStream => _messageStreamController.stream;
  @override
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;

  @override
  Future<void> connect(String commonUserId, String token) async {
    // 防止重复连接：如果已经连接了相同的用户，直接返回
    if (_isConnected &&
        _commonUserId == commonUserId &&
        _token == token) {
      AppLogger.d("[WebSocket] ✅ Already connected with userId: $commonUserId, skipping duplicate connection");
      return;
    }

    // 如果是不同用户或token，先断开旧连接
    if (_isConnected && (_commonUserId != commonUserId || _token != token)) {
      AppLogger.d("[WebSocket] ⚠️ User/token changed from $_commonUserId to $commonUserId, disconnecting old connection");
      await disconnect();
    }

    _commonUserId = commonUserId;
    _token = token;
    _reconnectAttempts = 0; // Reset attempts on new connect call
    _connectionStatusController.add(ConnectionStatus.connecting);
    AppLogger.d("[WebSocket] Attempting to connect with userId: $_commonUserId");
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    if (_channel != null) {
      await disconnect(); // Ensure previous connection is closed
    }

    if (_commonUserId == null || _token == null) {
      AppLogger.d("[WebSocket] Error: Cannot connect without commonUserId and token.");
      _connectionStatusController.add(ConnectionStatus.error);
      return;
    }

    // Construct WebSocket URL from backend URL
    final backendUrl = dotenv.env['BACKEND_BASE_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      throw Exception('BACKEND_BASE_URL environment variable is not set');
    }
    
    // Parse and clean the URL
    Uri parsedUrl;
    try {
      parsedUrl = Uri.parse(backendUrl);
    } catch (e) {
      throw Exception('Invalid BACKEND_BASE_URL format: $backendUrl');
    }
    
    // Convert HTTP/HTTPS to WS/WSS scheme
    String wsScheme;
    if (parsedUrl.scheme == 'https') {
      wsScheme = 'wss';
    } else if (parsedUrl.scheme == 'http') {
      wsScheme = 'ws';
    } else {
      wsScheme = 'ws';
    }
    
    // Build WebSocket URL properly
    // Backend URL already contains /prod-api, so we just append the WebSocket path
    final wsUri = Uri(
      scheme: wsScheme,
      host: parsedUrl.host,
      port: parsedUrl.hasPort ? parsedUrl.port : null,
      path: '${parsedUrl.path}/websocket/message/$_commonUserId/member',
    );
    
    final url = wsUri.toString();
    AppLogger.d("[WebSocket] Connecting to: $url");

    try {
       // Choose channel based on platform
      if (kIsWeb) {
        // Note: Web sockets might have different security considerations (WSS)
         _channel = WebSocketChannel.connect(Uri.parse(url));
          AppLogger.d("[WebSocket] Using Web Channel.");
      } else if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          // Use IOWebSocketChannel for mobile/desktop
          _channel = IOWebSocketChannel.connect(url);
           AppLogger.d("[WebSocket] Using IO Channel.");
      } else {
           AppLogger.d("[WebSocket] Error: Unsupported platform for WebSocket.");
           _connectionStatusController.add(ConnectionStatus.error);
           return;
      }

      _isConnected = true; // 标记为已连接
      _connectionStatusController.add(ConnectionStatus.connected);
      AppLogger.d("[WebSocket] Connected successfully.");
      _reconnectAttempts = 0; // Reset attempts on successful connection

      // Send authentication message
      _sendAuthMessage();

      // Start listening to messages
      _listenToMessages();

      // Start heartbeat
      _startHeartbeat();

    } catch (e) {
      AppLogger.d("[WebSocket] Connection error: $e");
      _isConnected = false; // 标记为未连接
      _connectionStatusController.add(ConnectionStatus.error);
      _handleReconnect(); // Attempt to reconnect on error
    }
  }


  void _listenToMessages() {
    _channelSubscription?.cancel(); // Cancel previous subscription if any
    _channelSubscription = _channel?.stream.listen(
      (message) {
        // Handle incoming messages
        AppLogger.d("[WebSocket] 🔍 Received raw: $message"); // 临时开启调试
        try {
          final decodedMessage = jsonDecode(message);
          if (decodedMessage is Map<String, dynamic>) {
            final action = decodedMessage['action']?.toString();
            final hasData = decodedMessage['data'] != null;
            AppLogger.d("[WebSocket] 🔍 Decoded action: $action (type: ${action.runtimeType}), hasData: $hasData");

            switch (action) {
              case 'LOGIN_SUCCESS':
                AppLogger.d("[WebSocket] Login acknowledged by server.");
                break;
              case 'LOGIN_FAIL':
                AppLogger.d("[WebSocket] Login rejected by server: ${decodedMessage['msg']}");
                _isConnected = false;
                _connectionStatusController.add(ConnectionStatus.error);
                break;
              case 'NOTIFICATION':
                AppLogger.d("[WebSocket] Received notification action: ${decodedMessage['msg']}");
                break;
              case 'CHAT':
                _handleChatMessage(decodedMessage, incrementUnread: true);
                break;
              case 'CHAT_WITHDRAW':
                _handleChatMessage(decodedMessage, incrementUnread: false);
                break;
              case 'PONG':
                AppLogger.d("[WebSocket] Received PONG.");
                break;
              default:
                if (hasData) {
                  AppLogger.d("[WebSocket] Falling back to chat payload parsing for action: $action");
                  _handleChatMessage(decodedMessage, incrementUnread: true);
                } else {
                  AppLogger.d("[WebSocket] Received unhandled message action: ${decodedMessage['action']}");
                }
            }
          } else {
             AppLogger.d("[WebSocket] Received non-map message: $message");
          }
        } catch (e) {
          AppLogger.d("[WebSocket] Error decoding message: $e, Raw message: $message");
        }
      },
      onDone: () {
        AppLogger.d("[WebSocket] Channel closed by server.");
        _isConnected = false;
        _connectionStatusController.add(ConnectionStatus.disconnected);
        _handleReconnect(); // Attempt to reconnect when channel closes
      },
      onError: (error) {
        AppLogger.d("[WebSocket] Channel error: $error");
        _isConnected = false;
        _connectionStatusController.add(ConnectionStatus.error);
        _handleReconnect(); // Attempt to reconnect on error
      },
      cancelOnError: true, // Cancel subscription on error
    );
     AppLogger.d("[WebSocket] Listening for messages.");
  }

  void _handleChatMessage(
    Map<String, dynamic> decodedMessage, {
    required bool incrementUnread,
  }) {
    try {
      final messageData = decodedMessage['data'];
      if (messageData is! Map<String, dynamic>) {
        AppLogger.d("[WebSocket] Error: Unexpected format for 'data' field: ${messageData.runtimeType}");
        return;
      }

      final chatMessageDto = ChatMessageDto.fromJson(messageData);
      _messageStreamController.add(chatMessageDto);
      final preview = chatMessageDto.context.length > 100
          ? '${chatMessageDto.context.substring(0, 100)}...'
          : chatMessageDto.context;
      AppLogger.d(
        "[WebSocket] Parsed ChatMessageDto: id=${chatMessageDto.id}, action=${decodedMessage['action']}, type=${chatMessageDto.type}, context=$preview",
      );

      _triggerChatNotification(
        chatMessageDto,
        incrementUnread: incrementUnread,
      );
    } catch (e) {
      AppLogger.d("[WebSocket] Error parsing message data: $e");
    }
  }
  
  // 触发聊天消息全局通知
  void _triggerChatNotification(
    ChatMessageDto messageDto, {
    required bool incrementUnread,
  }) {
    try {
      final currentUserId = int.tryParse(_commonUserId ?? '0') ?? 0;

      // 聊天室中，memberId 和 doctorId 分别代表聊天的两方
      // 判断消息是否是别人发的：如果当前用户既不是 memberId 也不是 doctorId，说明不是这个聊天室的参与者
      // 如果当前用户是参与者之一，则对方就是另一个 ID
      final isParticipant = (messageDto.memberId == currentUserId || messageDto.doctorId == currentUserId);

      // 获取对方的 ID（发送者）
      final senderId = (messageDto.memberId == currentUserId)
          ? messageDto.doctorId?.toString() ?? "0"  // 如果我是 member，对方是 doctor
          : messageDto.memberId?.toString() ?? "0";  // 如果我是 doctor，对方是 member

      // 注意：WebSocket 推送的消息可能包括自己发的和别人发的
      // 简单判断：如果我们在这个聊天室中，就处理所有消息（包括自己发的）
      // 前端 UI 会自动过滤显示
      AppLogger.d("[WebSocket] 🔔 Message check: currentUserId=$currentUserId, memberId=${messageDto.memberId}, doctorId=${messageDto.doctorId}, isParticipant=$isParticipant, senderId=$senderId");

      if (isParticipant) {
        // 我们是聊天室参与者，触发更新（包括自己发的消息，用于多设备同步）

        String senderName = "新消息";  // 没有名称字段，使用默认值
        String content = messageDto.context;
        String chatId = messageDto.chatId.toString();

        // 创建消息事件并触发
        final chatEvent = ChatMessageEvent(
          senderName: senderName,
          content: content,
          senderId: senderId,
          chatId: chatId,
        );

        EventBus().fireChatMessageEvent(chatEvent);
        AppLogger.d("[WebSocket] 已触发全局消息通知: $senderName - $content");

        // 同时触发聊天列表更新事件
        final chatListUpdateEvent = ChatListUpdateEvent(
          chatId: messageDto.chatId,
          lastMessage: content,
          lastMessageTime: messageDto.createTime != null
              ? DateTime.tryParse(messageDto.createTime!)
              : DateTime.now(),
          unreadCountDelta: incrementUnread ? 1 : 0,
        );

        EventBus().fireChatListUpdateEvent(chatListUpdateEvent);
        AppLogger.d("[WebSocket] 已触发聊天列表更新事件: chatId=$chatId");
      }
    } catch (e) {
      AppLogger.d("[WebSocket] 触发全局消息通知失败: $e");
    }
  }

  void _sendAuthMessage() {
    if (_channel != null && _token != null) {
      final authMessage = jsonEncode({'type': 'auth', 'token': _token});
      AppLogger.d("[WebSocket] Sending Auth: $authMessage");
      _channel!.sink.add(authMessage);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel(); // Cancel existing timer
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) { // 30秒发送一次心跳保活
      if (_channel != null) {
        final pingMessage = jsonEncode({'type': 'ping'});
        AppLogger.d("[WebSocket] Sending Ping (keep-alive)");
        _channel!.sink.add(pingMessage);
      }
    });
    AppLogger.d("[WebSocket] Heartbeat started (30s interval, ping mode).");
  }

  void _handleReconnect() {
     AppLogger.d("[WebSocket] Handling reconnect...");
    _isConnected = false; // 标记为未连接
    _heartbeatTimer?.cancel(); // Stop heartbeat during reconnection attempts
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      AppLogger.d("[WebSocket] Reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds} seconds...");
      Future.delayed(_reconnectDelay, () {
         if (_commonUserId != null && _token != null) { // Check if credentials still valid
            _connectionStatusController.add(ConnectionStatus.connecting); // Set status before attempting
            _establishConnection();
         } else {
             AppLogger.d("[WebSocket] Cannot reconnect: User credentials lost.");
             _connectionStatusController.add(ConnectionStatus.disconnected); // Stay disconnected
         }
      });
    } else {
      AppLogger.d("[WebSocket] Max reconnect attempts reached. Giving up.");
      _connectionStatusController.add(ConnectionStatus.disconnected); // Stay disconnected
    }
  }


  @override
  Future<void> disconnect() async {
    AppLogger.d("[WebSocket] Disconnecting...");
    _reconnectAttempts = _maxReconnectAttempts; // Prevent auto-reconnect after explicit disconnect
    _heartbeatTimer?.cancel();
    _channelSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false; // 标记为未连接
    _connectionStatusController.add(ConnectionStatus.disconnected);
     AppLogger.d("[WebSocket] Disconnected.");
     // Don't close controllers here if the Bloc might reconnect later
     // _messageStreamController.close();
     // _connectionStatusController.close();
  }

  // Remove or comment out this method as message sending is handled via HTTP
  /* 
  @override
  void sendMessage(String message) {
     if (_channel != null) {
      // 注释掉发送消息日志，避免日志过量
      // AppLogger.d("[WebSocket] Sending message (raw): $message");
      _channel!.sink.add(message);
    } else {
       AppLogger.d("[WebSocket] Error: Cannot send message, channel is not connected.");
       // Optionally notify about the error
    }
  }
  */
} 
