# AI_Docs 模块边界定义 (步骤 2)

本文档记录 `AI_Docs` 模块的边界定义过程，包括核心业务能力、Domain 层要素（Use Cases, Entities, Repository Interfaces）和交互点。

## 1. 核心业务能力

*基于所有分析 (Slices, 原型, TSX 文件, 导航结构) 并结合用户确认信息：*
*   **核心概念**: 提供一个支持**多会话管理**的 AI 聊天界面。
*   ~~**核心概念**: 提供一个以**用户画像 (Portrait)** 为中心的 AI 内容生成工作台。~~ (已废弃)
*   ~~**用户画像管理**: 查看、选择、创建和编辑用户画像/档案。~~ (已废弃)
*   ~~**应用生成与查看**: 基于选定的用户画像，查看已生成的 AI 应用 (文档/方案等)，并能触发生成新的应用。~~ (已废弃 - 现在专注于"会话")
*   提供一个支持**多会话管理**的 AI 聊天界面 (包括列表入口、详情页、新建入口)。
*   提供一个**独立的初始输入视图** (`input-view.tsx`)，用于收集用户需求（文本、图片、文档、语音），并可能根据输入分发到特定功能或开始新会话。
*   支持向 AI 发送消息，并能**关联文件/附件** (图片、文档、音频)。 (文件由后端 `/api/common/public/upload` 接口上传至**阿里云 OSS**，状态通过 `fileSlice` 管理，URL 需传递给 AI)。
*   通过 **SSE** 接收和显示 AI 的**流式响应**和**推理过程**。
*   管理和切换历史聊天会话。
*   ~~提供**预设问题**引导用户。~~ (已废弃)
*   提供 \"**匹配**\" 功能。
*   支持**语音输入** (录音和处理，音频文件由 `Core` 文件服务上传至 **阿里云 OSS**，状态通过 `fileSlice` 管理? URL 需传递给 AI)。
*   支持**分享**、~~**收藏**~~、**删除**单个会话。
*   ~~支持**分享**、**收藏**、**删除**单个会话。~~
*   ~~支持**分享**、**收藏**、**删除**和**报告**单个对话/应用?~~ (报告、收藏功能已废弃)
*   在对话详情页显示**相关服务**推荐。
*   ~~在对话详情页显示**相关服务**和**相关对话**推荐。~~ (相关对话已废弃)
*   **包含的视图**: `DocsHomepage` (**主要作为会话列表入口?**), `ChatView` (聊天), `InputView` (初始输入), `HistoryView` (历史会话列表?), `[id]/index.tsx` (聊天详情)。
*   ~~**包含多种内部功能视图**: `DocsHomepage` (画像/应用中心), `ChatView` (聊天/生成), `InputView` (初始输入), `HistoryView` (历史会话?), `FurnishView` (装修方案), `DocsView` (文档), `QuestionAnswerView` (问答), `LoadPortrait` (画像加载?), `CreateProfile 1&2` (画像创建/编辑步骤)。~~ (大部分特定视图已废弃)

## 2. 核心要素 (`Domain` 层) - 汇总所有分析并移除废弃项

