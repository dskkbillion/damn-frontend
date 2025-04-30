# Chat 模块重构任务清单 (Flutter Clean Architecture)

本文档跟踪 `Chat` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。

**当前分支**: `refactor/chat-module`

## 核心工作流步骤

- [✓] **1. 选择模块：Chat Module** (已完成)

  - [✓] 从 develop 分支创建：`refactor/chat-module`

- [✓] **2. 定义模块边界** (已完成)

  - [✓] **核心业务能力**:
    - 用户间实时消息通信（文本、图片、语音）。
    - 会话列表管理（获取、展示、更新、未读数）。
    - 消息历史记录与同步。
    - 消息状态管理（发送中、已发送、已读、失败）。
    - 消息撤回。
  - [✓] **识别核心要素 (`Domain` 层)**:
    - [✓] **Use Cases**:
      - `GetChatSessionsUseCase`: 获取会话列表。
      - `ObserveChatSessionsUseCase`: 监听会话列表变化流。
      - `GetMessagesUseCase`: 获取指定会话的消息列表（支持分页）。
      - `ObserveMessagesUseCase`: 监听指定会话的新消息流。
      - `SendMessageUseCase`: 发送消息（文本、图片、语音等）。
      - `RevokeMessageUseCase`: 撤回消息。
      - `MarkSessionAsReadUseCase`: 标记会话为已读。
      - `CreateChatSessionUseCase`: 创建或获取聊天会话。
      - `ConnectRealtimeUseCase`: 连接实时服务。
      - `DisconnectRealtimeUseCase`: 断开实时服务。
      - `ObserveConnectionStatusUseCase`: 监听实时服务连接状态。
    - [✓] **Entities** (字段严格参考 `chat_api.openapi.json` 和 `user_info.openapi.json`):
      - `ChatSession`:
        - `id`: int (会话 ID, 来自 `/api/chat/list` response.rows[x].id)
        - `doctorId`: int (对方用户 ID - 若对方是 "doctor", 来自 response.rows[x].doctorId)
        - `memberId`: int (对方用户 ID - 若对方是 "member", 来自 response.rows[x].memberId)
        - `messageNum`: int (未读消息数, 来自 response.rows[x].messageNum)
        - `context`: String? (最后一条消息内容预览, 来自 response.rows[x].context)
        - `chatMessageNewVo`: `Message`? (最后一条消息详情, 来自 response.rows[x].chatMessageNewVo)
        - `member`: `User`? (对方用户信息 - 若是 member, 来自 response.rows[x].member)
        - `doctor`: `User`? (对方用户信息 - 若是 doctor, 来自 response.rows[x].doctor)
        - `lastMessageTimestamp`: DateTime? (根据 `chatMessageNewVo.createTime` 推算)
      - `Message`:
        - `id`: int (消息 ID, 来自 `/api/chat/message/list` response.rows[x].id)
        - `chatId`: int (所属会话 ID, 来自 response.rows[x].chatId)
        - `doctorId`: int (发送者 ID - 若发送者是 "doctor", 来自 response.rows[x].doctorId)
        - `memberId`: int (发送者 ID - 若发送者是 "member", 来自 response.rows[x].memberId)
        - `context`: String (消息内容 - 文本或媒体 URL, 来自 response.rows[x].context)
        - `type`: String (`text`, `image`, `audio`, 来自 response.rows[x].type) -> 映射为 `MessageType` enum
        - `readFlg`: bool (是否已读, 来自 response.rows[x].readFlg)
        - `recipientId`: int (接收者 ID, 来自 response.rows[x].recipientId)
        - `withdrawFlag`: bool (是否已撤回, 来自 response.rows[x].withdrawFlag)
        - `senderDelFlag`: bool (发送者是否删除, 来自 response.rows[x].senderDelFlag)
        - `receiverDelFlag`: bool (接收者是否删除, 来自 response.rows[x].receiverDelFlag)
        - `member`: `User`? (发送者信息 - 若是 member, 来自 response.rows[x].member)
        - `doctor`: `User`? (发送者信息 - 若是 doctor, 来自 response.rows[x].doctor)
        - `createTime`: DateTime (消息创建时间, 来自 response.rows[x].createTime, 需要从 String 转换)
        - `localId`: String? (本地生成 ID，用于发送中的消息)
        - `sendStatus`: `MessageSendStatus` enum (本地维护: `sending`, `sent`, `failed`)
        - `fileUploadProgress`: double? (本地维护: 文件上传进度 0.0-1.0)
      - `User`: // 主要字段来自 `/api/member/info` 接口
        - `id`: int (用户 ID, 来自 `/api/member/info` response.data.id - 这是用户的内部 ID)
        - `nickName`: String (昵称, 来自 response.data.nickName)
        - `avatar`: String? (头像 URL, 来自 response.data.avatar)
        - `commonUserId`: int (通用用户 ID, **重要**: 用于 WebSocket 连接, 来自 response.data.commonUserId)
          // 其他来自 /api/member/info 的可选字段可在需要时添加，如 mobile, gender, status 等
      - `enum MessageType { text, image, audio, unknown }`
      - `enum MessageSendStatus { sending, sent, failed, none }`
      - `Failure`: (通用错误类)
    - [✓] **Repository Interfaces**:
      - `IChatRepository`:
        - `Future<Either<Failure, List<ChatSession>>> getChatSessions()`
        - `Stream<List<ChatSession>> observeChatSessions()`
        - `Future<Either<Failure, List<Message>>> getMessages(int chatId)` // API 不支持分页，获取指定会话的所有消息
        - `Future<Either<Failure, Message>> sendMessage(Message message)` // 返回发送成功后的消息（包含服务器 ID）
        - `Future<Either<Failure, void>> revokeMessage(int messageId)`
        - `Future<Either<Failure, void>> markSessionAsRead(int chatId)` // 逻辑可能在客户端或通过其他方式触发，API 未直接提供
        - `Future<Either<Failure, int>> createChatSession(int targetUserId)` // 返回 chatId
        - `Future<Either<Failure, String>> uploadFile(File file, {Function(double)? onProgress})` // 返回文件 URL
      - `IChatRealtimeService`:
        - `Future<Either<Failure, void>> connect()`
        - `Future<Either<Failure, void>> disconnect()`
        - `Stream<Message> get incomingMessages` // 监听接收到的新消息
        - `Stream<ConnectionStatus> get connectionStatus` // 监听连接状态 (connected, disconnected, connecting, error)
        - `Future<Either<Failure, void>> startHeartbeat({Duration interval = const Duration(seconds: 20)})` // 启动心跳
        - `Future<Either<Failure, void>> stopHeartbeat()` // 停止心跳
        - `Stream<HeartbeatStatus> get heartbeatStatus` // 监听心跳状态 (e.g., ok, failed, timeout)
      - `IChatLocalCache`:
        - `Future<void> saveChatSessions(List<ChatSession> sessions)`
        - `Future<List<ChatSession>> getChatSessions()`
        - `Future<void> saveMessages(int chatId, List<Message> messages)`
        - `Future<List<Message>> getMessages(int chatId)` // 获取本地缓存的所有消息
        - `Future<void> addOrUpdateMessage(Message message)`
        - `Future<void> deleteMessage(int messageId)`
        - `Future<void> clearSessionMessages(int chatId)`
        - `Future<void> clearAllCache()`
  - [✓] **识别交互点**:
    - [✓] **依赖 Core 模块**:
      - `IHttpClient`: 用于发起 REST API 请求。
      - `IWebSocketClient`: 用于实时消息通信。
      - `ILocalStorageService`: 用于本地缓存。
    - [✓] **依赖其他特性模块**:
      - `AuthModule`: 获取当前用户 ID (`memberId`) 和 Token。
      - `UserModule`: 获取用户信息（如头像、昵称）可能需要 `IUserRepository`。
      - `FilePicker/ImagePicker`: 用于选择图片/文件。
    - [✓] **导航需求**:
      - `ChatSessionsPage` -> `ChatDetailPage`
      - (可能) 其他页面 (如 `ProfilePage`, `HomePage`) -> `ChatDetailPage` (通过 `createChatSession`)

