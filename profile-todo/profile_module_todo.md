# Profile 模块重构任务清单

本文档跟踪 `Profile` (个人中心) 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。

**当前分支**: `refactor/profile-module` (建议)

## 核心工作流步骤

- [x] **2. 定义模块边界**
    - [x] 明确 `Profile` 模块的核心业务能力 (展示用户信息、功能入口、状态管理)。
    - [x] 识别核心要素 (`Domain` 层): `UserProfile`, `UserSettings`, 相关 Use Cases 和 Repository Interfaces。
    - [x] 识别交互点 (依赖 `Auth`, `Core`, `Navigation`, 可能依赖 `Orders`, `Wallet`, `Saved`, `LikedStory`, `Seller` 等)。
    - [x] 已产出边界定义文档: `profile-todo/02_boundary_definition.md`。
    - [ ] **下一步 (细化)**:
        - [ ] 确认 `UserProfile` 实体的最终字段 (基于 API `/api/user/member/profile` 和 Redux 状态)。
        - [ ] 确认 `UserSettings` 的具体结构和字段，以及其数据是包含在 `UserProfile` API 中，还是需要单独获取/更新 (无独立 API `/api/user/member/setting`)。
        - [ ] 确认 Profile 页面所需展示的其他模块摘要信息（如钱包余额 `/api/user/member/wallet/info`，收藏、点赞列表等）的 API 端点和获取方式 (明确 Profile 直接调用)。
        - [ ] 明确各个导航目标的具体路由路径和参数传递。
        - [ ] 明确头像上传 (`/api/common/public/upload`) 和处理流程。
        - [ ] (已确认) 移除修改密码功能。

- [x] **3. 分析参考代码 (验证与细化)**
    - [x] 已研究 RN 项目中 `app/(tabs)/profile/` 相关代码。
    - [x] 已验证/调整边界定义 (`profile-todo/02_boundary_definition.md`)。
    - [x] 已初步提取业务逻辑、数据交互 (部分 API 已识别)、UI 流程。

- [ ] **4. 精化 `Domain` 层接口**
    - [ ] 在 `lib/features/profile/domain/entities/` 下创建 `user_profile.dart`, `user_settings.dart` 等实体定义。
    - [ ] 在 `lib/features/profile/domain/usecases/` 下创建 Use Case 抽象类/接口 (e.g., `get_user_profile.dart`, `update_user_profile.dart`, `get_wallet_summary.dart`, `switch_to_seller_mode.dart`, `logout.dart`, 各导航 Use Case 等)。
    - [ ] 在 `lib/features/profile/domain/repositories/` 下创建 `i_user_profile_repository.dart`, `i_user_settings_repository.dart` (如果设置独立管理) 接口定义。
    - [ ] 添加详细的文档注释 (`///`)。

- [ ] **5. 实现 Flutter `Data` 层**
    - [ ] 在 `lib/features/profile/data/repositories/` 下创建 `user_profile_repository_impl.dart`, `user_settings_repository_impl.dart` (如果设置独立管理)。
    - [ ] 在 `lib/features/profile/data/datasources/` 下创建 `profile_remote_data_source.dart` (可能还有 `profile_local_data_source.dart` 用于缓存)。
    - [ ] **RemoteDataSource 实现**: 对接 API 端点:
        - [ ] `getUserProfile()` -> `GET /api/user/member/profile` (可能包含 UserSettings)
        - [ ] `updateUserProfile()` -> `POST /api/user/member/update` (可能包含 UserSettings 更新)
        - [ ] `uploadAvatar()` -> `POST /api/common/public/upload`
        - [ ] `getWalletSummary()` -> `GET /api/user/member/wallet/info` (Profile 直接调用)
        - [ ] (需要查找并添加) 获取收藏列表 API
        - [ ] (需要查找并添加) 获取点赞笔记列表 API
        - [ ] (需要查找并添加) 获取用户设置 API (如果独立于 Profile API)
    - [ ] 在 `lib/features/profile/data/models/` 下定义 DTOs (`user_profile_dto.dart`, `user_settings_dto.dart` 等) 并实现与 `Entities` 的映射 (`toEntity()`, `fromEntity()`)。
    - [ ] 处理数据层错误 (e.g., `DioException`) 并映射到 `Domain` `Failures` (`lib/core/error/failures.dart`)。
    - [ ] 创建 Mock `DataSource` (`mock_profile_remote_data_source.dart`) 用于测试和预览。

