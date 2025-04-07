# Chat 模块开发记录

## 开发进度

### 1. 分支创建 (2024-04-07) ✅

- 从 develop 分支创建新分支：`refactor/chat-module`
- 分支创建命令：
  ```bash
  git checkout develop
  git pull origin develop
  git checkout -b refactor/chat-module
  ```

### 2. 模块边界定义 (2024-04-07) ✅

#### 2.1 核心业务能力

- **实时消息通信**
  - 发送消息
  - 接收消息
- **会话管理**
  - 会话列表维护
    - 会话排序（按最后消息时间）
  - 会话状态同步
    - 消息已读状态同步: 消除未读消息数
- **消息历史**
  - 消息历史记录
  - 消息撤回

#### 2.2 核心要素（Domain 层）

##### 2.2.1 Use Cases

- `SendMessageUseCase`
  - 发送新消息
  - 处理发送状态
  - 处理发送失败重试
- `ReceiveMessageUseCase`
  - 接收新消息
  - 更新消息状态
  - 触发通知
- `CreateSessionUseCase`
  - 创建新会话
  - 初始化会话设置
- `ManageSessionUseCase`
  - 更新会话状态
  - 管理会话成员
  - 处理会话设置
- `SyncMessagesUseCase`
  - 同步消息历史
  - 处理消息冲突
  - 更新本地存储

##### 2.2.2 Entities

- `Message`（消息实体）

  - id: String（消息唯一标识）
  - content: String（消息内容）
  - senderId: String（发送者 ID）
  - senderType: MessageSenderType（发送者类型）
    - USER: 普通用户
    - SYSTEM: 系统通知
  - messageSource: MessageSourceType（消息来源）
    - USER: 用户直接发送
    - AI_DISTRIBUTION: AI 分发
    - SYSTEM_NOTIFICATION: 系统通知
  - receiverId: String（接收者 ID）
  - receiverType: MessageReceiverType（接收者类型）
    - USER: 普通用户
    - SYSTEM: 系统
  - timestamp: DateTime（消息时间戳）
  - status: MessageStatus（消息状态）
  - type: MessageType（消息类型）
    - TEXT: 文本消息
    - AUDIO: 音频消息
    - IMAGE: 图片消息
    - ORDER_NOTIFICATION: 订单通知
    - SYSTEM: 系统消息
  - syncStatus: MessageSyncStatus（消息同步状态）
    - PENDING: 待同步
    - SYNCING: 同步中
    - SYNCED: 已同步
    - FAILED: 同步失败
  - retryCount: int（重试次数）
  - error: ChatError?（错误信息）

- `ChatSession`（会话实体）

  - id: String（会话唯一标识）
  - userId: String（当前用户 ID）
  - targetUserId: String（对方用户 ID）
  - lastMessage: Message?（最后一条消息）
  - unreadCount: int（未读消息数）
  - createdAt: DateTime（创建时间）
  - updatedAt: DateTime（更新时间）

- `User`（用户实体）
  - id: String（用户 ID）
  - name: String（用户名称）
  - avatar: String?（头像 URL）
  - onlineStatus: OnlineStatus（在线状态）

##### 2.2.3 Repository Interfaces（仓库接口）

仓库接口定义了数据操作的契约，是 Domain 层与 Data 层之间的桥梁。它抽象了数据来源（如网络、本地数据库），只定义"做什么"而不关心"怎么做"。

