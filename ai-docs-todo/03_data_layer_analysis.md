# AI_Docs 模块 Data 层分析与实现策略

本文档总结了在进入 `AI_Docs` 模块 Data 层实现（工作流步骤 5）之前的分析结果、待确认的关键问题以及推荐的实现结构。

## 1. Data 层分析状态 (已完成)

通过分析 RN 代码 (`modelActions.ts`, `filesystem.tsx`, `uploadActions.ts` 等) 和 API 定义 (`model-new.json`)，我们已基本掌握 Data 层实现所需的核心信息：

*   **核心 API 端点及状态:**
    *   `/model/chat/list` (获取会话列表): API 文档 (`model-new.json`) 中存在，响应结构明确。
    *   `/model/chat/messages` (加载消息): API 文档中存在，请求参数明确，响应结构需参考 RN 实现或实际调用。
    *   `/model/chat/create` (创建会话): API 文档中存在，但**请求参数定义错误**。实际参数 (`{ user_id, title? }`) 已通过分析 RN 代码 (`createChatRoomThunk`) 确认。
    *   `/model/chat/delete` (删除会话): API 文档中存在，请求参数明确。
    *   `/model/chat` (发送消息/SSE): API 文档中存在，确认返回 SSE 流。但**请求参数定义缺失**。实际参数 (`{ model, user_id, message, conversation_id, files, stream }`) 已通过分析 RN 代码 (`Send2Model`) 确认。
    *   `/model/chat/audio` (语音转文字): API 文档中存在，需要文件 URL 作为输入。
    *   `/recsys/conversation/recommend` (相关服务推荐): API 文档中存在，请求参数明确，但**响应结构 (`schema`) 未定义**。
    *   `/model/chat/package` (匹配/打包?): API 文档中存在，但**确切用途和所需参数需参考 RN 调用点**。
    *   `/api/common/public/upload` (文件上传): **此关键端点在 `model-new.json` 中缺失**，但在 RN 代码 (`uploadActions.ts`) 中发现，确认由后端处理 OSS 上传。
    *   **缺失 API:** 收藏 (`toggleFavorite`) 功能已废弃，对应 API 无需查找。

*   **关键 API 参数:** 通过分析 RN 代码，明确了 `/model/chat` (发送消息) 和 `/model/chat/create` (创建会话) 的实际请求体结构，弥补了 API 文档的不足。
*   **文件上传流程:** 确认文件上传由后端 `/api/common/public/upload` 接口统一处理，该接口负责与阿里云 OSS 交互。前端只需将文件 `FormData` POST 到此接口，无需直接操作 OSS SDK 或处理 STS 凭证。

## 2. 待确认/解决的关键问题

在实现 Data 层期间，需要密切关注并解决以下问题：

1.  **`/model/chat` 的 `files` 参数处理 (最高优先级):**
    *   **问题:** RN 代码 `Send2Model` 的实现及其注释表明，发送给 `/model/chat` 的 `files` 数组可能包含**本地文件 URI (`file:///...`)** 而非预期的 OSS URL。
    *   **需确认:** 后端 `/model/chat` 接口**是否能处理**这些本地 URI？
    *   **解决方案 (若后端不能处理):** Flutter 的 `Data` 层或其调用者 (Use Case/Presentation) **必须**确保在调用 `repository.sendMessage` 前，文件已上传成功，并且 `fileUrls` 参数**仅包含有效 OSS URL**。

2.  **`/recsys/conversation/recommend` 响应结构:**
    *   **问题:** API 文档未定义此接口成功响应的 `schema`。
    *   **需确认:** 在 `DataSource` 实现中调用此 API 时，**记录并确认实际返回的 JSON 结构**，并据此调整 `RelatedServiceModel`。

3.  **`fileSlice` 状态重复问题 (RN 实现问题，Flutter 需避免):**
    *   **问题:** RN `fileSlice` 的逻辑似乎会导致上传成功后，状态列表中同时存在同一文件的本地 URI 条目和 OSS URL 条目。
    *   **需在 Flutter 中解决:** 在设计 `Core` 模块的 `IFileRepository` 实现（如果它管理文件状态）或 `Presentation` 层读取文件列表时，需要确保状态的准确性，**避免重复**。例如，上传成功后应更新现有条目，而非添加新条目。

4.  **`/model/chat/package` 接口细节:**
    *   **已知:** 与推荐服务相关，可能对应 UI 上的"一键分发"等操作。
    *   **需确认:** 参考 RN 代码中**具体的调用点**，明确所有必需的请求参数（除 API 文档中已列出的）以及精确的预期行为/返回数据结构。

## 3. Data 层结构设置 (推荐)

遵循 Clean Architecture 和 `docs/目录结构参考.md`，`AI_Docs` 模块的 `Data` 层结构建议如下：

```
lib/
└── features/
    └── ai_docs/
        ├── data/
        │   ├── models/                 # 数据传输对象 (DTOs / Models)
        │   │   ├── ai_conversation_model.dart
        │   │   ├── ai_chat_message_model.dart
        │   │   ├── related_service_model.dart
        │   │   └── ...                 # 其他 API 对应的 Model
        │   │
        │   ├── datasources/            # 数据源 (与外部交互)
        │   │   ├── i_ai_chat_remote_data_source.dart # 远程数据源接口
        │   │   └── ai_chat_remote_data_source_impl.dart # 远程数据源实现 (依赖 Core HTTP Client)
        │   │   # (可选) i_ai_chat_local_data_source.dart + 实现
        │   │
        │   └── repositories/           # Repository 实现
        │       └── ai_chat_repository_impl.dart  # 实现 Domain 层的 IAiChatRepository
        │
        ├── domain/                     # (已完成接口定义)
        │
        └── presentation/               # (待实现)
```

**各部分职责:**

*   **`models/`**: 定义与 API JSON 精确匹配的 Dart 类，包含 `fromJson`, `toJson`, `toEntity` 方法。
*   **`datasources/`**: 定义接口 (`IAiChatRemoteDataSource`) 描述每一次独立的网络调用。实现类 (`AiChatRemoteDataSourceImpl`) 依赖 `Core` HTTP Client，负责发起 API 请求、处理响应、返回 `Models` 或抛出具体网络异常。
*   **`repositories/`**: 实现类 (`AiChatRepositoryImpl`) 依赖 `DataSource` 接口。负责调用 `DataSource`，使用 `try-catch` 处理异常并映射为 Domain `Failure`，调用 `Model` 的 `toEntity()` 将数据转换为 Domain `Entity`，最终返回 `Either<Failure, Entity>`。 