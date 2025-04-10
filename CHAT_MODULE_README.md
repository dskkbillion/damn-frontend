# 聊天模块开发文档

## 构建与运行

聊天模块支持独立开发和预览，使用以下命令运行预览应用：

```bash
flutter pub get
flutter run -t lib/main_chat_preview.dart
```

## 架构说明

聊天模块采用清洁架构（Clean Architecture）设计，分为以下几层：

1. **领域层（Domain）**：

   - 定义业务实体和用例
   - 定义仓库接口
   - 不依赖于任何外部框架

2. **数据层（Data）**：

   - 实现领域层定义的仓库接口
   - 包括远程数据源和本地数据源
   - 负责数据的获取、转换和存储

3. **表现层（Presentation）**：
   - 使用 BLoC 模式管理状态
   - 包含所有 UI 相关代码
   - 通过用例与领域层交互

## 依赖注入

使用 GetIt 进行依赖注入，所有依赖在 `ChatModule` 中注册：

- `registerDependencies()` - 注册生产环境依赖
- `registerMockDependencies()` - 注册开发/测试环境依赖

## 修复问题记录

### 2024-MM-DD 修复

1. **修复接口引用错误**：

   - 修正 `chat_module.dart` 中的接口导入路径
   - 文件名从 `i_chat_repository.dart` 修改为 `chat_repository.dart`

2. **添加缺失的用例类**：

   - 创建 `GetChatSessionsUseCase` 类
   - 更新 `usecases.dart` 导出文件

3. **完善依赖注入**：

   - 添加 `NetworkInfo`、`ChatLocalDataSource` 和 `ChatWebSocketServiceImpl` 依赖
   - 为 `MockHttpClient` 实现所有 API 模拟

4. **添加必要依赖**：
   - 添加 `internet_connection_checker` 包

## 模拟数据

聊天模块预览使用 `MockHttpClient` 提供模拟数据，包括：

- 三个预设会话（日常生活助手、编程助手、旅行规划师）
- 每个会话包含多条模拟消息
- 支持发送文本消息、图片消息等
- 模拟网络请求延迟

## 待办事项

- [ ] 优化模拟数据，添加更多真实场景
- [ ] 完善错误处理
- [ ] 添加单元测试
- [ ] 实现消息通知功能