- `IChatRepository`（聊天仓库接口）

  - 会话管理

    - `Stream<List<ChatSession>> getChatSessions()`：获取会话列表流
    - `Future<Either<Failure, void>> markSessionAsRead(String sessionId)`：标记会话为已读
    - `Future<Either<Failure, void>> updateSessionStatus(String sessionId, SessionStatus status)`：更新会话状态
    - `Future<Either<Failure, void>> deleteSession(String sessionId)`：删除会话
    - `Future<Either<Failure, ChatSession>> getSessionDetail(String sessionId)`：获取会话详情

  - 消息管理
    - `Future<Either<Failure, List<Message>>> getMessages(String sessionId, String? beforeMessageId, int limit)`：获取历史消息
    - `Future<Either<Failure, Message>> sendMessage(Message message)`：发送消息
    - `Future<Either<Failure, void>> revokeMessage(String messageId)`：撤回消息
    - `Stream<Message> observeMessages()`：监听新消息
    - `Stream<MessageStatusUpdate> observeMessageStatusUpdates()`：监听消息状态更新
  - 错误处理
    - `Future<Either<Failure, T>> retryOperation<T>(Future<Either<Failure, T>> Function() operation, int maxRetries)`：重试操作
    - `Future<Either<Failure, void>> clearError(String messageId)`：清除错误状态

- `IChatRealtimeService`（聊天实时服务接口）

  - 连接管理
    - `Future<void> connect(String token)`：连接实时消息服务
    - `Future<void> disconnect()`：断开实时消息服务
    - `Future<void> startHeartbeat(Duration interval)`：启动心跳保活
    - `Future<void> stopHeartbeat()`：停止心跳保活
    - `Future<void> reconnect()`：重新连接
    - `Future<void> setConnectionTimeout(Duration timeout)`：设置连接超时
  - 消息传输
    - `Future<void> sendMessage(OutgoingMessageDto message)`：发送实时消息
    - `Future<void> sendHeartbeat()`：发送心跳包
    - `Future<void> acknowledgeMessage(String messageId)`：确认消息接收
  - 状态监听
    - `Stream<IncomingMessageDto> get incomingMessages`：接收实时消息流
    - `Stream<ConnectionStatus> get connectionStatus`：连接状态流
    - `Stream<HeartbeatStatus> get heartbeatStatus`：心跳状态流
    - `Stream<NetworkStatus> get networkStatus`：网络状态流

- `IChatLocalCache`（聊天本地缓存接口）
  - 会话缓存
    - `Future<void> saveSessions(List<ChatSession> sessions)`：保存会话列表
    - `Future<List<ChatSession>> getSessions()`：获取本地会话列表
    - `Future<void> updateSessionReadStatus(String sessionId)`：更新会话已读状态
  - 消息缓存
    - `Future<void> saveMessages(String sessionId, List<Message> messages)`：保存消息
    - `Future<List<Message>> getMessages(String sessionId, int limit, String? beforeMessageId)`：获取本地消息
    - `Future<void> updateMessageStatus(String messageId, MessageStatus status)`：更新消息状态
    - `Future<void> clearSessionMessages(String sessionId)`：清除会话消息
    - `Future<void> clearExpiredMessages(Duration expiration)`：清除过期消息
    - `Future<void> setCacheSizeLimit(int maxSize)`：设置缓存大小限制

#### 2.3 交互点

##### 2.3.1 对外依赖

- **核心模块依赖**：

  - `IUserRepository`：获取用户信息
  - `INotificationService`：处理消息通知
  - `IWebSocketService`：处理实时通信

- **业务模块依赖**：

  - `Home`模块：
    - 商品详情页的"咨询卖家"按钮
    - 需要获取商品信息和卖家信息
  - `Profile`模块：
    - 用户资料页的"发送消息"按钮
    - 需要获取用户基本信息
  - `Orders`模块：
    - 订单详情页的"咨询卖家"按钮
    - 需要获取卖家相关信息
  - `AI_Docs`模块：
    - AI 分发功能集成
    - 需要处理 AI 生成的消息内容

- **共享模块依赖**：
  - `Core/Shared`模块：
    - 文件上传服务
    - 图片处理服务
    - 通用工具类

##### 2.3.2 导航需求

- **主要页面**：

  - 聊天列表页面
  - 聊天详情页面
  - 用户信息页面