*   **Use Cases**:
    *   ~~**画像管理**:~~ (已废弃)
        *   ~~`ListUserPortraits`: 获取当前用户的画像列表。~~
        *   ~~`GetUserPortraitDetails`: 获取特定画像的详细信息。~~
        *   ~~`SelectUserPortrait`: (UI state) 选择当前活动的画像。~~
        *   ~~`StartCreateOrEditPortrait`: (UI state) 进入画像创建/编辑流程。~~
        *   ~~`SavePortraitStep1`: 保存画像创建/编辑的第一步数据。~~
        *   ~~`SavePortraitStep2`: 保存画像创建/编辑的第二步数据。~~
    *   **会话管理 (原应用管理)**:
        *   `ListConversations`: 获取历史聊天会话列表。
        *   `GetConversationDetails`: 获取特定会话的详情 (可能包含首批消息? `LoadChatHistory`)。
        *   `StartNewConversation`: 开始一个新的聊天会话 (返回 `conversationId`)。 (**请求参数已从 RN 代码 `createChatRoomThunk` 确认: `{ user_id, title? }`**)
        *   `DeleteConversation`: 删除一个会话。
    *   **聊天核心**:
        *   `SendMessageToAI`: 发送用户消息 (含可选**阿里云 OSS 文件 URL 列表**?) 到当前会话。( **请求参数已从 RN 代码 `Send2Model` 确认: `{ model, user_id, message, conversation_id, files: string[], stream }`。注意：RN 代码中 `files` 数组可能包含本地 URI，需确认后端处理能力或前端确保只传 OSS URL**)
        *   `StreamAIResponse`: (内部处理) 监听并处理 AI 的流式响应。
        *   `StreamReasoning`: (内部处理) 监听并处理 AI 的推理过程流。
        *   `LoadChatHistory`: 加载指定会话 (`conversationId`) 的历史消息。
        *   `ClearCurrentChatMessages`: 清除当前会话的消息记录 (本地状态)。
        *   `SwitchConversation`: 切换到指定的历史聊天会话 (`conversationId`)。
    *   **辅助功能**:
        *   ~~`GetPresetQuestions`: 获取预设问题列表。~~ (已废弃)
        *   ~~`SelectPresetQuestion`: 处理用户选择预设问题的动作。~~ (已废弃)
        *   `ShowAttachmentOptions`: 显示附件选项 (UI 逻辑)。
        *   `SelectAttachment`: *调用 Core 文件服务* 从设备选择文件 (图片/文档)，**并将选择结果存入全局文件状态 (`fileSlice`)**。
        *   `RemoveSelectedAttachment`: 从**全局文件状态 (`fileSlice`)** 中移除待发送附件。
        *   `UploadAttachments`: (**核心**) **调用 Core 文件服务触发后端 `/api/common/public/upload` 接口** 上传当前选中的附件到 **阿里云 OSS**，并获取返回的 URLs。( **RN 代码显示前端不直接操作 OSS SDK**。注意：`fileSlice` 状态更新逻辑可能导致本地 URI 和 OSS URL 重复存在，需检查)
        *   `TriggerMatchingAction`: (**原 `TriggerMatching`**) 在推荐服务上触发特定操作（如"一键分发"），调用 `/model/chat/package` API。( **需要参考 RN 代码确认具体触发按钮和 API 参数**)
        *   `ToggleVoiceInput`: 切换语音输入模式 (UI 逻辑)。
        *   `StartRecording`: 开始录音。
        *   `StopRecording`: 停止录音，**将音频数据存入全局文件状态 (`fileSlice`)**。
        *   `UploadAudio`: (**核心**) **调用 Core 文件服务触发后端 `/api/common/public/upload` 接口** 上传当前录音到 **阿里云 OSS**，并获取返回的 URL。( **RN 代码显示前端不直接操作 OSS SDK**。注意：`fileSlice` 状态更新逻辑可能导致本地 URI 和 OSS URL 重复存在，需检查)
        *   `TranscribeAudio`: (**核心**) **调用 Core 音频服务** 将 **阿里云 OSS** 上的音频 URL 转为文字。(调用 `/model/chat/audio` API，输入为 OSS URL)
        *   `ShareConversation`: 分享当前对话 (调用 `Core` 分享服务)。
        *   ~~`ToggleFavoriteConversation`: 切换当前对话的收藏状态。~~ (已废弃)
        *   `GetRelatedServices`: 获取当前对话的相关服务推荐。
    *   **特定视图启动/导航**:
        *   `ViewServiceDetails`: 查看服务详情 (导航)。
        *   ~~`ViewRelatedConversation`: 查看相关对话 (导航)。~~ (已废弃)
        *   `ContinueConversation`: 继续当前对话 (导航)。
        *   `InitiateSessionWithInput`: (源自 `input-view.tsx`) 收集初始用户需求...。
        *   `ViewConversationList`: 导航/显示会话列表主页。
        *   ~~`NavigateToFurnishView`: 导航到装修方案视图。~~ (已废弃)
        *   ~~`NavigateToDocsView`: 导航到文档视图。~~ (已废弃)
        *   ~~`NavigateToQuestionAnswerView`: 导航到问答视图。~~ (已废弃)
        *   ~~`NavigateToLoadPortrait`: 导航到用户画像视图。~~ (已废弃)
        *   ~~`NavigateToCreateProfile1/2`: 导航到配置流程视图。~~ (已废弃)
    *   ~~**UI 控制**:
        *   `SwitchHomepageMode`: (UI state) 切换主页的生成/编辑模式。~~ (已废弃)
