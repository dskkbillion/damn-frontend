# AI Docs API Configuration and Boundaries

This document summarizes the current state of API integration for the AI Docs feature, highlighting key configurations and external dependencies (boundaries).

## 1. API Base URL

- **Configured in:** `lib/core/network/dio_http_client.dart`
- **Current Value:** `http://47.113.230.11:5102`
- **Protocol:** HTTP (Ensure this matches the server requirement; switch to HTTPS if needed).

## 2. HTTP Client Implementation

- **Implementation:** `DioHttpClient` located in `lib/core/network/dio_http_client.dart`.
- **Library:** Uses the `dio` package.
- **Logging:** Basic request/response logging is **enabled** via `LogInterceptor` for debugging.
- **Error Handling:** Basic error handling converts `DioException` into `ServerException` (defined in `lib/core/error/exceptions.dart`) via `_handleDioError`. The `_handleResponse` method provides basic checks for successful status codes (2xx).

## 3. API Endpoint Summary & `userId` Handling

The following summarizes the main API endpoints used and how `userId` is currently handled:

- **Fetch Conversations:**
    - **Path:** `/model/chat/list`
    - **Method:** `POST`
    - **`userId`:** Required. Sent in the **request body** (`data` parameter).
- **Load History:**
    - **Path:** `/model/chat/messages`
    - **Method:** `GET`
    - **`userId`:** Required. Sent as a **query parameter** (`queryParameters`).
- **Create Conversation:**
    - **Path:** `/model/chat/create`
    - **Method:** `POST`
    - **`userId`:** Required. Sent in the **request body** (`data` parameter).
- **Delete Conversation:**
    - **Path:** `/model/chat/delete`
    - **Method:** `POST`
    - **`userId`:** Required. Sent in the **request body** (`data` parameter).
- **Stream Chat Completion (Send Message):**
    - **Path:** `/model/chat` (Currently Mocked)
    - **Method:** (Likely `POST` or WebSocket/SSE - Needs implementation)
    - **`userId`:** Required. Passed to the (currently mocked) data source method.
- **Upload File (for Images/Audio):**
    - **Path:** *Not yet confirmed* (Needs clarification, often something like `/api/common/public/upload`)
    - **Method:** `POST Multipart`
    - **`userId`:** *Not yet confirmed* if required as an additional field in the multipart request.
- **Get Related Services (Recommendations):**
    - **Path:** `/recsys/conversation/recommend`
    - **Method:** `GET`
    - **`userId`:** Required. Sent as a **query parameter** (`queryParameters`).
- **Allocate Chat Resource:**
    - **Path:** `/chat/allocate`
    - **Method:** `POST`
    - **`userId`:** Required. Sent in the **request body** (`data` parameter).
- **Transcribe Audio (if used directly via URL):**
    - **Path:** `/model/chat/audio`
    - **Method:** `POST`
    - **`userId`:** Optional (but likely needed). Sent in the **request body** (`data` parameter).

## 4. Authentication / User ID Boundary (IMPORTANT TODO)

- **Current State:** A **hardcoded `userId = 1`** is used throughout the AI Docs feature.
- **Location:** Defined as `final int _currentUserId = 1;` within `lib/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart`.
- **Action Required:** This hardcoded value **MUST** be replaced with a mechanism to obtain the **actual authenticated user's ID**. This typically involves:
    - Implementing an Authentication feature/module.
    - Storing the authenticated user's state (e.g., in a separate AuthBloc or using a global state solution).
    - Injecting the Auth state/service into `AiChatBloc` or passing the `userId` during Bloc creation/event dispatch.

## 5. Outstanding TODOs & Next Steps (API Related)

- Implement proper **Authentication** and replace the hardcoded `userId`.
- Confirm the exact **File Upload API endpoint path** and whether it requires a `userId`.
- Implement **actual SSE/WebSocket streaming** for `streamChatCompletion` in the DataSource and HttpClient.
- **Refine error handling:** Implement more specific error handling in the Bloc/UI based on different `Failure` types.
- **Review `_handleResponse`:** Adapt the response handling logic in `DioHttpClient` based on detailed review of actual API response structures for all endpoints.
- Consider adding more sophisticated **interceptors** to `DioHttpClient` (e.g., for automatically adding auth tokens, handling token refresh, more detailed error mapping).
- Implement **audio encoding/compression** to 16kbps MP3 *before* calling the upload endpoint. 