- **来源页面跳转**：

  - 从商品详情页跳转
  - 从用户资料页跳转
  - 从订单详情页跳转 (暂不实现)

- **返回处理**：
  - 支持返回到来源页面
  - 支持在聊天中查看来源信息（如商品、订单(暂不实现)）

### 3. 技术实现要点 📋

- 状态管理：Bloc
- 依赖注入：get_it + injectable
- 实时通信：WebSocket
- 本地持久化：SQLite 或 Hive
- 导航：go_router

### 4. 目录结构规划 📁

```
lib/
  ├── features/
  │   └── chat/
  │       ├── data/
  │       │   ├── datasources/
  │       │   │   ├── chat_remote_data_source.dart
  │       │   │   └── chat_local_data_source.dart
  │       │   ├── models/
  │       │   │   ├── message_model.dart
  │       │   │   └── session_model.dart
  │       │   └── repositories/
  │       │       ├── chat_repository_impl.dart
  │       │       └── message_repository_impl.dart
  │       ├── domain/
  │       │   ├── entities/
  │       │   │   ├── message.dart
  │       │   │   └── chat_session.dart
  │       │   ├── repositories/
  │       │   │   ├── i_chat_repository.dart
  │       │   │   └── i_message_repository.dart
  │       │   └── usecases/
  │       │       ├── send_message.dart
  │       │       ├── receive_message.dart
  │       │       └── manage_session.dart
  │       └── presentation/
  │           ├── bloc/
  │           │   ├── chat_bloc.dart
  │           │   ├── chat_event.dart
  │           │   └── chat_state.dart
  │           ├── pages/
  │           │   ├── chat_list_page.dart
  │           │   └── chat_detail_page.dart
  │           └── widgets/
  │               ├── message_bubble.dart
  │               └── chat_input.dart
```

### 5. 开发顺序 📝

1. 实现 Domain 层接口定义
2. 实现 Data 层的 Repository 和 DataSource
3. 实现 Domain 层的 Use Cases
4. 实现 Presentation 层的 Bloc
5. 实现 UI 组件

### 6. 测试策略 🧪

- Domain 层：单元测试 Use Cases
- Data 层：单元测试 Repository 和 DataSource
- Presentation 层：单元测试 Bloc 和 Widget 测试

### 7. 注意事项 ⚠️

- 使用 Mock 进行隔离开发
- 确保 WebSocket 连接的生命周期管理
- 处理离线消息和消息同步
- 实现消息状态追踪（发送中、已发送、已读等）
- 考虑消息持久化和缓存策略

### 4. 精化 Domain 层接口 (2024-04-14) ✅

在完成了模块边界定义和 API 分析后，我们需要精化 Domain 层接口，使其成为整个实现的"真理之源"。

#### 4.1 工作步骤

1. **创建核心实体类**：

   - 根据 3.3 节的字段映射，实现核心实体类
   - 添加详细的文档注释
   - 确保实体类具有适当的不可变性和方法

2. **定义枚举类型**：

   - 实现消息类型枚举 `MessageType`
   - 实现发送者类型枚举 `MessageSenderType`
   - 实现消息状态枚举 `MessageStatus`
   - 实现消息同步状态枚举 `MessageSyncStatus`

3. **完善仓库接口**：

   - 更新 `IChatRepository` 接口，添加详细文档
   - 更新 `IChatRealtimeService` 接口，添加详细文档
   - 更新 `IChatLocalCache` 接口，添加详细文档

4. **实现用例类**：
   - 创建并实现 `SendMessageUseCase`
   - 创建并实现 `ReceiveMessageUseCase`
   - 创建并实现 `CreateSessionUseCase`
   - 创建并实现 `ManageSessionUseCase`
   - 创建并实现 `SyncMessagesUseCase`

#### 4.2 代码示例

以下是各类型的示例实现：

##### 4.2.1 实体类示例

