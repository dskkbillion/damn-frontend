# Auth 模块重构任务清单

本文档跟踪 `Auth` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。**优先遵循 API 文档 (`backend-api.json`) 设计，但根据最新确认调整，并记录与文档的冲突。**

**负责人**: [你的名字/团队成员]
**当前分支**: `refactor/auth-module` (建议)

## 核心工作流步骤

### 阶段 1: 分析与设计 (基于 API 文档优先原则, 结合最新确认)

- [x] **1. 定义模块边界 (已基于 API 文档更新)**
    - [x] 核心业务能力: 短信登录 (`/api/auth/login`), 验证码 (`/api/common/send-code/register`), 会话管理 (Token), 用户信息获取 (`/api/member/info`)。 **(注：注册流程根据指示暂不实现)**
    - [x] 核心要素 (`Domain` 层):
        - [x] 主要 `Use Cases`: `LoginWithVerificationCodeUseCase`, `LogoutUseCase`, `SendVerificationCodeUseCase`, `GetAuthStatusStreamUseCase`, `GetLoggedInUserUseCase`, (Core) `FetchUserInfoUseCase`。
        - [x] 核心 `Entities`:
            - `AuthenticatedUser` (**包含 `token` (String) 和 `id` (int)**)
            - `VerificationCodeCredentials`
            - `AuthStatus`
            - `VerificationPurpose`
            - `UserInfo` (**基于 `/member/info` 响应定义**)
        - [x] 所需 `Repository Interfaces`: `IAuthRepository`, `ISecureStorageRepository`, (Core/Profile) `IUserInfoRepository`。
    - [x] 交互点:
        - [x] 依赖 `Core/Shared` (提供基础服务和 `IUserInfoRepository`?)。
        - [x] 导航需求: `navigateToHome`, `navigateToLogin`, `navigateToPreviousScreen`。

- [x] **2. 分析参考代码 (RN `design-info/demo-repository`) & API 文档 (`backend-api.json`) (已完成)**
    - [x] **登录 `/api/auth/login`**: **确认响应会包含 `token`** (与 API 文档冲突)。请求体场景为 `sms_code_login`。
    - [x] **注册 `/api/auth/register`**: **(根据指示暂不处理)** API 文档要求 `password` 等字段，且已弃用。
    - [x] 发送验证码 `/api/common/send-code/register`**: 文档与 RN 一致 (请求体 `{ mobile }`)。
    - [x] 获取用户信息 `/api/member/info`**: **确认响应包含 `id` (int) 及其他详细字段** (见下方实际响应)。API 文档缺失 `data` 对象结构。
    - [x] 无后端 Logout API。
    - [x] Token 校验通过 `/api/member/info`。

- [x] **3. 解决关键待办事项 (最新确认后)**
    - [x] **用户标识确认**: 使用 `/api/member/info` 响应中的 `id` (int) 作为用户唯一标识符，**必须存储**。`token` (String) 作为 API 凭证。
    - [ ] **【中优先级】更新 API 文档**: **必须**更新 `/api/auth/login` 的文档以反映返回 `token`，**必须**更新 `/api/member/info` 的文档以反映其 `data` 结构。
    - [ ] **(最低优先级/可能不需要) 确认 `/api/auth/login` 响应 `code` 字段**: 如果响应中除了 `token` 还有 `code` 字段，其含义是什么？
    - [ ] **Token 校验策略实现**: **将在 `core` 文件夹中实现** (例如，通过 AppLifecycleObserver 或 InitializationService)。

### `/api/member/info` 实际响应示例 (供参考)
```json
{
    "msg": "获取成功",
    "code": 200,
    "data": {
        "createTime": "2024-08-21 16:40:53", // string
        "updateTime": null, // string or null
        "sort": 0, // integer
        "id": 10302, // integer <- 已确认用此 ID
        "signature": null, // string or null
        "birthday": null, // string or null
        "vipTime": null, // string or null
        "mobile": "17895868541", // string
        "nickName": "178****1", // string
        "trueName": null, // string or null
        "avatar": null, // string or null
        "gender": "NONE", // string ("NONE", "MALE", "FEMALE"?)
        "status": "ENABLE", // string ("ENABLE", "DISABLE"?)
        "type": "DEFAULT", // string
        "province": null, // string or null
        "remarks": null, // string or null
        "weminiOpenid": null, // string or null
        "weappOpenid": null, // string or null
        "weUnionid": null, // string or null
        "realNameFlag": false, // boolean
        "attestationName": null, // string or null
        "productNum": null, // integer or null
        "orderNum": null, // integer or null
        "buyOrderNum": null, // integer or null
        "ip": null, // string or null
        "loginTime": null, // string or null
        "recoverFlag": false, // boolean
        "commonUserId": 10297, // integer
        "onlineFlag": true, // boolean
        "lastLoginTime": null, // string or null
        "payPriceTotal": null, // number or null?
        "inviter": null, // object or null?
        "isApplyDel": 0, // integer (0 or 1?)
        "age": null, // integer or null
        "xingzuo": null // string or null
    }
}
```

