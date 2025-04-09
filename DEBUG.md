### 11. 已知问题与解决方案 (2024-04-XX) 🚧

#### 11.1 功能调整记录

1. **会话置顶功能暂时移除**:

   - **问题描述**: 在运行预览环境时，出现错误 `The getter 'pinned' isn't defined for the class 'ChatSession'`
   - **临时解决方案**: 移除了`chat_list_page.dart`中对会话置顶属性(`pinned`)的引用和相关排序逻辑
   - **后续计划**: 在正式实现`ChatSession`实体类时添加`pinned`属性，并恢复置顶功能
   - **修改文件**: `lib/features/chat/presentation/pages/chat_list_page.dart`
   - **修改内容**: 移除依赖`pinned`属性的排序代码，改为仅按最后消息时间排序

2. **ChatSession 类属性更新**:

   - 需要更新`ChatSession`实体类，添加以下属性:

     ```dart
     class ChatSession {
       // 现有属性...

       /// 是否置顶
       final bool pinned;

       const ChatSession({
         // 现有参数...
         this.pinned = false,
       });

       // copyWith方法中也需添加pinned参数
       ChatSession copyWith({
         // 现有参数...
         bool? pinned,
       }) {
         return ChatSession(
           // 现有字段...
           pinned: pinned ?? this.pinned,
         );
       }
     }
     ```

3. **修复 NoParams 导入冲突问题**:

   - **问题描述**: 运行时出现错误 `'NoParams' is imported from both 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_sessions.dart' and 'package:dskk_flutter_refactor/features/chat/domain/usecases/usecase.dart'`
   - **解决方案**: 移除`get_chat_sessions.dart`中的`NoParams`类定义，统一使用`usecase.dart`中的`NoParams`
   - **修改文件**: `lib/features/chat/domain/usecases/get_chat_sessions.dart`
   - **修改内容**: 删除重复定义的`NoParams`类，保留导入`usecase.dart`
   - **后续建议**: 所有需要`NoParams`的用例都应从`usecase.dart`导入，避免重复定义

4. **修复 MockChatRealtimeService 重复定义问题**:

   - **问题描述**: 运行时出现错误 `'MockChatRealtimeService' is imported from both 'package:dskk_flutter_refactor/features/chat/mock/mock_repositories.dart' and 'package:dskk_flutter_refactor/features/chat/mock/mock_services.dart'`
   - **解决方案**: 从`mock_repositories.dart`中移除`MockChatRealtimeService`类的定义，只保留在`mock_services.dart`中的实现
   - **修改文件**: `lib/features/chat/mock/mock_repositories.dart`
   - **修改内容**: 删除`MockChatRealtimeService`类及其相关导入
   - **后续建议**: 遵循单一职责原则，mock_repositories.dart 文件只应包含仓库相关的模拟实现，而服务相关的模拟应该放在 mock_services.dart 文件中

5. **修复 MockChatRepository 缺少方法实现问题**:

   - **问题描述**: 运行时出现错误 `The non-abstract class 'MockChatRepository' is missing implementations for these members`
   - **解决方案**: 实现 IChatRepository 接口中定义的所有方法
   - **修改文件**: `lib/features/chat/mock/mock_repositories.dart`
   - **修改内容**:
     - 添加了以下缺失方法的实现:
       - `revokeMessage`: 撤回消息
       - `deleteMessage`: 删除消息
       - `observeMessages`: 监听新消息
       - `observeMessageStatusUpdates`: 监听消息状态更新
       - `retryOperation`: 重试操作
       - `clearError`: 清除错误状态
       - `getSessionDetail`: 获取会话详情
       - `searchMessages`: 搜索消息
       - `updateLocalSessionState`: 更新会话本地状态
     - 修正了 `batchLoadMessages` 方法的参数，将 `lastSyncTime` 改为 `fromTimestamp` 并设为必填参数
     - 添加了用于流式数据的控制器: `_messageController` 和 `_statusUpdateController`
   - **后续建议**: 使用接口工具或 IDE 插件检查接口实现的完整性，确保所有必需方法都得到实现

