import 'dart:async';
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
    if (getCurrentStatus() == CoreConnectionStatus.connected ||
        getCurrentStatus() == CoreConnectionStatus.connecting) {
      print("[CoreWebSocket] Already connected or connecting. Ignoring connect call.");
      return;
    }
    print("[CoreWebSocket] connect called with userId: $commonUserId");
    _commonUserId = commonUserId;
    _token = token;
    _reconnectAttempts = 0; // Reset attempts on new connect call
    _connectionStatusController.add(CoreConnectionStatus.connecting);
    await _establishConnection();
  }

  @override
  Future<void> disconnect() async {
    print("[CoreWebSocket] Disconnecting explicitly...");
    _reconnectAttempts = _maxReconnectAttempts; // Prevent auto-reconnect after explicit disconnect
    _heartbeatTimer?.cancel();
    _channelSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    if (!_connectionStatusController.isClosed) {
       _connectionStatusController.add(CoreConnectionStatus.disconnected);
    }
    print("[CoreWebSocket] Disconnected explicitly.");
    // Do NOT close stream controllers here, as the service might be long-lived
    // They should be closed when the service itself is disposed (e.g., app termination or user logout)
  }

  // 添加getCurrentStatus方法实现
  @override
  CoreConnectionStatus getCurrentStatus() {
    // 如果连接对象存在且连接正常，返回已连接状态
    if (_channel != null) {
      return CoreConnectionStatus.connected;
    }
    // 否则返回断开状态
    return CoreConnectionStatus.disconnected;
  }

  // --- Internal Logic (Migrated from ChatWebSocketDataSourceImpl) ---

  Future<void> _establishConnection() async {
    // Ensure previous connection resources are cleaned up IF they exist
    await _cleanupConnectionResources(); 

    if (_commonUserId == null || _token == null) {
      print("[CoreWebSocket] Error: Cannot connect without commonUserId and token.");
       if (!_connectionStatusController.isClosed) {
         _connectionStatusController.add(CoreConnectionStatus.error);
       }
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
    print("[CoreWebSocket] Connecting to: $url");

    try {
      // Choose channel based on platform
      _channel = _createWebSocketChannel(url);

      if (_channel == null) { // Unsupported platform case from _createWebSocketChannel
         if (!_connectionStatusController.isClosed) {
           _connectionStatusController.add(CoreConnectionStatus.error);
         }
         return; 
      }
      
      if (!_connectionStatusController.isClosed) {
         _connectionStatusController.add(CoreConnectionStatus.connected);
      }
      print("[CoreWebSocket] Connected successfully.");
      _reconnectAttempts = 0; // Reset attempts on successful connection

      _sendAuthMessage();
      _listenToMessages();
      _startHeartbeat();

    } catch (e) {
      print("[CoreWebSocket] Connection error: $e");
       if (!_connectionStatusController.isClosed) {
         _connectionStatusController.add(CoreConnectionStatus.error);
       }
      _handleReconnect(); 
    }
  }

  WebSocketChannel? _createWebSocketChannel(String url) {
     try {
        if (kIsWeb) {
          print("[CoreWebSocket] Using Web Channel.");
          // Consider adding connection timeout logic for web if possible/needed
          return WebSocketChannel.connect(Uri.parse(url));
        } else if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          print("[CoreWebSocket] Using IO Channel.");
          // IOWebSocketChannel allows setting connectTimeout
          return IOWebSocketChannel.connect(
              url, 
              connectTimeout: const Duration(seconds: 10), // Example timeout
          );
        } else {
          print("[CoreWebSocket] Error: Unsupported platform for WebSocket.");
          return null;
        }
     } catch (e) {
        print("[CoreWebSocket] Error creating WebSocket channel for url $url: $e");
        return null;
     }
  }


  void _listenToMessages() {
    _channelSubscription?.cancel(); 
    _channelSubscription = _channel?.stream.listen(
      (message) {
        print("[CoreWebSocket] Received raw: $message");
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
                   print("[CoreWebSocket] Parsed and added ChatMessageDto: ${chatMessageDto.id}");
                 } else {
                   print("[CoreWebSocket] Error: Unexpected format for 'data' field: ${messageData.runtimeType}");
                 }
               } catch (e) {
                 print("[CoreWebSocket] Error parsing message data: $e");
                 // Optionally add null to stream to indicate parsing error?
                 // if (!_messageStreamController.isClosed) { _messageStreamController.add(null); }
               }
            } else if (decodedMessage['action'] == 'PONG') {
               print("[CoreWebSocket] Received Pong (Heartbeat ACK)");
               // Handle Pong if needed (e.g., reset a timeout waiting for pong)
            } else {
              print("[CoreWebSocket] Received non-CHAT/PONG message action: ${decodedMessage['action']}");
            }
          } else {
             print("[CoreWebSocket] Received non-map message: $message");
          }
        } catch (e) {
          print("[CoreWebSocket] Error decoding message: $e, Raw message: $message");
          // Optionally add null to stream to indicate decoding error?
          // if (!_messageStreamController.isClosed) { _messageStreamController.add(null); }
        }
      },
      onDone: () {
        print("[CoreWebSocket] Channel closed by server.");
        if (!_connectionStatusController.isClosed) {
           _connectionStatusController.add(CoreConnectionStatus.disconnected);
        }
        _handleReconnect();
      },
      onError: (error) {
        print("[CoreWebSocket] Channel error: $error");
         if (!_connectionStatusController.isClosed) {
           _connectionStatusController.add(CoreConnectionStatus.error);
         }
        _handleReconnect(); 
      },
      cancelOnError: false, // Keep listening after an error to allow reconnection attempts
    );
     print("[CoreWebSocket] Listening for messages.");
  }

  void _sendAuthMessage() {
    if (_channel != null && _token != null) {
      try {
        final authMessage = jsonEncode({'type': 'auth', 'token': _token});
        print("[CoreWebSocket] Sending Auth: $authMessage");
        _channel!.sink.add(authMessage);
      } catch (e) {
         print("[CoreWebSocket] Error sending auth message: $e");
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel(); 
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null && getCurrentStatus() == CoreConnectionStatus.connected) {
         try {
            final pingMessage = jsonEncode({'type': 'ping'});
            print("[CoreWebSocket] Sending Ping (Heartbeat)");
            _channel!.sink.add(pingMessage);
         } catch (e) {
            print("[CoreWebSocket] Error sending ping: $e");
            // Consider attempting reconnect if ping fails?
         }
      } else {
         print("[CoreWebSocket] Heartbeat skipped (not connected)");
         // Stop timer if not connected to avoid unnecessary checks
         timer.cancel(); 
      }
    });
     print("[CoreWebSocket] Heartbeat started.");
  }
  
  Future<void> _cleanupConnectionResources() async {
     _heartbeatTimer?.cancel();
     _channelSubscription?.cancel();
     // Close sink gracefully if possible
     try {
       await _channel?.sink.close();
     } catch (e) {
       print("[CoreWebSocket] Error closing previous channel sink: $e");
     }
     _channel = null;
     _channelSubscription = null; 
     _heartbeatTimer = null;
  }

  void _handleReconnect() {
     print("[CoreWebSocket] Handling reconnect...");
    _cleanupConnectionResources(); // Clean up before attempting reconnect

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      print("[CoreWebSocket] Reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds} seconds...");
      Future.delayed(_reconnectDelay, () {
         if (_commonUserId != null && _token != null) {
             if (!_connectionStatusController.isClosed) {
                 _connectionStatusController.add(CoreConnectionStatus.connecting);
             }
            _establishConnection();
         } else {
             print("[CoreWebSocket] Cannot reconnect: User credentials lost.");
             if (!_connectionStatusController.isClosed) {
                 _connectionStatusController.add(CoreConnectionStatus.disconnected);
             }
         }
      });
    } else {
      print("[CoreWebSocket] Max reconnect attempts reached. Giving up.");
       if (!_connectionStatusController.isClosed) {
          _connectionStatusController.add(CoreConnectionStatus.disconnected);
       }
    }
  }

  // Optional: Add a dispose method if the service needs cleanup when DI removes it
  @disposeMethod // Import dispose_method from injectable if using this
  void dispose() {
    print("[CoreWebSocket] Disposing service...");
    _heartbeatTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _messageStreamController.close();
    _connectionStatusController.close();
    print("[CoreWebSocket] Service disposed.");
  }
} 