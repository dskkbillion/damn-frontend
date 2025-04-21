# Chat 模块重构任务清单

本文档跟踪 `Chat` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。

**当前分支**: `refactor/chat-module`

## 核心工作流步骤

- [ ] **2. 定义模块边界**

  - [x] **2.1. 明确核心业务能力**: 确认 Chat 模块负责的功能范围 (获取会话列表、进入聊天室、收发文本/图片/语音/订单/AI 分发消息、管理未读数、撤回/删除消息、创建会话、标记已读、根据类型渲染不同 UI、显示时间等)。
  - [x] **2.2. 定义 Domain Entities (基于 OpenAPI)**:
    - [x] **`Participant`**: `id` (int), `nickName` (String?), `avatar` (String?), `type` (String? - 'MEMBER', 'ADMIN', 'DOCTOR')。
    - [x] **`ChatMessage`**: `id` (int), `chatId` (int), `senderId` (int - 前端逻辑填充), `memberId` (int), `doctorId` (int), `context` (String), `type` (String - 'text', 'image', 'audio', 'order', 'distribute', 'revoke'), `createTime` (DateTime), `withdrawFlag` (bool), `readFlg` (bool?), `status` (enum { sending, sent, failed } - 前端状态)。
      - **注意**: `senderId` 需要前端根据 `currentUserId`, `memberId`, `doctorId` 实现判断逻辑。`readFlg` 含义待结合业务进一步明确。
    - [x] **`ChatRoom`**: `id` (int), `member` (Participant), `doctor` (Participant), `participants` (List<Participant> - 前端构建), `messageNum` (int), `chatMessageNewVo` (ChatMessage?), `lastActivityTime` (DateTime? - 取 `chatMessageNewVo?.createTime`)。
      - **注意**: `participants` 和 `lastActivityTime` 是根据其他字段派生的，确保实体类实现方式正确（如使用 getter）。
    - [x] `UnreadInfo` 作为 `ChatRoom.messageNum` 处理。
  - [x] **2.3. 定义 Domain Use Cases**:
    - [x] **2.3.1 确认/细化用例列表**: 确认 Use Cases: `GetChatRoomList`, `GetMessageList`, `SendMessage`, `CreateChatRoom`, `RevokeMessage`, `GetChatRoomDetails`, `DeleteChatMessage`. 明确 `MarkChatRoomAsRead` 是 `GetMessageList` 的副作用。
    - [x] **2.3.2 为每个 Use Case 定义输入参数和输出类型**: 已确认各 Use Case 的 Input 和 Output (`CreateChatRoom` 返回 `Result<int, Failure>`)。
  - [x] **2.4. 定义 Repository Interfaces**:
    - [x] **2.4.1 确认需要 `IChatRepository` 和 `IFileRepository`**: 确认职责划分合理。
    - [x] **2.4.2 为 `IChatRepository` 定义方法签名**: 确认方法列表和签名 (`getChatRooms`, `getMessages`, `sendMessage`, `createRoom`, `revokeMessage`, `getRoomDetails`, `deleteChatMessages`)。
    - [x] **2.4.3 为 `IFileRepository` 定义方法签名**: 确认方法签名 (`uploadFile(File file) -> Result<String, Failure>`)。
  - [x] **2.5. 识别外部交互点**:
    - [x] **2.5.1 确认需要 `IUserRepository` 的哪些方法**: 确认 `getCurrentUser()` 足够。
      - **待办**: 确保 `IUserRepository.getCurrentUser()` 返回的 `User` 实体包含 `commonUserId` (从用户登录信息获取)，或提供其他获取 `commonUserId` 的方式。
    - [x] **2.5.2 明确需要触发的导航事件及所需参数**: 确认 `navigateToChatRoom(int chatId)`, `navigateToUserProfile(int userId)`。
    - [x] **2.5.3 讨论 `INotificationRepository` 的必要性和交互方式**: 确认 Chat 模块不直接依赖。
  - [x] **2.6. (可选) 产出设计笔记/图表**: (暂时跳过/完成)。