- [✓] **3. 分析参考代码 (验证与细化)** (已完成)

  - [✓] **RN 代码 (`pre-project-docs.md`)**:
    - 确认使用 Redux Toolkit (`msgSlice`) 管理状态。
    - 确认 API 端点 (`/api/chat/list`, `/common/chat/message/add`, `/api/chat/message/withdraw`, `/api/chat/addChat`, `/api/chat/get`, `/api/common/public/upload`)。
    - 确认 WebSocket 主要用于接收消息，发送通过 REST API。
    - 确认文件上传使用通用接口 (`/api/common/public/upload`) 到 OSS。
    - 确认 WebSocket URL 格式：`ws://17-8187.proxy.product-demo.cn:8000/websocket/message/{commonUserId}/member`，其中 `{commonUserId}` 需要从 `/api/member/info` 接口获取。
  - [✓] **HTML 原型 (`fronted_docs.md`)**:
    - 确认 UI 布局：顶部栏（返回、标题、操作）、消息列表（区分收发、头像、气泡、时间、图片）、底部输入栏（语音切换、输入框、表情、更多、发送）。
    - 确认交互：长按消息菜单（复制、撤回等），点击图片预览，点击"+"显示更多操作（图片、文件），点击语音切换。
    - 确认图标库：Font Awesome。