### 阶段 2: Flutter 实现 (根据最新确认重构)

- [x] **4. 精化 `Domain` 层接口 (已完成/调整)**
    - [x] `AuthenticatedUser` 实体 (**包含 `token` (String) 和 `id` (int)**)
    - [x] `SendVerificationCodeUseCase` 接口 (**已完成**)。
    - [x] `IAuthRepository` 接口 (**移除 `register` 方法**)
    - [x] `UserInfo` 实体 (**可基于实际响应定义**)

- [ ] **5. 实现 Flutter `Data` 层 (基本完成，依赖 Core/Profile)**
    - [x] **(阻塞解除)**
    - [x] **更新 `AuthRemoteDataSource` 接口** (**移除 `register` 方法**) - **已完成**
    - [x] **更新 `AuthRemoteDataSourceImpl`**:
        - [x] `loginWithVerificationCode`: 实现 (**确认响应包含 `token`**) - **已完成**
        - [x] `sendVerificationCode`: 实现已更新。- **已完成**
    - [x] **更新 `AuthenticatedUserModel`**: (**确认包含 `token`**, `code` 待定) - **已完成**
    - [ ] **(Core/Profile) 实现 `UserInfoRemoteDataSource`**: 调用 `GET /api/member/info`。 - **需要在 Core/Profile 完成**
    - [x] **(Core/Profile) 实现 `UserInfoModel`**: **基于实际响应解析 `/api/member/info` `data` 结构**。 - **已在 Auth 中完成模型定义，实现需在 Core/Profile**
    - [x] **重构 `AuthRepositoryImpl`**: (注入 IUserInfoRepo, 更新 login (依赖 UserInfoRepo, **需存储 id**), **移除 register**) - **已完成**

- [x] **6. 实现 Flutter `Domain` 逻辑 (已完成/调整)**
    - [x] `SendVerificationCodeUseCase` 实现 (**已完成**)。

- [x] **7. 实现 Flutter `Presentation` 层 (需要更新)**
    - [x] `SmsLoginCubit`: (`sendCode` 移除 purpose) (**已完成**)。
    - [ ] `SmsLoginPage`: UI 和逻辑确认。
    - [x] `VerificationCodeButton`: (`onSendCode` 移除 purpose) (**已完成**)。

### 阶段 3: 测试与集成

- [ ] **8. 识别并配置外部依赖 (策略明确)**
    - [x] 主要依赖 `IUserInfoRepository` (获取用户信息)。
    - [x] **策略**: 在 `Auth` 模块测试中将 Mock `IUserInfoRepository` 接口。其真实实现 (`UserInfoRepositoryImpl`) 需要在 `Core` 或 `Profile` 模块中提供，并通过依赖注入配置。

- [~] **9. 编写单元/Widget 测试 (基本完成)**
    - [x] `Data` 层: `UserInfoModel`, `AuthRepositoryImpl` (login, logout, sendCode) 测试已添加。
    - [x] `Domain` 层: `LoginUseCase` 测试已添加。
    - [x] `Presentation` 层: `SmsLoginPage` Widget 测试已添加。
    - [ ] (待完善) 覆盖更多边缘情况和 `AuthRepositoryImpl` 其他方法测试。

- [ ] **10. 在模块预览环境中调试和验证 (主要流程通过)**
      - [x] 测试登录(确认有 token)->获取用户信息(解析完整 data, 包含 id)->更新状态的流程。
- [ ] **11. (模块完成后) 集成准备 (不变)**
    - [ ] 测试 `core` 中的 Token 校验逻辑。
- [ ] **12. 执行集成与测试 (不变)**
- [ ] **13. 重复 (不变)**