- [x] **3. 分析参考代码 (验证与细化)**

  - [x] **3.1. 详细阅读 RN 源码**: 已完成对相关文件的阅读理解。
  - [x] **3.2. 提取并记录 Domain 逻辑**:
    - [x] **消息状态机**: 包含 `sending`, `sent`, `failed`, `revoked`。 UI 需要反映这些状态 (加载指示、错误标记/重试)。
    - [x] **未读数更新逻辑**: 列表从未读数从 API 获取；WS 收到新消息时，若非当前聊天室则更新列表未读数；进入聊天室调用 `getMessages` 隐式标记已读。
    - [x] **错误处理**: API 调用失败时，直接展示后端返回的 `msg`。
    - [x] **文件消息流程**: 上传过程有 UI 反馈；上传失败有提示和重试；语音录制为"点击->弹窗->按住录->松开发送"。
  - [x] **3.3. 提取并记录 Data 交互**:
    - [x] **详细映射每个 Use Case 对应的 API 端点、HTTP 方法、请求/响应体**: 已确认所有 Use Case 的 API 调用细节，包括 `DeleteChatMessage` 使用 POST 请求体传递 `List<int>`。
      - **注意**: `DeleteChatMessage` 参数方式是根据口头确认，与 OpenAPI 文档不符，需确保后端实际处理方式。
    - [x] **确认使用 WebSocket**: App 启动时连接，心跳保活。端点: `ws://app.duoshaokankan.com/prod-api/websocket/message/{commonUserId}/member` (使用 `commonUserId`)。
    - [x] **分析 WebSocket 认证**: 连接成功后发送首条消息 `{"type": "auth", "token": ...}`。
    - [x] **分析 WebSocket 交互**: RN 中 `useWebSocket` Hook 处理连接/断开/重连/心跳/错误。发送消息仍使用 HTTP POST。
      - [x] **`onmessage` 处理**: 解析 JSON，检查 `action === 'CHAT'`，调用 `dispatch(receiveMessage(message.data))`。
      - [x] **接收消息 `message.data` 结构**: 推断与 `/api/chat/message/list` 返回的消息对象结构一致。
        - **注意**: 此为推断，若实现中发现不一致需调整 DTO 或映射逻辑。
      - [x] **状态更新**: `receiveMessage` Reducer 将收到的 `message.data` 直接 push 到 `state.msgList`。
    - [x] **确认文件上传接口的细节**: `POST /api/common/public/upload`, `multipart/form-data`, 只含文件。
  - [x] **3.4. 提取并记录 Presentation 交互**:
    - [x] **3.4.1 映射 UI 状态到具体场景**: 确认 `ChatListPage` (无 `loadingMore`) 和 `ChatRoomPage` 的状态列表。
      - **注意**: `messageSent` 状态是否需要单独体现待 Presentation 层实现时决定。
    - [x] **3.4.2 记录用户操作如何触发状态变化和 Use Case 调用**: 确认了页面内和启动新聊天的操作映射流程 (启动新聊天直接调用 `CreateChatRoom`)。
  - [x] **3.5. 验证/调整步骤 2 的定义**: 根据 API 幂等性分析，确认移除 `FindOrCreateChatRoom`，最终确定了 Domain 层定义。

- [x] **4. 精化 `Domain` 层接口 (代码实现)**

  - [x] **4.1. 创建目录结构**: 已创建 `lib/features/chat/domain/entities`, `usecases`, `repositories`。
  - [x] **4.2. 实现 Entity 类**: 已创建 `Participant`, `ChatMessage`, `ChatRoom` 实体类及 `MessageStatus` 枚举。
    - **待办**: 确保 `enum MessageStatus` 已在代码中定义。
  - [x] **4.3. 实现 Use Case 接口**: 已为所有 Use Case 创建抽象类及 `call` 方法签名。
    - **待办**: 确保项目中已有通用的 `Result` 和 `Failure` 类型定义。
  - [x] **4.4. 实现 Repository 接口**: 已创建 `IChatRepository` 和 `IFileRepository` 抽象类及方法签名。

