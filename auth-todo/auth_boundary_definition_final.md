# Auth 模块边界定义 (最终版)

本文档基于初步分析 (`docs/BD/auth_boundary_definition.md`)、React Native 源代码 (`design-info/demo-repository`) 的分析推断、API 文档 (`design-info/api/backend-api.json`) 及实际调用模式，最终确定了 `Auth` 模块的边界。

## 1. 模块名称

`Auth` (认证授权)

## 2. 核心业务能力 (Business Capability)

负责应用程序用户的身份验证、注册、会话管理以及相关的验证码服务。它是用户访问受保护资源的第一道屏障，确保只有经过验证和授权的用户才能使用应用的核心功能。其核心能力包括：

*   支持多种方式登录（密码、短信验证码）。
*   处理新用户的注册流程。
*   管理用户的认证状态和会话凭证 (Token)。
*   发送和校验用于登录或注册的手机验证码。

*(注意：用户详细资料的管理由 `Profile` 模块负责。)*

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`AuthenticatedUser`**: 表示已通过身份验证的用户凭证。
    *   `userId`: (String) 用户唯一标识符。
    *   `token`: (String) 用于 API 调用的认证令牌。
    *   ***注意：*** *此实体是客户端的核心需求，但与当前 `backend-api.json` 中 `/api/auth/login` 成功响应为空 (`{}`) 的定义存在**严重冲突**。需要**紧急确认** `userId` 和 `token` 的实际返回方式（响应体或响应头）并更新 API 文档。*

*   **`AuthCredentials`**: 认证凭证的抽象接口/基类。
    *   **`PasswordCredentials`**: 使用密码登录的凭证。
        *   `identifier`: (String) 用户标识符（手机号或邮箱，对应 API 的 `mobile` 字段，需确认是否支持邮箱）。
        *   `password`: (String) 用户密码 (对应 API 的 `smsCode/password` 字段，当 `scene` 为 `password_login` 时)。
    *   **`VerificationCodeCredentials`**: 使用验证码登录的凭证。
        *   `phone`: (String) 手机号 (对应 API 的 `mobile` 字段)。
        *   `code`: (String) 短信验证码 (对应 API 的 `smsCode/password` 字段，当 `scene` 为 `sms_code_login` 时)。

*   **`RegistrationDetails`**: 用户注册所需信息 (直接映射 `/api/auth/login` 场景为 `sms_code_register` 时的请求体)。
    *   `phone`: (String) 手机号 (对应 API 的 `mobile` 字段)。
    *   `code`: (String) 短信验证码 (对应 API 的 `smsCode/password` 字段)。
    *   `password`: (String) 设置的密码。
    *   `scene`: (String) 固定为 `"sms_code_register"` 或其他注册场景值。
    *   `inviterId`: (int?) 邀请者 ID (可选，对应 API 的 `inviterId`，需确认是否真的在注册场景的 `/api/auth/login` 中传递)。

*   **`AuthStatus`**: 用户认证状态的枚举。
    *   `authenticated(AuthenticatedUser user)`: 已认证，并持有用户凭证。
    *   `unauthenticated`: 未认证。
    *   `unknown`: 初始状态或正在检查认证状态。

*   **`VerificationPurpose`**: 验证码用途的枚举，用于区分发送验证码的场景。
    *   `login`: 用于登录 (`sms_code_login`)。
    *   `register`: 用于注册 (`sms_code_register`)。
    *   *(注意: 这个枚举需要映射到调用 `/api/common/send-code` (如果存在) 或相关 API 时所需的场景参数，例如 `scene`)*。

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`LoginWithPasswordUseCase`**: 处理使用账号密码登录的流程。
    *   输入: `PasswordCredentials`
    *   输出: `Either<Failure, AuthenticatedUser>`
*   **`LoginWithVerificationCodeUseCase`**: 处理使用手机和验证码登录的流程。
    *   输入: `VerificationCodeCredentials`
    *   输出: `Either<Failure, AuthenticatedUser>`
*   **`RegisterUseCase`**: 处理用户注册流程（注册成功后通常自动登录）。
    *   输入: `RegistrationDetails`
    *   输出: `Either<Failure, AuthenticatedUser>`
*   **`LogoutUseCase`**: 处理用户登出流程。
    *   输入: `void`
    *   输出: `Either<Failure, void>` (清除本地认证状态和凭证)。
*   **`SendVerificationCodeUseCase`**: 发送指定用途的验证码。
    *   输入: `phone` (String), `purpose` (VerificationPurpose)
    *   输出: `Either<Failure, void>`
*   **`GetAuthStatusStreamUseCase`**: 获取并监听认证状态的实时变化。
    *   输入: `void`
    *   输出: `Stream<AuthStatus>` (通常由 Repository 提供)。
*   **`GetLoggedInUserUseCase`**: 同步获取当前登录的用户凭证（如果已认证）。
    *   输入: `void`
    *   输出: `Either<Failure, AuthenticatedUser?>` (可能是 `GetAuthStatusStreamUseCase` 的一个快照或辅助方法)。