- [✓] **4. 精化 `Domain` 层接口** (已完成)

  - [✓] 在 `lib/features/chat/domain/` 目录下创建/完善 `.dart` 文件。
  - [✓] 编写最终的 `Entities`, `Use Cases` (抽象类/接口), `Repository Interfaces` 定义 (已在步骤 2 中完成)。
  - [✓] 添加详细的文档注释 (`///`)。

- [✓] **5. 实现 Flutter `Data` 层** (基本完成)

  - [✓] 在 `lib/features/chat/data/models/` 下定义 `DTOs` (e.g., `chat_session_model.dart`, `message_model.dart`, `user_model.dart`) 并实现与 `Entities` 的映射 (`fromJson`, `toEntity`)。**确保字段名与 `chat_api.openapi.json` 严格一致。**
  - [✓] 在 `lib/features/chat/data/datasources/remote/` 下创建 `IChatRemoteDataSource` 接口及 `ChatRemoteDataSourceImpl` 实现 (依赖 `Core/IHttpClient`)。实现调用 OpenAPI 定义的各个端点。
    - [✓] **注意**: 需要包含调用 `/api/member/info` 获取 `commonUserId` 的逻辑，供 WebSocket 连接使用。
  - [✓] 在 `lib/features/chat/data/datasources/realtime/` 下创建 `IChatRealtimeService` 接口及 `ChatRealtimeServiceImpl` 实现 (依赖 `Core/IWebSocketClient`)。处理 WebSocket 连接、消息接收、状态通知。
    - [✓] **WebSocket URL**: `ws://17-8187.proxy.product-demo.cn:8000/websocket/message/{commonUserId}/member`
    - [✓] **实现细节**: `connect` 方法需要先获取 `commonUserId` 再建立连接。
    - [✓] **心跳逻辑**: 实现 `startHeartbeat` (定时发送心跳包, 如每 20 秒), `stopHeartbeat`。在收到任何服务器消息时重置心跳计时器。通过 `heartbeatStatus` 流报告心跳状态。
  - [✓] 在 `lib/features/chat/data/datasources/local/` 下创建 `IChatLocalCache` 接口及 `ChatLocalCacheImpl` 实现。
    - [✓] **缓存工具**: 使用 **`hive`** (高性能 Key-Value 数据库，适合 Flutter)。
    - [✓] **缓存内容**: 缓存 `ChatSession` 列表和每个 `ChatSession` 的 `Message` 列表。
    - [✓] **缓存策略**:
      - **写入**: 获取到会话列表/消息列表后写入缓存；收到新消息或发送消息成功后更新/添加缓存；消息状态更新时更新缓存。
      - **读取**: 优先从缓存读取用于快速显示 UI，然后异步从网络获取最新数据并更新缓存和 UI。
      - **更新/失效**: 定期清理旧消息缓存（可选）；会话列表在获取时全量更新缓存；消息列表在获取时增量更新缓存（或根据分页策略）。
  - [✓] 在 `lib/features/chat/data/repositories/` 下创建 `ChatRepositoryImpl` (实现 `IChatRepository`)。
    - [✓] 注入 `IChatRemoteDataSource`, `IChatLocalCache`, `IChatRealtimeService`, `NetworkInfo`。
    - [✓] 实现接口方法，协调远程数据和本地缓存。
    - [✓] 处理数据源调用、错误转换 (API/Network Error -> Domain `Failure`) 和数据映射 (Model -> Entity)。
    - [✓] 实现文件上传逻辑，调用远程数据源的上传方法，处理进度回调。
    - [ ] **(隔离开发)** 创建 Mock 实现 (`MockChatRemoteDataSource`, `MockChatLocalCache`, `MockChatRealtimeService` in `test/mocks/` 或类似目录)。

- [✓] **6. 实现 Flutter `Domain` 逻辑** (已完成)

  - [✓] 在 `lib/features/chat/domain/usecases/` 下创建所有核心业务对应的 `Use Case` 实现类 (e.g., `GetChatSessionsUseCaseImpl`, `SendMessageUseCaseImpl` 等)。
  - [✓] 注入相应的 `Repository` 接口。
  - [✓] 实现核心业务逻辑 (通常是调用 Repository 方法，可能包含少量转换或组合逻辑)。