- [ ] **5. 实现 Flutter `Data` 层 (代码实现)**

  - [x] **5.1. 创建目录结构**: `lib/features/chat/data/repositories`, `data/datasources`, `models`。
  - [x] **5.2. 实现 DTO 模型**: 已创建 `ParticipantDto`, `ChatMessageDto`, `ChatRoomDto` 并生成代码，确认映射逻辑。
    - **手动**: 运行 `build_runner` 生成 `.freezed.dart` 和 `.g.dart` 文件。
    - **手动**: 检查 `ChatMessageDto.toEntity()` 中的 `senderId` 判断逻辑是否符合实际获取 `currentUserId` 的方式。
  - [x] **5.3. 实现 Remote DataSource**: 已创建 `IChatRemoteDataSource` 接口和 `ChatRemoteDataSourceImpl` 实现框架。
    - **手动**: 提供配置好的 `Dio` 实例 (通过 DI)。
    - **手动**: 确保 `ServerException` (或类似异常) 已定义。
    - **手动**: 根据实际情况调整 `createRoom` 中 `participantId` 到 `doctorId` 的映射。
    - **手动**: (可选) 细化 `DioException` 的处理。
  - [ ] **5.4. 实现 File Remote DataSource**: 创建 `file_remote_data_source.dart`, 实现调用文件上传 API 的方法。
    - **手动**: 提供配置好的 `Dio` 实例 (通过 DI)。
    - **手动**: 确认/修改 `FormData` 中文件对应的 `key` ("file")。
    - **手动**: (可选) 实现 `onSendProgress` 回调。
  - [x] **5.5. 实现 WebSocket DataSource**: 创建 `chat_web_socket_data_source.dart`, 处理连接、订阅、消息收发。
    - [ ] **待办**: 实现具体的连接、认证 (使用 `commonUserId` 和 Token)、心跳、接收/解析消息、错误处理、重连逻辑。
  - [ ] **5.6. 实现 Repository 实现**: 创建 `chat_repository_impl.dart`, `file_repository_impl.dart`, 注入 DataSources, 实现 Repository 接口, 调用 DataSource 方法, 捕获 DataSource 异常并映射为 `Domain` `Failure`, 调用 DTO 的 `toEntity()` 方法。
    - **待办**: 实现所有 `IChatRepository` 和 `IFileRepository` 的方法。
    - **待办**: 实现缓存策略 (注入并使用 `ChatLocalDataSource`)。
  - [ ] **5.7. 创建 Mock DataSources**: 为 `ChatRemoteDataSource`, `FileRemoteDataSource`, (和 `ChatWebSocketDataSource`) 创建 Mock 实现, 用于测试。
    - **待办**: 使用 `mockito` 或类似库创建 Mock 类。

- [ ] **6. 实现 Flutter `Domain` 逻辑 (代码实现)**

  - [ ] **6.1. 创建 Use Case 实现类**: 在 `lib/features/chat/domain/usecases/` 下为每个 Use Case 接口创建实现类 (如 `GetChatRoomListImpl`)。
  - [ ] **6.2. 注入 Repository**: 在 Use Case 实现类的构造函数中注入所需的 Repository 接口。
  - [ ] **6.3. 实现 `call` 方法**: 实现核心业务逻辑, 调用 Repository 方法, 处理 `Result` 类型。
  - [x] **待办**: 实现 `ChatMessageBubble` 中图片预览、语音播放、长按菜单等交互。

