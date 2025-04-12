# Chat 模块重构任务清单

本文档跟踪 `Chat` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。

**当前分支**: `refactor/chat-module-todo` (或其他相关分支)

## 核心工作流步骤 (参考 `@模块开发核心工作流.md`)

- [x] **1. 选择模块**: 已选择 `Chat` 模块。
- [x] **2. 定义模块边界 (初步)**: 已完成初步边界定义 (`@docs/BD/chat_boundary_definition.md`)。
- [x] **3. 分析参考代码 (验证与细化)**: 已分析 RN 代码 (`msgSlice`, `msgActions`) 和 API 响应示例。
- [x] **4. 精化 `Domain` 层接口 (初步)**: 已在 `@docs/BD/chat_boundary_definition.md` 中完成初步精化，包含实体、用例接口、仓库接口定义。

### Domain 层开发任务

- [ ] **4.1. 实现 `Entities`**:
    - [ ] 在 `lib/features/chat/domain/entities/` 目录下创建以下 Dart 类：
        - [ ] `chat_session.dart` (基于 `ChatSession` 定义，注意 ID 类型为 int，处理 participants 提取，标记 `lastActivityAt` 的不确定性)
        - [ ] `chat_participant.dart` (基于 `ChatParticipant` 定义，注意 ID 类型为 int，avatar 可空)
        - [ ] `chat_message.dart` (基于 `ChatMessage` 定义，注意 ID 类型为 int，处理 senderId 确定，**标记 timestamp 缺失问题**，处理 status 映射)
        - [ ] `chat_message_content.dart` (包含 `TextMessageContent`, `ImageMessageContent`, `AudioMessageContent`, `SystemMessageContent` 的基类和实现类，**File 类型待确认**)
    - [ ] 定义相关的枚举： `message_content_type.dart`, `message_status.dart`。
    - [ ] 添加详细的文档注释 (`///`)。
- [ ] **4.2. 实现 `Use Cases` 接口**:
    - [ ] 在 `lib/features/chat/domain/usecases/` 目录下创建对应的 Use Case 抽象类或接口（仅定义，不实现逻辑）：
        - [ ] `get_chat_session_list_use_case.dart`
        - [ ] `get_messages_use_case.dart`
        - [ ] `send_message_use_case.dart`
        - [ ] `mark_session_as_read_use_case.dart` (**依赖 API 确认**)
        - [ ] `observe_new_messages_use_case.dart`
        - [ ] `observe_message_updates_use_case.dart`
        - [ ] `observe_session_updates_use_case.dart`
        - [ ] `create_chat_session_use_case.dart`
        - [ ] `get_chat_session_details_use_case.dart`
        - [ ] `revoke_message_use_case.dart`
        - [ ] `delete_message_use_case.dart` (**行为待确认**)
        - [ ] `upload_chat_file_use_case.dart` (如果支持文件/音频发送)
- [ ] **4.3. 实现 `Repository Interface`**:
    - [ ] 在 `lib/features/chat/domain/repositories/` 目录下创建 `i_chat_repository.dart` 接口定义。
    - [ ] 包含 `@docs/BD/chat_boundary_definition.md` 中定义的 **所有** 方法签名（注意 ID 类型为 int）。

### Data 层开发任务

- [ ] **5.1. 定义 `Data Models` (DTOs)**:
    - [ ] 在 `lib/features/chat/data/models/` 目录下创建 Dart 类，精确匹配 API 响应结构：
        - [ ] `chat_session_model.dart` (包含 `fromJson`, `toEntity`；处理 `member`/`doctor` 到 `participants` 的转换；处理 `chatMessageNewVo` 映射；**处理时间戳缺失**)
        - [ ] `chat_participant_model.dart` (包含 `fromJson`, `toEntity`)
        - [ ] `chat_message_model.dart` (包含 `fromJson`, `toEntity`；处理 `member`/`doctor` 到 `senderId` 的转换；**处理时间戳缺失**)
    - [ ] 确保模型能正确解析提供的 JSON 示例。
- [ ] **5.1.1. 创建 Mock 数据样本**: 
    - [ ] 基于定义的 Models (`ChatSessionModel`, `ChatMessageModel` 等) 创建 JSON 或 Dart Map 格式的模拟数据，用于后续测试和预览。
