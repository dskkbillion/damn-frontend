import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'mock/mock_api_server.dart';
import 'mock/mock_websocket.dart';
import 'test_config.dart';

/// Shared helpers for integration tests.
///
/// Provides [pumpApp], [waitForWidget], [tapAndSettle], and server lifecycle.
class AppTestHelpers {
  AppTestHelpers._();

  static MockApiServer? _apiServer;
  static MockWebSocketServer? _wsServer;

  /// Access the running mock API server (for custom responses).
  static MockApiServer get apiServer {
    assert(_apiServer != null, 'Call setupServers() before accessing apiServer');
    return _apiServer!;
  }

  /// Access the running mock WebSocket server.
  static MockWebSocketServer get wsServer {
    assert(_wsServer != null, 'Call setupServers() before accessing wsServer');
    return _wsServer!;
  }

  /// Start mock servers. Call in setUpAll().
  static Future<void> setupServers() async {
    _apiServer = MockApiServer(port: TestConfig.mockApiPort);
    _wsServer = MockWebSocketServer(port: TestConfig.mockWsPort);
    await _apiServer!.start();
    await _wsServer!.start();
  }

  /// Stop mock servers. Call in tearDownAll().
  static Future<void> teardownServers() async {
    await _apiServer?.stop();
    await _wsServer?.stop();
    _apiServer = null;
    _wsServer = null;
  }

  /// Initialize the integration test binding.
  static IntegrationTestWidgetsFlutterBinding ensureInitialized() {
    return IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  }

  /// Pump a Material app wrapper for widget-level integration tests.
  ///
  /// For full-app tests, use [pumpFullApp] instead.
  static Future<void> pumpWidget(
    WidgetTester tester,
    Widget child, {
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Wait for a widget matching [finder] to appear, with timeout.
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration? timeout,
  }) async {
    final deadline = timeout ?? TestConfig.widgetTimeout;
    final end = DateTime.now().add(deadline);

    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }

    // Final pump and check
    await tester.pumpAndSettle();
    expect(finder, findsWidgets,
        reason: 'Widget not found within ${deadline.inSeconds}s');
  }

  /// Tap a widget and settle animations.
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(TestConfig.settleDuration);
  }

  /// Verify that a widget is NOT present on screen.
  static void expectAbsent(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Verify that a widget IS present on screen.
  static void expectPresent(Finder finder, {int count = 1}) {
    if (count == 1) {
      expect(finder, findsOneWidget);
    } else {
      expect(finder, findsNWidgets(count));
    }
  }

  /// Find widget by text content.
  static Finder findText(String text) => find.text(text);

  /// Find widget by type.
  static Finder findByType<T extends Widget>() => find.byType(T);

  /// Find widget by key.
  static Finder findByKey(String key) => find.byKey(ValueKey(key));
}