- [ ] **7. 实现 Flutter `Presentation` 层 (代码实现)**

  - [x] **7.1. 创建目录结构**: `lib/features/chat/presentation/pages`, `widgets`, `bloc`。
  - [x] **7.2. 选择并配置状态管理**: 确认使用 Bloc/Cubit。
  - [x] **7.3. 实现状态管理类**:
    - [x] 创建 `ChatListBloc`, `ChatListState`, `ChatListEvent`。
    - [x] 创建 `ChatMessagesBloc`, `ChatMessagesState`, `ChatMessagesEvent`。
      - [x] **待办**: 在 `ChatMessagesBloc` 中实现获取对方参与者信息的逻辑 (e.g., 使用 `GetChatRoomDetails` Use Case)。
  - [x] **7.4. 实现 UI 页面**:
    - [x] 创建 `ChatListPage` 骨架, 使用 `BlocProvider` 和 `BlocBuilder`。
    - [x] 创建 `ChatRoomPage` 骨架, 使用 `BlocProvider` 和 `BlocBuilder`。
      - [x] **待办**: 替换 `ChatRoomPage` 中硬编码的 `currentUserId`。
      - [x] **待办**: 替换 `ChatRoomPage` 中硬编码的 `opponentName` 和 `opponentDetails`。
      - [x] **待办**: 修正 `ChatRoomPage` 中判断 `isCurrentUser` 的逻辑, 需可靠判断消息发送者。
  - [x] **7.5. 实现 UI 组件**:
    - [x] 创建 `ChatListItem` Widget。
    - [x] 创建 `ChatMessageBubble` Widget。
    - [x] 创建 `MessageInputBar` Widget。
  - [ ] **7.6. 连接事件与逻辑**: 在 UI 组件中处理用户输入/手势, 调用状态管理类的方法来触发业务逻辑。
    - [x] **待办**: 实现 `ChatListItem` 的 `onTap` 导航。
    - [x] **待办**: 实现 `MessageInputBar` 的发送、语音切换、更多操作等逻辑。
    - [x] **待办**: 实现 `ChatMessageBubble` 中图片预览、语音播放、长按菜单等交互。

- [ ] **8. 识别并配置外部依赖 (隔离开发)**

  - [ ] **8.1. 明确导航调用**: 列出所有需要调用的导航方法及其参数。
  - [ ] **8.2. 明确外部 Repo 调用**: 列出需要从 `IUserRepository` 调用的方法。
  - [x] **处理 ID 复杂性**:
    - [x] **确认**: WebSocket 使用 `commonUserId` (或 `User.id`) 连接，而聊天室/消息 API 使用单独的 `Participant ID` (`memberId`/`doctorId`)。
    - [x] **确认**: `Participant` DTO/Entity 包含 `referId`，链接回 `commonUserId`。
    - [x] **实现**: 在 `ChatMessagesBloc` 加载时，通过 `getRoomDetails` 和 `referId` 查找当前用户的 `Participant ID` 并存入 State。
    - [x] **实现**: `ChatMessageDto.toEntity` 和 WebSocket 消息处理时，将 DTO 中的 `memberId` 或 `doctorId` (代表发送者) 直接赋值给 `ChatMessage.senderId`。
    - [x] **实现**: `ChatMessageBubble` 中通过比较 `message.senderId == state.currentUserParticipantId` 判断是否为当前用户消息。
  - [ ] **待办**: 实现删除消息逻辑
    - [x] 定义 `DeleteChatMessage` Use Case (接口, 实现, 参数 - 使用 `List<int> messageIds`)。
    - [x] 注册 Use Case 到 DI。
    - [x] 在 `ChatMessagesBloc` 中添加依赖和 `DeleteMessageRequested` 事件处理 (含乐观删除)。
    - [x] 连接 `ChatMessageBubble` 长按菜单的"删除"选项到 Bloc 事件。

- [ ] **13.1. (可选) 删除特性分支**。
- [ ] **13.2. 选择下一个模块**。

## 开发过程中的常见问题与解决方案记录

1.  **`GetIt` 注册错误 (`Object/factory with type ... is not registered`)**:

    - **问题**: 在 `setupLocator` 中注册实现类时, 没有显式指定其对应的接口类型。
    - **示例**: `sl.registerLazySingleton(() => GetChatRoomListImpl(sl()));` 导致 `ChatListBloc` 无法找到 `GetChatRoomList` 接口。
    - **解决方案**: 明确指定接口类型进行注册：`sl.registerLazySingleton<GetChatRoomList>(() => GetChatRoomListImpl(sl()));`。

