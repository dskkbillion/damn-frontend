# 模块合并前准备工作清单

**目的:** 本清单旨在帮助各位同事在将各自负责的功能模块合并到主开发分支之前，进行必要的检查和准备，以确保代码质量、规范统一，减少合并冲突，提高集成效率，为项目顺利上线奠定基础。

**请在合并你的模块代码前，逐项确认以下准备工作是否完成：**

---

## 1. 理解核心架构与规范 (文档阅读)

请确保你已仔细阅读并理解以下核心文档，这是我们项目协作的基础：

*   [ ] **必读:** `docs/模块开发核心工作流.md` - 理解推荐的开发流程和 Clean Architecture 分层思想。
*   [ ] **必读:** `docs/目录结构参考.md` - 遵循标准的目录结构。
*   [ ] **必读:** `docs/modular_routing_strategy_cn.md` - **(关键!)** 理解新的模块化路由策略，并准备将你的模块路由按此方式接入。
*   [ ] **必读:** `docs/caching_and_local_storage_strategy_cn.md` - 理解数据缓存和本地存储方案，保持一致性。
*   [ ] **必读:** `docs/api_usage_summary_cn.md` - 遵循通用的 API 调用约定 (认证、响应结构、错误处理)。
*   [ ] **必读:** `docs/tech_stack.md` - 确认使用的核心库与项目整体一致。
*   [ ] **必读:** `docs/module_documentation_guidelines_cn.md` - **(新增!)** 了解模块文档编写要求和存放位置。
*   [ ] (选读) 查阅你负责模块的边界定义文档 (`docs/BD/`)。
*   [ ] (选读) 参考 `order-todo/refactoring_todo.md` 了解 `Orders` 模块的实践细节。

## 2. 代码结构规范化

*   [ ] **分层检查:** 确认你的模块遵循 `Domain` / `Data` / `Presentation` 的分层结构。
*   [ ] **命名约定:** 检查类、方法、变量命名是否清晰、统一，符合 Dart/Flutter 规范。
*   [ ] **文件组织:** 确认 Widgets, Blocs, Pages, UseCases, Repositories 等文件是否放置在模块内约定的子目录下。

## 3. 路由设置适配 (模块化)

*   [ ] **创建模块路由文件:** 在你的模块 `presentation/routes/` 目录下创建路由文件 (如 `your_module_routes.dart`)。
*   [ ] **定义并暴露路由:** 将模块内的所有页面路由定义为 `GoRoute` 对象，并放在该文件的静态列表 (`static List<RouteBase> get routes => _routes;`) 中暴露出来 (参考 `features/orders/presentation/routes/order_routes.dart`)。
*   [ ] **移除旧路由定义:** 清理掉之前可能在核心路由或其他地方定义的、属于你模块的路由规则。
*   [ ] **准备聚合:** 你的模块路由列表已准备好，可以被 `lib/core/router/app_router.dart` 聚合。

## 4. 依赖注入 (DI) 检查

*   [ ] **注解检查:** 确保所有需要注入的类 (Repository 实现, UseCase 实现, Bloc, DataSource 实现等) 都已正确添加 `@injectable` 或相关注解 (`@LazySingleton`, `@Factory` 等)。
*   [ ] **模块注册:** 如果你的模块引入了需要手动注册的第三方库或特殊依赖，确保通过 `@module` 提供了注册方法。

## 5. 状态管理一致性

*   [ ] **理解模式:** 理解项目中主要使用的状态管理模式 (Bloc/Cubit)，确保你模块的状态管理实现易于理解和维护。
*   [ ] **数据流清晰:** 确认状态管理逻辑清晰，遵循单向数据流。

## 6. 核心服务使用

*   [ ] **检查复用:** 确认是否正确使用了 `lib/core/` 下提供的核心服务/组件 (如 `CoreDioClient`, `AppTheme`, `INavigationService`, `FlutterSecureStorage` 等)，避免重复造轮子。
*   [ ] **确认注入:** 确保你的模块可以通过 DI 正常获取所需的核心服务实例。

## 7. API 调用与数据模型

*   [ ] **遵循约定:** 确认 API 调用遵循了认证方式、响应结构处理 (`code` 字段判断) 等通用约定。
*   [ ] **错误处理:** 确认 API 调用有 `try-catch` 包裹，并将底层异常 (如 `DioException`) 映射为 `Domain` 层的 `Failure` 类型 (如 `ServerFailure`)。
*   [ ] **共享模型:** 如果你的模块需要使用其他模块已定义的实体类 (如 `User`, `Product`)，请提前沟通确认模型定义一致性或制定共享方案。

## 8. 测试覆盖

*   [ ] **基础测试:** 为你模块中的核心逻辑 (Models 的 `fromJson/toEntity`, UseCases, Blocs 的关键状态转换) 添加单元测试。
*   [ ] **Widget 测试:** 为关键的页面和 Widget 编写 Widget 测试，验证基本渲染和交互。

## 9. 版本控制 (Git) 与冲突处理

*   [ ] **提前更新:** 在发起合并请求 (PR/MR) **之前**，务必从最新的主开发分支 (`main`, `develop`, etc.) 拉取代码，并 merge 或 rebase 到你的特性分支。
*   [ ] **本地解决冲突:** **必须在本地**彻底解决所有合并冲突。请特别关注以下常见冲突文件：
    *   **核心路由 (`lib/core/router/app_router.dart`):** 
        *   冲突点: 聚合模块路由的 `routes` 列表 (`...YourModuleRoutes.routes,`)。
        *   解决: 通常保留所有模块的聚合行。注意检查 `initialLocation` 和其他全局配置。
    *   **依赖注入 (`lib/app/di/injection_container.dart`, `lib/app/di/injection_container.config.dart`):**
        *   冲突点: 手动注册 (`.dart`) 和自动生成 (`.config.dart`)。
        *   解决: 
            1.  先解决 `.dart` 文件中的手动注册冲突。
            2.  **然后重新运行 `flutter pub run build_runner build --delete-conflicting-outputs` 生成最新的 `.config.dart`。切勿手动修改 `.config.dart`！**
    *   **核心配置 (`pubspec.yaml`, `.env`):**
        *   冲突点: 依赖版本、assets、环境变量。
        *   解决: 仔细比对，保留所有必需项。版本冲突需团队讨论决定。
    *   **核心代码 (`lib/core/`):**
        *   冲突点: 若多模块修改了同一核心服务/工具。
        *   解决: 理解修改意图，合并逻辑，确保正确性。
    *   **共享实体/模型:**
        *   冲突点: 若多模块修改了同一共享实体类。
        *   解决: 仔细合并，确保模型定义一致。
*   [ ] **本地验证:** 解决完所有冲突后，**必须**在本地重新构建 (`flutter clean`, `flutter pub get`, `flutter run`) 并测试你的模块功能，确保没有引入新的错误。
*   [ ] **提交信息:** 确保 Git commit message 清晰、规范。

## 10. 沟通与审查

*   [ ] **主动沟通:** 在开发过程中遇到任何关于架构、规范、跨模块交互的不确定问题，请及时与相关同事或架构负责人沟通。
*   [ ] **代码审查:** 在准备合并前，建议进行代码审查 (Code Review)。

---

**完成以上检查后，你的模块将更容易、更顺利地集成到主项目中。感谢大家的配合！**


