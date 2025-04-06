# Auth 模块重构任务清单

本文档跟踪 `Auth` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。

**负责人**: [你的名字/团队成员]
**当前分支**: `refactor/auth-module` (建议)

## 核心工作流步骤

### 阶段 1: 分析与设计 (基于 `auth_boundary_definition_final.md`)

- [x] **1. 定义模块边界 (已完成)**
    - [x] 核心业务能力: 登录、注册、会话管理、验证码服务。
    - [x] 核心要素 (`Domain` 层):
        - [x] 主要 `Use Cases`: `LoginWithPasswordUseCase`, `LoginWithVerificationCodeUseCase`, `RegisterUseCase`, `LogoutUseCase`, `SendVerificationCodeUseCase`, `GetAuthStatusStreamUseCase`, `GetLoggedInUserUseCase` (以及潜在的 `ForgotPasswordUseCase`)。
        - [x] 核心 `Entities`: `AuthenticatedUser`, `AuthCredentials` (及其子类 `PasswordCredentials`, `VerificationCodeCredentials`), `RegistrationDetails`, `AuthStatus`, `VerificationPurpose`。
        - [x] 所需 `Repository Interfaces`: `IAuthRepository`, `ISecureStorageRepository` (由 Core/Shared 提供)。
    - [x] 交互点:
        - [x] 依赖 `Core/Shared` (`ISecureStorageRepository`, `Failure`, 网络客户端)。
        - [x] 无直接依赖其他业务模块 (Profile 模块通过监听 `AuthStatus` 间接交互)。
        - [x] 导航需求: `navigateToHome`, `navigateToLogin`, `navigateToRegistration`, `navigateToPreviousScreen`, (潜在 `navigateToForgotPassword`)。

- [ ] **2. 分析参考代码 (RN `design-info/demo-repository`)**
    - [ ] 深入研究 RN 项目中与 Auth 相关的功能实现 (登录页、注册页、状态管理逻辑等)。
    - [ ] **验证/细化**: 确认 RN 实现与边界定义 (`auth_boundary_definition_final.md`) 的一致性或差异点。
        *   [ ] **业务逻辑 (`Domain`)**: RN 中的登录/注册流程、状态判断条件是否与 Use Case 描述一致？有无遗漏的业务规则？
        *   [ ] **数据交互 (`Data`)**: RN 如何调用登录/注册/发码 API？请求/响应处理方式？Token/UserId 的存储和使用方式？
        *   [ ] **UI 流程 (`Presentation`)**: RN 认证相关的页面跳转逻辑、UI 状态（加载中、错误提示、按钮禁用等）、用户输入验证。

- [ ] **3. 解决关键待办事项 (阻塞性问题)**
    - [ ] **【最高优先级】与后端确认 API 响应**: 明确 `/api/auth/login` 成功时 `userId` 和 `token` 的返回方式 (响应体/头)。**在继续 `Data` 层实现前必须解决。**
    - [ ] **确认验证码发送 API**: 与后端确认发送验证码的准确 API 端点和参数。
    - [ ] **确认密码重置需求**: 与产品/后端确认是否需要密码重置功能，若需要，则定义 API。
    - [ ] **确认 `identifier` 支持**: 与后端确认密码登录是否支持邮箱等其他标识符。
    - [ ] **确认 `inviterId` 传递**: 与后端确认注册时 `inviterId` 是否需要以及如何传递。

### 阶段 2: Flutter 实现

- [ ] **4. 精化 `Domain` 层接口**
    - [ ] 在 `lib/features/auth/domain/` 目录下创建/完善 `.dart` 文件。
    - [ ] 基于 `auth_boundary_definition_final.md` 编写最终的 `Entities` (`authenticated_user.dart`, `auth_credentials.dart`, `registration_details.dart`, `auth_status.dart`, `verification_purpose.dart` 等)。
    - [ ] 编写最终的 `Use Cases` 抽象类/接口 (`login_with_password.dart`, `send_verification_code.dart` 等)。
    - [ ] 编写最终的 `Repository Interfaces` (`i_auth_repository.dart`)。
    - [ ] 添加详细的文档注释 (`///`)。