2.  **`LocaleDataException` (日期格式化错误)**:

    - **问题**: 在使用 `intl` 包进行日期格式化之前, 未对其进行初始化。
    - **解决方案**: 在应用启动时（如 `main` 函数中）调用 `await initializeDateFormatting('en_US', null);` (或所需的区域设置)。

3.  **编译时大量文件/类型找不到错误**:

    - **问题**: 通常由错误的 `import` 路径 (如使用了相对路径而非 `package:` 路径) 或文件/类定义缺失引起。
    - **解决方案**:
      - **检查并修正 `import` 语句**: 确保所有跨模块或核心库的导入都使用 `package:your_project_name/...` 格式。
      - **确认文件和定义存在**: 检查报错提示的文件路径和类型名称, 确保对应的 `.dart` 文件已创建并且类/接口已正确定义。

4.  **实体类 (Entity) 成员/方法缺失错误**:

    - **问题**: Mock 实现或 Bloc/Widget 中访问了实体类中尚未定义的字段或 `copyWith` 方法。
    - **解决方案**: 根据业务需求和 API 定义, 补全实体类 (`ChatMessage`, `Participant`, `ChatRoom` 等) 所需的字段 (如 `id`, `type`, `senderId` 等), 确保构造函数包含所有 `required` 字段, 并实现 `copyWith` 方法以方便状态更新。

5.  **Use Case 参数类 (Params) 未定义错误**:

    - **问题**: Bloc 在调用 Use Case 时, 尝试使用一个尚未定义的参数类 (如 `GetChatRoomDetailsParams`)。
    - **解决方案**: 在对应的 Use Case 文件 (`get_chat_room_details.dart` 等) 中定义所需的 `Params` 类, 并继承 `Equatable`。

6.  **Mock 实现与接口/实体不匹配**:

    - **问题**: Mock 类 (如 `MockChatRepository`, `MockUserRepository`) 中的方法签名、使用的实体构造函数或访问的字段与更新后的接口/实体定义不一致。
    - **解决方案**: 仔细检查 Mock 实现, 确保方法签名与接口匹配, 创建实体实例时使用正确的构造函数和参数, 访问实体字段时确保字段存在。

7.  **Bloc 逻辑错误**:

    - **问题**: 在 Bloc 的事件处理函数中, 可能错误地访问了 `state` 中的数据 (如在 `ChatMessagesLoading` 状态下尝试访问 `state.opponent`)，或者在异步操作后没有重新检查 `state` 类型。
    - **解决方案**: 在访问 `state` 的特定属性前, 先判断 `state` 是否为预期的类型 (如 `if (state is ChatMessagesLoaded)` )。在 `await` 调用之后, 如果需要基于之前的状态进行更新, 应重新获取当前 `state` 或再次检查其类型。

8.  **接口方法未定义 (`The method '...' isn't defined for the class '...'`)**:

    - **问题**: 在 Repository 接口 (如 `IChatRepository`) 中缺少了实现类或 Mock 类需要调用的方法签名。
    - **解决方案**: 仔细检查接口定义 (`i_chat_repository.dart` 等), 确保所有需要的方法（如 `getMessages`, `sendMessage`, `getRoomDetails` 等）都有对应的抽象方法签名。

9.  **特定 `Failure` 类型未定义**:

    - **问题**: 代码中尝试 `throw` 或返回一个尚未在 `core/error/failures.dart` 中定义的 `Failure` 子类 (如 `ClientFailure`)。
    - **解决方案**: 在 `failures.dart` 文件中添加所需的 `Failure` 子类定义。

10. **`Failure` 基类缺少通用属性 (如 `message`)**:

    - **问题**: Bloc 或其他地方尝试访问 `Failure` 对象的 `message` 属性, 但基类未定义该属性, 导致无法统一处理错误消息显示。
    - **解决方案**: 在 `Failure` 抽象基类中添加通用的 `message` 字段（可能带有默认值）, 并在构造函数中接收它。这样所有子类都可以继承, 方便统一处理。

