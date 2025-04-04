# AI Docs 模块外部依赖与集成点

本文档记录了 `ai_docs` 模块正常运行所需依赖的外部模块、数据或服务接口。

## 1. 用户认证 (User Authentication)

*   **依赖**: 需要获取当前已登录用户的 **User ID**。
*   **来源**: (待定) 预期从全局用户状态管理（如 `AuthBloc` 的状态）、用户仓储 (`UserRepository`) 或安全存储 (`SecureStorage`) 中获取。
*   **集成点**:
    *   `AiChatBloc`: 需要在初始化或相关操作时获取 `userId`，替换掉硬编码的 `_currentUserId = 1`。

## 2. API 授权 (API Authorization)(不然没法上传)

*   **依赖**: 需要获取有效的 API **Authorization Token** (Bearer Token)。
*   **来源**: (待定) 预期从全局用户状态管理（如 `AuthBloc` 的状态）或安全存储 (`SecureStorage`) 中获取。
*   **集成点**:
    *   `DioHttpClient` 或相应的网络请求拦截器 (`AuthInterceptor`)：需要在发起需要授权的 API 请求（如文件上传 `postMultipart`，可能还有其他模型或后端接口）时，将此 Token 添加到 `Authorization` 请求头中，替换掉硬编码的 Token。

## 3. 推荐/分配系统 (Recommendation/Allocation System)

*   **依赖**: 需要调用推荐系统提供的服务接口。
*   **接口**:
    *   获取相关服务: `/model/chat/related_services` (当前 `AiChatRemoteDataSourceImpl.getRelatedServices` 调用)
    *   执行分配操作: `/model/chat/allocate` (当前 `AiChatRemoteDataSourceImpl.allocateChatResource` 调用)
*   **状态**: (待定) 需要明确这些接口是否已可用、是否已最终确定、请求/响应格式是否稳定。
*   **集成点**:
    *   `AiChatRemoteDataSourceImpl`: 需要确保调用这两个接口的逻辑（路径、参数、响应解析）与最终实现一致。
    *   `AiChatBloc`: `FetchRecommendations`, `TriggerAllocationAction` 事件及其处理逻辑依赖于上述接口。
    *   UI (`ChatPage`, `RecommendationBottomSheetContent`, `ServiceCard`): 需要根据最终接口返回的数据正确展示推荐信息和处理分配操作。

**负责人**: (可以按模块或功能分配)
**整体协调**: (项目负责人或架构师)