import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration constants
class AppConfig {
  /// Get WebSocket base URL from environment or construct from backend URL
  static String get webSocketBaseUrl {
    // Try to get a specific WebSocket URL from env
    final wsUrl = dotenv.env['WEBSOCKET_BASE_URL'];
    if (wsUrl != null && wsUrl.isNotEmpty) {
      return wsUrl;
    }
    
    // Otherwise, derive from backend URL
    final backendUrl = dotenv.env['BACKEND_BASE_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      throw Exception('BACKEND_BASE_URL environment variable is not set');
    }
    
    // Convert HTTP/HTTPS to WS/WSS
    if (backendUrl.startsWith('https://')) {
      return backendUrl.replaceFirst('https://', 'wss://');
    } else if (backendUrl.startsWith('http://')) {
      return backendUrl.replaceFirst('http://', 'ws://');
    } else {
      // If no protocol, assume ws://
      return 'ws://$backendUrl';
    }
  } 

  // TODO: Add other configuration constants as needed
  // static const String apiBaseUrl = '...';
  
  /// 是否使用模拟数据
  static bool useMockData = false;
  
  /// 启用模拟数据模式
  static void enableMockMode() {
    useMockData = true;
  }
  
  /// 禁用模拟数据模式
  static void disableMockMode() {
    useMockData = false;
  }
  
  /// 切换模拟数据模式
  static void toggleMockMode() {
    useMockData = !useMockData;
  }
} 