- [ ] **5.2. 实现 `RemoteDataSource`**:
    - [ ] 在 `lib/features/chat/data/datasources/remote/` 下创建 `i_chat_remote_datasource.dart` 接口。
    - [ ] 创建 `chat_remote_datasource_impl.dart` 实现类。
    *   [ ] 实现 `getChatSessions` (调用 `POST /api/chat/list`)。
    *   [ ] 实现 `getMessages` (调用 `POST /api/chat/message/list`)。
    *   [ ] 实现 `sendMessage` (调用 `POST /common/chat/message/add`, **需要确认请求体构造方式**)。
    *   [ ] 实现 `createChatSession` (调用 `POST /api/chat/addChat`)。
    *   [ ] 实现 `getChatSessionDetails` (调用 `GET /api/chat/get`)。
    *   [ ] 实现 `revokeMessage` (调用 `POST /api/chat/message/withdraw`)。
    *   [ ] 实现 `deleteMessage` (调用 `POST /api/chat/message/delete`, **行为待确认**)。
    *   [ ] (可选) 尝试实现 `markSessionAsRead` (**API 待确认**)。
    *   [ ] 注入 `HttpClient` (来自 `Core` 模块或直接使用如 `dio`)。
    *   [ ] 处理 API 调用错误并抛出自定义异常 (如 `ServerException`)。
- [ ] **5.3. 实现 `LocalDataSource` (使用 Drift)**:
    *   [ ] 定义 Drift 数据库 (`lib/core/database/app_database.dart` 或 `lib/features/chat/data/datasources/local/chat_database.dart`)。
    *   [ ] 定义 `ChatSession` 和 `ChatMessage` 的 Drift 表 (`Table`) 定义。**需要仔细设计表结构以高效存储和查询数据，特别是处理时间戳缺失问题（例如，使用本地接收时间或列表顺序作为替代？）**。
    *   [ ] 在 `lib/features/chat/data/datasources/local/` 下创建 `i_chat_local_datasource.dart` 接口。
    *   [ ] 创建 `chat_local_datasource_impl.dart` 实现类，注入 Drift Database/DAO。
    *   [ ] 实现接口中定义的所有方法（`saveSessions`, `getSessions`, `saveMessages`, `getMessages` (分页), `addMessage`, `updateMessageStatus`, `deleteMessage` 等）。
- [ ] **5.4. 实现 `RealtimeService`**:
    *   [ ] 在 `lib/features/chat/data/datasources/realtime/` 下创建 `i_chat_realtime_service.dart` 接口。
    *   [ ] 创建 `chat_realtime_service_impl.dart` 实现类 (例如使用 `web_socket_channel`)。
    *   [ ] 实现 `connect` (**需要确认认证方式**) 和 `disconnect`。
    *   [ ] 实现 `connectionStatusStream`。
    *   [ ] 实现 `incomingMessagesStream` (**需要确认消息 JSON 结构并解析为 `ChatMessageModel`**)。
- [ ] **5.5. 实现 `Repository Implementation`**:
    *   [ ] 在 `lib/features/chat/data/repositories/` 下创建 `chat_repository_impl.dart`。
    *   [ ] 实现 `IChatRepository` 接口。
    *   [ ] 注入 `IChatRemoteDataSource`, `IChatLocalDataSource`, `IChatRealtimeService` (以及网络状态检查器)。
    *   [ ] 实现所有接口方法，协调数据源（遵循缓存策略：数据库优先），处理错误并映射到 `Domain` `Failure`。
    *   [ ] **重点处理 `sendMessage` 的状态流转和本地/远程同步逻辑。**
    *   [ ] **设计 `observeSessionUpdates` 和 `observeMessageUpdates` 的实现机制 (可能依赖 Drift 的 Stream 或 StreamController)。**
    *   [ ] **处理消息时间戳缺失带来的影响（如排序问题）。**

### Domain 层实现任务

- [ ] **6. 实现 `Use Cases` 逻辑**:
    - [ ] 在 `lib/features/chat/domain/usecases/` 目录下创建 Use Case 实现类。
    - [ ] 注入 `IChatRepository` 接口。
    - [ ] 实现各个 Use Case 的 `call` 或 `execute` 方法，调用 Repository 的相应方法。
    - [ ] **对于依赖待确认 API 的 Use Case (如 `MarkSessionAsRead`)，可以先留空或抛出未实现错误。**

### Presentation 层开发任务

