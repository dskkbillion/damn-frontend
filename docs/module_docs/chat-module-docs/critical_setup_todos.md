# Chat 模块 - 关键设置 TODO

本文档跟踪 Chat 模块 Data 层正常运行所需的基本设置任务。

## 1. 认证 Token 管理

- [ ] **集成认证模块:** 修改 `ChatRemoteDataSourceImpl`，使其依赖于认证服务/仓库 (例如 `IAuthRepository`)。
- [ ] **动态获取 Token:** 更新 `ChatRemoteDataSourceImpl` 中的 `_getHeaders` 方法，使其从认证模块获取当前的 `Authorization` Token，而不是使用占位符。
- [ ] **安全存储 Token:** 确保认证模块使用安全的方式存储 Token (例如 `flutter_secure_storage`)。

## 2. 基础 URL 配置

- [ ] **使用环境变量:** 为不同的构建环境 (dev, prod) 使用 `--dart-define` 配置 API (`API_BASE_URL`) 和 WebSocket (`WS_BASE_URL`) 的基础 URL。
  - _当前占位符:_ `http://17-8187.proxy.product-demo.cn:8000` / `ws://17-8187.proxy.product-demo.cn:8000` (请确认环境并相应更新)。
- [ ] **创建配置服务/类:** 实现读取这些环境变量的方法 (例如，使用 `String.fromEnvironment` 的静态 `AppConfig` 类)。
- [ ] **更新数据源:** 修改 `ChatRemoteDataSourceImpl` 和 `ChatRealtimeServiceImpl`，使用配置的基础 URL 而不是硬编码的字符串。

## 3. Hive 设置 (本地缓存)

- [ ] **添加依赖:** 确保 `hive`, `hive_flutter`, `hive_generator`, `build_runner` 已正确添加到 `pubspec.yaml`。
- [ ] **注解实体类:** 在 `lib/features/chat/domain/entities/` 目录下的 `Message`, `ChatSession`, `User` 实体 (以及任何嵌套的自定义类/枚举) 上添加 `@HiveType(typeId: ...)` 和 `@HiveField(...)` 注解。
- [ ] **生成 Adapters:** 运行 `flutter pub run build_runner build --delete-conflicting-outputs` 以生成必需的 `.g.dart` adapter 文件。
- [ ] **初始化并注册 Adapters:** 在 `main.dart` 中 (在 `main()` 函数内，**在 `runApp()` 之前**)，初始化 Hive (`await Hive.initFlutter();`) 并注册**所有**生成的 adapters (`Hive.registerAdapter(MessageAdapter());` 等)。

## 4. 其他 Data 层 TODO

- [ ] **文件上传进度:** 在 `ChatRemoteDataSourceImpl.uploadFile` 中实现进度报告，并可能更新 `Message` 状态/实体以反映进度。
- [ ] **本地消息删除/撤回:** 为 `deleteMessage` 定义清晰的策略并实现高效的本地缓存更新，并在 `ChatLocalCacheImpl` 和 `ChatRepositoryImpl` 中处理 `revokeMessage` 的结果。
- [ ] **未读数逻辑:** 在 `ChatRepositoryImpl` 中，当通过实时通信接收到新消息时，优化更新未读消息计数 (`messageNum`) 的逻辑。
