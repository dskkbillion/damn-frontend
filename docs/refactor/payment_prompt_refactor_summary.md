# 聊天模块付费提示功能重构总结

## 重构日期
2025-08-27

## 重构概述
将付费提示功能从后端API调用改为纯前端实现，实现5-10-20轮次递进触发机制。

## 主要改动

### 1. 存储接口增强（向后兼容）
**文件**: `lib/features/chat/data/datasources/i_chat_local_data_source.dart`
- 新增 `getPaymentPromptCount()` 和 `savePaymentPromptCount()` 方法
- 保留旧的 `getPaymentPromptStatus()` 和 `savePaymentPromptStatus()` 方法以确保向后兼容

### 2. 存储实现
**文件**: `lib/features/chat/data/datasources/chat_local_data_source_impl.dart`
- 实现新的计数存储逻辑
- 添加数据迁移逻辑：自动将旧的bool值转换为count（true=1, false=0）
- 保存计数时同步更新旧的bool状态

### 3. 核心逻辑重构
**文件**: `lib/features/chat/presentation/cubit/message_list/message_list_cubit.dart`

#### 新增功能
- 添加文案池常量 `_paymentPromptMessages`（8条友好文案，无"免费"字眼）
- 实现递进触发机制：
  - 第1次：5轮对话后触发
  - 第2次：10轮对话后触发
  - 第3次：20轮对话后触发
  - 第3次后永不再显示

#### 方法重构
- `_checkAndSendPaymentPrompt()` → `_checkAndInsertLocalPaymentPrompt()`
  - 不再调用后端API
  - 创建纯前端虚拟消息（负数ID标识）
  - 随机选择文案

#### 触发位置扩展
- `loadMessages()`: 加载消息后检查
- `sendTextMessage()`: 发送文本消息后检查
- `sendFileMessage()`: 发送文件消息后检查
- `addReceivedMessage()`: 接收新消息后检查
- **买卖双方都能触发**（移除了仅卖家端限制）

#### 清理代码
- 删除 `_paymentPromptSent` 布尔变量
- 删除 `_checkPaymentPromptInMessages()` 方法
- 简化 `_initializePaymentPromptStatus()` 方法

### 4. UI组件
**文件**: `lib/features/chat/presentation/widgets/payment_prompt_bubble.dart`
- 无需修改，已支持显示动态content
- 买家端显示3个价格按钮
- 卖家端显示等待提示

## 技术亮点

### 1. 向后兼容设计
- 保留旧的存储接口和实现
- 自动迁移旧数据
- 双重存储确保兼容性

### 2. 纯前端实现
- 不依赖后端API
- 虚拟消息使用负数ID
- 本地状态管理

### 3. 用户体验优化
- 递进式提醒（5-10-20轮次）
- 随机文案避免重复
- 最多3次提醒，避免骚扰
- 按聊天室隔离状态

### 4. 代码质量
- 异步操作使用Future.microtask避免阻塞
- 错误处理完善
- 代码结构清晰

## 测试要点

### 功能测试
1. **递进触发测试**
   - 验证第5轮、第10轮、第20轮正确触发
   - 验证第3次后不再显示

2. **文案随机性**
   - 多次触发验证文案随机性
   - 确认无"免费"等敏感词汇

3. **状态持久化**
   - 页面刷新后状态保持
   - 重新进入聊天室状态正确

4. **兼容性测试**
   - 旧数据自动迁移
   - 买卖双方都能看到提示

### 边界条件
- 聊天室切换时状态隔离
- 快速发送消息时的并发处理
- 网络断开重连后的状态一致性

## 注意事项

1. **数据迁移**
   - 首次运行会自动将旧的bool值迁移为count
   - 迁移是透明的，用户无感知

2. **虚拟消息识别**
   - 使用负数ID标识虚拟消息
   - source字段为'local'表示本地生成

3. **异步处理**
   - 使用Future.microtask避免阻塞主流程
   - 确保UI响应流畅

## 后续优化建议

1. 考虑添加配置化的轮次设置
2. 文案可以从远程配置获取
3. 价格档位可以与商品服务集成
4. 添加埋点统计转化率