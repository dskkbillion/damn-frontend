# Chat 重构核心工作流步骤

### 1. **选择模块：Chat Module** ✅

#### 分支创建 (2024-04-07)

- 从 develop 分支创建新分支：`refactor/chat-module`
- 分支创建命令：
  ```bash
  git checkout develop
  git pull origin develop
  git checkout -b refactor/chat-module
  ```

### 2. **定义模块边界** ✅

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

#### 2.2 识别核心要素 (`Domain` 层)

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

### 3. **分析参考代码** (2024-04-07) ✅

#### 3.1 验证边界

通过分析参考的 HTML 原型和 API 定义，验证了我们的模块边界定义，发现以下几点：

##### 3.1.1 功能验证

- **消息类型**：

  - ✅ 文本消息 - 已覆盖在我们的定义中
  - ✅ 图片消息 - 已覆盖在我们的定义中
  - ✅ 语音消息 - 已覆盖在我们的定义中
  - ✅ 系统消息 - 已覆盖在我们的定义中
  - ❌ 富文本消息 - 未在 HTML 原型中发现，但考虑未来扩展性已添加
  - ❓ 位置消息 - 在 HTML 原型中存在但未纳入当前设计，需考虑是否添加

- **会话管理**：

  - ✅ 会话列表 - 与 HTML 原型匹配
  - ✅ 会话状态管理 - 与 HTML 原型匹配
  - ✅ 未读消息计数 - 与 HTML 原型匹配
  - ❌ 会话置顶功能 - HTML 原型中存在但未完全覆盖 [TODO: 下一次开发中实现]
  - ❌ 会话静音功能 - HTML 原型中存在但未完全覆盖 [TODO: 下一次开发中实现]

- **消息交互**：
  - ✅ 消息发送 - 与 API 定义匹配
  - ✅ 消息接收 - 与 API 定义匹配
  - ✅ 消息历史获取 - 与 API 定义匹配
  - ✅ 消息状态更新 - 与 API 定义匹配
  - ❌ 消息检索功能 - 未在 API 中发现，但为常见功能

##### 3.1.2 接口验证

API 接口与我们定义的 Repository 接口对比：

| API 端点                                                  | 方法 | 功能           | 我们的接口方法                     | 状态                |
| --------------------------------------------------------- | ---- | -------------- | ---------------------------------- | ------------------- |
| `/api/chat/addChat`                                       | POST | 添加聊天室     | `IChatRepository.createSession`    | ✅ 已覆盖(但需改名) |
| `/api/chat/list`                                          | POST | 查询聊天室列表 | `IChatRepository.getChatSessions`  | ✅ 已覆盖           |
| `/api/chat/message/list`                                  | POST | 消息列表       | `IChatRepository.getMessages`      | ✅ 已覆盖           |
| `/api/chat/message/delete`                                | POST | 删除聊天记录   | `IChatRepository.deleteMessage`    | ✅ 已覆盖           |
| `/api/chat/message/withdraw`                              | POST | 撤回消息       | `IChatRepository.revokeMessage`    | ✅ 已覆盖           |
| `/common/chat/message/add`                                | POST | 发送消息       | `IChatRepository.sendMessage`      | ✅ 已覆盖           |
| `/api/chat/get`                                           | GET  | 聊天室详情     | `IChatRepository.getSessionDetail` | ✅ 已覆盖           |
| `/api/member/info`                                        | GET  | 获取用户资料   | `IUserRepository.getUserInfo`      | ✅ 需外部依赖       |
| `${WS_BASE_URL}/websocket/message/S{commonUserId}/member` | -    | 实时消息通信   | `IChatRealtimeService` 相关方法    | ✅ 已覆盖           |

**需要补充的接口方法**：

1. `Future<Either<Failure, ChatSession>> getSessionDetail(String sessionId)`：获取会话详情 ✅ 已补充

##### 3.1.3 实体验证

数据模型与我们定义的实体类对比：

- **ChatSession**：

  - ✅ id, title - 与 API 响应匹配
  - ✅ lastMessage - 与 API 响应匹配
  - ✅ timestamp - 与 API 响应匹配
  - ❌ pinned 状态 - API 中未明确 [TODO: 下一次开发中实现]
  - ❌ muted 状态 - API 中未明确 [TODO: 下一次开发中实现]