*   **Entities**:
    *   ~~**核心概念**:~~
        *   ~~`UserPortrait`: ...~~ (已废弃)
        *   ~~`ProfileData`: ...~~ (已废弃)
        *   ~~`Internship`: ...~~ (已废弃)
        *   ~~`Application`: ...~~ (已废弃 - 使用 `AIConversation`)
    *   **核心**: `AIConversation`: (源自 `chatBotSlice` & API `/list`) 包含 `conversation_id` (int), `title`? (string), `created_at` (string/DateTime), `updated_at` (string/DateTime), `first_message`? (string), `message_count`? (int)。 ~~`isFavorite`? (bool)。~~ (收藏已废弃)
    *   **聊天/消息相关**: `AIChatMessage`: (源自 `chatBotSlice` & API `/messages`) 包含 `id` (可选, int?), `message_id` (string), `conversation_id` (int), `role` (`user` | `assistant`), `content` (string), `files`: `List<String>` (**阿里云 OSS URLs**?), `timestamp`? (int/DateTime)。
    *   **文件相关 (结构参考 `fileSlice`)**: (保持不变，用于本地状态管理)
        *   `FileItem`: ...
        *   `ImageItem`: ...
        *   `Attachment`: 由 `Core` 定义 (类型，本地路径/URI)。
        *   `AudioData`: 由 `Core` 定义? (表示录音结果，可能是本地文件 URI)。
    *   **其他辅助**: `Failure`, `MatchingResult`?, `RelatedService`。
    *   ~~**特定视图所需 (待细化)**: `FurnishConfig`?, `DocsTemplate`?, `QuestionAnswerPair`?。~~ (已废弃)