6. **修复 createSession 方法参数类型不匹配问题**:

   - **问题描述**: 运行时出现错误 `The parameter 'initialMessage' of the method 'MockChatRepository.createSession' has type 'String?', which does not match the corresponding type, 'Message?', in the overridden method, 'IChatRepository.createSession'`
   - **解决方案**: 修改 `MockChatRepository.createSession` 方法的参数类型，使其与接口一致
   - **修改文件**: `lib/features/chat/mock/mock_repositories.dart`
   - **修改内容**:
     - 将 `initialMessage` 参数类型从 `String?` 改为 `Message?`
     - 移除创建临时 `Message` 对象的代码，直接使用传入的 `Message` 对象
     - 添加逻辑确保消息的 `sessionId` 与新创建的会话 ID 匹配
   - **后续建议**: 仔细核对接口方法签名与实现类的一致性，特别是在接口更新后

7. **修复 getMessages 方法参数不匹配问题**:

   - **问题描述**: 运行时出现错误 `The method 'MockChatRepository.getMessages' has fewer positional arguments than those of overridden method 'IChatRepository.getMessages'`
   - **解决方案**: 将 getMessages 方法的命名参数改为与接口一致的位置参数
   - **修改文件**: `lib/features/chat/mock/mock_repositories.dart`
   - **修改内容**:
     - 将方法签名从 `getMessages({required String sessionId, String? beforeMessageId, int limit = 20})` 改为 `getMessages(String sessionId, String? beforeMessageId, int limit)`
     - 移除命名参数和默认参数值，使用位置参数
   - **后续建议**: 在实现接口方法时，应严格遵守接口方法的参数列表，包括参数的顺序、命名方式和可选性

8. **修复 updateSessionStatus 方法参数不匹配问题**:

   - **问题描述**: 运行时出现错误 `The method 'MockChatRepository.updateSessionStatus' has fewer positional arguments than those of overridden method 'IChatRepository.updateSessionStatus'`
   - **解决方案**: 将 updateSessionStatus 方法的命名参数改为与接口一致的位置参数
   - **修改文件**: `lib/features/chat/mock/mock_repositories.dart`
   - **修改内容**:
     - 将方法签名从 `updateSessionStatus({required String sessionId, required SessionStatus status})` 改为 `updateSessionStatus(String sessionId, SessionStatus status)`
     - 移除命名参数，使用位置参数
   - **后续建议**: 在编写接口实现时，应当查看接口文件中的方法签名，确保参数列表完全匹配，包括参数类型、顺序和是否使用命名参数

9. **修复 batchLoadMessages 方法参数不匹配问题**:

   - **问题描述**: 方法 `batchLoadMessages` 的参数列表与接口定义不匹配
   - **解决方案**: 将 batchLoadMessages 方法的命名参数改为与接口一致的位置参数
   - **修改文件**: `lib/features/chat/mock/mock_repositories.dart`
   - **修改内容**:
     - 将方法签名从 `batchLoadMessages({required String sessionId, required DateTime fromTimestamp, int limit = 100})` 改为 `batchLoadMessages(String sessionId, DateTime fromTimestamp, int limit)`
     - 移除命名参数和默认参数值，使用位置参数
   - **后续建议**: 创建统一的接口实现检查流程，确保所有重写的方法都完全符合接口要求

10. **修复 ReceiveMessageUseCase 实现与接口不匹配问题**:

    - **问题描述**: ReceiveMessageUseCase 中使用了不存在的 `incomingMessages` 和 `IncomingMessageDto` 等接口，与 IChatRealtimeService 接口定义不匹配
    - **解决方案**: 更新 ReceiveMessageUseCase 实现，使用正确的接口方法和数据类型
    - **修改文件**: `lib/features/chat/domain/usecases/receive_message.dart`
    - **修改内容**:
      - 将 `_realtimeService.incomingMessages` 改为 `_realtimeService.messageStream`
      - 修改 `_processIncomingMessage` 方法的参数类型，从 `IncomingMessageDto` 改为 `Message`
      - 移除对不存在的 `acknowledgeMessage` 方法的调用
      - 简化消息处理逻辑，直接使用传入的 Message 对象
      - 增加异常处理，确保即使处理失败也能返回原始消息
    - **后续建议**:
      - 确保用例实现与接口定义保持一致
      - 避免在代码中引用不存在的类型和方法
      - 在开发过程中，当接口变更时及时更新所有依赖实现