11. **实体类 (Entity) 缺少派生属性的 Getter**:

    - **问题**: 需要根据实体的其他字段计算得出某个值（如 `ChatRoom` 的 `lastActivityTime`）, 但没有方便的 Getter 方法。
    - **解决方案**: 在实体类中添加 Getter 方法（如 `DateTime? get lastActivityTime => lastMessage?.createTime;`）来封装这种派生逻辑。

12. **Widget 找不到错误 (即使 import 正确)**:

    - **问题**: `import` 路径看起来正确, 但编译时仍然报找不到 Widget (如 `ChatMessageBubble`)。这可能是因为该 Widget 文件本身存在编译错误, 或者 Flutter 的构建缓存出现了问题。
    - **解决方案**:
      - **检查 Widget 文件**: 打开对应的 Widget 文件 (`chat_message_bubble.dart`), 查看是否有内部错误。
      - **(如果文件正常)** 尝试执行 `flutter clean` 然后重新运行 `flutter run`。

13. **跨 Feature 导入路径错误**:

    - **问题**: 在一个 feature（如 `chat`）的代码中, 尝试通过相对路径或错误的 `package:` 路径导入另一个 feature（如 `auth`）的类或接口。
    - **示例**: 在 `main_chat_preview.dart` 中使用 `import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_user_repository.dart';` 而不是 `import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart';`。
    - **解决方案**: 始终使用正确的 `package:` 路径来导入其他 feature 或 `core` 中的代码。

14. **构造函数参数不匹配**:

    - **问题**: 调用一个类的构造函数时, 传递了该构造函数未定义的命名参数, 或者缺少了必需的参数。
    - **示例**: 调用 `ClientFailure(message: '...')`, 但 `ClientFailure` 的构造函数已被修改为不接受 `message` 参数。
    - **解决方案**: 确保调用构造函数时传递的参数与目标构造函数的定义完全匹配。

15. **Widget 文件确实不存在**:

    - **问题**: 编译错误反复提示找不到 Widget 定义, 并且通过读取文件确认该 `.dart` 文件确实不在预期的位置。
    - **解决方案**: 根据之前的设计或代码记录, 重新创建该 Widget 文件 (`chat_message_bubble.dart`)。

16. **Widget 参数错误 (如 `CachedNetworkImage` 的 `constraints`)**:

    - **问题**: 调用 Widget 构造函数时, 传递了不存在的命名参数。
    - **示例**: `CachedNetworkImage(constraints: ...)`。
    - **解决方案**: 查阅 Widget 的文档或源代码, 确认可用的参数。对于尺寸限制, 通常应将其应用于包裹目标 Widget 的父 Widget (如 `Container`, `SizedBox`)。

17. **Bloc 状态类型识别错误 (如 `is ChatListLoaded` 不生效)**:

    - **问题**: 在 `BlocBuilder` 中使用 `is` 关键字检查 Bloc 状态类型时, 无法正确识别（即使 Bloc 文件中有 `part 'xxx_state.dart';` 指令）。这可能与之前的修复冲突、编译器缓存或 `part` 文件自身的导入/定义有关。
    - **解决方案**:
      - **检查 `part` 文件**: 确保 `part` 文件 (`xxx_state.dart`) 中没有错误的导入或定义。
      - **使用状态枚举**: 作为替代或更稳健的方法, 可以在 State 类中定义一个 `enum` 字段 (如 `status`), 并在 `BlocBuilder` 中通过判断 `state.status == Enum.value` 来区分状态, 而不是依赖 `is` 类型检查。
      - **清理缓存**: 尝试 `flutter clean`。

