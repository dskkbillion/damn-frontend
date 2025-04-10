/// 聊天模块API常量
class ChatApiConstants {
  /// 基础URL
  static const String baseUrl = '/api';
  
  /// WebSocket基础URL (在生产环境中需根据配置设置)
  static const String wsBaseUrl = 'wss://api.example.com';
  
  // 会话相关端点
  /// 添加聊天室
  static const String addChat = '$baseUrl/chat/addChat';
  
  /// 查询聊天室列表
  static const String chatList = '$baseUrl/chat/list';
  
  /// 获取聊天室详情
  static const String chatDetail = '$baseUrl/chat/get';
  
  // 消息相关端点
  /// 消息列表
  static const String messageList = '$baseUrl/chat/message/list';
  
  /// 删除聊天记录
  static const String deleteMessage = '$baseUrl/chat/message/delete';
  
  /// 撤回消息
  static const String withdrawMessage = '$baseUrl/chat/message/withdraw';
  
  /// 发送消息
  static const String addMessage = '/common/chat/message/add';
  
  // 用户相关端点
  /// 获取用户资料
  static const String memberInfo = '$baseUrl/member/info';
  
  // 文件上传端点
  /// 文件上传
  static const String fileUpload = '$baseUrl/common/public/upload';
  
  /// 获取WebSocket URL
  /// 
  /// [commonUserId] 通用用户ID
  static String getWebSocketUrl(String commonUserId) {
    return '$wsBaseUrl/websocket/message/S$commonUserId/member';
  }
} 