# Auth 模块边界定义

本文档基于 API 文档并结合实际开发经验，定义了 `Auth` 模块的边界和职责范围。

## 1. 模块名称

`Auth` (认证授权)

## 2. 核心业务能力 (Business Capability)

负责应用程序用户的身份验证 (短信验证码登录)、会话管理 (Token 获取与存储) 以及相关的验证码服务。

* 支持短信验证码登录 (`/api/auth/login` with `scene: sms_code_login`)
* 管理用户的认证状态和会话凭证 (Token 的获取、存储、清除)
* 发送用于登录的手机验证码 (`/api/common/send-code/register`)
* 获取并存储用户基本信息 (`/api/member/info`)

**注**: 根据项目需求，注册功能暂不实现。

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

* **`AuthenticatedUser`**: 表示已通过身份验证的用户凭证。
  * `id`: (int) 用户唯一标识符。(由 `/api/member/info` 响应获取)
  * `token`: (String) 用于 API 调用的认证令牌。(由 `/api/auth/login` 响应获取)

* **`VerificationCodeCredentials`**: 使用验证码登录的凭证。
  * `phone`: (String) 手机号。
  * `code`: (String) 短信验证码。
  * `scene`: (String) 场景值，固定为 "sms_code_login"。

* **`AuthStatus`**: 用户认证状态的枚举。
  * `authenticated(AuthenticatedUser user)`: 已认证。
  * `unauthenticated`: 未认证。
  * `unknown`: 初始状态。

* **`UserInfo`**: 用户信息实体。
  * 包含从 `/api/member/info` 获取的所有用户详细信息。
  * 核心字段包括 `id`、`mobile`、`nickName`、`commonUserId` 等。

### 3.2. `Use Cases` (主要功能点/用户故事)

* **`LoginWithVerificationCodeUseCase`**: 处理短信登录。
  * 输入: `VerificationCodeCredentials`
  * 输出: `Either<Failure, AuthenticatedUser>`

* **`LogoutUseCase`**: 处理用户登出 (本地操作)。
  * 输入: 无
  * 输出: `Either<Failure, void>`

* **`SendVerificationCodeUseCase`**: 发送验证码。
  * 输入: `phone` (String)
  * 输出: `Either<Failure, void>`

* **`GetAuthStatusStreamUseCase`**: 获取并监听认证状态。
  * 输入: 无
  * 输出: `Stream<AuthStatus>`

* **`GetLoggedInUserUseCase`**: 同步获取当前登录用户。
  * 输入: 无
  * 输出: `Either<Failure, AuthenticatedUser?>`

* **`FetchUserInfoUseCase`**: 使用 Token 获取用户信息。
  * 输入: `token` (String)
  * 输出: `Either<Failure, UserInfo>`

### 3.3. `Repository Interfaces` (数据操作契约)

* **`IAuthRepository`**:
  * `Stream<AuthStatus> get authStatus`
  * `Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(VerificationCodeCredentials credentials)`
  * `Future<Either<Failure, void>> logout()`
  * `Future<Either<Failure, void>> sendVerificationCode({required String phone})`
  * `Either<Failure, AuthenticatedUser?> getLoggedInUserSync()`

* **`IUserInfoRepository`**:
  * `Future<Either<Failure, UserInfo>> fetchUserInfo(String token)`

* **`ISecureStorageRepository`**: (来自 Core/Shared)
  * `Future<int?> getInt(String key)`
  * `Future<String?> getString(String key)`
  * `Future<void> saveInt(String key, int value)`
  * `Future<void> saveString(String key, String value)`
  * `Future<void> delete(String key)`
  * 等其他便捷方法

## 4. API 映射

* **`/api/auth/login` (POST)**: **短信登录接口**。
  * 请求体: `{ "mobile": string, "code": string, "scene": "sms_code_login" }`
  * 响应: 包含 `token`

* **`/api/common/send-code/register` (POST)**: **发送验证码接口**。
  * 请求体: `{ "mobile": string }`
  * 请求头: 需要添加设备信息 (`clienttype`、`client`、`version`)

* **`/api/member/info` (GET)**: **获取用户信息接口**。
  * 请求需携带 Token
  * 响应: 包含用户完整信息，包括 `id`、`commonUserId` 等字段

* **Logout**: **无后端 API**，仅本地操作。

## 5. 交互点 (Interaction Points)

* **依赖项**:
  * `Core/Shared` 模块提供的基础服务 (如 `DioClient`, `ISecureStorageRepository`, `NetworkInfo`)
  * `Core` 模块提供的 `TokenValidator` 服务

* **被依赖项**:
  * 应用的导航/路由层依赖 `Auth` 模块获取 `AuthStatus` 来实现登录拦截
  * 其他模块可能需要获取当前用户ID或commonUserId

* **导航需求**:
  * `navigateToHome` (登录成功后)
  * `navigateToLogin` (需要登录时)

## 6. 安全考虑 (Security Considerations)

* Token 通过安全存储 (`ISecureStorageRepository`) 保存
* UserId 和 CommonUserId 也通过安全存储保存
* API 请求使用 HTTPS
* 实现了 Token 校验机制，确保 Token 有效性

## 7. 特别说明

* `UserInfoRemoteDataSource` 和 `UserInfoRepositoryImpl` 理论上应该在 Core/Profile 模块实现，但为了解除开发阻塞，暂时在 Auth 模块中实现。未来会迁移到相应模块。
* 实现过程中发现API文档与实际不符的地方已在实现中处理，后续需更新API文档。