18. **Widget 构造函数参数不匹配 (如 `ChatListItem` 缺少 `avatarUrl`)**:

    - **问题**: 在 Widget (如 `ChatListPage`) 中调用另一个自定义 Widget (如 `ChatListItem`) 时, 传递的参数与目标 Widget 构造函数的实际定义不符。
    - **示例**: `ChatListPage` 尝试传递 `avatarUrl`, `name` 等给 `ChatListItem`, 但 `ChatListItem` 的构造函数只接收 `chatRoom`。
    - **解决方案**:
      - **保持一致**: 确保调用 Widget 时传递的参数名称和类型与目标 Widget 构造函数声明的完全一致。
      - **封装数据**: 如果一个 Widget 需要展示的数据都来自同一个对象 (如 `ChatRoom`), 通常更好的做法是直接传递整个对象, 而不是拆分成多个单独的参数。数据的提取和处理逻辑应封装在目标 Widget 内部。

19. **Bloc 中直接访问 UI 服务/上下文 (如 `NavigationService`, `BuildContext`)**:

    - **问题**: 在 Bloc 代码中直接引用 UI 层的服务实例 (如 `NavigationService.instance`) 或尝试获取 `BuildContext` 来执行 UI 操作 (如显示 `SnackBar`)。
    - **示例**: `ScaffoldMessenger.of(NavigationService.instance.navigatorKey.currentContext!).showSnackBar(...)`。
    - **解决方案**: 保持 Bloc 层与 UI 无关。UI 反馈（如 `SnackBar`）应通过 UI 层监听 Bloc 状态变化 (使用 `BlocListener`) 或一次性事件 (Single Event Stream) 来触发。

20. **`onPressed` 回调类型不匹配 (如 `void Function(BuildContext)` vs `void Function()?`)**:

    - **问题**: 将一个需要参数（如 `BuildContext`）的方法直接赋值给不需要参数的回调（如 `IconButton.onPressed`）。
    - **示例**: `IconButton(onPressed: _myMethodWithContext)`。
    - **解决方案**: 使用匿名函数包裹方法调用：`IconButton(onPressed: () => _myMethodWithContext(context))`。

21. **`MissingPluginException` (常见于 Web)**:

    - **问题**: 调用某个插件的方法时，出现 `MissingPluginException`，提示找不到方法的原生实现。这在 Web 平台尤其常见，因为很多依赖原生功能的插件（如 `path_provider`, `record` 的部分功能）在 Web 上没有完全对应的实现。
    - **示例**: 在 Web 上调用 `path_provider` 的 `getTemporaryDirectory()`。
    - **解决方案**:
      - **检查插件文档**: 查看插件是否支持当前目标平台，以及是否有平台特定的限制或替代方法。
      - **平台条件判断**: 使用 `kIsWeb` (来自 `package:flutter/foundation.dart`) 或 `Platform` (来自 `dart:io`) 来判断当前平台，并为不支持的平台提供替代逻辑（如禁用功能、显示提示信息、使用 Web 专有的 API）。

22. **用户 ID 与参与者 ID 不匹配**:

    - **问题**: WebSocket 连接使用全局 `commonUserId`，而聊天消息和聊天室详情中的发送者/接收者由特定的 `Participant ID` (`memberId`/`doctorId`) 标识。直接比较 `commonUserId` 和 `memberId`/`doctorId` 来判断消息发送者是错误的。
    - **解决方案**:
      1. 确保 `Participant` DTO/Entity 包含 `referId` (链接回 `commonUserId`)。
      2. 在进入聊天室时 (`ChatMessagesBloc._onLoadChatMessages`)，获取当前用户的 `commonUserId`，然后通过 `getRoomDetails` 返回的参与者列表，找到 `referId` 与 `commonUserId` 匹配的那个参与者，并将其 `id` (即 `currentUserParticipantId`) 存储在 Bloc 状态 (`ChatMessagesLoaded.currentUserParticipantId`) 中。
      3. 在转换消息 DTO 为 Entity 时 (`ChatMessageDto.toEntity`, `_onInternalMessageReceived`)，将消息 DTO 中的 `memberId` 或 `doctorId` (代表发送者) 直接赋值给 `ChatMessage.senderId`。
      4. 在 UI (`ChatMessageBubble`) 中，通过比较 `message.senderId == state.currentUserParticipantId` 来判断消息是否由当前用户发送。