```dart
/// 表示一条聊天消息
///
/// 消息包含发送者、接收者、内容和各种状态信息
/// 与后端API的消息数据结构相匹配
class Message extends Equatable {
  /// 消息唯一标识符
  final String id;

  /// 消息所属的会话ID
  final String sessionId;

  /// 消息内容
  final String content;

  /// 发送者ID
  final String senderId;

  /// 发送者类型 (用户、系统等)
  final MessageSenderType senderType;

  /// 消息来源
  final MessageSourceType messageSource;

  /// 接收者ID
  final String receiverId;

  /// 接收者类型
  final MessageReceiverType receiverType;

  /// 消息发送/接收时间
  final DateTime timestamp;

  /// 消息当前状态
  final MessageStatus status;

  /// 消息类型 (文本、图片等)
  final MessageType type;

  /// 消息同步状态
  final MessageSyncStatus syncStatus;

  /// 重试次数 (用于发送失败的消息)
  final int retryCount;

  /// 错误信息 (如果发送失败)
  final ChatError? error;

  const Message({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.senderId,
    required this.senderType,
    required this.messageSource,
    required this.receiverId,
    required this.receiverType,
    required this.timestamp,
    required this.status,
    required this.type,
    required this.syncStatus,
    this.retryCount = 0,
    this.error,
  });

  /// 创建此消息的副本，但部分字段替换为新值
  Message copyWith({
    // 字段参数...
  }) {
    // 实现...
  }

  /// 判断消息是否是本地用户发送的
  bool get isFromLocalUser => senderType == MessageSenderType.USER;

  /// 判断消息是否已发送成功
  bool get isDelivered => status == MessageStatus.DELIVERED || status == MessageStatus.READ;

  /// 判断消息是否已被读取
  bool get isRead => status == MessageStatus.READ;

  @override
  List<Object?> get props => [
    id, sessionId, content, senderId, senderType, messageSource,
    receiverId, receiverType, timestamp, status, type, syncStatus,
    retryCount, error
  ];
}
```

##### 4.2.2 仓库接口示例

```dart
/// 聊天仓库接口
///
/// 负责聊天会话和消息的数据操作，包括获取、发送、更新等
abstract class IChatRepository {
  /// 获取用户的会话列表流
  ///
  /// 返回会话列表的流，当有新会话或会话更新时，流会发出新的会话列表
  Stream<List<ChatSession>> getChatSessions();

  /// 获取指定会话的消息历史
  ///
  /// [sessionId] 聊天会话ID
  /// [beforeMessageId] 可选，指定获取此消息ID之前的消息
  /// [limit] 返回的消息数量上限
  ///
  /// 返回消息列表或失败信息
  Future<Either<Failure, List<Message>>> getMessages(
    String sessionId,
    String? beforeMessageId,
    int limit,
  );

  /// 发送消息
  ///
  /// [message] 要发送的消息对象
  ///
  /// 返回发送成功的消息对象(可能包含服务器分配的ID)或失败信息
  Future<Either<Failure, Message>> sendMessage(Message message);

  // 更多方法...
}
```

#### 4.3 创建目录结构

已创建以下目录结构：

```
lib/
  ├── features/
  │   └── chat/
  │       ├── domain/
  │       │   ├── entities/
  │       │   │   ├── chat_session.dart
  │       │   │   ├── message.dart
  │       │   │   └── user.dart
  │       │   ├── repositories/
  │       │   │   ├── i_chat_repository.dart
  │       │   │   └── i_chat_realtime_service.dart
  │       │   ├── usecases/
  │       │   │   ├── send_message.dart
  │       │   │   ├── receive_message.dart
  │       │   │   └── manage_session.dart
  │       │   └── failures/
  │       │       └── chat_failure.dart
```

## 下一步计划 📅

1. 完成 Domain 层实体和接口的详细文档注释
2. 在 Data 层实现仓库接口
3. 开始实现 Presentation 层组件

## 图标说明

