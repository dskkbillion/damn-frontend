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

- [ ] **5. 实现 Flutter `Data` 层**
    - [ ] 在 `lib/features/ai_docs/data/repositories/` 下创建 `AiChatRepositoryImpl` (实现 `IAiChatRepository`)。
    - [ ] 在 `lib/features/ai_docs/data/datasources/` 下创建 `IAiChatRemoteDataSource` 接口及 `AiChatRemoteDataSourceImpl` 实现 (依赖 `Core` HTTP Client)。
    - [ ] 在 `lib/features/ai_docs/data/models/` 下定义 `DTOs` (e.g., `AiConversationModel`, `AiChatMessageModel`) 并实现与 `Entities` 的映射 (`fromJson`, `toEntity`)。
    - [ ] 在 `AiChatRepositoryImpl` 中处理数据源调用、错误转换 (API Error -> Domain `Failure`) 和数据映射 (Model -> Entity)。
    - [ ] **(隔离开发)** 创建 Mock `DataSource` (`MockAiChatRemoteDataSource`) 用于单元测试和模块预览。

- [ ] **6. 实现 Flutter `Domain` 逻辑**
    - [ ] 在 `lib/features/ai_docs/domain/usecases/` 下创建 `Use Case` 实现类。
    - [ ] 注入 `Repository` 接口。
    - [ ] 实现核心业务逻辑。

- [ ] **7. 实现 Flutter `Presentation` 层**
    - [ ] 在 `lib/features/ai_docs/presentation/pages/` 下创建页面 `Widgets`。
    - [ ] 在 `lib/features/ai_docs/presentation/widgets/` 下创建可复用组件。
    - [ ] 在 `lib/features/ai_docs/presentation/bloc/` (或 `cubit/`) 下创建状态管理类。
    - [ ] 状态管理类依赖 `Use Case` 接口。
    - [ ] 实现状态管理逻辑和 UI 事件处理。
    - [ ] UI `Widgets` 监听状态并触发事件。

- [ ] **8. 识别并配置外部依赖 (隔离开发)**
    - [ ] 确定需要调用的导航服务方法。
    - [ ] 确定需要依赖的其他模块 `Domain` 接口 (或 `Core` 服务接口，如 `IHttpClient`, `IAuthService`, `IFileRepository` 等)。
    - [ ] (在预览/测试环境中) 配置 Mock 依赖注入 (例如 Mock Repository, Mock `Core` 服务)。

- [ ] **9. 编写单元/Widget 测试**
    - [ ] **`Domain` 层**: 测试 `Use Cases`, `Entities`。
    - [ ] **`Data` 层**: 测试 `Repository` 实现 (用 Mock `DataSource`), `DataSources` (若有复杂逻辑)。
    - [ ] **`Presentation` 层**: 测试状态管理逻辑 (`Blocs/Cubits` using `bloc_test`)，关键 `Widgets`。
    - [ ] 检查测试覆盖率。

- [ ] **10. 在模块预览环境中调试和验证**
    - [ ] (可选但推荐) 创建并运行 `main_ai_docs_preview.dart`。
    - [ ] 确保 Mock 依赖已注入。
    - [ ] 手动测试 UI 和交互流程。

- [ ] **11. (模块完成后) 集成准备**
    - [ ] 确认满足 DoD (Definition of Done)。
    - [ ] 完成代码评审 (PR/MR)。
    - [ ] 确保主开发分支为最新。

- [ ] **12. 执行集成与测试**
    - [ ] 合并 `refactor/ai-docs-module` 分支到主开发分支。
    - [ ] 在主工程中更新 DI 配置 (替换 Mock)。
    - [ ] 在主工程中更新导航配置 (注册真实路由)。
    - [ ] 执行集成测试 (模块间、E2E、回归)。

- [ ] **13. 重复**
    - [ ] (可选) 删除特性分支。
    - [ ] 选择下一个模块。 