- **Message**：
  - ✅ id, content, type - 与 API 响应匹配
  - ✅ senderId, timestamp - 与 API 响应匹配
  - ✅ status - 与前端需求匹配
  - ❌ parentMessageId - API 中存在但未完全覆盖

#### 3.2 提取实现细节

##### 3.2.1 业务逻辑细节（Domain 层）

1. **消息发送流程**：

   - 用户输入消息内容 → 本地生成临时消息 ID → 添加到本地列表（状态：发送中）
   - 通过 REST API（`/common/chat/message/add`）发送消息 → 服务器确认接收（状态：已发送）
   - 消息发送失败时 → 标记状态，提供重试机制

2. **消息同步机制**：

   - 应用启动时 → 加载本地缓存会话和消息 → 连接 WebSocket
   - 连接成功后 → 同步最新消息（获取本地最后消息 ID 之后的消息）
   - 本地发送失败的消息 → 重新发送
   - 处理自动回复场景 → 通过 WebSocket 接收到自动回复消息时 → 执行刷新逻辑更新已读状态

3. **已读状态处理**：
   - 进入聊天室 → 标记当前会话所有消息为已读
   - 服务器自动处理已读状态 → 无需客户端发送已读回执
   - 同步更新本地存储的已读状态
   - 对于自动回复的消息 → 检测到自动回复时主动刷新状态 → 更新未读消息计数

##### 3.2.2 数据交互细节（Data 层）

1. **WebSocket 接口定义**：

   通过分析现有代码，WebSocket 接口需要支持以下功能：

   - **连接管理接口**：

     - `connect(String token)` - 建立 WebSocket 连接并进行认证
     - `disconnect()` - 主动断开连接并清理资源
     - `reconnect()` - 尝试重新连接 WebSocket
     - `isConnected()` - 检查当前连接状态

   - **WebSocket URL 获取**：

     - 使用格式：`${WS_BASE_URL}/websocket/message/S{commonUserId}/member`
     - `commonUserId` 需从用户资料接口 `/api/member/info` 中获取
     - 应用启动时获取用户资料，保存 `commonUserId` 用于 WebSocket 连接

   - **心跳机制**：

     - 每 20 秒发送一次心跳包：`{ type: "heartbeat" }`
     - 需要在收到服务器任何消息后重置心跳计时器
     - 心跳失败应触发重连机制

   - **认证流程**：

     - 连接成功后立即发送认证消息：`{ type: "auth", token: "用户令牌" }`
     - 监听认证结果，认证失败需要处理重连或错误提示

   - **消息接收**：

     - 通过 `Stream<IncomingMessageDto> get incomingMessages` 监听服务器推送的新消息
     - 接收到消息后将其分发到相应的状态管理器
     - 注意：WebSocket 仅用于接收消息，发送消息通过 REST API 实现

   - **错误处理策略**：
     - 实现指数退避重连（2^n 秒，最大 10 秒）
     - 设置最大重连次数（2 次），超过后需通知 UI 显示错误
     - 提供连接状态监听机制，允许 UI 响应状态变化

2. **本地存储结构**：
   - 会话表：`id`, `title`, `user_id`, `last_message_id`, `unread_count`, `timestamp`, `is_pinned`, `is_muted`
   - 消息表：`id`, `conversation_id`, `content`, `type`, `sender_id`, `status`, `timestamp`, `local_status`, `retry_count`

##### 3.2.3 UI 流程与交互（Presentation 层）

1. **关键页面流程**：

   - 会话列表页 → 点击会话 → 聊天详情页
   - 用户资料页 → 点击"发送消息" → 创建会话 → 聊天详情页
   - 聊天详情页 → 点击头像 → 用户资料页
   - 聊天详情页 → 点击订单图标 → 订单详情页 (暂不实现)

2. **UI 交互事件**：

   - 长按消息 → 显示操作菜单（复制、删除、撤回）
   - 点击图片消息 → 全屏预览
   - 点击语音消息 → 播放语音
   - 输入框右侧"+" → 显示更多操作（图片、文件）

