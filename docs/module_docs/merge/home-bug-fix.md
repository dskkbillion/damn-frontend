# Home 模块加载卡顿及 Base URL 配置问题修复记录

## 问题背景

在 `dev_preview` 模式下启动应用时，发现 **Home (主页)** 和 **Chat (AI 助手/消息)** 两个模块的页面长时间停留在加载状态（转圈），无法正常显示内容。而 **Seller (卖家中心)** 模块可以正常加载。

## 调试过程与分析

1.  **初步排查 (Home 模块):**
    *   检查 `HomePage` 的 Bloc (`HomeBloc`) 和 UI 代码，确认状态处理逻辑基本合理，能够处理加载、成功、错误等状态。
    *   检查 `HomeRemoteDataSourceImpl`，发现其使用的是 Dart 内置的 `http` 包，而非 `Dio`。排除了 Dio 拦截器导致问题的可能性。

2.  **问题扩展 (Chat 模块):**
    *   发现 Chat 模块同样卡在加载状态，指向一个更普遍的底层问题，而非 Home 模块独有。

3.  **怀疑认证问题:**
    *   考虑到 `dev_preview` 使用了 `MockAuthRepository` (提供假用户 9999) 和手动注入的真实测试 Token/UserID (用户 18888888888)，怀疑可能是测试 Token 无效或权限不足导致 API 调用失败 (401/403)。

4.  **日志分析 (关键突破):**
    *   检查控制台日志，发现 Home 和 Chat 模块发起的 API 请求（分别使用 `http` 和 `Dio`）均出现了 **`Connection timed out`** 错误。请求的目标地址都是 `http://47.113.230.11:5102`。
    *   同时，观察到正常工作的 Seller 模块请求的 API 地址是 `https://app.duoshaokankan.com/prod-api`。
    *   **结论:** 问题并非认证失败，而是 Home 和 Chat 模块使用了**错误且无法访问**的 Base URL (`http://47.113.230.11:5102`)，而 Seller 模块使用了正确的 Base URL (`https://app.duoshaokankan.com/prod-api`)。

5.  **追踪 Base URL 配置:**
    *   确认 `.env` 文件中定义了 `BACKEND_BASE_URL=https://app.duoshaokankan.com/prod-api` 和 `MODEL_BASE_URL=http://47.113.230.11:5102`。预期 Home 模块应使用 `BACKEND_BASE_URL`。
    *   检查 `lib/features/home/di/home_di.dart`，发现它**试图**从 `.env` 读取 `BACKEND_BASE_URL` 并注册为名为 `'baseUrl'` 的实例，但前提是该名称的实例尚未被注册。
    *   在 `home_di.dart` 中添加日志，运行时发现名为 `'baseUrl'` 的实例**在 `initHomeDi()` 执行前已被注册**，且值为错误的 `http://47.113.230.11:5102`。
    *   检查 DI 初始化顺序 (`main_dev_preview.dart`)：`configureDependencies` (运行 `injectable` 生成的代码) -> `initHomeDi` -> `FavoritesDI.init`。确认错误注册发生在 `configureDependencies` 或其调用的生成代码中。
    *   检查 `injectable` 生成的文件 `lib/app/di/injection_container.config.dart`，发现它会注册一个名为 `'baseUrl'` 的实例，其值来源于 `registerModule.baseUrl`。
    *   检查 `lib/app/di/register_module.dart`，找到 `RegisterModule` 类中定义了 `String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://47.113.230.11:5102';`。由于 `.env` 中没有 `API_BASE_URL`，它总是回退到硬编码的错误 URL。

## 根本原因

依赖注入配置中存在冗余和冲突：

1.  `lib/app/di/register_module.dart` 文件中的 `RegisterModule` 类定义了一个名为 `baseUrl` 的 getter，该 getter 在 `.env` 文件缺少 `API_BASE_URL` key 时会错误地返回模型服务的 URL (`http://47.113.230.11:5102`)。
2.  `injectable` 包根据这个 getter 和 `@Named('baseUrl')` 注解，在自动生成的 `injection_container.config.dart` 文件中注册了一个名为 `'baseUrl'` 的 `String` 单例，其值为上述错误的 URL。
3.  这个自动生成的注册逻辑在 `configureDependencies` 函数中被执行，早于 `initHomeDi()` 的执行。
4.  当 `initHomeDi()` 执行时，它检测到名为 `'baseUrl'` 的实例已被注册，因此跳过了使用正确的 `BACKEND_BASE_URL` 进行注册的逻辑。
5.  最终，`HomeRemoteDataSourceImpl` 在创建时被注入了由 `RegisterModule` 错误提供的 `'baseUrl'` 值，导致 API 请求发往了错误的地址。

## 解决方案

1.  **移除冗余配置:** 编辑 `lib/app/di/register_module.dart` 文件，删除 `RegisterModule` 类中多余且错误的 `baseUrl` getter 及其 `@Named('baseUrl')` 注解。因为核心的 `Dio` 实例已经由 `CoreRegisterModule` 使用正确的 `'backendBaseUrl'` 进行了配置。
2.  **清理缓存:** 在终端运行 `flutter clean`。
3.  **重新生成 DI 代码:** 在终端运行 `flutter pub run build_runner build --delete-conflicting-outputs`，确保 `injection_container.config.dart` 文件被更新，不再包含错误的 `'baseUrl'` 注册。
4.  **(可选) 移除调试日志:** 删除之前为调试目的添加到 `lib/features/home/di/home_di.dart` 的 `print` 语句。

## 后续问题

在应用上述修复并重新运行后：

1.  Home 模块的 API 请求 URL 已正确变为 `https://app.duoshaokankan.com/prod-api/...`。
2.  API 请求成功返回 `200 OK` 状态码，连接超时问题解决。
3.  但是，API 返回的实际业务数据为空（例如 Banner 的 `rows: []`，Feed 的 `products: []`）。
4.  因此，Home 页面显示"暂无数据"的界面。

**结论:** 前端的 Base URL 配置问题已解决。目前数据显示为空的问题需要检查**后端接口逻辑**或**生产环境的测试数据**。
