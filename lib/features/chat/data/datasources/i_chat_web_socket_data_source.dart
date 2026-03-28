import 'dart:async';

import 'package:dskk_flutter_refactor/features/chat/data/datasources/chat_web_socket_data_source.impl.dart'; // Import ConnectionStatus enum
import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart';

/// Abstract interface for WebSocket communication related to chat.
abstract class IChatWebSocketDataSource {
  /// Stream of incoming messages (as DTOs).
  Stream<ChatMessageDto> get messageStream;

  /// Stream of connection status updates.
  Stream<ConnectionStatus> get connectionStatusStream;

  /// Connects to the WebSocket server.
  ///
  /// Requires [commonUserId] and [token] for authentication.
  Future<void> connect(String commonUserId, String token);

  /// Disconnects from the WebSocket server.
  Future<void> disconnect();

  /// Sets the currently active chat room ID.
  /// When a message arrives for this chat, unread count will not be incremented.
  /// Pass null when leaving the chat room.
  void setActiveChatId(int? chatId);
} 