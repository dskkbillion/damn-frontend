/// 聊天模块使用的枚举类型
/// 
/// 该文件包含消息类型、发送者类型、接收者类型等枚举定义

/// 消息类型枚举
/// 
/// 用于标识不同类型的消息内容
enum MessageType {
  /// 文本消息
  TEXT,
  
  /// 图片消息
  IMAGE,
  
  /// 音频消息
  AUDIO,
  
  /// 订单通知
  ORDER_NOTIFICATION,
  
  /// 系统消息
  SYSTEM
}

/// 消息发送者类型枚举
///
/// 用于标识消息的发送者类型
enum MessageSenderType {
  /// 普通用户
  USER,
  
  /// 系统
  SYSTEM
}

/// 消息接收者类型枚举
///
/// 用于标识消息的接收者类型
enum MessageReceiverType {
  /// 普通用户
  USER,
  
  /// 系统
  SYSTEM
}

/// 消息来源类型枚举
///
/// 用于标识消息的来源
enum MessageSourceType {
  /// 用户直接发送
  USER,
  
  /// AI分发
  AI_DISTRIBUTION,
  
  /// 系统通知
  SYSTEM_NOTIFICATION
}

/// 消息状态枚举
///
/// 用于标识消息的当前状态
enum MessageStatus {
  /// 发送中
  SENDING,
  
  /// 已发送
  SENT,
  
  /// 已送达
  DELIVERED,
  
  /// 已读
  READ,
  
  /// 已撤回
  REVOKED,
  
  /// 已删除
  DELETED,
  
  /// 发送失败
  FAILED
}

/// 消息同步状态枚举
///
/// 用于标识消息与服务器的同步状态
enum MessageSyncStatus {
  /// 待同步
  PENDING,
  
  /// 同步中
  SYNCING,
  
  /// 已同步
  SYNCED,
  
  /// 同步失败
  FAILED
}

/// 会话状态枚举
///
/// 用于标识会话的状态
enum SessionStatus {
  /// 活跃 - 正常使用
  ACTIVE,
  
  /// 已归档 - 不再活跃但保留历史
  ARCHIVED,
  
  /// 已屏蔽 - 不接收新消息
  BLOCKED
}

/// 在线状态枚举
///
/// 用于标识用户的在线状态
enum OnlineStatus {
  /// 在线
  ONLINE,
  
  /// 离线
  OFFLINE,
  
  /// 忙碌
  BUSY,
  
  /// 离开
  AWAY
}

/// 网络状态枚举
///
/// 用于标识当前网络连接状态
enum NetworkStatus {
  /// 已连接
  CONNECTED,
  
  /// 已断开
  DISCONNECTED,
  
  /// 正在连接
  CONNECTING
}

/// 心跳状态枚举
///
/// 用于标识心跳包的状态
enum HeartbeatStatus {
  /// 活跃
  ACTIVE,
  
  /// 失败
  FAILED,
  
  /// 已停止
  STOPPED
}

/// 连接状态枚举
///
/// 用于标识WebSocket连接的状态
enum ConnectionStatus {
  /// 已连接
  CONNECTED,
  
  /// 已断开
  DISCONNECTED,
  
  /// 正在连接
  CONNECTING,
  
  /// 认证失败
  AUTH_FAILED,
  
  /// 连接失败
  CONNECTION_FAILED
} 