*   **Repository Interfaces**: (细化返回类型, 如 `Either<Failure, T>`)
    *   **`IAiChatRepository` (原 `IAiDocsRepository`，精简)**:
        *   ~~**画像 CRUD**:~~ (已废弃)
        *   **会话 CRUD**:
            *   `Future<Either<Failure, List<AIConversation>>> listConversations()`
            *   `Future<Either<Failure, List<AIChatMessage>>> loadHistory(int conversationId, {int? offset, int? limit})`
            *   `Future<Either<Failure, int>> startNewConversation({required int userId, String? title})` (返回 `conversationId`) (**请求体: `{ user_id, title? }`**)
            *   `Future<Either<Failure, void>> deleteConversation(int conversationId)`
        *   **消息/生成**:
            *   `Stream<Either<Failure, String>> sendMessage({required int conversationId, required int userId, required String message, required List<String> fileUrls})` (**请求体: `{ model: 'dify', user_id, message, conversation_id, files: fileUrls, stream: true }`。注意 `fileUrls` 内容的不确定性**)
            *   `Stream<Either<Failure, String>> streamReasoning(int conversationId)`?
        *   **其他**:
            *   ~~`Future<Either<Failure, List<PresetQuestion>>> getPresetQuestions(String? portraitId)`?~~ (已废弃)
            *   `Future<Either<Failure, void>> toggleFavorite(int conversationId, bool isFavorite)`? (**功能已废弃，接口不存在**)
            *   ~~`Future<Either<Failure, void>> reportIssue(int applicationId, ReportIssueDetails details)`?~~ (已废弃)
            *   `Future<Either<Failure, List<RelatedService>>> getRelatedServices(int conversationId)`
            *   *`TriggerMatchingAction` 相关接口?* (对应 `/model/chat/package`? **需参考 RN 代码确认具体参数和触发逻辑**)
            *   ~~*获取特定视图数据接口 (Furnish, Docs, QA)?*~~ (已废弃)
    *   **`IFileRepository` (`Core`)**: (接口不变，**实现通过调用后端 `/api/common/public/upload` 触发 OSS 上传，具体流程参考 RN 代码**)
        *   `Future<Either<Failure, List<Attachment>>> pickFiles(...)`
        *   `Future<Either<Failure, Attachment>> takePhoto()`
        *   `Future<Either<Failure, List<String>>> uploadFiles(List<Attachment> files, String type)` (**返回 OSS URLs。注意：RN 中 `fileSlice` 状态更新方式可能导致重复**)
    *   **`IAudioRepository` (`Core`)**: (接口不变，**实现通过调用后端 `/api/common/public/upload` 触发 OSS 上传，并调用 `/model/chat/audio`，具体流程参考 RN 代码**)
        *   `Future<Either<Failure, void>> startRecording()`
        *   `Future<Either<Failure, AudioData>> stopRecording()`
        *   `Future<Either<Failure, String>> uploadAudio(AudioData audio, String type)` (**返回 OSS URL。注意：RN 中 `fileSlice` 状态更新方式可能导致重复**)
        *   `Future<Either<Failure, String>> transcribeAudio(String ossAudioUrl)` (**调用 `/model/chat/audio`**)
    *   **`IShareService` (`Core`)**: (不变)

## 3. 交互点 - 汇总所有分析并移除废弃项

*   **对外依赖**: (保持不变，核心依赖聊天 API、文件/音频服务、认证、配置、分享)
*   **导航需求**: (基于 `Expo Router` 结构，移除废弃视图)
    *   `/ai-docs` (Tab 入口, 会话列表, 可能对应 `docs_homepage.tsx` 或 `history.tsx`?)
    *   `/ai-docs/history` (如果 `history.tsx` 是独立列表页)
    *   `/ai-docs/{id}` (**特定会话聊天详情页**, 对应 `[id]/index.tsx`)。
    *   `/ai-docs/{id}/doc_detail`?
    *   `/ai-docs/{id}/{match_id}`?
    *   `/ai-docs/input` (独立输入视图, 对应 `input-view.tsx`)。
    *   `/service/{serviceId}` (查看服务详情 - 外部导航)。
    *   其他 UI 交互触发 (Dialogs, BottomSheets)。

## 4. 下一步

*   ~~**API 参数与流程确认 (参考 RN 代码)**: **通过分析 React Native 代码**，确定 `/model/chat` (发送消息) 和 `/model/chat/create` (创建会话) 的确切请求参数，以及完整的阿里云 OSS 文件上传流程 (凭证、上传、URL 关联)。同时确认 `/model/chat/package` 的参数和前端触发逻辑。~~
*   **精化 Domain 层接口**: 基于**当前已确认的需求、从 RN 代码理解的 API 参数和文件上传流程**，编写 `AI_Docs` 模块的 `.dart` 接口文件。
*   **遗留问题处理:** 在后续实现中，需要关注并解决：
    *   RN `fileSlice` 中潜在的状态重复问题（本地 URI 与 OSS URL 并存）。
    *   确认 `SendMessageToAI` 传递给后端的 `files` 数组应只包含 OSS URL，并确保前端实现这一点（可能需要调整状态读取或上传逻辑）。或者，与后端确认是否能处理本地 URI (可能性低)。
    *   确认 `/model/chat/package` 的具体参数和前端触发逻辑（参考 RN 代码）。
*   ~~最终确认 Use Cases, Entities, Repository Interfaces。~~
*   ~~开始 **步骤 4: 精化 Domain 层接口** (编写 `.dart` 文件)。~~ 