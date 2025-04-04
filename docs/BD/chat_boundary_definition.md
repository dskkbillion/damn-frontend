# Chat 模块边界定义 (Boundary Definition)

本文档基于初步分析、React Native 源代码、HTML 原型、API 文档以及实时通信应用的特点，定义了 `Chat` 模块的边界。

## 1. 模块名称

`Chat` (聊天)

## 2. 核心业务能力 (Business Capability)

提供用户与其他用户（或系统客服）进行实时或近实时文本、图片等消息通信的能力。主要功能包括：管理聊天会话列表（展示、排序、未读数）、进入单个会话查看历史消息、发送新消息、接收并展示新消息、更新消息已读状态。

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`ChatSession` / `Conversation`**: 聊天会话实体。
    *   `id`: (String) 会话唯一标识。
    *   `participants`: (`List<ChatParticipant>`) 参与者信息 (通常是对方，如果是群聊则有多个)。
    *   `lastMessage`: (`ChatMessage`?) 最后一条消息。
    *   `unreadCount`: (int) 当前用户的未读消息数。
    *   `lastActivityAt`: (DateTime) 最后活跃时间（用于排序）。
    *   `type`: (枚举: `private`, `group`, `system`) 会话类型 (可能需要)。
    *   `isPinned`: (bool?) 是否置顶 (可选)。
*   **`ChatParticipant`**: 聊天参与者信息。
    *   `userId`: (String) 用户 ID。
    *   `displayName`: (String) 显示名称。
    *   `avatarUrl`: (String) 头像 URL。
    *   *(这些信息可能来自 `Profile/User` 模块，或者由聊天 API 直接提供)*
*   **`ChatMessage`**: 单条聊天消息实体。
    *   `id`: (String) 消息唯一标识 (可能是本地生成+服务端确认)。
    *   `sessionId`: (String) 所属会话 ID。
    *   `senderId`: (String) 发送者用户 ID。
    *   `receiverId`: (String?) 接收者用户 ID (私聊时)。
    *   `content`: (`ChatMessageContent`) 消息内容。
    *   `contentType`: (`MessageContentType`) 消息内容类型。
    *   `timestamp`: (DateTime) 消息发送或接收时间。
    *   `status`: (`MessageStatus`) 消息状态。
*   **`ChatMessageContent`**: 消息内容的抽象基类/接口。
    *   `TextMessageContent`: (实现 `ChatMessageContent`)
        *   `text`: (String)
    *   `ImageMessageContent`: (实现 `ChatMessageContent`)
        *   `imageUrl`: (String) 图片 URL。
        *   `thumbnailUrl`: (String?) 缩略图 URL。
        *   `width`: (int?) 图片宽度。
        *   `height`: (int?) 图片高度。
    *   *(未来可能扩展: `VoiceMessageContent`, `VideoMessageContent`, `SystemNotificationContent` 等)*
*   **`MessageContentType`**: 消息内容类型 (枚举)。
    *   `text`, `image`, `voice`, `video`, `system`, etc.
*   **`MessageStatus`**: 消息状态 (枚举)。
    *   `sending` (发送中 - 本地状态)
    *   `sent` (已发送到服务器)
    *   `failed` (发送失败 - 本地状态)
    *   `delivered` (已送达对方客户端 - 如果支持)
    *   `read` (对方已读 - 如果支持)
*   **`ChatSettings`**: (可选) 聊天相关的用户设置。
    *   `receiveNotifications`: (bool) 是否接收新消息通知。
    *   `enterToSend`: (bool) 是否回车键发送消息。

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`GetChatSessionListUseCase`**: 获取用户的聊天会话列表。
    *   输入: `void` (或分页参数，如果列表很长)
    *   输出: `Either<Failure, List<ChatSession>>` (可能是一个 Stream 提供实时更新)
*   **`GetMessagesUseCase`**: 获取指定会话的历史消息（分页）。
    *   输入: `sessionId` (String), `beforeMessageId` (String?, 用于分页), `limit` (int)
    *   输出: `Either<Failure, List<ChatMessage>>`
*   **`SendMessageUseCase`**: 发送新消息。
    *   输入: `sessionId` (String), `content` (ChatMessageContent)
    *   输出: `Either<Failure, ChatMessage>` (返回带有本地 ID 和 `sending` 状态的消息，用于 UI 即时显示；成功或失败通过状态流更新)
*   **`ReceiveMessagesUseCase`**: (内部或由 Repository/Service 触发) 处理接收到的新消息。
    *   输入: `ChatMessage` (来自实时服务)
    *   输出: `void` (内部更新状态)
*   **`MarkSessionAsReadUseCase`**: 将指定会话标记为已读（更新未读数）。
    *   输入: `sessionId` (String)
    *   输出: `Either<Failure, void>`
*   **`ObserveMessageUpdatesUseCase`**: 监听消息状态的变更 (发送成功/失败, 对方已读等)。
    *   输入: `void` (或特定 `sessionId`)
    *   输出: `Stream<ChatMessage>` (包含更新后的消息)