- [ ] **5. 实现 Flutter `Data` 层**
    - [ ] **(前置条件: 关键待办事项 #3 已解决)**
    - [ ] 在 `lib/features/auth/data/repositories/` 下创建 `AuthRepositoryImpl` 并实现 `IAuthRepository`。
    - [ ] 在 `lib/features/auth/data/datasources/` 下创建 `AuthRemoteDataSource` (定义调用 API 的抽象方法)。
        - [ ] 创建 `AuthRemoteDataSourceImpl` (使用网络客户端实现 API 调用)。
    - [ ] 在 `lib/features/auth/data/models/` 下定义 DTOs (如 `authenticated_user_model.dart`) 并实现与 `Entities` 的映射 ( `fromDTO`, `toEntity`)。
        *   **注意**: `AuthenticatedUserModel` 的定义依赖于阻塞问题 #3 的解决。
    - [ ] 处理数据层错误 (API 错误、网络错误) 并映射到 `Domain` `Failures`。
    - [ ] 创建 Mock `AuthRemoteDataSource` 用于测试。
    - [ ] (依赖 Core/Shared) 实现或确认 `ISecureStorageRepository` 的具体实现可用。

- [ ] **6. 实现 Flutter `Domain` 逻辑**
    - [ ] 在 `lib/features/auth/domain/usecases/` 下创建 `Use Case` 实现类 (如 `LoginWithPassword`, `SendVerificationCode` 等)。
    - [ ] 注入 `IAuthRepository` 接口。
    - [ ] 实现 `call()` 方法，调用 Repository 方法执行业务逻辑。

- [ ] **7. 实现 Flutter `Presentation` 层**
    - [ ] 在 `lib/features/auth/presentation/pages/` 下创建页面 Widgets (如 `login_page.dart`, `registration_page.dart`)。
    - [ ] 在 `lib/features/auth/presentation/widgets/` 下创建可复用组件 (如 `phone_input_field.dart`, `password_input_field.dart`, `verification_code_button.dart`)。
    - [ ] 在 `lib/features/auth/presentation/providers/` (或 `bloc/`, `cubit/`) 下创建状态管理类 (如 `login_provider.dart`, `registration_provider.dart`, `auth_status_provider.dart`)。
    - [ ] 状态管理类依赖相应的 `Use Case` 接口。
    - [ ] 实现状态管理逻辑 (处理用户输入、调用 Use Case、更新 UI State - 加载中、成功、失败等)。
    - [ ] UI `Widgets` 监听状态变化，展示 UI，并触发状态管理类的方法。

### 阶段 3: 测试与集成

- [ ] **8. 识别并配置外部依赖 (隔离开发)**
    - [ ] 确定需要调用的导航服务方法 (e.g., `goRouter.go('/home')`, `goRouter.push('/login')`)。
    - [ ] 确认 `Core/Shared` 提供的 `ISecureStorageRepository` 实现。
    - [ ] (在预览/测试环境中) 配置 Mock 依赖注入: Mock `IAuthRepository` (用于 UI 测试), Mock 导航服务。

- [ ] **9. 编写单元/Widget 测试**
    - [ ] **`Domain` 层**: 测试所有 `Use Cases`。
    - [ ] **`Data` 层**: 测试 `AuthRepositoryImpl` (需 Mock `AuthRemoteDataSource` 和 `ISecureStorageRepository`), 测试 `AuthRemoteDataSourceImpl` (需 Mock 网络客户端), 测试 Model 与 Entity 的映射。
    - [ ] **`Presentation` 层**: 测试状态管理逻辑 (Providers/Blocs), 测试关键 Widgets (如登录表单)。
    - [ ] 检查测试覆盖率。

- [ ] **10. 在模块预览环境中调试和验证**
    - [ ] (可选但推荐) 创建并运行 `main_auth_preview.dart`。
    - [ ] 确保 Mock 依赖已注入。
    - [ ] 手动测试登录、注册、登出流程，检查 UI 和交互。

- [ ] **11. (模块完成后) 集成准备**
    - [ ] 确认满足 DoD (Definition of Done): 所有任务完成、测试通过、阻塞问题解决。
    - [ ] 完成代码评审 (PR/MR)。
    - [ ] 确保主开发分支为最新。

- [ ] **12. 执行集成与测试**
    - [ ] 合并 `refactor/auth-module` 分支到主开发分支。
    - [ ] 在主工程中更新 DI 配置 (注入真实的 `AuthRepositoryImpl`, `ISecureStorageRepository` 实现)。
    - [ ] 在主工程中更新导航配置 (注册 Auth 相关路由)。
    - [ ] 执行集成测试 (登录后访问其他模块、模块间跳转)。

- [ ] **13. 重复**
    - [ ] (可选) 删除特性分支。
    - [ ] 选择下一个模块。