- [ ] **6. 实现 Flutter `Domain` 逻辑**
    - [ ] 在 `lib/features/profile/domain/usecases/` 下创建 Use Case 实现类 (e.g., `get_user_profile.dart` 实现)。
    - [ ] 注入相应的 `Repository` 接口。
    - [ ] 实现 `call()` 方法中的核心业务逻辑。

- [ ] **7. 实现 Flutter `Presentation` 层**
    - [ ] 在 `lib/features/profile/presentation/pages/` 下创建页面 `Widgets`:
        - [ ] `profile_page.dart` (主页面，包含用户信息、买/卖家切换、功能入口列表)
        - [ ] (根据导航需求细分) `account_safety_page.dart` (不含修改密码), `notification_settings_page.dart` 等 (如果这些页面属于 Profile 模块)。
    - [ ] 在 `lib/features/profile/presentation/widgets/` 下创建可复用组件 (e.g., `profile_header.dart`, `function_list_item.dart`, `seller_mode_switch.dart`)。
    - [ ] 在 `lib/features/profile/presentation/bloc/` (或 `cubit/`, `provider/`) 下创建状态管理类:
        - [ ] `profile_bloc.dart` (管理用户资料加载、更新、登出、模式切换等状态)
        - [ ] (可能需要) `user_settings_bloc.dart` (如果设置独立管理)。
    - [ ] 状态管理类依赖 `Use Case` 接口。
    - [ ] 实现状态管理逻辑 (事件处理、状态变更)。
    - [ ] UI `Widgets` 监听状态 (e.g., `BlocBuilder`, `BlocListener`) 并通过事件触发 Bloc 方法。

- [ ] **8. 识别并配置外部依赖 (隔离开发)**
    - [ ] 确定需要调用的导航服务方法 (`NavigationService`): `navigateToLogin`, `navigateToSellerScreens`, `navigateToOrders`, `navigateToSavedList`, etc.
    - [ ] 确定需要依赖的其他模块 `Domain` 接口: `IAuthRepository` (`logout`, `getCurrentUserId`), `IWalletRepository` (`getWalletSummary`)。
    - [ ] (可能需要) `ISavedRepository`, `ILikedStoryRepository` 等。
    - [ ] (在预览/测试环境中) 配置 Mock 依赖注入 (Mock `IAuthRepository`, Mock `NavigationService`, Mock `IWalletRepository`, Mock 其他所需 Repo)。

- [ ] **9. 编写单元/Widget 测试**
    - [ ] **`Domain` 层**: 测试 `Use Cases`, `Entities`。
    - [ ] **`Data` 层**: 测试 `Repository` 实现 (使用 Mock `DataSource`), `DataSource` (使用 Mock HTTP client), DTO 映射。
    - [ ] **`Presentation` 层**: 测试 `Bloc` 逻辑 (使用 Mock `Use Cases`), 关键 `Widgets` (使用 Mock `Bloc`)。
    - [ ] 检查测试覆盖率。

- [ ] **10. 在模块预览环境中调试和验证**
    - [ ] 创建并运行 `main_profile_preview.dart` 入口文件。
    - [ ] 确保 Mock 依赖已通过 DI (如 GetIt) 正确注入。
    - [ ] 手动测试用户界面、功能入口跳转、买/卖家模式切换、登录/未登录状态显示、登出功能等。

- [ ] **11. (模块完成后) 集成准备**
    - [ ] 确认满足 DoD (Definition of Done): 功能完成、测试通过、文档更新。
    - [ ] 完成代码评审 (PR/MR)。
    - [ ] 确保主开发分支 (`develop`) 为最新。

- [ ] **12. 执行集成与测试**
    - [ ] 合并 `refactor/profile-module` 分支到 `develop` 分支。
    - [ ] 在主工程 (`lib/app/injection.dart`?) 更新 DI 配置，替换 Mock 为真实实现 (Profile Repos/DataSources, Auth Repo, Wallet Repo)。
    - [ ] 在主工程导航配置中注册 Profile 相关真实路由。
    - [ ] 执行集成测试：检查 Profile 与 Auth, Navigation, Orders, Seller, Wallet 等模块的交互。

- [ ] **13. 重复**
    - [ ] (可选) 删除特性分支。
    - [ ] 选择下一个模块进行重构。
