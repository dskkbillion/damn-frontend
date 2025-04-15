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
        - [x] 确认 `UserProfile` 实体的最终字段 (基于 API `/api/user/member/profile` 和 Redux 状态)。
        - [x] 确认 `UserSettings` 的具体结构和字段，以及其数据是包含在 `UserProfile` API 中，还是需要单独获取/更新 (无独立 API `/api/user/member/setting`)。
        - [x] 确认 Profile 页面所需展示的其他模块摘要信息（如钱包余额 `/api/user/member/wallet/info`，收藏、点赞列表等）的 API 端点和获取方式 (明确 Profile 直接调用)。
        - [ ] 明确各个导航目标的具体路由路径和参数传递。
        - [x] 明确头像上传 (`/api/common/public/upload`) 和处理流程。
        - [x] (已确认) 移除修改密码功能。

- [x] **3. 分析参考代码 (验证与细化)**
    - [x] 已研究 RN 项目中 `app/(tabs)/profile/` 相关代码。
    - [x] 已验证/调整边界定义 (`profile-todo/02_boundary_definition.md`)。
    - [x] 已初步提取业务逻辑、数据交互 (部分 API 已识别)、UI 流程。

- [x] **4. 精化 `Domain` 层接口**
    - [x] 在 `lib/features/profile/domain/entities/` 下创建 `user_profile.dart`, `wallet_summary.dart` 等实体定义。
    - [x] 在 `lib/features/profile/domain/usecases/` 下创建 Use Case 抽象类/接口 (e.g., `get_user_profile.dart`, `update_user_profile.dart`, `get_wallet_summary.dart`, `switch_to_seller_mode.dart`, `logout.dart`, `check_auth_status.dart` 等)。
    - [x] 在 `lib/features/profile/domain/repositories/` 下创建 `i_user_profile_repository.dart`, `i_wallet_repository.dart`, `i_auth_repository.dart` 接口定义。
    - [x] 添加详细的文档注释 (`///`)。

- [x] **5. 实现 Flutter `Data` 层**
    - [x] 在 `lib/features/profile/data/repositories/` 下创建 `user_profile_repository_impl.dart`, `wallet_repository_impl.dart`。
    - [x] 在 `lib/features/profile/data/datasources/` 下创建 `profile_remote_data_source.dart` 和 `profile_local_data_source.dart` (用于缓存)。
    - [x] **RemoteDataSource 实现**: 对接 API 端点:
        - [x] `getUserProfile()` -> `GET /api/user/member/profile` (包含基本信息)
        - [x] `updateUserProfile()` -> `POST /api/user/member/update` (更新用户信息)
        - [x] `uploadAvatar()` -> `POST /api/common/public/upload`
        - [x] `getWalletSummary()` -> `GET /api/user/member/wallet/info` (Profile 直接调用)
        - [x] `getSavedItems()` -> 为收藏列表添加 API
        - [x] `getLikedStories()` -> 为点赞笔记列表添加 API
    - [x] 在 `lib/features/profile/data/models/` 下定义 DTOs (`user_profile_dto.dart`, `wallet_summary_dto.dart` 等) 并实现与 `Entities` 的映射 (`toEntity()`, `fromEntity()`)。
    - [x] 处理数据层错误 (e.g., `DioException`) 并映射到 `Domain` `Failures` (`lib/core/error/failures.dart`)。
    - [x] 创建 Mock `DataSource` (`mock_profile_remote_data_source.dart`) 用于测试和预览。

- [x] **6. 实现 Flutter `Domain` 逻辑**
    - [x] 在 `lib/features/profile/domain/usecases/` 下创建 Use Case 实现类：
        - [x] `get_user_profile.dart`
        - [x] `update_user_profile.dart`
        - [x] `upload_avatar.dart`
        - [x] `get_wallet_summary.dart`
        - [x] `check_auth_status.dart`
        - [x] `logout.dart`
    - [x] 注入相应的 `Repository` 接口。
    - [x] 实现 `call()` 方法中的核心业务逻辑。

