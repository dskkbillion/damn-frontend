import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Mock WebSocket server for integration tests.
///
/// Simulates real-time message push from the backend.
class MockWebSocketServer {
  HttpServer? _server;
  final int port;
  final List<WebSocket> _clients = [];

  MockWebSocketServer({this.port = 8090});

  bool get isRunning => _server != null;

  /// Number of connected clients.
  int get clientCount => _clients.length;

  /// Start the WebSocket server.
  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server!.transform(WebSocketTransformer()).listen(_handleConnection);
  }

  /// Stop the WebSocket server.
  Future<void> stop() async {
    for (final client in _clients) {
      await client.close();
    }
    _clients.clear();
    await _server?.close(force: true);
    _server = null;
  }

  void _handleConnection(WebSocket ws) {
    _clients.add(ws);
    ws.listen(
      (data) {
        // Echo back for test verification
        ws.add(data);
      },
      onDone: () => _clients.remove(ws),
      onError: (_) => _clients.remove(ws),
    );
  }

  /// Push a chat message to all connected clients.
  void pushChatMessage({
    required String roomId,
    required String senderId,
    required String content,
    String type = 'text',
  }) {
    final message = jsonEncode({
      'type': 'chat_message',
      'data': {
        'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
        'roomId': roomId,
        'senderId': senderId,
        'content': content,
        'type': type,
        'createdAt': DateTime.now().toIso8601String(),
      },
    });
    _broadcast(message);
  }

  /// Push a notification to all connected clients.
  void pushNotification({
    required String title,
    required String body,
    String type = 'system',
  }) {
    final message = jsonEncode({
      'type': 'notification',
      'data': {
        'title': title,
        'body': body,
        'type': type,
        'createdAt': DateTime.now().toIso8601String(),
      },
    });
    _broadcast(message);
  }

  void _broadcast(String message) {
    for (final client in _clients) {
      client.add(message);
    }
  }
}
