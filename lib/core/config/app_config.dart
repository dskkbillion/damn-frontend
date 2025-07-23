/// Application configuration constants
class AppConfig {
  // TODO: Replace with your actual WebSocket base URL from environment variables or build flavors
  static const String webSocketBaseUrl = 'ws://47.113.230.11:5102'; 
  // static const String webSocketBaseUrl = 'ws://app.duoshaokankan.com/prod-api'; 

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