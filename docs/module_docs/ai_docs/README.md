# AI 文档/聊天模块 (AiDocs) 核心说明文档

**最后更新:** YYYY-MM-DD (请根据实际日期修改)

---

## 1. 模块概述 (Brief Overview)

*   **一句话描述:** 提供与 AI 进行交互式聊天（支持多会话管理）、处理文档附件（上传、关联）以及获取相关推荐等功能。
*   **主要功能点:**
    *   AI 对话界面 (`ChatPage`)
    *   发送文本、文件（图片/音频）给 AI (文件通过 `/api/common/public/upload` 上传至 OSS)
    *   通过 SSE 流式接收 AI 回复
    *   管理历史对话列表 (获取、创建、删除)
    *   获取相关服务推荐 (调用 `/recsys/conversation/recommend` API)
    *   语音输入转文本 (调用 `/model/chat/audio` API)
    *   (待实现) 聊天资源分配/一键派单 (调用 `/chat/allocate` API)

## 2. 路由入口与参数 (Routing Entry Points & Parameters)

*   **如何进入本模块:**
    *   路径: `/ai_chat`, 名称: `aiChat` (AI 聊天主界面，当前实现默认进入新对话或上次对话状态)
    *   (规划中) 路径: `/conversation/:conversationId`, 名称: `aiConversation` (进入指定对话，尚未在 `ai_docs_routes.dart` 实现)
*   **必需参数:**
    *   `/ai_chat`: 无需参数。
    *   (规划中) `/conversation/:conversationId`: 需要路径参数 `conversationId` (类型待定)。
*   **参考:** 路由定义在 `lib/features/ai_docs/presentation/routes/ai_docs_routes.dart`。遵循 `docs/modular_routing_strategy_cn.md` 规范。

## 3. 外部依赖说明 (External Dependencies)

*   **核心服务依赖:**
    *   `CoreDioClient` (通过 Repository 间接依赖，用于网络请求)
    *   `IAuthRepository` (或类似服务，用于获取当前用户 ID 和 Token，目前由入口文件硬编码注入)
    *   (可能) `INavigationService` (仅当模块内部有多页面导航时需要，目前看主要为单页 `ChatPage`)
*   **跨模块依赖:**
    *   目前看无直接 Feature 模块依赖。主要依赖 Core 层的网络、认证(待集成)、文件/音频处理(待集成)。

## 4. 调用的主要 API (APIs Consumed)

*   **接口列表与目的:**
    *   `/model/chat/list` (获取历史对话列表)
    *   `/model/chat/messages` (加载指定对话的消息历史)
    *   `/model/chat/create` (创建新对话)
    *   `/model/chat/delete` (删除对话)
    *   `/model/chat` (核心 SSE 端点，用于发送消息并流式接收回复)
    *   `/model/chat/audio` (语音转文本)
    *   `/api/common/public/upload` (文件上传至 OSS，由后端处理)
    *   `/recsys/conversation/recommend` (获取相关服务推荐)
    *   `/chat/allocate` (聊天分配/一键派单)
    *   (待确认) `/model/chat/cancel` (中断流式生成，目前 Flutter 端未调用)
*   **细节参考:** 详细信息请参考全局的 `docs/api_usage_summary_cn.md` 文档及模块内的 `03_data_layer_analysis.md`, `04_api_config_and_boundaries.md`。

## 5. (可选) 对外暴露的服务/接口 (Exposed Services/Interfaces)

*   该模块主要提供 UI 界面 (`ChatPage`)，目前不直接对外暴露服务或接口。

## 6. (可选) 注意事项/配置要求

*   **API Key/认证:** 需要有效的用户 Token (通过 `AuthInterceptor` 添加到请求头)，目前在预览入口硬编码。
*   **文件存储:** 文件上传功能依赖于后端配置好的对象存储服务 (OSS)，前端通过 `/api/common/public/upload` 接口间接使用。
*   **模型依赖:** 功能依赖于后端部署的特定 AI 模型。
*   **.env 配置:** 需要在项目根目录 `.env` 文件中配置 `BACKEND_BASE_URL`。