- [ ] **7.1. 实现状态管理 (Bloc/Cubit)**:
    - [ ] 在 `lib/features/chat/presentation/bloc/` (或 `cubit/`) 目录下创建：
        - [ ] `chat_list/chat_list_bloc.dart` (处理 `LoadChatList`, `SessionTapped` 事件，管理 `ChatListState` - isLoading, error, sessions)。
        - [ ] `chat_room/chat_room_bloc.dart` (处理 `LoadInitialMessages`, `LoadMoreMessages`, `TextMessageSent`, `ImageMessageSent`, `MessageReceived`, `MessageStatusUpdated` 等事件，管理 `ChatRoomState` - isLoading, messages, hasMore, inputText 等)。
    - [ ] 注入相应的 `Use Cases`。
- [ ] **7.2. 实现 UI 页面 (`Screens`)**:
    - [ ] 在 `lib/features/chat/presentation/screens/` 目录下创建：
        - [ ] `chat_list_screen.dart` (构建页面布局，使用 `BlocBuilder` 监听 `ChatListBloc` 状态，显示列表、加载指示器或错误信息)。
        - [ ] `chat_room_screen.dart` (构建页面布局，包括 App Bar, 消息列表 (使用 `ListView.builder` 并反转), 输入框区域；使用 `BlocBuilder`/`BlocListener` 监听 `ChatRoomBloc` 状态)。
- [ ] **7.3. 实现 UI 组件 (`Widgets`)**:
    - [ ] 在 `lib/features/chat/presentation/widgets/` 目录下创建可复用组件：
        - [ ] `chat_list_item.dart` (根据 `ChatSession` 数据显示头像、名称、最后消息预览、**未读数**)。
        - [ ] `message_item.dart` (根据 `ChatMessage` 数据显示头像、气泡、内容(文本/图片/音频)、时间戳(**需处理缺失**)、**发送状态指示器**)。
        - [ ] 其他可能需要的组件 (如输入框封装、菜单等)。

### 测试任务

- [ ] **9. 编写单元/Widget 测试**:
    - [ ] **Domain 层**: 测试 `Use Cases` (注入 Mock `IChatRepository`)。
    - [ ] **Data 层**: 测试 `ChatRepositoryImpl` (注入 Mock DataSources/Service)，测试 `DataSource`/`Service` 实现 (可能需要 Mock HTTP Client/WebSocket/Drift)。
    - [ ] **Presentation 层**: 测试 `Blocs/Cubits` (使用 `bloc_test`，注入 Mock Use Cases)，测试关键 `Widgets`。
    - [ ] 确保达到合理的测试覆盖率。

### 集成与验证任务

- [ ] **8 & 10. 配置 Mock 依赖与预览环境**:
    - [ ] (可选) 创建 `main_chat_preview.dart`。
    *   [ ] 在 DI 配置中为 `Auth`, `Profile`, `File` 等模块提供 Mock 实现。
    *   [ ] 配置 Mock `IChatRepository` 或 Mock DataSources/Service 以提供模拟数据。
    *   [ ] 运行预览环境，调试 UI 和基本流程。
- [ ] **11 & 12. 集成到主工程**:
    *   [ ] (模块完成后) 合并代码到主开发分支。
    *   [ ] 在主工程 DI 配置中替换 Mock 为真实实现。
    *   [ ] 注册 Chat 模块的路由 (`ChatListScreen`, `ChatRoomScreen`) 到 GoRouter。
    *   [ ] 执行集成测试，确保与其他模块（Auth, Profile, Navigation）交互正常。
    *   [ ] **进行实际的 API 对接测试，验证之前待确认的 API 行为和数据结构。**

**特别注意的待确认点 (影响开发进度):**

*   **消息时间戳缺失**: 在获取后端确认前，需要设计临时方案（如使用本地时间或假定列表顺序）。
*   **标记已读机制**: 在确认 API 或自动机制前，`MarkSessionAsReadUseCase` 无法完全实现。
*   **发送富媒体请求格式**: 在确认前，`SendMessageUseCase` 对图片/音频的处理逻辑不完整。
*   **WebSocket 消息结构**: 在确认前，`IChatRealtimeService` 的消息解析可能不准确。
*   **获取当前用户 ID**: 需要依赖 Auth 模块提供。
*   **`distribute` 消息类型处理**: 需要明确其展示逻辑。
*   **删除消息行为**: 需要确认。 