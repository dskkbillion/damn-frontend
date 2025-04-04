# Auth 模块边界定义 (Boundary Definition)

本文档基于对 React Native 源代码 (`design-info/demo-repository`) 和 HTML 原型 (`design-info/HTML原型/HTML-new`) 的分析，定义了 `Auth` 模块的边界。

## 1. 模块名称

`Auth` (认证)

## 2. 核心业务能力 (Business Capability)

负责用户的身份验证（密码登录、验证码登录、注册）、会话管理（Token 存储与清除）以及验证码的发送。

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`AuthenticatedUser`**: 表示身份验证成功后核心的用户凭证。
    *   `userId`: (String) 用户唯一标识。
    *   `token`: (String) 认证令牌。
    *   *(注意：更详细的用户资料如昵称、头像等由 `Profile` 模块管理，登录成功后应触发获取 Profile 的流程)*
*   **`AuthCredentials`**: 认证凭证的基类/接口。
    *   `PasswordCredentials`: (实现 `AuthCredentials`)
        *   `identifier`: (String) 手机号或邮箱。
        *   `password`: (String) 密码。
    *   `VerificationCodeCredentials`: (实现 `AuthCredentials`)
        *   `phone`: (String) 手机号。
        *   `code`: (String) 验证码。
*   **`RegistrationDetails`**: 用户注册所需信息 (基于 `/api/auth/register` 定义)。
    *   `phone`: (String) 手机号 (对应 API 的 `mobile`)。
    *   `code`: (String) 验证码。
    *   `password`: (String) 密码。
    *   `scene`: (String) 注册场景 (例如 `sms_code_register`)。
    *   `inviterId`: (int?) 邀请者 ID (可选)。
    *   *(注意: API 文档显示 `required`: ["mobile", "code", "scene", "password", "inviterId"], 但 `inviterId` 又标记为 `x-nullable: true`，实际是否必需待确认)*
*   **`AuthStatus`**: 表示用户的认证状态 (枚举)。
    *   `authenticated(AuthenticatedUser user)`: 已认证，包含用户凭证。
    *   `unauthenticated`: 未认证。
    *   `unknown`: 初始状态或检查中。
*   **`VerificationPurpose`**: 验证码用途 (枚举)。
    *   `login`: 用于登录。
    *   `register`: 用于注册。
    *   *(暂不包含 `resetPassword`)*

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`LoginWithPasswordUseCase`**: 处理使用账号密码登录。
    *   输入: `PasswordCredentials`
    *   输出: `Either<Failure, AuthenticatedUser>`
*   **`LoginWithVerificationCodeUseCase`**: 处理使用手机和验证码登录。
    *   输入: `VerificationCodeCredentials`
    *   输出: `Either<Failure, AuthenticatedUser>`
*   **`RegisterUseCase`**: 处理用户注册。
    *   输入: `RegistrationDetails`
    *   输出: `Either<Failure, AuthenticatedUser>` (假设注册成功后自动登录)
*   **`LogoutUseCase`**: 处理用户登出。
    *   输入: `void`
    *   输出: `Either<Failure, void>`
*   **`SendVerificationCodeUseCase`**: 发送指定用途的验证码。
    *   输入: `phone` (String), `purpose` (VerificationPurpose)
    *   输出: `Either<Failure, void>`
*   **`GetAuthStatusStreamUseCase`**: 获取并监听认证状态变化。
    *   输入: `void`
    *   输出: `Stream<AuthStatus>`
*   **`GetLoggedInUserUseCase`**: (可选，可能由 `GetAuthStatusStreamUseCase` 覆盖) 获取当前已登录的用户凭证。
    *   输入: `void`
    *   输出: `Either<Failure, AuthenticatedUser?>`

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IAuthRepository`**: 定义 `Auth` 模块的数据交互接口。
    *   `Stream<AuthStatus> get authStatus`: 提供认证状态流 (可能需要结合 `ISecureStorageRepository` 实现)。
    *   `Future<Either<Failure, AuthenticatedUser>> loginWithPassword(PasswordCredentials credentials)`: 调用后端 API 执行密码登录。
    *   `Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(VerificationCodeCredentials credentials)`: 调用后端 API 执行验证码登录。
    *   `Future<Either<Failure, AuthenticatedUser>> register(RegistrationDetails details)`: 调用后端 API 执行注册。
    *   `Future<Either<Failure, void>> logout()`: 调用后端 API 执行登出。
    *   `Future<Either<Failure, void>> sendVerificationCode(String phone, VerificationPurpose purpose)`: 调用后端 API 发送验证码。
*   **`ISecureStorageRepository`** (由 `Core/Shared` 模块提供实现):
    *   `Future<void> saveToken(String token)`
    *   `Future<String?> getToken()`
    *   `Future<void> deleteToken()`
    *   `Future<void> saveUserId(String userId)`
    *   `Future<String?> getUserId()`
    *   `Future<void> deleteUserId()`
    *   `Future<void> clearAllAuthData()` (登出时调用)

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**:
    *   依赖 `ISecureStorageRepository` 接口的实现。
    *   依赖通用的 `Failure` 定义。
    *   依赖网络请求客户端抽象 (或其实现)。
*   **`Profile` 模块**:
    *   `Auth` 模块不直接 *调用* `Profile` 的 `Domain` 接口。
    *   但登录成功后，需要通过应用层逻辑（如 App Bloc/Router 监听 `AuthStatus`）触发 `Profile` 模块获取详细用户信息。

### 4.2. 导航需求 (Navigation Needs)

`Auth` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToHome()`: 登录/注册成功后。
*   `navigateToLogin()`: 登出后或需要认证时。
*   `navigateToPreviousScreen()`: (可选) 登录成功后返回之前的页面。
*   `navigateToRegistration()`: 从登录页跳转到注册页。

---

**待确认/后续步骤:**

*   **确认注册 API 的具体请求/响应格式，以最终确定 `RegistrationDetails` 实体。** (请求格式已根据 API 文档更新，响应格式仍需确认，特别是成功时是否返回 `userId` 和 `token`)。
*   确认登录成功后，`Auth` 模块的 API 响应是否包含除 `userId` 和 `token` 外的其他基本信息（**API 文档未明确，维持仅含 `userId` 和 `token` 的假设**）。
*   明确密码重置流程是否需要实现，如果需要，则补充相关 `Entities`, `Use Cases`, `Repository` 方法和导航。 