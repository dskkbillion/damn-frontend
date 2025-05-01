import 'dart:async';

import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart'; // Use the existing DTO

// Define ConnectionStatus enum here or import from the implementation later
enum CoreConnectionStatus {
  connecting,
  connected,
  disconnected,
  error,
}

abstract class ICoreWebSocketService {
  /// Stream broadcasting incoming WebSocket messages as DTOs.
  /// Blocs can listen to this stream for real-time updates.
  Stream<ChatMessageDto?> get messageStream;

  /// Stream broadcasting the current connection status.
  /// UI or other services can react to connection changes.
  Stream<CoreConnectionStatus> get connectionStatusStream;

  /// Initiates the WebSocket connection.
  /// Requires the user's internal ID (commonUserId like 10304) and authentication token.
  /// This should typically be called after successful login.
  Future<void> connect(String commonUserId, String token);

  /// Disconnects the WebSocket connection.
  /// This should typically be called on logout or when the app is terminated.
  Future<void> disconnect();

  /// Disposes resources used by the service.
  /// Call this when the service is no longer needed.
  void dispose();

  // Optional: Method to explicitly send a message (like ping/pong if needed centrally)
  // void sendMessage(String message);

  // Optional: Method to get current status synchronously if needed
  CoreConnectionStatus getCurrentStatus();
} 