- ✅ 已完成
- 🚧 进行中
- 📋 技术要点
- 📁 目录结构
- 📝 开发顺序
- 🧪 测试相关
- ⚠️ 注意事项
- 📅 计划

### 5. 实现 Data 层 (2024-04-14) ✅

在完成了 Domain 层的精化工作后，下一步是实现 Data 层，它负责具体的数据获取和存储逻辑。

#### 5.1 工作步骤

1. **创建数据模型**：

   - 实现与后端 API 对应的数据传输对象（DTO）
   - 创建实体映射方法（toEntity, fromEntity）
   - 添加 JSON 序列化/反序列化支持

2. **实现数据源**：

   - 创建远程数据源（`ChatRemoteDataSource`）
   - 创建本地数据源（`ChatLocalDataSource`）
   - 实现 WebSocket 连接管理

3. **实现仓库**：

   - 实现 `ChatRepositoryImpl`
   - 实现 `ChatRealtimeServiceImpl`
   - 实现错误处理和转换逻辑

4. **创建测试数据**：
   - 创建 Mock 数据源
   - 实现假数据生成器
   - 准备测试用例

#### 5.2 目录结构

```
lib/
  ├── features/
  │   └── chat/
  │       ├── data/
  │       │   ├── datasources/
  │       │   │   ├── chat_remote_data_source.dart
  │       │   │   ├── chat_local_data_source.dart
  │       │   │   └── chat_websocket_data_source.dart
  │       │   ├── models/
  │       │   │   ├── message_dto.dart
  │       │   │   ├── chat_session_dto.dart
  │       │   │   └── user_dto.dart
  │       │   └── repositories/
  │       │       ├── chat_repository_impl.dart
  │       │       └── chat_realtime_service_impl.dart
```

#### 5.3 实现要点

- 使用 `dio` 进行 HTTP 请求
- 使用 `web_socket_channel` 处理 WebSocket 通信
- 使用 `sqflite` 或 `hive` 进行本地存储
- 实现完整的离线支持和错误恢复
- 处理网络状态监听和自动重连

### 6. 实现 Domain 逻辑 (2024-04-14) ✅

在 Data 层实现完成后，需要实现 Domain 层的核心业务逻辑，主要通过用例（Use Cases）来封装。

#### 6.1 工作步骤

1. **完善现有用例类**：

   - 完善 `SendMessageUseCase` 的业务逻辑
   - 完善 `ReceiveMessageUseCase` 的业务逻辑
   - 完善 `CreateSessionUseCase` 的业务逻辑
   - 完善 `ManageSessionUseCase` 的业务逻辑
   - 完善 `SyncMessagesUseCase` 的业务逻辑

2. **添加新的用例类**：

   - 创建 `GetChatSessionsUseCase` 获取会话列表
   - 创建 `GetMessagesUseCase` 获取历史消息
   - 创建 `SearchMessagesUseCase` 搜索消息
   - 创建 `RetryFailedMessageUseCase` 重试失败消息
   - 创建 `ObserveMessageStatusUseCase` 监听消息状态变更

3. **实现业务规则**：
   - 消息排序和分组逻辑
   - 会话排序逻辑（最新消息优先，置顶优先）
   - 消息发送前的验证规则
   - 会话状态自动更新规则

#### 6.2 实现示例

以下是 `GetChatSessionsUseCase` 的实现示例：

```dart
/// 获取聊天会话列表用例
///
/// 提供会话列表的实时流，当会话更新时会自动推送新数据
class GetChatSessionsUseCase implements UseCase<Stream<List<ChatSession>>, NoParams> {
  final IChatRepository _chatRepository;

  /// 创建获取聊天会话列表用例
  ///
  /// [chatRepository] 聊天仓库接口
  const GetChatSessionsUseCase(this._chatRepository);

  @override
  Stream<List<ChatSession>> call(NoParams params) {
    return _chatRepository.getChatSessions();
  }
}
```

