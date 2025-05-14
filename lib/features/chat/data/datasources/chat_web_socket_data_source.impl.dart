import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For Platform check

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

// @LazySingleton(as: IChatWebSocketDataSource) // Add injectable annotation
class ChatWebSocketDataSourceImpl implements IChatWebSocketDataSource {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Timer? _heartbeatTimer;
  String? _token; // Store token for authentication
  String? _commonUserId; // Store user ID for connection URL
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = const Duration(seconds: 5);

  final StreamController<ChatMessageDto> _messageStreamController = StreamController.broadcast();
  final StreamController<ConnectionStatus> _connectionStatusController = StreamController.broadcast();

  @override
  Stream<ChatMessageDto> get messageStream => _messageStreamController.stream;
  @override
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;

  @override
  Future<void> connect(String commonUserId, String token) async {
    _commonUserId = commonUserId;
    _token = token;
    _reconnectAttempts = 0; // Reset attempts on new connect call
    _connectionStatusController.add(ConnectionStatus.connecting);
    print("[WebSocket] Attempting to connect with userId: $_commonUserId");
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    if (_channel != null) {
      await disconnect(); // Ensure previous connection is closed
    }

    if (_commonUserId == null || _token == null) {
      print("[WebSocket] Error: Cannot connect without commonUserId and token.");
      _connectionStatusController.add(ConnectionStatus.error);
      return;
    }

    // FIX: Revert to ws:// as confirmed by user
    final url = 'ws://app.duoshaokankan.com/prod-api/websocket/message/$_commonUserId/member';
    print("[WebSocket] Connecting to: $url");

    try {
       // Choose channel based on platform
      if (kIsWeb) {
        // Note: Web sockets might have different security considerations (WSS)
         _channel = WebSocketChannel.connect(Uri.parse(url));
          print("[WebSocket] Using Web Channel.");
      } else if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          // Use IOWebSocketChannel for mobile/desktop
          _channel = IOWebSocketChannel.connect(url);
           print("[WebSocket] Using IO Channel.");
      } else {
           print("[WebSocket] Error: Unsupported platform for WebSocket.");
           _connectionStatusController.add(ConnectionStatus.error);
           return;
      }

      _connectionStatusController.add(ConnectionStatus.connected);
      print("[WebSocket] Connected successfully.");
      _reconnectAttempts = 0; // Reset attempts on successful connection

      // Send authentication message
      _sendAuthMessage();

      // Start listening to messages
      _listenToMessages();

      // Start heartbeat
      _startHeartbeat();

    } catch (e) {
      print("[WebSocket] Connection error: $e");
      _connectionStatusController.add(ConnectionStatus.error);
      _handleReconnect(); // Attempt to reconnect on error
    }
  }


  void _listenToMessages() {
    _channelSubscription?.cancel(); // Cancel previous subscription if any
    _channelSubscription = _channel?.stream.listen(
      (message) {
        // Handle incoming messages
        print("[WebSocket] Received raw: $message");
        try {
          final decodedMessage = jsonDecode(message);
          if (decodedMessage is Map<String, dynamic>) {
            if (decodedMessage['action'] == 'CHAT' && decodedMessage['data'] != null) {
              // Assuming 'data' contains the ChatMessageDto structure
               try {
                 final messageData = decodedMessage['data'];
                 // Explicitly cast to Map<String, dynamic> before passing to fromJson
                 if (messageData is Map<String, dynamic>) {
                   final chatMessageDto = ChatMessageDto.fromJson(messageData);
                   _messageStreamController.add(chatMessageDto);
                   print("[WebSocket] Parsed ChatMessageDto: ${chatMessageDto.id}");
                   
                   // 触发全局消息通知事件
                   _triggerChatNotification(chatMessageDto);
                 } else {
                     print("[WebSocket] Error: Unexpected format for 'data' field: ${messageData.runtimeType}");
                 }
               } catch (e) {
                   print("[WebSocket] Error parsing message data: $e");
               }
            } else if (decodedMessage['action'] == 'PONG') {
               print("[WebSocket] Received Pong (Heartbeat ACK)");
            } else {
              // Handle other message types if necessary
              print("[WebSocket] Received non-CHAT/PONG message action: ${decodedMessage['action']}");
            }
          } else {
             print("[WebSocket] Received non-map message: $message");
          }
        } catch (e) {
          print("[WebSocket] Error decoding message: $e, Raw message: $message");
        }
      },
      onDone: () {
        print("[WebSocket] Channel closed by server.");
        _connectionStatusController.add(ConnectionStatus.disconnected);
        _handleReconnect(); // Attempt to reconnect when channel closes
      },
      onError: (error) {
        print("[WebSocket] Channel error: $error");
        _connectionStatusController.add(ConnectionStatus.error);
        _handleReconnect(); // Attempt to reconnect on error
      },
      cancelOnError: true, // Cancel subscription on error
    );
     print("[WebSocket] Listening for messages.");
  }
  
  // 触发聊天消息全局通知
  void _triggerChatNotification(ChatMessageDto messageDto) {
    try {
      // 假设我们只对别人发给我们的消息触发通知
      if (messageDto.memberId != int.tryParse(_commonUserId ?? '0') &&
          messageDto.doctorId != int.tryParse(_commonUserId ?? '0')) {
        
        // 获取发送者信息（根据ChatMessageDto实际结构）
        String senderName = "新消息";  // 没有名称字段，使用默认值
        String content = messageDto.context;
        String senderId = messageDto.memberId?.toString() ?? messageDto.doctorId?.toString() ?? "0";
        String chatId = messageDto.chatId.toString();
        
        // 创建消息事件并触发
        final chatEvent = ChatMessageEvent(
          senderName: senderName,
          content: content,
          senderId: senderId,
          chatId: chatId,
        );
        
        EventBus().fireChatMessageEvent(chatEvent);
        print("[WebSocket] 已触发全局消息通知: $senderName - $content");
      }
    } catch (e) {
      print("[WebSocket] 触发全局消息通知失败: $e");
    }
  }

  void _sendAuthMessage() {
    if (_channel != null && _token != null) {
      final authMessage = jsonEncode({'type': 'auth', 'token': _token});
      print("[WebSocket] Sending Auth: $authMessage");
      _channel!.sink.add(authMessage);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel(); // Cancel existing timer
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null) {
        final pingMessage = jsonEncode({'type': 'ping'});
         print("[WebSocket] Sending Ping (Heartbeat)");
        _channel!.sink.add(pingMessage);
      }
    });
     print("[WebSocket] Heartbeat started.");
  }

  void _handleReconnect() {
     print("[WebSocket] Handling reconnect...");
    _heartbeatTimer?.cancel(); // Stop heartbeat during reconnection attempts
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      print("[WebSocket] Reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds} seconds...");
      Future.delayed(_reconnectDelay, () {
         if (_commonUserId != null && _token != null) { // Check if credentials still valid
            _connectionStatusController.add(ConnectionStatus.connecting); // Set status before attempting
            _establishConnection();
         } else {
             print("[WebSocket] Cannot reconnect: User credentials lost.");
             _connectionStatusController.add(ConnectionStatus.disconnected); // Stay disconnected
         }
      });
    } else {
      print("[WebSocket] Max reconnect attempts reached. Giving up.");
      _connectionStatusController.add(ConnectionStatus.disconnected); // Stay disconnected
    }
  }


  @override
  Future<void> disconnect() async {
    print("[WebSocket] Disconnecting...");
    _reconnectAttempts = _maxReconnectAttempts; // Prevent auto-reconnect after explicit disconnect
    _heartbeatTimer?.cancel();
    _channelSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _connectionStatusController.add(ConnectionStatus.disconnected);
     print("[WebSocket] Disconnected.");
     // Don't close controllers here if the Bloc might reconnect later
     // _messageStreamController.close();
     // _connectionStatusController.close();
  }

  // Remove or comment out this method as message sending is handled via HTTP
  /* 
  @override
  void sendMessage(String message) {
     if (_channel != null) {
      print("[WebSocket] Sending message (raw): $message");
      _channel!.sink.add(message);
    } else {
       print("[WebSocket] Error: Cannot send message, channel is not connected.");
       // Optionally notify about the error
    }
  }
  */
} 