23. **ListView 消息顺序错误 (新消息在顶部)**:

    - **问题**: 移除 `ListView.builder` 的 `reverse: true` 后，新消息仍然显示在顶部，尤其是在重新进入聊天室时。
    - **原因**: 初始假设 API (`getMessageList`) 返回反序列表（新->旧）是错误的。API 很可能返回正序列表（旧->新）。Bloc 在 `_onLoadChatMessages` 中错误地调用了 `.reversed`，导致初始状态列表变成反序。后续追加的新消息（发送或 WebSocket）被添加到了这个反序列表的末尾。
    - **解决方案**:
      - **移除 Bloc 中的反转**: 在 `ChatMessagesBloc._onLoadChatMessages` 处理函数中，**移除** 对从 Repository 获取的初始消息列表的 `.reversed` 调用。直接使用 API 返回的列表（假设为正序）。
      - **确认 Bloc 中追加逻辑**: 确保 `_onSendMessageRequested` (乐观更新) 和 `_onInternalMessageReceived` (WebSocket 更新) 仍然将新消息添加到列表的 _末尾_，使用 `[...currentState.messages, newMessage]`，这对于正序列表是正确的。

24. **ChatMessagesBloc 中硬编码 Token 和 WebSocket User ID**:

    - **问题**: 在 `ChatMessagesBloc._onLoadChatMessages` 方法中，`_token` 和 `commonUserIdForWS` 被硬编码为特定值。
    - **风险**: 导致 WebSocket 连接和可能的 API 调用使用固定的用户凭证，无法适配实际登录用户。
    - **解决方案**:
      - **动态获取 Token**: 修改代码，从用户认证状态管理器（如 `AuthBloc`/`AuthRepository`）动态获取当前用户的有效 Token。
      - **动态获取 commonUserId**: 修改代码，使用从 `IUserRepository.getCurrentUser()` 获取到的 `_currentUser!.id` 作为 WebSocket 连接的 `commonUserId`，而不是硬编码的 `commonUserIdForWS`。

25. **ChatListPage 中硬编码 currentUserId**:
    - **问题**: 在 `ChatListPage` 的 `build` 方法中，传递给 `ChatListItem` 的 `currentUserId` 被硬编码为 `10307`。
    - **风险**: 导致列表项始终基于固定的用户 ID 来判断谁是对方，无法适应实际登录用户。
    - **解决方案**:
      - 从合适的来源（如 `AuthBloc` 的状态或 `UserRepository`）获取当前已登录用户的 `referId`。
      - 将动态获取到的 `referId` 传递给 `ChatListItem` 的 `currentUserId` 参数。

- [ ] **实现 WebSocket 实时更新**
  - [x] 添加 `web_socket_channel` 依赖。
  - [x] 定义 `IChatWebSocketDataSource` 接口。
  - [x] 实现 `ChatWebSocketDataSourceImpl` (连接, 认证, 心跳, 消息处理, 断开, 重连)。
  - [x] 注册 DataSource 到 DI。
  - [x] 在 `ChatMessagesBloc` 中注入 DataSource，实现连接和消息订阅。
  - [x] 在 `ChatMessagesBloc` 的 `close` 方法中断开连接。
  - [ ] **待办**: 在 UI 层根据 WebSocket 连接状态显示反馈 (可选)。
  - [ ] **待办**: 需要真实的 `commonUserId` 和 `token` 进行实际测试。

26. **系统管理员入口视觉区分**:
    - **问题**: 聊天列表顶部的“系统管理员”入口目前使用标准的 `ChatListItem` 样式，不够突出。
    - **解决方案**:
      - 可以考虑修改 `ChatListItem`，增加一个可选参数（如 `isSpecialEntry: true`），并根据此参数应用不同的背景色、图标或字体样式。
      - 或者，创建一个专门的 `AdminChatListItem` Widget，完全自定义其外观，并在 `ChatListPage` 的 `itemBuilder` 中使用它来渲染 `index == 0` 的情况。
      - 更新 `_buildAdminListItem` 帮助函数，使用自定义的头像或图标代替默认的 CircleAvatar。