*   **(潜在 Use Case - 待确认)**
    *   `ForgotPasswordUseCase` / `ResetPasswordUseCase`: 处理忘记密码或重置密码流程。**当前 API 文档未定义相关端点，需确认产品需求。**

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IAuthRepository`**: 定义 Auth 模块的数据交互接口。
    *   `Stream<AuthStatus> get authStatus`: 提供认证状态的流。
    *   `Future<Either<Failure, AuthenticatedUser>> loginWithPassword(PasswordCredentials credentials)`: 执行密码登录 API 调用。
    *   `Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(VerificationCodeCredentials credentials)`: 执行验证码登录 API 调用。
    *   `Future<Either<Failure, AuthenticatedUser>> register(RegistrationDetails details)`: 执行注册 API 调用。
    *   `Future<Either<Failure, void>> logout()`: 执行登出逻辑（可能包括调用后端 API 使 Token 失效，并清除本地存储）。
    *   `Future<Either<Failure, void>> sendVerificationCode({required String phone, required VerificationPurpose purpose})`: 调用发送验证码 API。

*   **`ISecureStorageRepository`**: (由 `Core/Shared` 模块提供实现) 定义安全存储操作接口。
    *   `Future<void> saveToken(String token)`
    *   `Future<String?> getToken()`
    *   `Future<void> deleteToken()`
    *   `Future<void> saveUserId(String userId)`
    *   `Future<String?> getUserId()`
    *   `Future<void> deleteUserId()`
    *   `Future<void> clearAllAuthData()`: 清除所有认证相关数据（用于登出）。

## 4. API 映射与关键问题

`Auth` 模块主要依赖以下后端 API 端点 (基于 `design-info/api/backend-api.json`):

*   **`/api/auth/login` (POST)**: **核心接口**，用于统一处理登录和注册。
    *   通过请求体中的 `scene` 字段区分不同操作 (e.g., `"password_login"`, `"sms_code_login"`, `"sms_code_register"`)。
    *   请求体包含 `mobile` 和 `smsCode/password` (根据 `scene` 决定含义)。
    *   **关键问题**: API 文档显示成功 (200) 时响应体为空 (`{}`), 这与客户端需要 `userId` 和 `token` 来建立会话状态**严重不符**。需要紧急确认实际返回机制。
*   **`/api/auth/register` (POST)**: **已弃用 (Deprecated)**。注册功能已整合入 `/api/auth/login`。
*   **`/api/common/send-code` (或类似端点)**: 用于发送验证码。
    *   **关键问题**: 在 `backend-api.json` 中**未明确找到**此端点。需要确认发送验证码的实际 API 路径和参数（预计需要 `mobile` 和 `scene`/`purpose`）。

## 5. 交互点 (Interaction Points)

### 5.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**:
    *   依赖其提供的 `ISecureStorageRepository` 实现，用于安全存储 Token 和 UserId。
    *   依赖通用的 `Failure` 定义进行错误处理。
    *   依赖网络请求客户端 (如 `Dio`) 的实例和配置。
    *   可能依赖通用的工具类 (如日志、设备信息等)。
*   **`Profile` 模块**: **无直接依赖**。但应用层逻辑 (如 App Bloc 或 Router) 通常会在 `AuthStatus` 变为 `authenticated` 后，触发 `Profile` 模块去获取详细的用户信息。
*   **(无直接业务逻辑依赖于其他业务模块)**

### 5.2. 导航需求 (Navigation Needs)

`Auth` 模块的 `Presentation` 层 (UI 页面/组件) 需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToHome()`: 登录或注册成功后，通常导航到应用主页。
*   `navigateToLogin()`: 用户未认证或执行登出操作后，导航到登录页面。
*   `navigateToRegistration()`: 从登录页面跳转到注册页面。
*   `navigateToPreviousScreen()`: (可选) 登录成功后，如果用户是从其他页面跳转到登录页的，则返回之前的页面。
*   `navigateToForgotPassword()`: (如果实现密码重置) 从登录页跳转到忘记密码流程。

## 6. 安全考虑 (Security Considerations)

*   **凭证存储**: 必须使用 `ISecureStorageRepository` (如 iOS Keychain, Android Keystore) 存储 `token` 和 `userId`，避免使用不安全的本地存储 (如 `SharedPreferences`, `localStorage`)。
*   **登出**: 登出时必须调用 `ISecureStorageRepository.clearAllAuthData()` 清除所有本地存储的认证凭证。考虑是否需要调用后端 API 使 Token 失效。
*   **API 调用**: 所有需要认证的 API 调用都必须携带有效的 `token` (通常在请求头 `Authorization` 中)。
*   **错误处理**: API 调用失败或返回错误时，不能泄露敏感信息。使用 `Either<Failure, T>` 或类似机制封装错误。
*   **验证码**: 验证码应有有效期限制，并区分不同用途 (`VerificationPurpose`/`scene`) 防止滥用。

## 7. 结论与待办事项

`Auth` 模块边界清晰，核心职责是用户身份认证和会话管理。其设计遵循了领域驱动设计原则，通过 Use Cases 封装业务逻辑，Repository 隔离数据访问。

**关键待办事项:**

1.  **【最高优先级】解决 API 响应冲突**: 与后端确认 `/api/auth/login` 成功时 `userId` 和 `token` 的实际返回方式，并更新 `backend-api.json` 文档。这是实现 Auth 模块功能的前提。
2.  **确认验证码发送 API**: 找到并确认用于发送验证码的 API 端点及其参数。
3.  **确认密码重置需求**: 根据产品需求决定是否需要实现密码重置流程，如果需要，则与后端定义相关 API。
4.  **细化 `identifier` 支持**: 确认 `PasswordCredentials` 中的 `identifier` 是否需要支持除手机号外的其他标识符（如邮箱），并与 API 对齐。
5.  **确认 `inviterId` 传递**: 确认注册场景下 (`/api/auth/login` with `scene=sms_code_register`) 是否需要传递 `inviterId`。