#### 6.3 关键点实现

1. **流式数据处理**：

   - 使用 Streams 处理实时数据变化
   - 处理会话和消息的实时更新

2. **错误处理策略**：

   - 使用 Either 类型封装操作结果
   - 在异常场景下提供明确的 Failure 类型

3. **业务规则封装**：
   - 在用例层处理复杂的业务规则
   - 保持领域模型的纯净和无状态

### 7. 实现 Presentation 层 (2024-04-XX) 🚧

在完成 Domain 逻辑后，我们需要实现 Presentation 层，构建用户界面并处理 UI 状态。

#### 7.1 工作步骤

1. **创建 Bloc 状态管理**：

   - 创建 `ChatBloc` 处理会话列表状态
   - 创建 `MessageBloc` 处理消息交互
   - 创建相应的事件（Event）和状态（State）类

2. **实现页面**：

   - 创建 `ChatListPage` 显示会话列表
   - 创建 `ChatDetailPage` 显示会话详情和消息历史
   - 创建 `ChatSearchPage` 实现消息搜索功能

3. **开发组件**：
   - 创建 `MessageBubble` 显示消息气泡
   - 创建 `ChatInput` 实现消息输入框
   - 创建 `SessionTile` 实现会话列表项
   - 创建各种状态指示器和加载组件

#### 7.2 状态管理设计

- **ChatBloc**：

  - 管理会话列表状态
  - 处理会话置顶、标记已读、删除等操作
  - 监听新消息更新会话列表

- **MessageBloc**：
  - 管理单个会话的消息列表
  - 处理消息发送、接收、加载历史消息
  - 管理消息状态（发送中、已发送、已读等）

#### 7.3 页面交互流程

1. **聊天列表交互**：

   - 进入应用 -> 加载会话列表
   - 点击会话 -> 进入会话详情
   - 长按会话 -> 显示操作菜单（置顶、标记已读、删除等）
   - 下拉刷新 -> 同步最新会话

2. **聊天详情交互**：
   - 进入会话 -> 加载最近消息 + 标记已读
   - 上滑加载更多 -> 获取历史消息
   - 发送消息 -> 显示发送状态 -> 更新 UI
   - 接收新消息 -> 自动滚动到底部

### 8. 识别并配置外部依赖 (2024-04-XX) ✅

#### 8.1 工作内容

在这一步中，我们需要识别 Chat 模块的外部依赖，创建 Mock 实现以便于在开发和测试阶段隔离使用。

1. **识别外部服务调用**:

   - 确定聊天模块需要与哪些外部服务交互
   - 这些服务通常包括 API 客户端、本地存储、实时通信服务等

2. **创建 Mock 实现**:

   - 实现了`IChatRepository`接口的`MockChatRepository`类
   - 实现了`IChatRealtimeService`接口的`MockChatRealtimeService`类
   - 创建`MockChatData`类提供模拟数据

3. **配置 Mock 依赖**:
   - 使用依赖注入框架(GetIt)注册 Mock 实现
   - 在模块预览环境中使用 Mock 依赖

#### 8.2 实现示例

以下是`MockChatRepository`的部分实现代码，用于模拟聊天仓库的行为：

```dart
class MockChatRepository implements IChatRepository {
  final _data = MockChatData();
  final _sessionStreamController = StreamController<List<ChatSession>>.broadcast();

  MockChatRepository() {
    // 初始化时发送会话列表
    _sessionStreamController.add(_data.chatSessions);
  }

  @override
  Stream<List<ChatSession>> getChatSessions() {
    return _sessionStreamController.stream;
  }

  @override
  Future<Either<ChatFailure, Message>> sendMessage({
    required String sessionId,
    required String content,
    required MessageType type,
  }) async {
    // 模拟实现发送消息的业务逻辑
    // ...
  }

  // 其他接口实现...
}
```

此外，我们还创建了模块的依赖注入配置：

