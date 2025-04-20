# React Native 聊天模块 (Demo Repository) 核心逻辑分析

本文档分析了 `demo-repository` 中基于 React Native 和 Expo Router 实现的聊天模块的核心逻辑，旨在为 Flutter 重构提供参考。

## 1. 路由与导航

聊天模块主要包含两个核心页面，使用 Expo Router 进行管理：

- **会话列表页面**:
  - 路径: `app/(tabs)/chat/index.tsx` 和 `app/(sellerscreens)/chat/index.tsx` (功能类似，可能部署在不同的 Tab/Screen 分组下)。
  - 功能: 展示用户的会话列表。
  - 跳转: 点击某个会话项，使用 `router.push` 跳转到对应的聊天界面，并传递 `chatId` 参数。例如：`router.push({ pathname: "/(outer)/chatroom", params: { chatId: item.id } });`。
  - 特殊入口: 提供一个固定入口 (如 "小粽子") 用于快速创建与特定用户 (如管理员) 的聊天，创建成功后同样跳转到聊天界面。
- **聊天界面页面**:
  - 路径: `app/(outer)/chatroom.tsx`。
  - 功能: 展示特定 `chatId` 的消息流，并提供消息发送 (文本、图片、语音)、接收、撤回、复制等交互功能。
  - 接收参数: 通过 `useLocalSearchParams().chatId` 获取从列表页传递过来的 `chatId`。
  - 返回逻辑: 页面卸载时，如果用户在该聊天室发送了新消息 (`hasNewMessages` 状态为 `true`)，会通过 Redux action (`slices.msg.actions.setChangedId`) 设置 `changedId`。会话列表页会监听此 `changedId`，以便在返回时刷新对应的会话项状态（如未读数）。

## 2. 数据管理 (Redux)

使用 `@reduxjs/toolkit` 进行状态管理，主要通过 Redux Thunk Actions 调用后端 API 来实现数据的流入和流出。关键 API 交互如下：

- **获取会话列表 (`getChatRoomList` -> `POST /api/chat/list`)**:

  - **输入**: 无特定请求体参数 (依赖 Header 中的 `Authorization`)。
  - **流出 (Action 触发)**: 发起 API 请求。
  - **流入 (API 响应)**: 获取 `rows` 数组，每个元素代表一个会话，包含：
    - `id`: 会话 ID (`chatId`)。
    - `doctorId`, `memberId`: 参与者 ID。
    - `messageNum`: 未读消息数。
    - `chatMessageNewVo`: 最新消息摘要 (`context`, `type`)。
    - `member`, `doctor`: 参与者详细信息 (`nickName`, `avatar`)。
  - **状态更新**: 将 `rows` 数据存入 Redux state 的 `msg.chatRoomList`。

- **获取消息列表 (`getMsgList` -> `POST /api/chat/message/list`)**:

  - **输入 (Action 参数)**: `chatId` (会话 ID)。
  - **流出 (Action 触发)**: 发起 API 请求，请求体包含 `{ "chatId": ... }`。
  - **流入 (API 响应)**: 获取 `rows` 数组，每个元素代表一条消息，包含：
    - `id`: 消息 ID。
    - `chatId`: 所属会话 ID。
    - `memberId`, `doctorId`: 发送者 ID (通过与当前用户 `userId` 对比判断发送方)。
    - `context`: 消息内容 (文本字符串、图片 URL、音频 URL)。
    - `type`: 消息类型 (`text`, `image`, `audio`)。
    - `withdrawFlag`: 是否已撤回。
  - **状态更新**: 将 `rows` 数据存入 Redux state 的 `msg.msgList`。

- **获取聊天室详情 (`fetchChatroomDetail` -> `GET /api/chat/get`)**:

  - **输入 (Action 参数)**: `id` (会话 ID, 作为 URL query 参数)。
  - **流出 (Action 触发)**: 发起 API 请求。
  - **流入 (API 响应)**: 获取 `data` 对象，包含聊天室详细信息，主要是参与者 `member` 和 `doctor` 的信息 (`id`, `nickName`, `avatar`)。
  - **状态更新**: 将 `data` 存入 Redux state 的 `msg.chatRoom`。

