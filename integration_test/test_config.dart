/// Integration test environment configuration.
///
/// Points the app at a local mock server so tests run without a real backend.
class TestConfig {
  TestConfig._();

  /// Mock API server host
  static const String mockHost = '127.0.0.1';

  /// Mock API server port
  static const int mockApiPort = 8089;

  /// Mock WebSocket server port
  static const int mockWsPort = 8090;

  /// Base URL for mock API
  static String get mockBaseUrl => 'http://$mockHost:$mockApiPort';

  /// WebSocket URL for mock WS
  static String get mockWsUrl => 'ws://$mockHost:$mockWsPort';

  /// Timeout for waiting on widgets to appear
  static const Duration widgetTimeout = Duration(seconds: 10);

  /// Timeout for waiting on network responses from mock server
  static const Duration networkTimeout = Duration(seconds: 5);

  /// Short settle duration after taps
  static const Duration settleDuration = Duration(milliseconds: 500);
}