```dart
class ChatModule {
  static void registerMockDependencies(GetIt getIt) {
    // 注册Mock仓库和服务
    getIt.registerLazySingleton<IChatRepository>(
      () => MockChatRepository(),
    );

    getIt.registerLazySingleton<IChatRealtimeService>(
      () => MockChatRealtimeService(),
    );

    // 注册用例和Bloc
    // ...
  }
}
```

#### 8.3 关键点说明

- **模块隔离**: 通过 Mock 实现，使得聊天模块可以独立开发和测试，不依赖后端 API
- **真实体验**: Mock 实现模拟了真实的数据流和业务规则，提供接近真实的体验
- **易于切换**: 使用依赖注入模式，可以在不改变业务代码的情况下轻松切换实现

### 9. 编写单元测试/Widget 测试 (2024-04-XX) 🚧

#### 9.1 工作内容

这一步中，我们为 Chat 模块的各个层次编写测试用例，确保功能正确性和质量。

1. **Domain 层测试**:

   - 为 UseCase 编写单元测试，验证业务规则
   - 测试各种错误情况和边界条件

2. **Data 层测试**:

   - 为 Repository 实现编写单元测试
   - 模拟网络请求和数据库操作

3. **Presentation 层测试**:
   - 为 Bloc 编写单元测试，验证状态转换
   - 为 Widget 编写集成测试，验证 UI 行为

#### 9.2 测试示例

以下是`GetChatSessionsUseCase`的单元测试示例：

```dart
void main() {
  late GetChatSessionsUseCase useCase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = GetChatSessionsUseCase(mockRepository);
  });

  test('应该从仓库获取聊天会话流', () async {
    // 准备测试数据
    final sessions = [
      ChatSession(id: '1', title: 'Test 1', ...),
      ChatSession(id: '2', title: 'Test 2', ...),
    ];

    // 设置Mock行为
    when(mockRepository.getChatSessions())
        .thenAnswer((_) => Stream.value(sessions));

    // 执行用例
    final result = useCase();

    // 验证结果
    expect(result, emits(sessions));
    verify(mockRepository.getChatSessions()).called(1);
  });
}
```

#### 9.3 关键点说明

- **测试覆盖率**: 尽量达到高测试覆盖率，特别是核心业务逻辑
- **测试隔离**: 使用 Mock 对象隔离测试单元，避免外部依赖
- **持续集成**: 将测试集成到 CI 流程中，确保代码质量

### 10. 在预览环境中调试和验证 (2024-04-XX) 🚧

#### 10.1 工作内容

在这一步中，我们创建一个独立的预览环境，用于验证聊天模块的功能和 UI。

1. **创建预览入口**:

   - 实现`main_chat_preview.dart`作为独立入口
   - 配置路由和依赖注入

2. **调试功能**:

   - 验证聊天列表的显示和排序
   - 测试发送和接收消息
   - 验证会话状态管理的正确性

3. **验收标准**:
   - UI 与设计规范一致
   - 功能按预期工作
   - 性能满足要求

#### 10.2 预览入口示例

以下是聊天模块预览入口的实现:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册依赖
  final getIt = GetIt.instance;
  ChatModule.registerMockDependencies(getIt);

  runApp(const ChatPreviewApp());
}

class ChatPreviewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatBloc>(
          create: (_) => getIt<ChatBloc>()..add(const LoadChats()),
        ),
        BlocProvider<MessageBloc>(
          create: (_) => getIt<MessageBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: '聊天模块预览',
        theme: ThemeData(...),
        routerConfig: _router,
      ),
    );
  }

  // 路由配置...
}
```

#### 10.3 关键点说明

- **独立性**: 预览环境可以独立于主应用运行，便于开发和测试
- **真实数据**: 使用模拟数据，但反映真实的数据结构和业务逻辑
- **快速迭代**: 便于快速验证和迭代功能实现