- **创建聊天室 (`createRoom` -> `POST /api/chat/addChat`)**:

  - **输入 (Action 参数)**: `doctorId` (要聊天的对象 ID) 或 `type: 'ADMIN'` (前端逻辑，由 Action 转换为特定 `doctorId`)。
  - **流出 (Action 触发)**: 发起 API 请求，请求体包含 `{ "doctorId": ... }`。
  - **流入 (API 响应)**: 获取 `data` (整数)，即新创建的会话 ID (`chatId`)。
  - **后续操作**: 通常使用返回的 `chatId` 跳转到聊天界面。

- **发送消息 (`sendMsg` -> `POST /common/chat/message/add`)**:

  - **输入 (Action 参数)**: `chatId`, `context` (文本内容、图片 URL、音频 URL), `type` (`text`, `image`, `audio`)。
  - **流出 (Action 触发)**: 发起 API 请求，请求体包含 `{ "chatId": ..., "context": ..., "type": ... }`。
  - **流入 (API 响应)**: 获取 `data` 对象，包含已发送消息的详细信息 (类似消息列表中的单条消息)。
  - **状态更新**: 可能将返回的 `data` 追加到 `msg.msgList`，并设置 `msg.changedId` 以便列表页刷新。

- **撤回消息 (`revokeMessage` -> `POST /api/chat/message/withdraw`)**:

  - **输入 (Action 参数)**: `id` (要撤回的消息 ID)。
  - **流出 (Action 触发)**: 发起 API 请求，请求体包含 `{ "id": ... }`。
  - **流入 (API 响应)**: 获取操作结果 (`msg`, `code`)。
  - **状态更新**: 在 `msg.msgList` 中更新对应消息的状态为已撤回，并设置 `msg.changedId`。

- **上传文件 (`uploadImage` in `file` Slice)**:
  - **输入 (Action 参数)**: 文件对象 (来自图片选择器或拍照)。
  - **流出 (Action 触发)**: 调用**另一个**文件上传 API (未在 `chat_module.openapi.json` 中定义)，上传文件。
  - **流入 (API 响应)**: 获取上传后的文件 URL。
  - **状态更新/后续操作**: 将文件 URL 存入 `file.chatImages` 或直接用于触发 `sendMsg` Action (作为 `context` 参数)。

组件通过 `useSelector` 钩子订阅 Redux state (如 `msg.chatRoomList`, `msg.msgList`, `user.data.id`) 以获取数据进行渲染。通过 `useDispatch` 钩子派发这些 Thunk Actions 来与后端交互并更新状态。

## 3. API 对接

前后端交互通过 Redux Thunk Actions 实现，这些 Actions 内部会调用相应的 API 接口：

- **获取数据**:
  - 获取会话列表 (`getChatRoomList`)。
  - 获取消息列表 (`getMsgList`)。
  - 获取聊天室详情 (`fetchChatroomDetail`)。
- **发送数据**:
  - 发送文本/图片/语音消息 (`sendMsg`)。图片和语音消息发送前会先调用文件上传接口。
  - 创建聊天室 (`createRoom`)。
  - 撤回消息 (`revokeMessage`)。
- **文件处理**:
  - 上传图片/语音文件 (`uploadImage`)。

API 请求的成功与否通常使用辅助函数 (如 `isAxiosSuccess`) 进行判断，并据此进行后续操作 (如显示 Toast 提示)。

## 4. UI 渲染与交互

- **组件库**: 使用 Tamagui 构建界面。
- **列表渲染**:
  - 会话列表和消息列表均使用 `@shopify/flash-list` (`FlashList`) 组件以提高性能。
  - `renderItem` 函数根据数据动态渲染列表项。
- **会话列表项 (`renderMessage` in `MessagesScreen`)**:
  - 显示对方头像 (`Avatar`)、昵称。
  - 根据最新消息类型显示预览内容 (文本、"[图片]"、"[语音]")。
  - 显示未读消息数红点。
