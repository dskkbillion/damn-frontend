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
