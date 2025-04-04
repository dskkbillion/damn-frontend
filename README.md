# DSKK Flutter 重构项目

本项目旨在将现有的 React Native 应用（参考代码位于 `design-info/demo-repository`）逐步重构为基于 Flutter 的新应用，同时采用清晰的架构模式。

## 核心开发范式

我们遵循 **"基于参考的、模块化增量的 Flutter Clean Architecture 重构范式"**。核心理念是：

1.  **模块化 (Modular)**: 将应用拆分为独立的业务功能模块（如 Auth, Home, Orders, Chat, Profile, Seller, AI_Docs, Cart 等）。
2.  **增量式 (Incremental)**: 逐个模块进行重构和替换，而非一次性推倒重来。
3.  **基于参考 (Reference-Based)**: 以现有的 RN 代码和 HTML 原型 (`design-info/`) 作为业务逻辑和 UI 实现的主要参考依据。
4.  **Clean Architecture**: 在每个模块内部遵循清晰的分层结构（Domain, Data, Presentation）。
5.  **隔离开发 (Isolated Development)**: 每个模块在独立分支上开发，并大量使用 Mock 替代外部依赖（其他模块接口、导航服务），确保模块可以独立编译、测试和预览。

## 模块开发核心工作流

针对 **单个模块** 的开发遵循以下循环步骤 (详情请参考 `docs/模块开发核心工作流.md`):

1.  **选择模块** & 创建特性分支 (`refactor/module-name`)。
2.  **定义模块边界**: 清晰界定模块职责、核心 Domain 实体/用例/接口、以及与外部的交互点（依赖和导航需求）。**这是关键设计步骤**。产出物位于 `docs/BD/` 目录下，例如 `docs/BD/auth_boundary_definition.md`。
3.  **分析参考代码**: 对比 RN/HTML，验证边界定义，提取业务逻辑、数据交互、UI 流程细节。
4.  **精化 `Domain` 层接口**: 编写接口定义和详细文档注释。
5.  **实现 `Data` 层**: 实现 `Repository` 接口，对接 API/本地存储，创建 Mock 数据源。
6.  **实现 `Domain` 逻辑**: 实现 `Use Cases`。
7.  **实现 `Presentation` 层**: 实现 UI 页面/组件和状态管理 (Bloc/Cubit/...).
8.  **配置 Mock 依赖**: 在模块的测试/预览环境中注入 Mock 实现。
9.  **编写测试**: 编写单元测试和 Widget 测试，确保模块质量。
10. **隔离调试与验证**: 在模块预览环境中手动测试功能和 UI。
11. **集成准备**: 代码评审，确认满足 DoD。
12. **集成与测试**: 合并到主开发分支，替换 Mock 为真实实现，进行集成测试。
13. **重复**: 选择下一个模块。

## 分支策略

*   **`main`**: 对应线上稳定版本。**禁止直接向 `main` 分支提交代码**。
*   **`develop`**: 主开发分支，集成了所有已完成并通过测试的模块特性。这是功能开发分支 (如 `refactor/module-name`) 的合并目标。`develop` 分支应保持相对稳定，随时可以基于它创建发布分支 (`release/*`)。
*   **特性分支 (`refactor/module-name`, `feature/*`, `fix/*`)**: 用于开发单个模块、新功能或修复 Bug。从 `develop` 分支创建，完成后合并回 `develop` 分支。

## 当前状态与进展

*   **模块边界定义**: 我们正在逐步分析并定义各个核心模块的边界，文档存放于 `docs/BD/` 目录下。这是当前阶段的重点工作之一。
*   **`AI Docs` 模块**: 作为第一个实践模块，`AI Docs` 已基本完成边界定义 (`ai-docs-todo/02_boundary_definition.md`) 和初步开发。根据开发体验，完成这样一个模块大致需要数天时间（初步估计约 10+ 人日工作量），具体取决于复杂度和对流程的熟悉程度。

## 如何协作

1.  **开始新工作前**: 确保你的本地 `develop` 分支是最新状态 (`git checkout develop && git pull origin develop`)。
2.  **创建特性分支**: 从最新的 `develop` 分支创建你的工作分支 (`git checkout -b refactor/your-module-name` 或 `feature/your-feature`)。
3.  熟悉 `docs/模块开发核心工作流.md` 中定义的开发流程。
4.  查看 `docs/BD/` 目录下的模块边界定义文档，了解各模块范围。
5.  认领一个尚未开始或正在进行的模块（请先沟通协调）。
6.  遵循上述工作流进行开发和测试。
7.  积极参与模块边界定义的讨论和完善。
8.  **完成工作后**: 将你的特性分支推送到远程，并创建 Pull Request (或 Merge Request) 请求合并到 `develop` 分支。确保进行代码评审。

---

*如有任何疑问，请随时沟通。*
