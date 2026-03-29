import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'mock_data.dart';

/// Local HTTP mock server for integration tests.
///
/// Listens on localhost and returns fixture JSON responses based on request path.
/// Start before tests, stop after.
class MockApiServer {
  HttpServer? _server;
  final int port;
  final Map<String, Map<String, dynamic>> _customResponses = {};

  MockApiServer({this.port = 8089});

  /// Whether the server is currently running.
  bool get isRunning => _server != null;

  /// Register a custom response for a specific path (overrides defaults).
  void registerResponse(String path, Map<String, dynamic> response) {
    _customResponses[path] = response;
  }

  /// Clear all custom response overrides.
  void clearCustomResponses() {
    _customResponses.clear();
  }

  /// Start the mock server.
  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server!.listen(_handleRequest);
  }

  /// Stop the mock server.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _customResponses.clear();
  }

  void _handleRequest(HttpRequest request) {
    final path = request.uri.path;
    final method = request.method;

    // Check custom responses first
    if (_customResponses.containsKey(path)) {
      _sendJson(request, _customResponses[path]!);
      return;
    }

    // Route to fixture data
    final response = _routeRequest(method, path);
    _sendJson(request, response);
  }

  Map<String, dynamic> _routeRequest(String method, String path) {
    // Auth endpoints
    if (path.contains('/auth/login') || path.contains('/auth/sms-login')) {
      return MockData.loginResponse;
    }
    if (path.contains('/auth/profile') || path.contains('/user/profile')) {
      return MockData.userProfile;
    }

    // Product / Service endpoints
    if (path.contains('/products') || path.contains('/services')) {
      if (path.contains('/detail') || RegExp(r'/products/\w+$').hasMatch(path)) {
        return MockData.productDetailResponse;
      }
      return MockData.productListResponse;
    }

    // Order endpoints
    if (path.contains('/orders')) {
      if (path.contains('/seller')) {
        return MockData.sellerOrderListResponse;
      }
      return MockData.buyerOrderListResponse;
    }

    // Chat endpoints
    if (path.contains('/chat/rooms') || path.contains('/chat/list')) {
      return MockData.chatRoomListResponse;
    }
    if (path.contains('/chat/messages')) {
      return MockData.chatMessagesResponse;
    }

    // Favorites
    if (path.contains('/favorites')) {
      return MockData.emptyListResponse;
    }

    // Seller-specific
    if (path.contains('/seller')) {
      return MockData.successResponse;
    }

    // Default: empty success
    return MockData.successResponse;
  }

  void _sendJson(HttpRequest request, Map<String, dynamic> data) {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(data))
      ..close();
  }
}