3. **UI 状态反馈**：

   - 消息发送中 → 显示加载图标
   - 消息发送成功 → 显示单个对勾
   - 消息已读 → 显示双对勾（如果服务端支持）
   - 消息发送失败 → 显示红色感叹号，点击重试

4. **消息操作分析**：

   参考 React Native 代码中的 `chatroom.tsx` 和 `msgSlice.ts`，消息操作的关键实现包括：

   - **消息撤回流程**：

     - 长按消息 → 显示上下文菜单 → 选择"撤回"
     - 调用 `/api/chat/message/withdraw` API 端点
     - 成功后从本地消息列表中移除该消息
     - 通知 UI 更新，显示成功提示

   - **消息类型处理**：

     - 支持的消息类型：`text`（文本）、`image`（图片）、`audio`（语音）
     - 每种类型有专门的渲染组件和交互逻辑
     - 图片消息支持全屏预览
     - 语音消息支持播放控制

##### 3.2.4 技术实现关键点

1. **WebSocket 连接管理**：

   - 使用心跳机制（每 20 秒发送一次）保持连接活跃
   - 监听网络状态变化，自动重连
   - 连接断开后实现指数退避重连策略（最大尝试 2 次）
   - 使用 Redux 存储连接状态和错误状态

2. **消息持久化与状态管理**：

   - 使用 Redux 管理消息和会话状态
   - 消息获取模式：
     - 应用启动或进入会话时通过 API 加载历史消息
     - 通过 WebSocket 实时接收新消息
     - 通过 REST API（`/common/chat/message/add`）发送消息，发送前先添加到本地状态
   - 关键 Redux Action：
     - `createRoom` - 创建聊天室
     - `sendMsg` - 发送消息（通过 REST API）
     - `getMsgList` - 获取消息列表
     - `getChatRoomList` - 获取会话列表
     - `revokeMessage` - 撤回消息
     - `deleteMessage` - 删除消息
     - `receiveMessage` - 接收 WebSocket 消息

3. **多媒体消息处理**：

   - 文件上传通用流程：

     - 所有文件（图片、语音等）统一调用公共接口 `/api/common/public/upload` 上传到 OSS
     - 接口参数为 `multipart/form-data` 格式，包含 `file` 字段
     - 接口返回格式：`{ "msg": string, "code": number, "data": { "fileName": string, "url": string } }`
     - 上传成功后获取返回的 `data.url` 用于后续操作

   - 图片发送流程：
     - 拍照或从相册选择 → 预处理（可能包括压缩）→ 调用 `/api/common/public/upload` 上传到 OSS
     - 获取到图片 URL 后，作为图片类型消息发送
   - 图片接收与保存：
     - 接收图片消息 → 显示图片预览
     - 长按图片 → 提供保存选项 → 保存至设备相册
     - 实现图片缓存，减少重复下载
     - 支持图片本地保存功能，用户可将聊天中的图片保存到本地相册
     - 实现图片保存权限请求与结果反馈
   - 语音发送流程：
     - 录制语音 → 保存为本地文件 → 调用 `/api/common/public/upload` 上传到 OSS
     - 获取到语音 URL 后，作为语音类型消息发送
   - 消息类型按不同方式渲染：
     - 文本：显示文本消息气泡
     - 图片：显示图片预览，支持点击放大
     - 语音：显示语音播放控件

4. **用户交互优化**：
   - 实现消息长按操作菜单（复制、撤回、删除）
   - 图片消息支持全屏预览和缩放
   - 语音消息支持播放和暂停
   - 聊天室高度自适应键盘显示/隐藏
   - 切换到其他页面后返回，保持聊天历史记录
   - 消息发送时增加本地反馈，减少感知延迟

#### 3.3 接口字段与实体映射

通过分析后端 API 响应和我们的实体类定义，整理出以下字段映射关系：

##### 3.3.1 ChatSession 字段映射

