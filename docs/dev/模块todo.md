# 模块重构任务清单(以ai doc为例)

本文档跟踪 `AI_Docs` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。

**当前分支**: `refactor/ai-docs-module`

## 核心工作流步骤

- [ ] **2. 定义模块边界**
    - [ ] 明确 `AI_Docs` 模块的核心业务能力 (例如：与特定 AI 模型交互、处理文档、生成内容等)。
    - [ ] 识别核心要素 (`Domain` 层)：
        - [ ] 列出主要 `Use Cases` (例如：`SendMessageToAI`, `GetAIDocumentList`, `GenerateSummary` 等)。
        - [ ] 定义核心 `Entities` (例如：`AIChatMessage`, `AIDocument`, `AIResponse` 等)。
        - [ ] 定义所需的 `Repository Interfaces` (例如：`IAiDocsRepository`)。
    - [ ] 识别交互点：
        - [ ] 确定需要调用的其他模块 `Domain` 接口 (例如：`IUserRepository` 获取用户信息?)。
        - [ ] 确定需要触发的导航事件。
    - [ ] (可选) 产出初步设计笔记/图表。

- [ ] **3. 分析参考代码 (验证与细化)**
    - [ ] 深入研究 RN 项目中 `ai_docs` 和 `chatBotSlice` 相关代码。
    - [ ] 验证/调整步骤 2 中定义的边界和核心要素。
    *   [ ] **提取业务逻辑 (`Domain` 层)**: 记录具体算法、交互逻辑、状态条件。
    *   [ ] **提取数据交互 (`Data` 层)**: 记录 API 端点、请求/响应格式、认证方式等。
    *   [ ] **提取 UI 流程与交互 (`Presentation` 层)**: 记录页面流、UI 状态、用户事件映射。

- [ ] **4. 精化 `Domain` 层接口**
    - [ ] 在 `lib/features/ai_docs/domain/` 目录下创建/完善 `.dart` 文件。
    - [ ] 编写最终的 `Entities`, `Use Cases` (抽象类/接口), `Repository Interfaces` 定义。
    - [ ] 添加详细的文档注释 (`///`)。

- [ ] **5. 实现 Flutter `Data` 层**
    - [ ] 在 `lib/features/ai_docs/data/repositories/` 下创建 `AiDocsRepositoryImpl`。
    - [ ] 在 `lib/features/ai_docs/data/datasources/` 下创建 `AiDocsRemoteDataSource` (可能还有 `LocalDataSource`?)。
    - [ ] 在 `lib/features/ai_docs/data/models/` 下定义 `DTOs` 并实现与 `Entities` 的映射。
    - [ ] 处理数据层错误并映射到 `Domain` `Failures`。
    - [ ] 创建 Mock `DataSource` 用于测试。

- [ ] **6. 实现 Flutter `Domain` 逻辑**
    - [ ] 在 `lib/features/ai_docs/domain/usecases/` 下创建 `Use Case` 实现类。
    - [ ] 注入 `Repository` 接口。
    - [ ] 实现核心业务逻辑。

- [ ] **7. 实现 Flutter `Presentation` 层**
    - [ ] 在 `lib/features/ai_docs/presentation/pages/` 下创建页面 `Widgets`。
    - [ ] 在 `lib/features/ai_docs/presentation/widgets/` 下创建可复用组件。
    - [ ] 在 `lib/features/ai_docs/presentation/providers/` (或 `bloc/`, `cubit/`) 下创建状态管理类。
    - [ ] 状态管理类依赖 `Use Case` 接口。
    - [ ] 实现状态管理逻辑和 UI 事件处理。
    - [ ] UI `Widgets` 监听状态并触发事件。

- [ ] **8. 识别并配置外部依赖 (隔离开发)**
    - [ ] 确定需要调用的导航服务方法。
    - [ ] 确定需要依赖的其他模块 `Domain` 接口。
    - [ ] (在预览/测试环境中) 配置 Mock 依赖注入 (例如 Mock `IUserRepository`, Mock 导航)。

- [ ] **9. 编写单元/Widget 测试**
    - [ ] **`Domain` 层**: 测试 `Use Cases`, `Entities`。
    - [ ] **`Data` 层**: 测试 `Repository` 实现, `DataSources`。
    - [ ] **`Presentation` 层**: 测试状态管理逻辑 (`Riverpod Providers`), 关键 `Widgets`。
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