- **聊天界面 (`MessagePage`)**:
  - 使用 `FlashList` 渲染消息流。
  - `renderMessage` 函数根据消息发送者 (`item.fromId === userId`) 决定消息气泡的左右布局。
  - 根据消息类型 (`item.type`) 渲染不同组件：
    - 文本: 普通文本气泡，支持长按弹出复制/撤回菜单 (`ChatModal` 通过 `Portal` 渲染)。
    - 图片: 显示图片 (`FastImage`)，点击可放大预览 (`ImageView`)。
    - 语音: 显示语音播放器 (`VoicePlayer`)。
    - 撤回: 显示 "消息已撤回"。
  - **输入区域**:
    - 文本输入框 (`Input`)。
    - 发送按钮 (`Button`)。
    - "+" 按钮 (`StyledButton`) 展开更多选项 (拍照、相册、语音)。
    - 图片选择/拍照: 调用设备 API (`pickImage`, `takePhoto`)，选择后上传并发送。
    - 语音录制/发送: 使用 `VoiceDialog` 组件处理录音和发送流程。
- **交互处理**:
  - `KeyboardAvoidingView`: 处理键盘遮挡输入框的问题。
  - `TouchableWithoutFeedback`: 点击聊天背景区域可收起键盘或长按菜单。
  - 下拉刷新: 支持 `onRefresh` 事件重新加载数据。
  - 长按消息: 弹出操作菜单 (复制/撤回)。
  - 状态提示: 使用 `toast` 显示操作结果 (如复制成功、撤回失败)。
  - 确认对话框: 使用 `alert` 进行敏感操作确认 (如撤回消息)。
  - **区分发送者/接收者**:
    1.  **获取当前用户 ID**: 从 Redux state (`state.user.data.id`) 获取当前登录用户的 `userId`。
    2.  **获取消息发送者 ID**: 消息列表 (`msgList`) 中的每条消息 `item` 包含 `memberId` 和 `doctorId` 字段。
    3.  **比较**: 在渲染每条消息时，比较当前 `userId` 与消息 `item` 中的发送者 ID (具体是 `memberId` 还是 `doctorId` 取决于业务逻辑或后端返回的标识字段，代码中似乎用 `item.fromId === userId` 或类似逻辑判断，但 `fromId` 未在 API 中直接体现，可能是在前端处理或需要更明确的字段)。
    4.  **条件渲染**: 将比较结果 (如布尔值 `isCurrentUserSender`) 传递给消息渲染组件 (`ChatElement`)。
    5.  **应用样式**: `ChatElement` 根据 `isCurrentUserSender` 的值：
    - 设置消息气泡的水平对齐方式 (`justifyContent`) 为 `flex-end` (自己) 或 `flex-start` (对方)。
    - 应用不同的背景色、文字颜色等样式。
    - 仅在 `isCurrentUserSender` 为 `false` 时（即对方消息），渲染发送者的头像 (`Avatar`)。

## 5. Flutter 重构关注点

- **路由**: 调研 Flutter 路由库 (如 GoRouter) 如何实现类似的嵌套路由和参数传递。关注页面返回时状态同步的实现方式 (类似 `changedId` 机制)。
- **状态管理**: 考虑使用 Flutter 社区流行的状态管理方案 (如 Provider, Riverpod, Bloc/Cubit) 替代 Redux。需要重新设计 State 结构和 Action/Event 逻辑。
- **API 对接**: 封装 HTTP 请求逻辑，处理异步操作和错误。
- **UI 实现**:
  - 选择合适的 UI 组件库或自行构建。
  - 实现高效的列表渲染 (类似 `FlashList`)。
  - 复刻消息气泡的不同样式、左右布局。
  - 实现图片预览、语音播放功能。
  - 处理键盘交互、手势操作 (长按、点击)。
  - 实现图片选择/拍照、语音录制功能 (需要集成原生能力插件)。
- **数据持久化**: Demo 中未明确体现，但实际应用可能需要本地数据库 (如 sqflite) 缓存消息和会话列表。