## 7. 依赖包使用说明 (Package Dependencies)

*   **`flutter_bloc` / `bloc`**: 状态管理 (`AiChatBloc`)。
*   **`get_it` / `injectable`**: 依赖注入。
*   **`go_router`**: 路由管理。
*   **`dio` / `pretty_dio_logger`**: 网络请求 (通过 `CoreDioClient`)。
*   **`dartz` / `equatable`**: 函数式编程辅助、值比较。
*   **`flutter_secure_storage`**: 安全存储 (用于 Token 和 User ID)。
*   **`package_info_plus`**: 获取应用信息 (用于请求头)。
*   **`flutter_dotenv`**: 加载环境变量。
*   **`(可能)` `http`**: 用于 SSE 连接的底层实现。
*   **`(可能)` `file_picker` / `image_picker`**: 用于文件选择 UI。
*   **`(可能)` `record` / `audioplayers` / `permission_handler`**: 用于语音输入 UI 和处理。
*   (版本请参考 `pubspec.yaml`)

## 8. 资源管理说明 (Resource Management)

*   **模块资源列表:** 尚未定义明确的本地资源 (图片、图标等)。可能需要聊天气泡背景、默认头像、加载/错误占位图。
*   **资源命名规范:** 待定义。建议遵循全局规范，模块特定资源使用 `ai_docs_` 或 `ic_aichat_` 前缀。
*   **资源存放位置:** 待定义。建议模块专属放 `assets/images/ai_docs/`。
*   **资源使用方式:** 待定义。建议使用 `assets_gen`。

## 9. 已知问题与解决方案 (Known Issues & Solutions)

*   **已知限制/问题:**
    *   流式输出在网络不稳定时可能中断 (需要健壮的错误处理和重连机制)。
    *   文件上传大小和类型可能有限制 (需后端明确)。
    *   `/chat/allocate` API 的确切请求参数未知。
    *   `/api/common/public/upload` 成功响应的具体结构未知 (用于提取 OSS URL)。
    *   当前使用**硬编码的用户 ID (`1`)** 在 `AiChatBloc` 中。
    *   当前使用**硬编码的 Authorization Token 和 version (`'100'`)** 在 `dio_http_client.dart` 的 `postMultipart` 中。
*   **临时解决方案/规避措施:**
    *   在预览入口 (`main_dev_preview.dart` 等) 硬编码注入测试 Token 和 User ID 到 `FlutterSecureStorage`。
*   **修复计划:**
    *   **集成 Auth 模块**后，替换所有硬编码的 User ID 和 Token。
    *   与后端确认 `/chat/allocate` 和 `/api/common/public/upload` 的细节。
    *   完善 SSE 流的错误处理。
    *   确认 `version` 请求头是否应动态获取。
*   **开发者注意事项:**
    *   处理 SSE 流时注意连接管理和错误处理 (解析 JSON、处理 done 事件)。
    *   确保文件上传后，传递给 `/model/chat` 的 `files` 参数**仅包含有效的 OSS URL**，避免传递本地 URI。
    *   避免在 Flutter 中重现 RN `fileSlice` 可能存在的状态重复问题（本地 URI 与 OSS URL 并存）。

## 10. 跨模块通信机制 (Cross-Module Communication)

*   **输出事件/通知:** 目前无明确的跨模块事件输出需求。
*   **输入事件/通知:** 需要监听用户认证状态变化 (来自 Auth 模块) 以更新 User ID 和 Token。
*   **通信方式:**
    *   主要通过 GoRouter 进行页面导航。
    *   通过 DI (GetIt) 获取核心服务 (如 `CoreDioClient`, `IAuthRepository`)。
*   **直接依赖:**
    *   不应直接依赖其他 Feature 模块。依赖 Core 服务和未来的 Auth 服务。

---

**请根据模块的实际开发情况，持续更新本文档。** 