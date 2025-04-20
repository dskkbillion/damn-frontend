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

## 6. UI/UX 对齐目标 (基于 HTML 原型)

本章节描述 Flutter 版本 Chat 模块需要对齐的 UI 和 UX 目标，主要参考 React Native 版本（基于 HTML 原型实现）的行为和视觉风格。

### 6.1. 聊天列表页 (`ChatListPage`)

- **列表项 (`ChatListItem`)**:
  - **布局**: 左侧显示圆形头像，右侧垂直排列对方昵称和最新消息预览。
  - **头像**: 使用 `CircleAvatar` 或类似组件展示对方头像 (`Participant.avatar`)。
  - **昵称**: 加粗显示，字体大小适中。
  - **最新消息**:
    - 根据 `ChatRoom.chatMessageNewVo.type` 显示不同预览：
      - `text`: 直接显示文本内容，可能需要截断。
      - `image`: 显示 `[图片]`。
      - `audio`: 显示 `[语音]`。
      - `revoke`: 显示 `[消息已撤回]`。
      - 其他类型：待定。
    - 字体颜色稍暗，单行显示，末尾省略。
  - **未读数**: 如果 `ChatRoom.messageNum > 0`，在列表项最右侧（或头像右上角）显示红色圆形徽标，内部显示未读数量数字。需要处理数字过大时的显示。
  - **时间戳**: 在最新消息预览的右侧（或昵称行的右侧）用较浅颜色显示 `ChatRoom.lastActivityTime` 的格式化时间（例如：昨天、15:30、2024/10/26）。
  - **分割线**: 列表项之间使用细分割线。
  - **点击效果**: 提供标准的点击反馈效果 (水波纹)。
  - **间距与填充**: 整体列表项应有合适的垂直和水平内边距。
- **特殊入口**: （可选）如果原型中有类似 "小粽子" 的固定入口，需在列表顶部或其他位置添加相应的 UI 元素。
- **列表滚动**: 保持流畅的滚动性能。

### 6.2. 聊天室页面 (`ChatRoomPage`)

- **AppBar**:
  - **标题**: 显示对方昵称 (`state.opponent.nickName`)。考虑居中显示。
  - **返回按钮**: 标准的返回箭头。
  - **背景/样式**: 与 App 整体风格统一。
- **消息列表区域**:
  - **背景**: 使用 App 主题的背景色。
  - **滚动**: 默认显示最新消息（列表底部），向上滚动加载历史消息（分页加载逻辑待实现）。新消息到达时自动滚动到底部。
  - **时间戳显示**:
    - 不再每条消息都显示时间。
    - 在消息列表顶部显示最早一条消息的日期（例如：MM 月 DD 日）。
    - 当两条消息时间间隔超过一定阈值（例如 5 分钟）时，在它们之间插入一个居中的时间标签（例如：HH:mm 或 MM 月 DD 日 HH:mm）。
- **整体风格**: 保持页面干净、整洁，聚焦于消息内容。

### 6.3. 消息气泡 (`ChatMessageBubble`)

- **布局与对齐**:
  - **自己消息**: 靠右对齐，右侧显示头像（原型中自己消息不显示头像，确认最终设计）。
  - **对方消息**: 靠左对齐，左侧显示对方圆形头像。
  - **头像与气泡间距**: 保持合适的间距。
- **气泡样式**:
  - **形状**: 使用圆角矩形，圆角半径适中 (e.g., 12-16)。
  - **背景色**:
    - **自己**: 主题色（例如蓝色系）的较浅变种。
    - **对方**: 浅灰色或其他中性色。
  - **内边距**: 气泡内的文本/内容应有合适的内边距 (e.g., 8-12)。
  - **最大宽度**: 限制气泡最大宽度，避免撑满全屏 (e.g., 70-75% 屏幕宽度)。
- **内容渲染**:
  - **文本**: 正常显示文本，自动换行。
  - **图片**: 显示图片缩略图，保持一定宽高比，点击可全屏预览（需要实现预览组件或逻辑）。加载中显示占位符或加载指示器，加载失败显示错误图标。
  - **语音**:
    - 左侧显示播放/暂停图标。
    - 右侧显示语音时长（格式如 0:05）。
    - （可选）中间可以有简单的波形或进度条指示。
    - 播放时图标切换为暂停，并可能有播放进度反馈。
  - **撤回**: 显示灰色居中的提示文本，例如 "消息已撤回"。
- **状态指示器** (可选，位于气泡旁或时间戳旁):
  - **发送中**: 加载中的菊花图标。
  - **发送失败**: 红色错误图标（可点击重试）。
  - **已发送/已读**: (根据业务需求决定是否显示)。
- **长按菜单**:
  - 弹出菜单样式与 App 风格统一。
  - 菜单项根据消息类型和发送者动态显示（复制、撤回、删除）。
- **消息间距**: 消息气泡之间保持合适的垂直间距。

### 6.4. 消息输入栏 (`MessageInputBar`)

- **整体布局**: 从左到右依次为：语音/键盘切换按钮、文本输入框、表情符号按钮（暂缓）、附件按钮 (+)、发送按钮（仅在有文本输入时显示）。
- **背景与边框**: 使用卡片颜色或浅灰色背景，可能有顶部细边框与消息区分。
- **语音/键盘切换**: 根据当前模式显示不同图标 (麦克风 / 键盘)。
- **文本输入框**:
  - 圆角矩形样式。
  - 背景色稍暗于输入栏背景。
  - 无明显边框。
  - 支持多行输入，高度根据内容自适应（限制最大高度）。
  - 内边距合适。
- **附件按钮 (+)**: 标准的圆形加号图标。
- **发送按钮**:
  - 仅在输入框有内容时可见。
  - 使用主题色，可以是圆形图标按钮或带背景色的圆角按钮。
- **语音录制交互**:
  - 点击麦克风图标切换到"按住说话"状态。
  - 输入框区域变为一个大的"按住说话"按钮。
  - 按下按钮开始录音，UI 显示录音状态（例如波纹动画、计时）。
  - 手指上划或移出按钮区域提示"松开取消"。
  - 松开手指发送语音（在按钮区域内松开）或取消发送（在按钮区域外松开）。
- **附件菜单**: 点击 (+) 按钮从底部弹出菜单，包含"相册"、"拍照"等选项，菜单样式统一。

### 6.5. 整体风格与交互

- **颜色**: 遵循 App 整体主题色板。
- **字体**: 使用 App 标准字体，不同元素（昵称、消息、时间戳）区分字号和字重。
- **图标**: 使用清晰、一致的图标集。
- **动画与反馈**: 提供流畅的页面切换动画、按钮点击反馈、列表滚动反馈。
- **错误提示**: 使用 Toast 或 SnackBar 显示操作失败信息（如发送失败、撤回失败）。
- **确认对话框**: 对于敏感操作（如撤回、删除），弹出样式统一的确认对话框。