- [x] **7. 实现 Flutter `Presentation` 层**
    - [x] 在 `lib/features/profile/presentation/pages/` 下创建页面 `Widgets`:
        - [x] `bloc_profile_page.dart` (使用 BLoC 架构的主页面)
    - [x] 在 `lib/features/profile/presentation/bloc/` 下创建状态管理类:
        - [x] `profile_bloc.dart` (管理用户资料加载、更新、登出、模式切换等状态)
        - [x] `profile_event.dart` (定义 ProfileBloc 的事件)
        - [x] `profile_state.dart` (定义 ProfileBloc 的状态)
        - [x] `wallet_bloc.dart` (管理钱包摘要信息)
        - [x] `wallet_event.dart` (定义 WalletBloc 的事件)
        - [x] `wallet_state.dart` (定义 WalletBloc 的状态)
    - [x] 状态管理类依赖 `Use Case` 接口。
    - [x] 实现状态管理逻辑 (事件处理、状态变更)。
    - [x] UI `Widgets` 监听状态 (使用 `BlocConsumer`) 并通过事件触发 Bloc 方法。
    - [x] 实现卖家/买家模式切换功能。
    - [x] 更新应用主题色为 #b66d0e 金黄棕色，统一 UI 风格。

- [x] **8. 识别并配置外部依赖 (隔离开发)**
    - [x] 确定需要调用的导航服务方法。
    - [x] 确定需要依赖的其他模块 `Domain` 接口: `IAuthRepository` (`logout`, `isLoggedIn`, `getCurrentUserId`), `IWalletRepository` (`getWalletSummary`)。
    - [x] 配置 Mock 依赖注入 (Mock `IAuthRepository`, Mock `IWalletRepository`)。

- [ ] **9. 编写单元/Widget 测试**
    - [ ] **`Domain` 层**: 测试 `Use Cases`, `Entities`。
    - [ ] **`Data` 层**: 测试 `Repository` 实现 (使用 Mock `DataSource`), `DataSource` (使用 Mock HTTP client), DTO 映射。
    - [ ] **`Presentation` 层**: 测试 `Bloc` 逻辑 (使用 Mock `Use Cases`), 关键 `Widgets` (使用 Mock `Bloc`)。
    - [ ] 检查测试覆盖率。

- [x] **10. 在模块预览环境中调试和验证**
    - [x] 创建并运行 `main_profile_preview.dart` 入口文件。
    - [x] 确保 Mock 依赖已通过 DI (使用 GetIt) 正确注入。
    - [x] 手动测试用户界面、功能入口跳转、买/卖家模式切换、显示状态等。
    - [x] 修复 Web 平台网络检测问题。
    - [x] 解决运行时资源加载问题。

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

## 完成进度

- [x] **已实现的实体 (Entities):**
  - [x] `UserProfile` - 用户基本信息
  - [x] `WalletSummary` - 钱包摘要信息

- [x] **已实现的用例 (Use Cases):**
  - [x] `GetUserProfile` - 获取用户资料
  - [x] `UpdateUserProfile` - 更新用户资料
  - [x] `UploadAvatar` - 上传头像
  - [x] `GetWalletSummary` - 获取钱包信息
  - [x] `CheckAuthStatus` - 检查认证状态
  - [x] `Logout` - 退出登录

- [x] **已实现的仓库 (Repositories):**
  - [x] `UserProfileRepositoryImpl` - 用户资料仓库实现
  - [x] `WalletRepositoryImpl` - 钱包仓库实现

- [x] **已实现的状态管理:**
  - [x] `ProfileBloc` - 个人信息状态管理
  - [x] `WalletBloc` - 钱包状态管理

- [x] **界面功能:**
  - [x] 用户信息展示
  - [x] 卖家/买家模式切换
  - [x] 个人中心菜单项 (订单、收藏、钱包等)