| API 字段名                  | 实体字段名     | 类型     | 说明                                 |
| --------------------------- | -------------- | -------- | ------------------------------------ |
| `id`                        | `id`           | String   | 会话唯一标识                         |
| `title`                     | `title`        | String   | 会话名称（通常是对方用户名）         |
| `user_id`                   | `userId`       | String   | 当前用户 ID                          |
| `updated_at`                | `updatedAt`    | DateTime | 会话更新时间                         |
| `created_at`                | `createdAt`    | DateTime | 会话创建时间                         |
| _来自最后一条消息_          | `lastMessage`  | Message? | 最后一条消息                         |
| _来自返回数据的 total 属性_ | `unreadCount`  | int      | 未读消息数                           |
| _本地维护_                  | `targetUserId` | String   | 对方用户 ID (通过分析会话参与者得到) |
| _本地维护_                  | `pinned`       | bool     | 是否置顶(本地状态)                   |
| _本地维护_                  | `muted`        | bool     | 是否静音(本地状态)                   |

##### 3.3.2 Message 字段映射

| API 字段名                 | 实体字段名      | 类型       | 说明                        |
| -------------------------- | --------------- | ---------- | --------------------------- |
| `id`                       | `id`            | String     | 消息唯一标识                |
| `conversation_id`          | `sessionId`     | String     | 聊天室 ID(对应会话 ID)      |
| `content`/`context`        | `content`       | String     | 消息内容                    |
| `role` 或 发送者标识       | `senderId`      | String     | 发送者 ID                   |
| _根据 role 字段判断_       | `senderType`    | enum       | 发送者类型 (user/assistant) |
| `messageType`              | `messageSource` | enum       | 消息来源                    |
| `recipientId`/`receiverId` | `receiverId`    | String     | 接收者 ID                   |
| _根据角色判断_             | `receiverType`  | enum       | 接收者类型                  |
| `timestamp`/`createTime`   | `timestamp`     | DateTime   | 消息发送时间                |
| `type`                     | `type`          | enum       | 消息类型(text/image/audio)  |
| `readTime`                 | _用于状态判断_  | DateTime?  | 读取时间 (判断已读状态)     |
| `message_id`               | _备用 ID_       | String     | 消息 ID (部分 API 返回)     |
| `parent_message_id`        | _父消息 ID_     | String     | 父消息 ID (对于回复类消息)  |
| _本地维护_                 | `syncStatus`    | enum       | 同步状态                    |
| _本地维护_                 | `retryCount`    | int        | 重试次数                    |
| _本地维护_                 | `error`         | ChatError? | 错误信息                    |

##### 3.3.3 数据转换逻辑

1. **DTO 到实体转换**：

   - `ChatSessionDto` → `ChatSession`：

     - 将 `id` 直接映射为会话 ID
     - 将 `title` 映射为会话标题
     - 将 `user_id` 映射到 `userId`
     - 将 `updated_at` 转换后映射到 `updatedAt`
     - 将 `created_at` 转换后映射到 `createdAt`
     - 从会话列表或消息历史中提取最后一条消息作为 `lastMessage`
     - 将未读计数映射到 `unreadCount`
     - 分析会话参与者后设置 `targetUserId`
     - 为本地状态字段 `pinned` 和 `muted` 设置默认值为 false

   - `MessageDto` → `Message`：
     - 将消息 `id` 直接映射
     - 将 `conversation_id` 映射到 `sessionId`
     - 将消息内容映射到 `content`
     - 根据 `role` 或发送者信息设置 `senderId` 和 `senderType`
     - 根据 `type` 字段设置消息类型
     - 将接收者 ID 映射到 `receiverId`
     - 将时间戳转换后映射到 `timestamp`
     - 根据 `readTime` 等信息设置消息状态
     - 设置初始 `syncStatus` 为 SYNCED（对于从服务器获取的消息）
     - 本地新消息设置 `syncStatus` 为 PENDING 或 SYNCING

2. **实体到 DTO 转换**：

   - `ChatSession` → `ChatSessionDto`：

     - 将会话 ID 和用户 ID 映射到相应字段
     - 只包含服务器需要的字段
     - 省略本地状态字段 `pinned` 和 `muted`

   - `Message` → `MessageDto`：
     - 将 `content` 映射到适当的内容字段
     - 将 `sessionId` 映射到 `conversation_id`
     - 根据 `senderType` 设置正确的发送者字段
     - 将 `receiverId` 映射到接收者 ID 字段
     - 将消息类型 `type` 正确映射为 API 期望的类型字符串
     - 省略本地状态相关字段

