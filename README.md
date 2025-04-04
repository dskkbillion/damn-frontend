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
=======
# dskk_flutter_refactor (Flutter 重构项目)

一个 Flutter 项目，用于重构和实现各种功能，包括一个 AI 文档（ai_docs）模块。

## 开始使用

本项目使用 Flutter 构建，重点采用清晰架构、依赖注入 (GetIt/Injectable) 和状态管理 (Bloc)。

### 环境要求

*   Flutter SDK (请确保版本兼容，参考 `pubspec.yaml`)
*   Dart SDK
*   代码编辑器，如 VS Code 或 Android Studio，并安装 Flutter 插件。

### 项目设置

1.  **克隆仓库:**
    ```bash
    git clone <repository-url> # 请替换为实际仓库 URL
    cd dskk_flutter_refactor
    ```
2.  **配置环境变量:**
    *   复制环境变量示例文件: `cp .env.example .env`
    *   编辑 `.env` 文件，提供必要的 URL:
        *   `MODEL_BASE_URL`: AI 模型服务的基础 URL。
        *   `BACKEND_BASE_URL`: 后端服务（例如文件上传）的基础 URL。
    *   确保 `.env` 文件已在 `pubspec.yaml` 的 `flutter -> assets` 部分声明。
3.  **安装依赖:**
    ```bash
    flutter pub get
    ```
4.  **运行代码生成 (如果使用了 Injectable, Freezed 等):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

## 运行 AI 文档模块预览

`ai_docs` 模块提供了一个具备多模态交互能力的 AI 聊天界面。

要专门运行此模块的预览：

```bash
flutter run -t lib/main_ai_docs_preview.dart
```

这将使用专用的入口点 (`main_ai_docs_preview.dart`) 和特定的 App Widget (`AiDocsPreviewApp`) 来启动 `ChatPage`。

**注意:** 此预览目前为了测试目的，使用了一些硬编码值（用户 ID、认证 Token、API 版本号 Header）。详情请参考 `ai-docs-todo/hardcoded_values.md`。

## 项目结构 (简述)

*   **`lib/app/`**: 核心应用配置 (依赖注入 DI, 路由, 主 App Widget)。
*   **`lib/core/`**: 共享工具 (错误处理, 网络客户端接口)。
*   **`lib/features/`**: 包含独立的功能模块 (例如 `ai_docs`)。
    *   **`ai_docs/`**: AI 聊天模块。
        *   `data/`: 数据层 (Repository 实现, 数据源, 数据模型)。
        *   `domain/`: 领域层 (实体 Entity, 用例 UseCase, Repository 接口)。
        *   `presentation/`: 表示层 (Bloc, 页面 Page, 组件 Widget)。
*   **`ai-docs-todo/`**: AI 文档模块专属文档 (集成指南, TODO 列表)。

## 使用的关键 Packages

*   `flutter_bloc`: 状态管理。
*   `get_it` / `injectable`: 依赖注入。
*   `dio`: 用于大多数请求的 HTTP 客户端。
*   `http`: 用于 SSE 流式传输。
*   `flutter_dotenv`: 环境变量管理。
*   `package_info_plus`: 获取应用包信息。
*   `record`: 音频录制。
*   `audioplayers`: 音频播放 (计划中)。
*   `image_picker`: 图片选择。
*   `go_router`: 导航 (集成指南中用作示例)。

## 原始 Flutter Readme 内容

(以下保留了 Flutter 默认 README 中的通用入门资源链接，供参考。)

如果你是 Flutter 新手，以下资源可以帮助你入门：

- [实验：编写你的第一个 Flutter 应用](https://docs.flutter.dev/get-started/codelab)
- [手册：有用的 Flutter 示例](https://docs.flutter.dev/cookbook)

要获取 Flutter 开发的帮助，请查看
[在线文档](https://docs.flutter.dev/)，其中提供了教程、示例、移动开发指南以及完整的 API 参考。

