import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'mock/mock_api_server.dart';
import 'mock/mock_websocket.dart';
import 'test_config.dart';

/// Step 0.0: Verify integration test infrastructure works.
///
/// - Mock API server starts and responds
/// - Mock WebSocket server starts and accepts connections
/// - Test config values are correct
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockApiServer apiServer;
  late MockWebSocketServer wsServer;

  setUpAll(() async {
    apiServer = MockApiServer(port: TestConfig.mockApiPort);
    wsServer = MockWebSocketServer(port: TestConfig.mockWsPort);
    await apiServer.start();
    await wsServer.start();
  });

  tearDownAll(() async {
    await apiServer.stop();
    await wsServer.stop();
  });

  group('TestConfig', () {
    testWidgets('has correct default values', (tester) async {
      expect(TestConfig.mockHost, '127.0.0.1');
      expect(TestConfig.mockApiPort, 8089);
      expect(TestConfig.mockWsPort, 8090);
      expect(TestConfig.mockBaseUrl, 'http://127.0.0.1:8089');
      expect(TestConfig.mockWsUrl, 'ws://127.0.0.1:8090');
    });
  });

  group('MockApiServer', () {
    testWidgets('is running after start', (tester) async {
      expect(apiServer.isRunning, isTrue);
    });

    testWidgets('responds to HTTP requests with JSON', (tester) async {
      // Use dart:io HttpClient to make a request to the mock server
      final client = await HttpClient()
          .getUrl(Uri.parse('${TestConfig.mockBaseUrl}/products'));
      final response = await client.close();
      expect(response.statusCode, 200);
      final body = await response.transform(utf8.decoder).join();
      expect(body, contains('prod_001'));
    });

    testWidgets('returns product detail for detail path', (tester) async {
      final client = await HttpClient()
          .getUrl(Uri.parse('${TestConfig.mockBaseUrl}/products/prod_001'));
      final response = await client.close();
      expect(response.statusCode, 200);
      final body = await response.transform(utf8.decoder).join();
      expect(body, contains('Logo Design Service'));
    });

    testWidgets('returns chat rooms for chat path', (tester) async {
      final client = await HttpClient()
          .getUrl(Uri.parse('${TestConfig.mockBaseUrl}/chat/rooms'));
      final response = await client.close();
      expect(response.statusCode, 200);
      final body = await response.transform(utf8.decoder).join();
      expect(body, contains('room_001'));
    });

    testWidgets('supports custom response override', (tester) async {
      apiServer.registerResponse('/custom', {'code': 200, 'custom': true});
      final client = await HttpClient()
          .getUrl(Uri.parse('${TestConfig.mockBaseUrl}/custom'));
      final response = await client.close();
      final body = await response.transform(utf8.decoder).join();
      expect(body, contains('"custom":true'));
    });
  });

  group('MockWebSocketServer', () {
    testWidgets('is running after start', (tester) async {
      expect(wsServer.isRunning, isTrue);
    });
  });
}
