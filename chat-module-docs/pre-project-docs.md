## Demo Repository (React Native / TypeScript) 分析总结 (用于 Flutter 重构参考)

### 1. 状态管理 (Redux Toolkit)

- **核心 Slice**: `src/slices/msgSlice.ts`
- **管理状态**:
  - `chatRoomList`: 会话列表
  - `msgList`: 当前会话的消息列表
  - `chatRoom`: 当前会话详情
  - `isConnected`, `wsError`: WebSocket 连接状态
  - `loading`, `error`, `success`: 异步操作状态
  - `chatId`: 当前聊天室 ID
  - `shouldConnect`: 是否应连接 WebSocket
  - `currentPage`, `hasMoreMessages`: (注意：`getMsgList` 实现似乎未分页)
- **异步操作**: 使用 `createAsyncThunk` (定义在 `src/util/msgActions.ts`) 处理 API 调用。
- **WebSocket 消息**: 通过 `receiveMessage` reducer 添加到 `msgList`。

### 2. API 交互 (Axios + Redux Thunk)

- **Action 定义**: `src/util/msgActions.ts`
- **请求库**: Axios (通过 `axiosFn` 注入)
- **关键端点**:
  - `POST /api/chat/addChat`: 创建会话 (`createRoom`)
  - `POST /common/chat/message/add`: 发送消息 (`sendMsg`)
  - `POST /api/chat/list`: 获取会话列表 (`getChatRoomList`)
  - `POST /api/chat/message/list`: 获取消息列表 (`getMsgList`) - **注意：实现似乎是全量获取，非分页**
  - `POST /api/chat/message/withdraw`: 撤回消息 (`revokeMessage`)
  - `POST /api/chat/message/delete`: 删除消息 (`deleteMessage`) - **注意：未见本地状态更新逻辑**
  - `GET /api/chat/get`: 获取会话详情 (`fetchChatroomDetail`)

### 3. 实时通信 (WebSocket)

- **配置**: WebSocket URL (`baseUrl`) 在 `msgSlice.ts` 中定义。
- **状态管理**: `isConnected`, `wsError` 由 Redux 管理。
- **消息接收**: 通过 `receiveMessage` reducer 处理。
- **消息发送**: 主要通过 REST API (`sendMsg`)。

### 4. UI 与导航 (Expo Router + Tamagui)

- **主屏幕**: `app/(outer)/chatroom.tsx`
- **消息列表**: 使用 `@shopify/flash-list` 实现高性能滚动列表。
- **UI 库**: `tamagui`
- **导航**: 使用 `expo-router`。
- **进入聊天**: `components/chat/goToChat.tsx` 负责调用 `createRoom` API，成功后通过 `router.push` 跳转到 `chatroom` 页面。
- **交互组件**:
  - 图片预览: `react-native-image-viewing`
  - 语音播放: `VoicePlayer` (自定义组件)
  - 长按菜单: 自定义实现，支持复制 (`@react-native-clipboard/clipboard`) 和撤回。
  - 文件/图片选择: `pickImage`, `takePhoto` (自定义工具函数)。

### 5. 核心流程

- **获取消息**: 进入页面调用 `getMsgList` Thunk，替换本地列表 (全量)。
- **发送文本**: 调用 `sendMsg` Thunk，同时乐观更新 UI (添加带 `flag: "send"` 的消息到 `msgList`)。
- **发送媒体**: 选择文件 -> 上传 (可能通过 `fileSlice`) -> 获取 URL -> 调用 `sendMsg`。
- **接收消息**: WebSocket 触发 `receiveMessage` reducer，添加带 `flag: "receive"` 的消息到 `msgList`。
- **撤回消息**: 调用 `revokeMessage` Thunk -> 成功后从本地 `msgList` 过滤。
- **创建会话**: 调用 `createRoom` -> 成功后导航到 `chatroom`。

### 6. 关键依赖

- `@reduxjs/toolkit`
- `axios`
- `expo-router`
- `tamagui`
- `@shopify/flash-list`
- `@react-native-clipboard/clipboard`
- `react-native-fast-image`
- `react-native-image-viewing`

### 7. 与 Flutter 重构计划的对比点/注意事项

- **消息获取**: Demo Repo 实现是全量获取，Flutter 计划是分页获取。
- **状态管理**: Demo Repo 使用 Redux Toolkit，Flutter 计划使用 Bloc/Cubit。
- **实时通信**: Demo Repo 中 WebSocket 主要用于接收，发送通过 REST。Flutter 计划需要确认 WebSocket 的双向通信职责。
- **数据模型**: Demo Repo 的 Redux State 结构 (`MsgState`) 和 API DTOs 可与 Flutter 的 `Entities` 和 `Models` 对比。
- **UI 库**: Demo Repo 使用 Tamagui，Flutter 使用 Flutter Widgets。
