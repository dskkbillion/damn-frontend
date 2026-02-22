import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'dart:convert';
import 'dart:io'; // For Platform check

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For platform check
import 'package:injectable/injectable.dart';

import 'i_core_web_socket_service.dart'; // Import the interface

@LazySingleton(as: ICoreWebSocketService) // Register for DI
class CoreWebSocketServiceImpl implements ICoreWebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Timer? _heartbeatTimer;
  String? _token; // Store token for authentication
  String? _commonUserId; // Store user ID for connection URL
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = const Duration(seconds: 5);

  // 显式状态枚举，替代 _channel != null 的不精确判断
  CoreConnectionStatus _connectionState = CoreConnectionStatus.disconnected;
  
  // Use broadcast controllers to allow multiple listeners (e.g., different Blocs)
  final StreamController<ChatMessageDto?> _messageStreamController = StreamController.broadcast();
  final StreamController<CoreConnectionStatus> _connectionStatusController = StreamController.broadcast();

  // --- Interface Implementation --- 

  @override
  Stream<ChatMessageDto?> get messageStream => _messageStreamController.stream;

  @override
  Stream<CoreConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;

  @override
  Future<void> connect(String commonUserId, String token) async {
    if (_connectionState == CoreConnectionStatus.connected ||
        _connectionState == CoreConnectionStatus.connecting) {
      AppLogger.d("[CoreWebSocket] Already connected or connecting. Ignoring connect call.");
      return;
    }
    AppLogger.d("[CoreWebSocket] connect called with userId: $commonUserId");
    _commonUserId = commonUserId;
    _token = token;
    _reconnectAttempts = 0;
    _setConnectionState(CoreConnectionStatus.connecting);
    await _establishConnection();
  }

  @override
  Future<void> disconnect() async {
    AppLogger.d("[CoreWebSocket] Disconnecting explicitly...");
    _reconnectAttempts = _maxReconnectAttempts; // Prevent auto-reconnect after explicit disconnect
    await _cleanupConnectionResources();
    _setConnectionState(CoreConnectionStatus.disconnected);
    AppLogger.d("[CoreWebSocket] Disconnected explicitly.");
    // Do NOT close stream controllers here, as the service might be long-lived
    // They should be closed when the service itself is disposed (e.g., app termination or user logout)
  }

  @override
  CoreConnectionStatus getCurrentStatus() => _connectionState;

  /// 统一更新连接状态，避免直接操作 controller
  void _setConnectionState(CoreConnectionStatus status) {
    _connectionState = status;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
  }

  // --- Internal Logic (Migrated from ChatWebSocketDataSourceImpl) ---

  Future<void> _establishConnection() async {
    // Ensure previous connection resources are cleaned up IF they exist
    await _cleanupConnectionResources(); 

    if (_commonUserId == null || _token == null) {
      AppLogger.d("[CoreWebSocket] Error: Cannot connect without commonUserId and token.");
      _setConnectionState(CoreConnectionStatus.error);
      return;
    }

    // Construct WebSocket URL from backend URL
    final backendUrl = dotenv.env['BACKEND_BASE_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      throw Exception('BACKEND_BASE_URL environment variable is not set');
    }
    
    // Convert HTTP/HTTPS to WS/WSS
    String wsBaseUrl;
    if (backendUrl.startsWith('https://')) {
      wsBaseUrl = backendUrl.replaceFirst('https://', 'wss://');
    } else if (backendUrl.startsWith('http://')) {
      wsBaseUrl = backendUrl.replaceFirst('http://', 'ws://');
    } else {
      wsBaseUrl = 'ws://$backendUrl';
    }
    
    final url = '$wsBaseUrl/websocket/message/$_commonUserId/member';
    AppLogger.d("[CoreWebSocket] Connecting to: $url");

    try {
      // Choose channel based on platform
      _channel = _createWebSocketChannel(url);

      if (_channel == null) {
        _setConnectionState(CoreConnectionStatus.error);
        return;
      }

      _setConnectionState(CoreConnectionStatus.connected);
      AppLogger.d("[CoreWebSocket] Connected successfully.");
      _reconnectAttempts = 0;

      _sendAuthMessage();
      _listenToMessages();
      _startHeartbeat();

    } catch (e) {
      AppLogger.d("[CoreWebSocket] Connection error: $e");
      _setConnectionState(CoreConnectionStatus.error);
      await _handleReconnect();
    }
  }

  WebSocketChannel? _createWebSocketChannel(String url) {
     try {
        if (kIsWeb) {
          AppLogger.d("[CoreWebSocket] Using Web Channel.");
          // Consider adding connection timeout logic for web if possible/needed
          return WebSocketChannel.connect(Uri.parse(url));
        } else if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          AppLogger.d("[CoreWebSocket] Using IO Channel.");
          // IOWebSocketChannel allows setting connectTimeout
          return IOWebSocketChannel.connect(
              url, 
              connectTimeout: const Duration(seconds: 10), // Example timeout
          );
        } else {
          AppLogger.d("[CoreWebSocket] Error: Unsupported platform for WebSocket.");
          return null;
        }
     } catch (e) {
        AppLogger.d("[CoreWebSocket] Error creating WebSocket channel for url $url: $e");
        return null;
     }
  }


  void _listenToMessages() {
    _channelSubscription?.cancel(); 
    _channelSubscription = _channel?.stream.listen(
      (message) {
        AppLogger.d("[CoreWebSocket] Received raw: $message");
        try {
          final decodedMessage = jsonDecode(message);
          if (decodedMessage is Map<String, dynamic>) {
            if (decodedMessage['action'] == 'CHAT' && decodedMessage['data'] != null) {
              try {
                 final messageData = decodedMessage['data'];
                 if (messageData is Map<String, dynamic>) {
                   final chatMessageDto = ChatMessageDto.fromJson(messageData);
                   if (!_messageStreamController.isClosed) {
                       _messageStreamController.add(chatMessageDto);
                   }
                   AppLogger.d("[CoreWebSocket] Parsed and added ChatMessageDto: ${chatMessageDto.id}");
                 } else {
                   AppLogger.d("[CoreWebSocket] Error: Unexpected format for 'data' field: ${messageData.runtimeType}");
                 }
               } catch (e) {
                 AppLogger.d("[CoreWebSocket] Error parsing message data: $e");
                 // Optionally add null to stream to indicate parsing error?
                 // if (!_messageStreamController.isClosed) { _messageStreamController.add(null); }
               }
            } else if (decodedMessage['action'] == 'PONG') {
               AppLogger.d("[CoreWebSocket] Received Pong (Heartbeat ACK)");
               // Handle Pong if needed (e.g., reset a timeout waiting for pong)
            } else {
              AppLogger.d("[CoreWebSocket] Received non-CHAT/PONG message action: ${decodedMessage['action']}");
            }
          } else {
             AppLogger.d("[CoreWebSocket] Received non-map message: $message");
          }
        } catch (e) {
          AppLogger.d("[CoreWebSocket] Error decoding message: $e, Raw message: $message");
          // Optionally add null to stream to indicate decoding error?
          // if (!_messageStreamController.isClosed) { _messageStreamController.add(null); }
        }
      },
      onDone: () {
        AppLogger.d("[CoreWebSocket] Channel closed by server.");
        _setConnectionState(CoreConnectionStatus.disconnected);
        _handleReconnect();
      },
      onError: (error) {
        AppLogger.d("[CoreWebSocket] Channel error: $error");
        _setConnectionState(CoreConnectionStatus.error);
        _handleReconnect();
      },
      cancelOnError: false, // Keep listening after an error to allow reconnection attempts
    );
     AppLogger.d("[CoreWebSocket] Listening for messages.");
  }

  void _sendAuthMessage() {
    if (_channel != null && _token != null) {
      try {
        final authMessage = jsonEncode({'type': 'auth', 'token': _token});
        AppLogger.d("[CoreWebSocket] Sending Auth message (token omitted)");
        _channel!.sink.add(authMessage);
      } catch (e) {
        AppLogger.d("[CoreWebSocket] Error sending auth message: $e");
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel(); 
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null && _connectionState == CoreConnectionStatus.connected) {
         try {
            final pingMessage = jsonEncode({'type': 'ping'});
            AppLogger.d("[CoreWebSocket] Sending Ping (Heartbeat)");
            _channel!.sink.add(pingMessage);
         } catch (e) {
            AppLogger.d("[CoreWebSocket] Error sending ping: $e");
            // Consider attempting reconnect if ping fails?
         }
      } else {
         AppLogger.d("[CoreWebSocket] Heartbeat skipped (not connected)");
         // Stop timer if not connected to avoid unnecessary checks
         timer.cancel(); 
      }
    });
     AppLogger.d("[CoreWebSocket] Heartbeat started.");
  }
  
  Future<void> _cleanupConnectionResources() async {
     _heartbeatTimer?.cancel();
     _channelSubscription?.cancel();
     // Close sink gracefully if possible
     try {
       await _channel?.sink.close();
     } catch (e) {
       AppLogger.d("[CoreWebSocket] Error closing previous channel sink: $e");
     }
     _channel = null;
     _channelSubscription = null; 
     _heartbeatTimer = null;
  }

  Future<void> _handleReconnect() async {
    AppLogger.d("[CoreWebSocket] Handling reconnect...");
    // 必须 await，确保旧连接完全清理后再重连（修复竞态条件）
    await _cleanupConnectionResources();

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      AppLogger.d("[CoreWebSocket] Reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds} seconds...");
      Future.delayed(_reconnectDelay, () async {
        if (_commonUserId != null && _token != null) {
          _setConnectionState(CoreConnectionStatus.connecting);
          await _establishConnection();
        } else {
          AppLogger.d("[CoreWebSocket] Cannot reconnect: User credentials lost.");
          _setConnectionState(CoreConnectionStatus.disconnected);
        }
      });
    } else {
      AppLogger.d("[CoreWebSocket] Max reconnect attempts reached. Giving up.");
      _setConnectionState(CoreConnectionStatus.disconnected);
    }
  }

  // Optional: Add a dispose method if the service needs cleanup when DI removes it
  @disposeMethod // Import dispose_method from injectable if using this
  void dispose() {
    AppLogger.d("[CoreWebSocket] Disposing service...");
    _heartbeatTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _messageStreamController.close();
    _connectionStatusController.close();
    AppLogger.d("[CoreWebSocket] Service disposed.");
  }
} 