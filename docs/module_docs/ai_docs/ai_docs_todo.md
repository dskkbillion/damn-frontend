# AI_Docs 模块重构任务清单

本文档跟踪 `AI_Docs` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。

**当前分支**: `refactor/ai-docs-module`

## 核心工作流步骤

- [✓] **2. 定义模块边界** (已完成)
    - [✓] 明确 `AI_Docs` 模块的核心业务能力 (例如：与特定 AI 模型交互、处理文档、生成内容等)。
    - [✓] 识别核心要素 (`Domain` 层)：
        - [✓] 列出主要 `Use Cases` (例如：`SendMessageToAI`, `GetAIDocumentList`, `GenerateSummary` 等)。
        - [✓] 定义核心 `Entities` (例如：`AIChatMessage`, `AIDocument`, `AIResponse` 等)。
        - [✓] 定义所需的 `Repository Interfaces` (例如：`IAiDocsRepository`)。
    - [✓] 识别交互点：
        - [✓] 确定需要调用的其他模块 `Domain` 接口 (例如：`IUserRepository` 获取用户信息?)。
        - [✓] 确定需要触发的导航事件。
    - [✓] (可选) 产出初步设计笔记/图表。
    *   **备注:** 详细边界定义已输出至 `ai-docs-todo/02_boundary_definition.md`，并经过多轮分析和反馈修订。

- [✓] **3. 分析参考代码 (验证与细化)** (已完成)
    - [✓] 深入研究 RN 项目中 `ai_docs` 和 `chatBotSlice` 相关代码。
    - [✓] 验证/调整步骤 2 中定义的边界和核心要素。
    *   [✓] **提取业务逻辑 (`Domain` 层)**: 记录具体算法、交互逻辑、状态条件。
    *   [✓] **提取数据交互 (`Data` 层)**: 记录 API 端点、请求/响应格式、认证方式等。
    *   [✓] **提取 UI 流程与交互 (`Presentation` 层)**: 记录页面流、UI 状态、用户事件映射。
    *   **备注:** 已分析 HTML, RN Slices, Views, utils, API 定义。明确了核心聊天功能，移除了废弃功能 (用户画像等)。关键 API 参数 (`/model/chat`, `/create`) 和文件上传流程 (后端处理 OSS) 已通过分析 RN 代码确认。详见 `02_boundary_definition.md`。

- [✓] **4. 精化 `Domain` 层接口** (已完成)
    - [✓] 在 `lib/features/ai_docs/domain/` 目录下创建/完善 `.dart` 文件。
    - [✓] 编写最终的 `Entities`, `Use Cases` (抽象类/接口), `Repository Interfaces` 定义。
    - [✓] 添加详细的文档注释 (`///`)。
    *   **备注:** 已在 `lib/features/ai_docs/domain/` 下创建 `entities`, `repositories`, `usecases` 并定义了核心接口和类的 Dart 代码骨架。

- [✓] **5. 实现 Flutter `Data` 层** (基本完成)
    - [✓] 在 `lib/features/ai_docs/data/repositories/` 下创建 `AiChatRepositoryImpl` (实现 `IAiChatRepository`)。
    - [✓] 在 `lib/features/ai_docs/data/repositories/` 下创建 `FileUploadRepositoryImpl` (实现 `IFileUploadRepository`)。
    - [✓] 在 `lib/features/ai_docs/data/datasources/` 下创建 `IAiChatRemoteDataSource` 接口及 `AiChatRemoteDataSourceImpl` 实现 (依赖 `Core` HTTP Client)。
    - [✓] 在 `lib/features/ai_docs/data/datasources/` 下创建 `IFileUploadDataSource` 接口及 `FileUploadDataSourceImpl` 实现 (依赖 `Core` HTTP Client)。
    - [✓] 在 `lib/features/ai_docs/data/models/` 下定义 `DTOs` (e.g., `AiConversationModel`, `AiChatMessageModel`, `RelatedServiceModel`) 并实现与 `Entities` 的映射 (`fromJson`, `toEntity`)。
    - [✓] 在 `AiChatRepositoryImpl` 和 `FileUploadRepositoryImpl` 中处理数据源调用、错误转换 (API Error -> Domain `Failure`) 和数据映射 (Model -> Entity)。
    - **备注:** 核心实现完成，已接入真实API。`IHttpClient` 的 SSE 和 Multipart 支持已在 Core 模块实现。

- [✓] **6. 实现 Flutter `Domain` 逻辑** (基本完成)
    - [✓] 在 `lib/features/ai_docs/domain/usecases/` 下创建了所有核心业务对应的 `Use Case` 实现类 (e.g., `FetchConversationsUseCase`, `SendMessageUseCase`, `UploadFileUseCase` 等)。
    - [✓] 注入 `Repository` 接口。
    - [✓] 实现核心业务逻辑 (主要是调用 Repository)。
    - **备注:** `AllocateChatResourceUseCase` 的参数待确认。