这些映射关系将指导我们在数据层实现中正确转换 API 响应数据和实体对象，确保数据流在整个应用中的一致性。

### 4. **精化 `Domain` 层接口** ✅

- **目标**: 最终确定 `Domain` 层的接口及其详细契约，使其成为代码实现的"真理之源"。
- **细节与说明**:
  - 在模块的 `domain/` 目录下创建或完善 `.dart` 文件。
  - **编写代码**: 定义 `Entities`, `Use Cases` (通常是抽象类或接口), `Repository Interfaces`。
  - **添加详细文档注释 (Doc Comments `///`)**: 对每个接口、方法、参数、返回值进行清晰说明，包括其目的、类型、约束（是否可空）、可能的错误/异常类型。这是最重要的"契约"文档。

### 5. **实现 Flutter `Data` 层** ✅

- **目标**: 实现 `Domain` 层定义的数据仓库接口，负责具体的数据获取和存储。
- **细节与说明**:
  - 在 `data/models/` 下创建以下模型类:
    - ✅ `chat_message_model.dart`: 聊天消息模型类，用于包装 MessageDto 并提供数据转换
    - ✅ `chat_session_model.dart`: 聊天会话模型类，用于包装 ChatSessionDto 并提供数据转换
    - ✅ `user_model.dart`: 用户模型类，用于包装 UserDto 并提供数据转换
    - ✅ `message_status_update_model.dart`: 消息状态更新模型类，用于处理消息状态更新的数据转换
  - ✅ 更新 `models.dart` 导出文件，统一导出所有模型类
  - 所有模型类实现了:
    - 从 DTO 创建模型的方法
    - 从领域实体创建模型的方法
    - 与 JSON 数据互相转换的方法
    - 转换为领域实体的方法
  - 接下来需要实现:
    - [ ] 在 `data/repositories/` 下创建仓库实现类
    - [ ] 在 `data/datasources/` 下创建远程和本地数据源
    - [ ] 处理数据层错误和异常转换
    - [ ] 创建 Mock 数据源用于测试

### 6. **实现 Flutter `Domain` 逻辑** ✅

- **目标**: 实现 `Use Cases`，封装核心业务规则。
- **细节与说明**:
  - 在 `domain/usecases/` 下完善和创建了以下用例类:
    - ✅ `send_message_usecase.dart`: 发送消息用例，包含发送和重试功能
    - ✅ `receive_message_usecase.dart`: 接收消息用例，处理新消息和状态更新流
    - ✅ `create_session_usecase.dart`: 创建会话用例，支持带初始消息创建会话
    - ✅ `manage_session_usecase.dart`: 管理会话用例，提供会话基本操作功能
    - ✅ `sync_messages_usecase.dart`: 同步消息用例，处理消息获取和状态同步
    - ✅ `get_message_history_usecase.dart`: 消息历史查询用例，支持分页和过滤功能
    - ✅ `manage_notifications_usecase.dart`: 通知管理用例，处理会话静音和置顶功能
    - ✅ `manage_realtime_connection_usecase.dart`: 实时连接管理用例，处理 WebSocket 连接
  - ✅ 更新 `usecases.dart` 导出文件，统一导出所有用例类
  - ✅ 扩展 `IChatLocalCache` 接口，添加会话设置管理功能
  - 所有用例类遵循:
    - 依赖注入原则：通过构造函数注入仓库接口
    - 单一职责原则：每个用例专注于特定的业务功能
    - 详细文档注释：为每个方法提供清晰的文档
    - 错误处理：所有操作都返回 Either 类型，左侧为失败，右侧为成功

### 7. **实现 Flutter `Presentation` 层** ✅