- [⏱️] **7. 实现 Flutter `Presentation` 层** (进行中...)

  - [✓] **状态管理 (Bloc/Cubit)**:
    - [✓] 在 `lib/features/chat/presentation/bloc/sessions/` 下创建 `ChatSessionsBloc`, `ChatSessionsState`, `ChatSessionsEvent`。
    - [✓] 在 `lib/features/chat/presentation/bloc/messages/` 下创建 `ChatMessagesBloc`, `ChatMessagesState`, `ChatMessagesEvent`。
  - [✓] **UI 页面 (`lib/features/chat/presentation/pages/`)**:
    - [✓] 创建 `ChatSessionsPage`。
    - [✓] 创建 `ChatDetailPage`。
  - [⏱️] **UI 组件 (`lib/features/chat/presentation/widgets/`)**: (进行中...)
    - [✓] `ChatSessionListItem`: 显示会话信息（头像、昵称、最后消息、时间、未读数）。
    - [✓] `ChatMessageList`: 显示消息列表，处理滚动。
    - [✓] `ChatMessageItem`: 根据消息类型 (`text`, `image`, `audio`) 和发送方渲染消息气泡。处理消息状态（发送中、失败）。
    - [✓] `ChatInputField`: 包含文本输入、附件按钮（+）、发送按钮。处理附件菜单弹出（图片、文件）、语音输入切换。
    - [✓] `AttachmentMenu`: 底部弹出的附件选项。
    - [✓] `MessageStatusIndicator`: 显示消息发送状态（✓, ✓✓, !）。
    - [ ] `ImagePreview`: 点击图片消息后的全屏预览。
    - [ ] `AudioPlayerWidget`: 用于播放语音消息。
  - [✓] **连接 UI 与 Bloc**: 在 Page 中使用 `BlocProvider` 和 `BlocBuilder`/`BlocListener`。
  - [⏱️] **实现用户交互**: 核心交互已连接 Bloc (加载、文本发送、撤回、重试)，但附件、媒体、实时更新等**未完成**。

- [✓] **8. 设置依赖注入 (DI)** (基本完成)

  - [ ] **工具**: 使用 `get_it` 和 `injectable`。
  - [✓] **配置**:
    - [ ] (手动) 添加依赖 (`get_it`, `injectable`, `injectable_generator`, `build_runner`) 到 `pubspec.yaml` 并运行 `flutter pub get`。
    - [✓] 创建 `lib/core/di/injection.dart` (或类似文件) 并添加配置函数。
    - [✓] 使用 `@injectable` 等注解标记 UseCases, Repositories, DataSources, `ChatSessionsBloc`。
    - [ ] (手动) 运行 `build_runner` 生成 `injection.config.dart`。
    - [ ] (手动) 在 `main.dart` 调用 `configureDependencies()`。
    - [ ] (需要确认/手动) 注册 `Core` 模块依赖 (`IHttpClient`, `IWebSocketClient`, `NetworkInfo`)。
    - [ ] (需要确认/手动) 确保 `ChatMessagesBloc` (带参数) 被正确注册 (例如，使用 `registerFactoryParam` in `injection.dart`)。
  - [✓] **应用**: 在 Presentation 层更新以使用 `getIt<...>()` 获取实例。

- [ ] **9. 编写单元/Widget 测试** (已跳过)

  - **说明**: 根据用户要求，此步骤跳过。

- [ ] **10. 在模块预览环境中调试和验证** (待办)

  - [ ] 创建 `main_chat_preview.dart` 作为模块预览入口。
  - [ ] 配置预览环境使用 Mock 依赖 (`registerMockDependencies` in DI)。
  - [ ] 手动测试 UI 流程、交互、状态变化、错误处理。
    - 测试会话列表加载与显示。
    - 测试进入聊天详情页，消息加载与显示。
    - 测试发送文本、图片、语音消息。
    - **注意**: 由于 API 不支持分页，消息列表是一次性加载，需要验证 `ListView.builder` 在大量消息下的渲染性能。
    - 测试消息状态显示（发送中、失败）。
    - 测试消息接收。
    - 测试消息撤回。
    - 测试 WebSocket 连接状态变化。

- [ ] **11. (模块完成后) 集成准备** (待办)

  - [ ] **DoD (Definition of Done) 检查**:
    - 核心功能（会话列表、消息收发、状态显示、图片/语音消息）按要求实现。
    - UI 与 `fronted_docs.md` 中定义的样式和交互基本一致。
    - 依赖注入配置完成。
    - 缓存按策略实现。
    - 代码遵循项目规范。
  - [ ] 进行代码评审 (Code Review)。
  - [ ] 确保 `
