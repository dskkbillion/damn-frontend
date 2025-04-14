import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart'; // Using rxdart for BehaviorSubject

import '../../../../core/error/failure.dart';
import '../../../../core/network/i_web_socket_client.dart'; // Assume this interface exists
import '../../../domain/entities/message.dart';
import '../models/message_model.dart'; // For parsing incoming messages
import './chat_realtime_service.dart';

class ChatRealtimeServiceImpl implements IChatRealtimeService {
  final IWebSocketClient _webSocketClient;
  // TODO (Critical): Get WebSocket URL from configuration (e.g., environment variables via AppConfig class) instead of hardcoding.
  final String _wsBaseUrl = "ws://17-8187.proxy.product-demo.cn:8000"; // Placeholder
  
  final BehaviorSubject<Message> _messageSubject = BehaviorSubject<Message>();
  final BehaviorSubject<ConnectionStatus> _connectionStatusSubject = BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected);
  final BehaviorSubject<HeartbeatStatus> _heartbeatStatusSubject = BehaviorSubject<HeartbeatStatus>();

  StreamSubscription? _webSocketSubscription;
  Timer? _heartbeatTimer;
  Timer? _pongTimer; // Timer to check for pong response
  bool _manuallyDisconnected = false;
  int? _connectedCommonUserId;

  ChatRealtimeServiceImpl({required IWebSocketClient webSocketClient}) : _webSocketClient = webSocketClient;

  @override
  Stream<Message> get incomingMessages => _messageSubject.stream;

  @override
  Stream<ConnectionStatus> get connectionStatus => _connectionStatusSubject.stream;

  @override
  Stream<HeartbeatStatus> get heartbeatStatus => _heartbeatStatusSubject.stream;


  @override
  Future<Either<Failure, void>> connect(int commonUserId) async {
     if (_connectionStatusSubject.value == ConnectionStatus.connected || _connectionStatusSubject.value == ConnectionStatus.connecting) {
        if (_connectedCommonUserId == commonUserId) {
          print("WebSocket already connected/connecting for user $commonUserId.");
          return const Right(unit); // Already connected/connecting to the same user
        } else {
           print("Switching WebSocket connection to user $commonUserId (was ${_connectedCommonUserId})");
           await disconnect(); // Disconnect from the previous user first
        }
     }

    _manuallyDisconnected = false;
    _connectedCommonUserId = commonUserId;
    final url = "$_wsBaseUrl/websocket/message/$commonUserId/member";
    print("Connecting WebSocket to: $url");
    _connectionStatusSubject.add(ConnectionStatus.connecting);

    try {
      _webSocketSubscription?.cancel(); // Cancel any previous subscription
      final stream = _webSocketClient.connect(url);
      
      _webSocketSubscription = stream.listen(
        (data) {
           _handleIncomingData(data);
           // Reset pong timer on any incoming data (acts as implicit pong)
           _resetPongTimer(); 
        },
        onDone: () {
          print("WebSocket connection closed.");
          if (!_manuallyDisconnected) {
             _connectionStatusSubject.add(ConnectionStatus.disconnected);
             // TODO: Implement auto-reconnect logic if needed
             stopHeartbeat(); // Ensure heartbeat stops on disconnect
          }
        },
        onError: (error) {
          print("WebSocket error: $error");
          _connectionStatusSubject.add(ConnectionStatus.error);
          stopHeartbeat(); // Stop heartbeat on error
        },
        cancelOnError: false, // Keep listening even after an error?
      );
       // Assuming connect is successful if no immediate exception
      _connectionStatusSubject.add(ConnectionStatus.connected);
      print("WebSocket connected successfully.");
      // Automatically start heartbeat on successful connection
      await startHeartbeat(); 
      return const Right(unit);
    } catch (e) {
       print("WebSocket connection failed: $e");
      _connectionStatusSubject.add(ConnectionStatus.error);
      _connectedCommonUserId = null;
      return Left(NetworkFailure('WebSocket connection failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    print("Disconnecting WebSocket...");
    _manuallyDisconnected = true;
    stopHeartbeat();
    await _webSocketSubscription?.cancel();
    await _webSocketClient.disconnect();
    _webSocketSubscription = null;
    _connectionStatusSubject.add(ConnectionStatus.disconnected);
    _connectedCommonUserId = null;
     print("WebSocket disconnected manually.");
    return const Right(unit);
  }

  void _handleIncomingData(dynamic data) {
     print("WebSocket received data: $data");
     // Reset pong timer as any message implies connection is alive
     _resetPongTimer(); 

     if (data is String) {
       // Handle PING/PONG or other string-based protocol messages
       if (data.toUpperCase() == 'PONG') {
         print("WebSocket received PONG");
         _pongTimer?.cancel(); // Received pong, cancel timeout check
         _heartbeatStatusSubject.add(HeartbeatStatus.ok);
         return; // Don't try to parse Pong as JSON
       }
        if (data.toUpperCase() == 'PING') {
          print("WebSocket received PING, sending PONG");
          _webSocketClient.send('PONG');
          return; 
       }

       // Assume other strings might be JSON messages
       try {
         final jsonData = json.decode(data);
         // TODO: Determine message structure from server
         // Assuming the server sends message objects directly
          if (jsonData is Map<String, dynamic>) {
             // Attempt to parse as a Message
             try {
               final messageModel = MessageModel.fromJson(jsonData);
               // TODO: Map MessageModel to Message Entity before adding to stream
               _messageSubject.add(messageModel.toEntity()); 
             } catch (e) {
               print("Failed to parse incoming JSON as Message: $e");
             }
          } else {
             print("Received non-map JSON data: $jsonData");
          }
       } catch (e) {
         print("Failed to decode incoming string data as JSON: $e");
         // Handle non-JSON string messages if applicable
       }
     } else {
       // Handle binary data if needed
       print("WebSocket received non-string data: ${data.runtimeType}");
     }
  }


  @override
  Future<Either<Failure, void>> startHeartbeat({Duration interval = const Duration(seconds: 20)}) async {
    if (_heartbeatTimer?.isActive ?? false) {
      print("Heartbeat already active.");
      return const Right(unit);
    }
    if (_connectionStatusSubject.value != ConnectionStatus.connected) {
       print("Cannot start heartbeat: WebSocket not connected.");
       return Left(GenericFailure("WebSocket not connected"));
    }

    print("Starting heartbeat timer with interval: $interval");
    _heartbeatTimer = Timer.periodic(interval, (_) {
       if (_connectionStatusSubject.value == ConnectionStatus.connected) {
           print("Sending PING");
           _webSocketClient.send('PING');
           _startPongTimer(interval); // Start timer to expect PONG
       } else {
           print("WebSocket not connected, stopping heartbeat.");
           stopHeartbeat(); // Stop if connection lost
       }
    });
     return const Right(unit);
  }

  @override
  Future<Either<Failure, void>> stopHeartbeat() async {
     print("Stopping heartbeat timer.");
     _heartbeatTimer?.cancel();
     _pongTimer?.cancel();
     _heartbeatTimer = null;
     _pongTimer = null;
     return const Right(unit);
  }

  void _startPongTimer(Duration timeoutDuration) {
     _pongTimer?.cancel(); // Cancel previous pong timer if any
     // Set a timeout slightly longer than the heartbeat interval to wait for PONG
     final pongTimeout = timeoutDuration + const Duration(seconds: 5);
     print("Setting PONG timer for $pongTimeout");
     _pongTimer = Timer(pongTimeout, () {
         print("PONG timeout! No PONG received within ${pongTimeout.inSeconds}s.");
         _heartbeatStatusSubject.add(HeartbeatStatus.timeout); 
         // Optional: Consider the connection stale/lost and attempt reconnect or disconnect
         // _connectionStatusSubject.add(ConnectionStatus.error); 
         // disconnect(); 
     });
  }
   void _resetPongTimer() {
      if (_pongTimer?.isActive ?? false) {
         // print("Resetting PONG timer."); // Can be noisy
         _pongTimer!.cancel(); 
          // We might not need to restart it immediately after *any* data,
          // only after receiving an explicit PONG or after sending a PING.
          // For simplicity here, we just cancel it. The next PING will restart it.
      }
   }


  // Close streams when the service is disposed (e.g., by GetIt)
  Future<void> dispose() async {
     print("Disposing ChatRealtimeServiceImpl...");
     await disconnect(); 
     await _messageSubject.close();
     await _connectionStatusSubject.close();
     await _heartbeatStatusSubject.close();
      print("ChatRealtimeServiceImpl disposed.");
  }
}

// --- 假设的 Core 模块依赖 ---
nothing_here_yet2() { } 