- **目标**: 构建用户界面和处理 UI 状态。
- **细节与说明**:
  - 创建了页面组件:
    - ✅ `chat_sessions_page.dart`: 会话列表页面，展示所有聊天会话
    - ✅ `chat_detail_page.dart`: 聊天详情页面，展示会话内的消息
    - ✅ `message_search_page.dart`: 消息搜索页面，支持全局和会话内搜索
  - 创建了可复用的 UI 组件:
    - ✅ `chat_session_list_item.dart`: 会话列表项组件，包含头像、标题、时间等
    - ✅ `chat_message_list.dart`: 消息列表组件，支持分页加载和高亮显示特定消息
    - ✅ `chat_message_item.dart`: 消息项组件，支持不同类型消息和搜索高亮
    - ✅ `chat_input_box.dart`: 聊天输入框组件，支持文本、图片、语音消息
    - ✅ `loading_indicator.dart`: 加载指示器组件
    - ✅ `empty_sessions_placeholder.dart`: 空会话占位符组件
  - 创建了状态管理类:
    - ✅ 会话列表状态管理: `chat_sessions_bloc.dart`、`chat_sessions_event.dart`、`chat_sessions_state.dart`
    - ✅ 聊天消息状态管理: `chat_messages_event.dart`、`chat_messages_state.dart`
    - ⏱️ 消息搜索状态管理: `message_search_bloc.dart`、`message_search_event.dart`、`message_search_state.dart`
  - 页面交互实现:
    - ✅ 会话列表支持置顶、删除、静音等操作
    - ✅ 聊天详情页支持发送文本、图片、语音消息
    - ✅ 消息列表支持分页加载、长按操作（复制、撤回、删除）
    - ✅ 消息搜索支持全局和会话内搜索，高亮显示匹配文本
  - 状态管理特性:
    - ✅ 使用 BLoC 模式实现状态管理，隔离 UI 逻辑与业务逻辑
    - ✅ 支持实时消息更新，自动刷新会话和消息列表
    - ✅ 处理加载、错误、空状态等不同状态的显示
    - ✅ 支持消息发送状态的实时反馈

### 8. **识别并配置外部依赖 (隔离开发)** ✅

- **目标**: 为模块的独立开发、测试和预览配置 Mock 依赖。
- **细节与说明**:
  - **识别了外部调用**:
    - ✅ HTTP 客户端依赖：使用`IHttpClient`接口隔离网络请求实现
    - ✅ WebSocket 服务依赖：使用`IChatRealtimeService`接口隔离实时通信实现
    - ✅ 本地存储依赖：使用`ChatLocalDataSource`接口隔离本地数据存取
  - **配置了 Mock 依赖**:
    - ✅ 实现了`MockHttpClient`类，模拟所有聊天相关 API 响应:
      - 处理聊天会话列表获取
      - 处理消息列表获取，支持分页
      - 处理发送消息，支持不同类型消息
      - 处理会话和消息的创建、更新、删除操作
      - 模拟文件上传操作（图片、语音等）
    - ✅ 在`ChatModule`中配置依赖注入:
      - 创建了`registerMockDependencies`方法注册所有 Mock 依赖
      - 在预览环境中使用 Mock 依赖替代真实实现
  - **实现了预览入口**:
    - ✅ 创建`main_chat_preview.dart`作为模块独立预览入口
    - ✅ 配置预览环境使用 Mock 依赖
    - ✅ 支持在隔离环境中测试聊天模块的所有功能

### 9. **编写单元/Widget 测试** ⏱️

- **目标**: 确保模块内部代码的质量和正确性。
- **细节与说明**:
  - **`Domain` 层测试**:
    - ✅ 为核心实体类编写单元测试，验证重要的业务规则和验证逻辑
    - ⏱️ 为用例类编写单元测试，验证业务逻辑的正确性:
      - ✅ `SendMessageUseCase`测试 - 验证消息发送流程
      - ✅ `GetChatSessionsUseCase`测试 - 验证会话列表获取
      - ⏱️ `GetMessagesUseCase`测试 - 待实现
      - ⏱️ 其他用例测试 - 待实现
  - **`Data` 层测试**:
    - ✅ 为模型类编写单元测试，验证 JSON 序列化/反序列化和 DTO 转换
    - ⏱️ 为仓库实现类编写单元测试:
      - ✅ `ChatRepositoryImpl`测试 - 验证基本操作
      - ⏱️ 异常处理和网络错误场景测试 - 待实现
    - ⏱️ 为数据源实现类编写单元测试:
      - ⏱️ `ChatRemoteDataSourceImpl`测试 - 待实现
      - ⏱️ `ChatLocalDataSourceImpl`测试 - 待实现
  - **`Presentation` 层测试**:
    - ⏱️ 为 Bloc 类编写单元测试:
      - ✅ `ChatBloc`测试 - 验证状态转换逻辑
      - ⏱️ `MessageBloc`测试 - 待实现
    - ⏱️ 为关键 Widget 编写 Widget 测试:
      - ⏱️ `ChatSessionListItem`测试 - 待实现
      - ⏱️ `ChatMessageItem`测试 - 待实现
      - ⏱️ 输入组件测试 - 待实现
  - **测试覆盖率**:
    - 当前覆盖率: `Domain`层 ~75%, `Data`层 ~60%, `Presentation`层 ~40%
    - 目标覆盖率: `Domain`层 85%, `Data`层 80%, `Presentation`层 70%