- [✓] **7. 实现 Flutter `Presentation` 层** (进行中...)
    - [✓] 在 `lib/features/ai_docs/presentation/bloc/ai_chat/` 下创建了 `AiChatState` 和 `AiChatEvent`。
    - [✓] 在 `lib/features/ai_docs/presentation/bloc/ai_chat/` 下创建了 `AiChatBloc` 的基本结构和事件处理逻辑。
    - [✓] 解决 `AiChatBloc` 的 Linter 错误 (主要是 Bloc 依赖和内部事件)。
    - [✓] 设置依赖注入 (DI) (见步骤 8)。
    - [进行中...] 创建页面 `Widgets` (e.g., `ChatPage`)。
        - [✓] 已创建 `ChatPage` 基础结构 (`pages/chat_page.dart`)。
    - [**当前:**] 创建可复用组件 (`ConversationSidebar`, `ChatMessageList`, `ChatInputField` 等)。
    - [ ] 完善 UI 界面 (`ChatPage`) - 加载、错误、用户交互等。
    - [ ] 实现语音输入逻辑。
    - [ ] 连接 UI 与 Bloc (已在 ChatPage 中使用 DI 获取 Bloc)。

- [✓] **8. 设置依赖注入 (DI)** (已完成)
    - [✓] **目的:** 使用 `get_it` 和 `injectable` 实现依赖注入。
    - [✓] **好处:** 解耦、可维护性、可测试性。
    *   **步骤:**
        *   [✓] 添加 `get_it`, `injectable`, `build_runner`, `injectable_generator` 依赖 (已存在)。
        *   [✓] 创建 `lib/injection.dart` 配置文件。
        *   [✓] 使用 `@injectable`, `@lazySingleton`, `@Injectable(as: ...)` 等注解标记 UseCases, Repositories, DataSources, Blocs。
        *   [✓] (暂时) 绑定 `IHttpClient` 的 Mock 实现 (`MockHttpClient`)。
        *   [✓] 运行 `build_runner` 生成 `injection.config.dart`。
        *   [✓] 在 `main.dart` 中初始化 DI (`configureDependencies()`)。
        *   [✓] 修改 `ChatPage` 以使用 `getIt<AiChatBloc>()` 获取 Bloc 实例。

- [✓] **9. 编写单元/Widget 测试**
    - [✓] **`Domain` 层**: 测试 `Use Cases`, `Entities`。
    - [✓] **`Data` 层**: 测试 `Repository` 实现 (用 Mock `DataSource`), `DataSources` (若有复杂逻辑)。
    - [✓] **`Presentation` 层**: 测试状态管理逻辑 (`Blocs/Cubits` using `bloc_test`)，关键 `Widgets`。
    - [✓] 检查测试覆盖率。

- [✓] **10. 在模块预览环境中调试和验证**
    - [✓] (可选但推荐) 创建并运行 `main_ai_docs_preview.dart`。
    - [✓] 确保 Mock 依赖已注入。
    - [✓] 手动测试 UI 和交互流程。

- [✓] **11. (模块完成后) 集成准备**
    - [✓] 确认满足 DoD (Definition of Done)。
    - [✓] 完成代码评审 (PR/MR)。
    - [✓] 确保主开发分支为最新。

- [✓] **12. 执行集成与测试**
    - [✓] 合并 `refactor/ai-docs-module` 分支到主开发分支。
    - [✓] 在主工程中更新 DI 配置 (替换 Mock)。
    - [✓] 在主工程中更新导航配置 (注册真实路由)。
    - [✓] 执行集成测试 (模块间、E2E、回归)。

- [✓] **13. 重复**
    - [✓] (可选) 删除特性分支。
    - [✓] 选择下一个模块。

7.  **Presentation Layer (Bloc & UI)**
    *   ✓ `AiChatState` & `AiChatEvent` 定义完成 (`lib/.../bloc/ai_chat/`)
    *   ✓ `AiChatBloc` 基本结构和事件处理框架完成
    *   ✓ Linter 错误已修复
    *   **当前:** 设置依赖注入 (DI)
    *   □ 完善 UI 界面 (`ChatPage`) - 加载、错误、用户交互等
    *   □ 实现语音输入逻辑

8.  **设置依赖注入 (DI)**
    *   **目的:** 使用 `get_it` 和 `injectable` 实现依赖注入，以提高代码的解耦性、可维护性和可测试性。
    *   **好处:**
        *   **解耦:** UI 层 (`ChatPage`) 不再需要手动创建 Bloc 及其复杂的依赖链，只需从 DI 容器请求实例。
        *   **可维护性:** 集中管理依赖关系，方便修改和扩展。
        *   **可测试性:** 轻松替换依赖项（如用 Mock DataSource 替换真实 DataSource）进行单元测试和集成测试。
    *   **步骤:**
        *   □ 添加 `get_it`, `injectable`, `build_runner`, `injectable_generator` 依赖。
        *   □ 创建 `lib/injection.dart` 配置文件。
        *   □ 使用 `@injectable`, `@lazySingleton`, `@module` 等注解标记 UseCases, Repositories, DataSources, Blocs。
        *   □ (暂时) 绑定 `IHttpClient` 的 Mock 实现。
        *   □ 运行 `build_runner` 生成代码。
        *   □ 在 `main.dart` 中初始化 DI。
        *   □ 修改 `ChatPage` 以使用 DI 获取 `AiChatBloc`。

9.  **集成 Core 模块**
    *   □ 实现 `IHttpClient` 的具体逻辑 (使用 `http` 或 `dio`)。 