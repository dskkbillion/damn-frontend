# Auth 模块重构任务清单

本文档跟踪 `Auth` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。**优先遵循 API 文档 (`backend-api.json`) 设计，并记录与 RN 实现的冲突。**

**负责人**: [你的名字/团队成员]
**当前分支**: `refactor/auth-module` (建议)

## 核心工作流步骤

### 阶段 1: 分析与设计 (基于 API 文档优先原则)

- [x] **1. 定义模块边界 (已基于 API 文档更新)**
    - [x] 核心业务能力: 短信登录 (`/api/auth/login`), 注册 (`/api/auth/register`), 验证码 (`/api/common/send-code/register`), 会话管理 (Token), UserId 获取依赖 (`/api/member/info`)。
    - [x] 核心要素 (`Domain` 层):
        - [x] 主要 `Use Cases`: `LoginWithVerificationCodeUseCase`, `RegisterUseCase`, `LogoutUseCase`, `SendVerificationCodeUseCase`, `GetAuthStatusStreamUseCase`, `GetLoggedInUserUseCase`, (Core) `FetchUserInfoUseCase`。
        - [x] 核心 `Entities`: `AuthenticatedUser` (含 token, userId), `VerificationCodeCredentials`, `RegistrationDetails` (**严格按 API 文档**: 含 `mobile`, `code`, `password`, `scene`, `inviterId?`), `AuthStatus`, `VerificationPurpose`。
        - [x] 所需 `Repository Interfaces`: `IAuthRepository`, `ISecureStorageRepository`, (Core/Profile) `IUserInfoRepository`。
    - [x] 交互点:
        - [x] 依赖 `Core/Shared` (提供基础服务和 `IUserInfoRepository`?)。
        - [x] 导航需求: `navigateToHome`, `navigateToLogin`, `navigateToRegistration`, `navigateToPreviousScreen`。

- [x] **2. 分析参考代码 (RN `design-info/demo-repository`) & API 文档 (`backend-api.json`) (已完成)**
    - [x] **登录 `/api/auth/login`**: 文档响应为空，RN 实现响应含 `{ code, token }`。**-> 暂按 RN 实现，待确认。**
    - [x] **注册 `/api/auth/register`**: 文档要求 `password`, `scene`, `inviterId`，RN 实现未使用 `password`。**-> 按文档实现，待确认。**
    - [x] 发送验证码 `/api/common/send-code/register`**: 文档与 RN 一致 (请求体 `{ mobile }`)。
    - [x] 获取用户信息 `/api/member/info`**: 文档缺失响应结构，RN 实现分析响应为 `data: { id: number, ... }`。**-> 暂按 RN 分析，待确认。**
    - [x] 无后端 Logout API。
    - [x] Token 校验通过 `/api/member/info`。

- [ ] **3. 解决关键待办事项 (API 文档优先)**
    - [ ] **【最高优先级 - 阻塞性】确认 `/api/auth/login` 成功响应**: 与后端确认实际响应是否包含 `token`，并**必须更新 API 文档**。
    - [ ] **【高优先级】确认 `/api/auth/register` 请求体与状态**: 与后端确认此接口是否仍在使用？是否真的需要 `password`, `scene`, `inviterId`？`inviterId` 的确切类型和可选性？
    - [ ] **【高优先级】确认 `/api/member/info` 响应**: 与后端确认准确 JSON 结构，定义统一 `UserInfo` 实体/模型，明确 `id` 类型。
    - [ ] **(次要) 确认 `/api/auth/login` 响应 `code` 字段**: 含义及是否需要检查？
    - [ ] **Token 校验策略实现**: **将在 `core` 文件夹中实现** (例如，通过 AppLifecycleObserver 或 InitializationService)。

### 阶段 2: Flutter 实现 (根据 API 文档优先原则重构)

- [x] **4. 精化 `Domain` 层接口 (已完成)**
    - [x] `RegistrationDetails` 实体 (**已按 API 文档更新**)。
    - [x] `RegisterUseCase` 接口 (返回 void) (**已完成**)。
    - [x] `SendVerificationCodeUseCase` 接口 (移除 purpose) (**已完成**)。
    - [x] `IAuthRepository` 接口 (register 返回 void, 依赖 IUserInfoRepo) (**已完成**)。

- [ ] **5. 实现 Flutter `Data` 层 (需要更新)**
    - [ ] **(前置条件: 待办事项 #1 必须解决才能完成登录)**
    - [ ] **更新 `AuthRemoteDataSource` 接口** (register 返回 void, 移除 fetchUserInfo) (**已完成**)。
    - [ ] **更新 `AuthRemoteDataSourceImpl`**: (**已完成**)
        - [ ] `loginWithVerificationCode`: **暂时假设响应含 token (待确认)**。
        - [ ] `register`: **按 API 文档实现 (含 password/scene/inviterId)，待确认**。
        - [ ] `sendVerificationCode`: 实现已更新。
    - [ ] **更新 `LoginResponseModel`**: (**已完成**, 待确认 code 类型)。
    - [ ] **(Core/Profile) 实现 `UserInfoRemoteDataSource`**: 调用 `GET /api/member/info`。
    - [ ] **(Core/Profile) 实现 `UserInfoModel`**: 解析 `/api/member/info` 响应 (**待确认结构**)。
    - [ ] **重构 `AuthRepositoryImpl`**: (注入 IUserInfoRepo, 更新 login (依赖 UserInfoRepo), 实现 register (调用 DS)) (**已完成**)。

- [x] **6. 实现 Flutter `Domain` 逻辑 (已完成)**
    - [x] `RegisterUseCase` 实现：(**已按 API 文档添加校验**)。
    - [x] `SendVerificationCodeUseCase` 实现 (移除 purpose) (**已完成**)。

- [ ] **7. 实现 Flutter `Presentation` 层 (需要更新)**
    - [ ] `SmsLoginCubit`: (`sendCode` 移除 purpose) (**已完成**)。
    - [ ] `RegistrationBloc/Cubit`: (**已创建基础**, `register` 方法参数需包含 `password`, `scene`, `inviterId?`)。
    - [ ] `RegistrationPage`: (**已创建基础**, 需添加 `password`, `scene`, `inviterId?` 输入 UI)。
    - [ ] `SmsLoginPage`: 可能需要添加导航到注册页的按钮。
    - [ ] `VerificationCodeButton`: (`onSendCode` 移除 purpose) (**已完成**)。

### 阶段 3: 测试与集成

- [ ] **8. 识别并配置外部依赖 (需要更新)**
    - [ ] 确认/注入 `IUserInfoRepository` 实现。
- [ ] **9. 编写单元/Widget 测试 (需要更新)**
    - [ ] `Data` 层: 更新 `AuthRepositoryImpl` 测试, Mock `IUserInfoRepository`。
    - [ ] 更新 `RegisterUseCase`, `RegistrationBloc/Cubit`, `RegistrationPage` 的测试 (基于 API 文档定义的注册逻辑)。
- [ ] **10. 在模块预览环境中调试和验证 (需要更新)**
    - [ ] 重点测试 **API 文档定义** 的注册流程。
    - [ ] 测试登录(假设有 token)->获取用户信息->更新状态的流程。
- [ ] **11. (模块完成后) 集成准备 (不变)**
    - [ ] 测试 `core` 中的 Token 校验逻辑。
- [ ] **12. 执行集成与测试 (不变)**
- [ ] **13. 重复 (不变)**