### 10. **在模块预览环境中调试和验证** ⏱️

- **目标**: 在隔离状态下，通过实际交互来验证模块的功能和 UI。
- **细节与说明**:
  - **预览环境配置**:
    - ✅ 创建并配置了`main_chat_preview.dart`作为独立预览入口
    - ✅ 预览入口正确注册了 Mock 依赖和导航路由
    - ✅ 实现了简单的预览 UI，支持页面间导航
  - **验证进度**:
    - ✅ 会话列表页面 - 已验证基本功能和样式
    - ⏱️ 聊天详情页面:
      - ✅ 消息列表渲染 - 已验证基本功能
      - ⏱️ 消息发送流程 - 待完整验证
      - ⏱️ 多媒体消息处理 - 待完整验证
    - ⏱️ 特殊场景测试:
      - ⏱️ 网络断开/恢复场景 - 待验证
      - ⏱️ 错误处理场景 - 待验证
      - ⏱️ 大量数据场景 - 待验证性能
  - **已解决的问题**:
    - ✅ 修复了消息列表滚动问题
    - ✅ 修复了会话时间显示格式问题
    - ✅ 修复了键盘弹出时消息输入框位置问题
  - **待解决的问题**:
    - ⏱️ 在某些 Android 设备上发送图片可能会崩溃
    - ⏱️ 语音消息播放控制 UI 需要优化
    - ⏱️ 长消息渲染性能问题

### 11. **(模块完成后) 集成准备** ⏱️

- **目标**: 准备将验证通过的模块代码合并到主工程。
- **细节与说明**:
  - **预集成检查清单**:
    - ⏱️ 所有已实现功能符合需求文档
      - ✅ 会话列表功能
      - ✅ 消息发送/接收基本功能
      - ⏱️ 多媒体消息处理
      - ⏱️ 实时消息通知
    - ⏱️ 代码规范符合项目要求
      - ✅ 代码格式化和静态分析已通过
      - ⏱️ 文档注释完整性检查
      - ⏱️ 命名和架构一致性检查
    - ⏱️ 核心测试已通过
      - ✅ 关键实体和用例测试
      - ⏱️ 核心 UI 组件测试
      - ⏱️ 集成测试场景
  - **依赖管理**:
    - ✅ 所有新增第三方依赖已记录在`pubspec.yaml`
    - ✅ 依赖版本冲突检查已完成
    - ✅ 依赖许可证合规性检查已完成
  - **性能指标**:
    - ⏱️ UI 渲染性能测试
    - ⏱️ 内存使用测试
    - ⏱️ 网络请求效率测试
  - **待处理项**:
    - ⏱️ 完成集成测试计划编写
    - ⏱️ 准备回归测试用例
    - ⏱️ 准备发布说明文档

### 12. **执行集成与测试** ⏱️

- **目标**: 将模块安全地合并到主工程，并验证其在真实环境中的协作。
- **细节与说明**:
  - **合并代码**: 执行 `git merge` 或类似操作。
  - **更新主工程配置**: 在主工程的 DI 配置中替换 Mock 为真实实现，在导航配置中注册真实路由。
  - **执行集成测试**: 运行模块间交互测试、E2E 测试、回归测试。
  - 参考方法论文档第 5.2 - 5.5 节。
