# Auth 模块边界定义 (最终版)

本文档基于 API 文档 (`design-info/api/backend-api.json`) 并结合 RN 源代码 (`design-info/demo-repository`) 片段分析，最终确定了 `Auth` 模块的边界。**当 API 文档与 RN 实现冲突时，优先以 API 文档定义为准进行设计。**

## 1. 模块名称

`Auth` (认证授权)

## 2. 核心业务能力 (Business Capability)

负责应用程序用户的身份验证 (短信验证码登录)、新用户注册、会话管理 (Token 获取与存储) 以及相关的验证码服务。

*   支持短信验证码登录 (`/api/auth/login` with `scene: sms_code_login`)。
*   处理新用户的注册 (`/api/auth/register`)。
*   管理用户的认证状态和会话凭证 (Token 的获取、存储、清除)。
*   发送用于登录或注册的手机验证码 (`/api/common/send-code/register`)。

*(注意：用户详细资料 (`userId` 等) 的获取 (`/api/member/info`) 和管理通常由 Profile 模块或应用层逻辑负责。)*

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`AuthenticatedUser`**: 表示已通过身份验证的用户凭证。
    *   `userId`: (String) 用户唯一标识符。 *(注意: 由 `/api/member/info` 获取)*
    *   `token`: (String) 用于 API 调用的认证令牌。 ***【API 文档冲突警告】*** *`/api/auth/login` 的 API 文档定义其成功响应为空，与客户端需要 Token 的基本要求冲突。Flutter 实现将**暂时假设**响应中包含 `token` (基于 RN 实现)，但这需要紧急与后端确认并修复文档或实现。*

*   **`AuthCredentials`**: 认证凭证的抽象接口/基类。
    *   **`VerificationCodeCredentials`**: 使用验证码登录的凭证。
        *   `phone`: (String) 手机号。
        *   `code`: (String) 短信验证码。

*   **`RegistrationDetails`**: 用户注册所需信息 (用于 `/api/auth/register`，**严格遵循 API 文档**)。
    *   `phone`: (String) 手机号 (必选)。
    *   `code`: (String) 短信验证码 (必选)。
    *   `password`: (String) 密码 (必选)。
    *   `scene`: (String) 场景值 (必选)。
    *   `inviterId`: (int?) 邀请者 ID (API 定义为必选 integer, nullable)。 *(类型为 int?, 可选性待最终确认)*

*   **`AuthStatus`**: 用户认证状态的枚举。
    *   `authenticated(AuthenticatedUser user)`: 已认证。
    *   `unauthenticated`: 未认证。
    *   `unknown`: 初始状态。

*   **`VerificationPurpose`**: 验证码用途的枚举 (用于客户端逻辑区分)。
    *   `login`
    *   `register`

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`LoginWithVerificationCodeUseCase`**: 处理短信登录。
    *   输入: `VerificationCodeCredentials`
    *   输出: `Either<Failure, AuthenticatedUser>`
*   **`RegisterUseCase`**: 处理用户注册。
    *   输入: `RegistrationDetails` (包含 API 文档定义的字段)
    *   输出: `Either<Failure, void>`
*   **`LogoutUseCase`**: 处理用户登出 (本地操作)。
*   **`SendVerificationCodeUseCase`**: 发送验证码。
    *   输入: `phone` (String)
    *   输出: `Either<Failure, void>`
*   **`GetAuthStatusStreamUseCase`**: 获取并监听认证状态。
*   **`GetLoggedInUserUseCase`**: 同步获取当前登录用户。
*   **(Core/Profile) `FetchUserInfoUseCase`**: 使用 Token 获取用户信息。

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IAuthRepository`**:
    *   `Stream<AuthStatus> get authStatus`
    *   `Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(VerificationCodeCredentials credentials)`
    *   `Future<Either<Failure, void>> register(RegistrationDetails details)`
    *   `Future<Either<Failure, void>> logout()`
    *   `Future<Either<Failure, void>> sendVerificationCode({required String phone})`
    *   `Either<Failure, AuthenticatedUser?> getLoggedInUserSync()`

*   **`ISecureStorageRepository`** (来自 Core/Shared)。
*   **`IUserInfoRepository`** (来自 Core/Profile): `Future<Either<Failure, UserInfo>> fetchUserInfo(String token)`。

## 4. API 映射与关键问题

**优先基于 API 文档 (`backend-api.json`)**，结合 RN 代码确认实际调用。

*   **`/api/auth/login` (POST)**: **短信登录接口**。
    *   请求体 (确认): `{ "mobile": string, "code": string, "scene": "sms_code_login" }`。
    *   **成功响应 (200 OK)**: ***【API 文档冲突警告】*** API 文档定义为空 (`{}`)，与 RN 实现 (`{ code, token }`) 和客户端需求严重冲突。**必须修复此问题才能使登录功能正常工作。**
*   **`/api/auth/register` (POST)**: **注册接口** (API 文档标记为 deprecated)。
    *   请求体 (根据 API 文档): `{ "mobile": string, "code": string, "password": string, "scene": string, "inviterId": integer? }` (inviterId 可选性待确认)。**注意：这与 RN 实现不一致，RN 未使用 password。**
    *   **成功响应**: 可能是 HTTP 200/204，无特定响应体。
*   **`/api/common/send-code/register` (POST)**: **发送验证码接口**。
    *   请求体 (确认): `{ "mobile": string }`。
    *   用途: 用于登录和注册前。
*   **`/api/member/info` (GET)**: **获取用户信息接口**。
    *   请求需携带 Token。
    *   成功响应 (基于 RN 分析，API 文档缺失): `data: { id: number, mobile: string, ... }`。
*   **Logout**: **无后端 API**。

## 5. 交互点 (Interaction Points)

*   **依赖项**: `Auth` 模块依赖 `Core/Shared` 模块提供的基础服务 (如 `HttpClient`, `ISecureStorageRepository`) 以及可能的 `Core/Profile` 提供的 `IUserInfoRepository`。
*   **被依赖项**: 应用的导航/路由层会依赖 `Auth` 模块获取 `AuthStatus` 来实现登录拦截 (Navigation Guards)。UI 层 (Pages/Widgets) 依赖 `Auth` 模块的 Blocs/Cubits 来展示认证状态和用户信息。
*   **导航需求**: 需要应用提供导航能力，如 `navigateToHome`, `navigateToLogin`, `navigateToPreviousScreen`。

## 6. 安全考虑 (Security Considerations)

*   Token 必须通过安全存储 (`ISecureStorageRepository`) 保存。
*   API 请求应使用 HTTPS。
*   防止验证码被滥用 (频率限制等由后端负责)。

## 7. 结论与待办事项

边界已根据 API 文档和最新确认为准。Auth 核心是获取/管理 Token 和 `id`，并对外提供认证状态。**应用启动时的 Token 有效性检查逻辑应放在 `core` 或 App 初始化部分，而导航拦截逻辑应放在应用的路由层，并依赖本模块提供的 `AuthStatus`。**

**关键待办事项:**

1.  **【中优先级】更新 API 文档**: **必须**更新 `/api/auth/login` 的文档以反映返回 `token`，**必须**更新 `/api/member/info` 的文档以反映其 `data` 结构。
2.  **(最低优先级/可能不需要) 确认 `/api/auth/login` 响应 `code` 字段**: 如果响应中除了 `token` 还有 `code` 字段，其含义是什么？
3.  **Token 校验策略实现**: 具体实现在 `core` 文件夹 (应用启动检查) 和导航层 (路由守卫)。