11. **修复 MessageBloc 依赖项不足和缺少 MarkMessagesReadUseCase 问题**:

    - **问题描述 1**: 运行时错误 `MessageBloc.markMessagesReadUseCase was called on null` 以及 `MessageBloc is missing required parameters`
    - **问题描述 2**: 找不到 `mark_messages_read.dart` 文件
    - **解决方案**: 完善 MessageBloc 构造函数参数，注册缺失的 MarkMessagesReadUseCase，创建导出文件
    - **修改内容**:
      - 在 `lib/features/chat/injection/chat_module.dart` 中注册 MarkMessagesReadUseCase
      - 在 MessageBloc 中添加 MarkMessagesReadUseCase 作为依赖项和成员变量
      - 创建 `lib/features/chat/domain/usecases/mark_messages_read.dart` 文件，导出需要的类
      - 更新 MessageBloc 工厂方法参数列表，传入新注册的 MarkMessagesReadUseCase
    - **后续建议**:
      - 使用代码生成工具自动注册和注入依赖，减少手动配置错误
      - 在添加新的 UseCase 时，创建单独的文件，而非通过导出间接引用

12. **修复 MessageBloc 中 \_onMarkAsRead 方法的实现问题**:

    - **问题描述**: `_onMarkAsRead` 方法中虽然添加了 `_markMessagesReadUseCase` 成员变量，但实际没有使用，导致标记消息已读功能无效
    - **解决方案**: 修改 `_onMarkAsRead` 方法，使用已注入的 `_markMessagesReadUseCase` 用例
    - **修改文件**: `lib/features/chat/presentation/bloc/message_bloc/message_bloc.dart`
    - **修改内容**:
      - 将注释 `// 此处简化处理，实际应调用对应的UseCase` 替换为实际调用代码
      - 添加 `await _markMessagesReadUseCase(MarkMessagesReadParams(sessionId: event.sessionId))`
      - 增强错误处理，打印错误信息以便调试
    - **后续建议**:
      - 尽量避免在代码中留下待实现的"TODO"注释，特别是关键功能
      - 确保所有注入的依赖都被实际使用
      - 考虑添加适当的错误处理和日志记录，即使是"可以忽略"的错误

13. **修复 ReceiveMessageUseCase 实现与接口不匹配问题**:

    - **问题描述**: ReceiveMessageUseCase 中使用了不存在的 `incomingMessages` 和 `IncomingMessageDto` 等接口，与 IChatRealtimeService 接口定义不匹配
    - **解决方案**: 更新 ReceiveMessageUseCase 实现，使用正确的接口方法和数据类型
    - **修改文件**: `lib/features/chat/domain/usecases/receive_message.dart`
    - **修改内容**:
      - 将 `_realtimeService.incomingMessages` 改为 `_realtimeService.messageStream`
      - 修改 `_processIncomingMessage` 方法的参数类型，从 `IncomingMessageDto` 改为 `Message`
      - 移除对不存在的 `acknowledgeMessage` 方法的调用
      - 简化消息处理逻辑，直接使用传入的 Message 对象
      - 增加异常处理，确保即使处理失败也能返回原始消息
    - **后续建议**:
      - 确保用例实现与接口定义保持一致
      - 避免在代码中引用不存在的类型和方法
      - 在开发过程中，当接口变更时及时更新所有依赖实现

14. **解决修改未生效的构建缓存问题**:
    - **问题描述**: 尽管修复了代码中的参数不匹配问题，但运行时依然出现错误 `Too few positional arguments: 2 required, 1 given`
    - **解决方案**: 清理 Flutter 构建缓存，重新构建应用
    - **执行命令**:
      ```bash
      flutter clean       # 清理所有构建产物和缓存
      flutter pub get     # 重新获取依赖
      flutter run -t lib/main_chat_preview.dart    # 重新运行预览环境
      ```
    - **原因分析**:
      - Flutter 和 Dart 会缓存编译结果以加快构建速度
      - 有时修改后的代码虽然已保存，但缓存的旧版本仍被使用
      - 特别是当修改涉及依赖注入和类型系统时，缓存问题更为常见
    - **后续建议**:
      - 遇到不一致的编译错误时，尝试清理缓存
      - 对于重大重构，建议定期清理缓存确保所有更改生效
      - 考虑在 CI/CD 流程中添加定期清理缓存的步骤
