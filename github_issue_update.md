## 轻咨询付费提示功能 - 实现进展更新

### ✅ 已完成的实现

#### 1. 付费提示消息发送机制
- 实现了卖家发送付费提示消息的功能
- 消息以普通文本类型（type: 'text'）发送，内容为特殊格式的 JSON
- 包含商品的三个价格档位信息，从真实商品 API 获取

#### 2. 付费提示卡片渲染
- **买家视图**：显示三个价格按钮，点击可直接跳转到付款页面
- **卖家视图**：显示「已发送提示」的绿色状态标记
- 作为聊天历史记录永久保存，不是临时弹窗

#### 3. 对话轮数计算逻辑
**最终采用方案：基于卖家消息数的计算方式**

```dart
// 轮数 = 卖家发送的消息总数
// 优点：卖家可以更主动地控制付费提示时机
void _calculateRoundCount(List<ChatMessage> messages) {
  int sellerMessageCount = 0;
  for (final msg in sortedMessages) {
    if (msg.type == 'payment_prompt' || msg.type == 'system') continue;
    if (msg.doctorId != null && msg.senderId == msg.doctorId) {
      sellerMessageCount++;
    }
  }
  _roundCount = sellerMessageCount;
}
```

**触发时机**：
- 卖家第 1 条消息后
- 卖家第 5 条消息后
- 卖家第 10 条消息后
- 卖家第 20 条消息后

### 🐛 修复的关键问题

#### 1. 卖家角色识别错误
**问题**：API 返回的 doctor.type 字段值为 "MEMBER" 而不是 "doctor"，导致角色判断失败

**最终解决方案**：
```dart
// 在 ChatRoom 实体中保存原始的 doctorId 和 memberId
class ChatRoom extends Equatable {
  final int? doctorId; // 卖家的 participant ID
  final int? memberId; // 买家的 participant ID
  // ...
}

// 在页面中使用这些字段进行准确的角色判断
if (chatRoom.doctorId != null && currentUserParticipant.id == chatRoom.doctorId) {
  isSeller = true;  // 当前用户是卖家
} else if (chatRoom.memberId != null && currentUserParticipant.id == chatRoom.memberId) {
  isSeller = false; // 当前用户是买家
}
```

**优点**：
- 避免了硬编码 ID 值
- 复用了 ChatRoomDto 中已经正确的角色判断逻辑
- 不依赖于可能变化的 type 字段

#### 2. 商品数据加载时机
- 在 _initializePaymentPromptStatus 中自动加载聊天室详情和商品信息
- 加载完成后主动触发状态更新，确保 UI 刷新

#### 3. 付费提示消息检测
支持检测两种格式：
- type: 'payment_prompt' 的专用类型
- type: 'text' 但内容包含付费提示 JSON 的消息

### 📋 实现细节

#### 核心文件修改：
1. `message_list_cubit.dart` - 业务逻辑核心
2. `chat_room_page_refactored.dart` - 页面 UI 和角色判断
3. `payment_prompt_bubble.dart` - 付费提示卡片组件
4. `chat_message_bubble.dart` - 消息类型识别

#### 数据流程：
1. 卖家点击「发送付费提示」按钮
2. 调用 sendPaymentPromptMessage() 获取商品档位信息
3. 构造 JSON 格式的付费提示内容
4. 通过 sendTextMessage() 发送为普通文本消息
5. 前端通过内容格式识别并渲染为付费提示卡片

### 🎯 业务价值
- **更主动的控制**：卖家可通过自己的回复节奏控制提示时机
- **更好的用户体验**：付费提示作为聊天记录保存，不会丢失
- **灵活的定价策略**：支持商品的多档位价格展示

### ✨ 最终实现总结

**轻咨询付费提示功能已完全实现**，核心特性：

1. **计算逻辑**：基于卖家发送的消息数量，让卖家更主动控制付费提示时机
2. **角色识别**：通过 ChatRoom 实体的 doctorId/memberId 字段准确判断用户身份，无需硬编码
3. **触发机制**：在卖家第 1/5/10/20 条消息后自动显示付费提示按钮
4. **用户体验**：付费提示作为聊天消息永久保存，买家可随时点击付款

---
_更新时间：2025-01-21_
_状态：✅ 功能已完成_