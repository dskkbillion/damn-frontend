# Chat Module 前端原型 (HTML) 分析总结

基于 `design-info/HTML原型/HTML-new/outer/chatroom.html`

## 1. 整体布局与样式

- **容器**: `.mobile-container` (模拟移动视图)
- **背景色**: 页面主体 `#f5f5f5` (浅灰)
- **布局**: 主要使用 Flexbox
- **图标库**: Font Awesome 6

## 2. 顶部标题栏 (`.chat-header`)

- **样式**: 白色背景, 底部阴影, 固定顶部 (Sticky)
- **组件**:
  - **左**: 返回按钮 (`<i class="fas fa-chevron-left"></i>`)
  - **中**: 对方用户名 (`.user-name`)
  - **右**:
    - 订单按钮 (`<i class="fas fa-receipt"></i>`, `onclick="viewOrderDetails()"`)
    - 更多选项按钮 (`<i class="fas fa-ellipsis-v"></i>`, `onclick="showChatOptions()"`)

## 3. 消息显示区域 (`.chat-messages`)

- **布局**: 垂直列表
- **消息项 (`.message-item`)**:
  - **区分**: `.sent` (右) / `.received` (左)
  - **头像**: `.message-avatar` (圆形 `<img>`)
  - **内容 (`.message-content`)**:
    - 气泡: `.message-bubble` (不同背景/圆角)
    - 图片: `.image-message` 内嵌 `<img>`
    - 时间戳: `.message-time`
  - **时间分割**: `.time-divider` (e.g., "今天 9:15")

## 4. 底部输入区域 (`.chat-input-container`)

- **布局**: 水平 Flex
- **组件**:
  - **左**: 语音按钮 (`<i class="fas fa-microphone"></i>`, `onclick="toggleVoiceInput()"`)
  - **中 (`.input-wrapper`)**:
    - 输入框 (`<input type="text" class="message-input">`)
    - 表情按钮 (`<i class="fas fa-smile emoji-button"></i>`, `onclick="showEmojiPicker()"`)
    - 更多操作 (`<i class="fas fa-plus-circle more-button"></i>`, `onclick="showMoreActions()"`)
  - **右**: 发送按钮 (`<i class="fas fa-paper-plane"></i>`, `onclick="sendMessage()"`)

## 5. 附加菜单与界面

- **更多操作菜单 (`.more-actions-menu`)**:
  - **触发**: 输入区 `+` 按钮
  - **样式**: 底部弹出, 网格图标按钮
  - **操作**: 图片 (`fas fa-image`), 文件 (`fas fa-file`), 位置 (`fas fa-map-marker-alt`)
- **语音输入 (`.voice-input-interface`)**:
  - **触发**: 输入区麦克风按钮
  - **样式**: 声波动画 (`.voice-wave`), 提示文本, 取消按钮
- **聊天选项菜单 (`.chat-options-menu`)**:
  - **触发**: 标题栏 `...` 按钮
  - **样式**: 下拉或底部弹出
  - **操作**: 查看资料 (`fas fa-user`), 清空记录 (`fas fa-trash`), 屏蔽 (`fas fa-ban`), 举报 (`fas fa-flag`)

## 6. 核心交互 (基于 `onclick`)

- 导航 (返回, 查看订单)
- 菜单显隐 (聊天选项, 更多操作)
- 输入模式切换 (文本/语音)
- 功能触发 (发送消息/媒体, 聊天选项操作)