*   **`ObserveSessionUpdatesUseCase`**: 监听会话列表的变更 (新消息、未读数变化、新会话等)。
    *   输入: `void`
    *   输出: `Stream<List<ChatSession>>` (或者 `Stream<ChatSessionUpdate>`) // 这是对 GetChatSessionListUseCase 输出的补充或替代
*   **(可选 Use Cases)**
    *   `CreateChatSessionUseCase`: (如果需要手动创建会话，例如从用户列表发起聊天)
    *   `DeleteChatSessionUseCase`: 删除会话。
    *   `PinChatSessionUseCase`: 置顶/取消置顶会话。
    *   `UploadChatImageUseCase`: 上传用于发送的图片文件。

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IChatRepository`**: 定义聊天模块的核心数据访问和操作接口。
    *   `Stream<List<ChatSession>> getChatSessions()`: 提供会话列表流。
    *   `Future<Either<Failure, List<ChatMessage>>> getMessages(String sessionId, String? beforeMessageId, int limit)`: 获取历史消息。
    *   `Future<Either<Failure, String>> sendMessage(String sessionId, ChatMessageContent content)`: 发送消息 (返回本地临时 ID 或服务端 ID)。
    *   `Future<Either<Failure, void>> markSessionAsRead(String sessionId)`: 标记会话已读。
    *   `Stream<ChatMessage> observeMessages()`: 提供收到的新消息流。
    *   `Stream<ChatMessageStatusUpdate>` observeMessageStatusUpdates(): 提供消息状态更新流。
    *   *(可能需要: `deleteSession`, `pinSession`, etc.)*
*   **`IChatRealtimeService`** (可能由 `Core/Shared` 或 `Chat` Data 层实现): 封装 WebSocket 连接管理、消息收发、状态同步的底层细节。
    *   `connect(String token)`
    *   `disconnect()`
    *   `sendMessage(OutgoingChatMessageDto message)`
    *   `Stream<IncomingChatMessageDto> get incomingMessages`
    *   `Stream<ConnectionStatus> get connectionStatus`
*   **`IChatLocalCache`** (本地数据库/存储): 负责缓存会话列表和消息。
    *   `saveSessions(List<ChatSession> sessions)`
    *   `getSessions()`
    *   `saveMessages(String sessionId, List<ChatMessage> messages)`
    *   `getMessages(String sessionId, ...)`
    *   `updateMessageStatus(String messageId, MessageStatus status)`
    *   `clearSessionMessages(String sessionId)`
*   **`IFileRepository`** (来自 `Core/Shared` 或 `File` 模块): 用于上传图片。
    *   `Future<Either<Failure, String>> uploadFile(File file, UploadPurpose purpose)` (返回文件 URL)。

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**:
    *   依赖通用的 `Failure` 定义。
    *   依赖 WebSocket 服务抽象 (`IChatRealtimeService` 的实现或接口)。
    *   依赖本地缓存/数据库服务 (`IChatLocalCache` 的实现)。
    *   依赖网络客户端 (用于 API 调用，如获取历史消息、发送图片)。
    *   依赖 `IFileRepository` (用于图片上传)。
*   **`Auth` 模块**:
    *   强依赖。需要用户 `token` 来建立实时连接，需要 `userId` 来识别消息发送者/接收者和过滤会话。
*   **`Profile/User` 模块**:
    *   可能依赖此模块获取参与者的详细信息 (`displayName`, `avatarUrl`)，如果聊天 API 或缓存数据不完整。
*   **`Notification` 模块 (如果存在)**:
    *   新消息到达时，可能需要调用 `Notification` 模块来显示系统通知（当应用在后台时）。

### 4.2. 导航需求 (Navigation Needs)

`Chat` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToChatRoom(sessionId: String, participantInfo: ChatParticipant?)`: 从会话列表进入聊天室。
*   `navigateToUserProfile(userId: String)`: 从聊天室顶部或消息发送者头像点击，跳转到用户资料页。
*   `navigateToImageViewer(imageUrl: String)`: 点击聊天中的图片消息。
*   `navigateToLogin()`: 访问聊天功能但未登录时。

---

**待确认/后续步骤:**

*   明确实时通信方案：纯 WebSocket 还是结合 Push？使用的具体技术/库？WebSocket 服务器地址？消息协议格式 (JSON?)？
*   确认 API 端点：获取会话列表、历史消息、发送消息（HTTP 后备？）、标记已读等。
*   确认 `ChatMessage` 和 `ChatSession` 实体的最终字段，特别是服务端返回的数据结构。
*   明确 `MessageStatus`（送达、已读）是否需要精确支持，以及如何实现。
*   明确图片等富媒体消息的处理流程（上传、下载、展示）。
*   确定本地缓存策略（缓存哪些数据？缓存多久？同步机制？）。
*   与 `Notification` 模块的集成方式。 