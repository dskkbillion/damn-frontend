# Profile 模块边界定义 (步骤 2)

本文档基于对 React Native 源代码 (`design-info/demo-repository/app/(tabs)/profile/`) 的分析，并结合服务买卖平台的业务特点，定义了 `Profile` (个人中心) 模块的边界。

## 1. 核心业务能力 (Business Capability)

负责展示用户的基本个人信息，提供账户相关功能的入口，管理用户在平台内的状态（如买/卖家模式），并作为导航枢纽访问其他用户相关的模块（如订单、收藏、钱包、设置等）。

## 2. 核心要素 (`Domain` 层)

### 2.1. `Entities` (核心业务对象)

*   **`UserProfile`**: 用户的核心档案信息。
    *   `userId`: (String) 用户唯一标识 (关联 `Auth` 模块)。
    *   `nickName`: (String) 昵称。
    *   `avatarUrl`: (String?) 头像 URL。
    *   `onlineFlag`: (bool?) 卖家在线状态 (用于卖家模式显示)。
    *   *(可能还有：认证状态，具体依赖业务和 API `/api/user/member/profile`)*
*   **`UserSettings`**: 应用相关的用户偏好设置 (具体字段和数据来源待确认，可能包含在 `UserProfile` 中或有独立 API)。
    *   `userId`: (String)
    *   `notificationPreferences`: (`NotificationSettings`?) 通知设置 (对应 `notification.tsx`)。
    *   `accountSafetySettings`: (`AccountSafetySettings`?) 账户安全设置 (对应 `accountSafe/`，不含密码修改)。
    *   `language`: (String?) 应用语言偏好。
    *   `theme`: (枚举: `light`, `dark`, `system`?) 应用主题偏好。
*   **`NotificationSettings`**: (嵌套对象或独立实体) 通知偏好细节。
    *   *(具体字段待确认)*
*   **`AccountSafetySettings`**: (嵌套对象或独立实体) 账户安全偏好细节。
    *   *(具体字段待确认，例如绑定状态等)*
*   **`WalletSummary`**: (由 Wallet 模块定义，Profile 通过 API `/api/user/member/wallet/info` 获取) 用户钱包概览。
    *   `balance`: (Number?) 余额。
    *   *(其他钱包相关信息)*
*   **`SavedItem`**: (由 Saved 模块定义，Profile 通过 API 获取列表?) 用户收藏的服务或项目。
    *   `itemId`: (String)
    *   `title`: (String)
    *   `imageUrl`: (String?)
    *   *(其他必要信息)*
*   **`LikedStory`**: (由 Story 模块定义，Profile 通过 API 获取列表?) 用户点赞的笔记/内容。
     *   `storyId`: (String)
     *   `title`: (String)
     *   `previewContent`: (String?)
     *   *(其他必要信息)*

### 2.2. `Use Cases` (主要功能点/用户故事)

*   **`GetUserProfileUseCase`**: 获取当前用户的个人资料（可能包含部分设置）。
    *   输入: `void` (隐式使用当前 `userId`)
    *   输出: `Either<Failure, UserProfile>`
*   **`UpdateUserProfileUseCase`**: 更新用户的可编辑资料 (如果允许，如昵称、头像，可能包含部分设置)。
    *   输入: `updatedProfileData`
    *   输出: `Either<Failure, UserProfile>`
*   **`GetWalletSummaryUseCase`**: 获取钱包摘要信息。
    *   输入: `void`
    *   输出: `Either<Failure, WalletSummary>`
*   **`SwitchToSellerModeUseCase`**: 切换到卖家界面/模式。
    *   输入: `void` (触发导航)
    *   输出: `void` (导航事件)
*   **`NavigateToLoginUseCase`**: (如果用户未登录) 导航到登录页面。
    *   输入: `void`
    *   输出: `void` (导航事件)
*   **`NavigateToOrdersUseCase`**: 导航到订单列表页面。
    *   输入: `orderStatusFilter?` (可选的状态过滤参数，如待付款、进行中)
    *   输出: `void` (导航事件)
*   **`NavigateToSavedListUseCase`**: 导航到我的收藏列表页面。
    *   输入: `void`
    *   输出: `void` (导航事件)
*   **`NavigateToLikedStoriesUseCase`**: 导航到点赞的笔记列表页面。
    *   输入: `void`
    *   输出: `void` (导航事件)
*   **`NavigateToTimeManageUseCase`**: 导航到时间银行/管理页面。
    *   输入: `void`
    *   输出: `void` (导航事件)
*   **`NavigateToWalletUseCase`**: 导航到我的钱包页面。
    *   输入: `void`
    *   输出: `void` (导航事件)
*   **`NavigateToNotificationsUseCase`**: 导航到消息通知设置/列表页面。
    *   输入: `void`
    *   输出: `void` (导航事件)
*   **`NavigateToAccountSafetyUseCase`**: 导航到账户安全设置页面。
    *   输入: `void`
    *   输出: `void` (导航事件)
*   **`NavigateToHelpCenterUseCase`**: 导航到帮助与客服页面。
    *   输入: `void`
    *   输出: `void` (导航事件)
*   **`LogoutUseCase`**: 登出当前用户。
    *   输入: `void`
    *   输出: `Either<Failure, void>` (成功后触发导航到登录页)
*   **`NavigateToBecomeSellerUseCase`**: 导航到成为卖家/卖家申请页面。
    *   输入: `void`
    *   输出: `void` (导航事件)
*   **`GetUserSettingsUseCase`**: 获取用户的应用设置 (如果设置独立于 Profile 获取)。
    *   输入: `void`
    *   输出: `Either<Failure, UserSettings>`
*   **`UpdateUserSettingsUseCase`**: 更新用户的应用设置 (如果设置独立于 Profile 更新)。
    *   输入: `updatedSettingsData`
    *   输出: `Either<Failure, UserSettings>`

### 2.3. `Repository Interfaces` (数据操作契约)

*   **`IUserProfileRepository`**: 定义用户资料的数据访问接口。
    *   `Future<Either<Failure, UserProfile>> getUserProfile()`: 获取用户资料。
    *   `Future<Either<Failure, UserProfile>> updateUserProfile(UserProfileUpdateData data)`: 更新用户资料 (如果支持)。
    *   `Future<Either<Failure, String>> uploadAvatar(File imageFile)`: (如果支持) 上传头像文件 (返回 URL)。
*   **`IUserSettingsRepository`**: 定义用户设置的数据访问接口 (如果设置独立管理)。
    *   `Future<Either<Failure, UserSettings>> getUserSettings()`: 获取设置。
    *   `Future<Either<Failure, UserSettings>> updateUserSettings(UserSettingsData data)`: 更新设置。
*   **`IWalletRepository` (由 Wallet 模块定义)**: Profile 模块依赖此接口。
    *   `Future<Either<Failure, WalletSummary>> getWalletSummary()`: 获取钱包摘要。
*   **(依赖接口 - 由其他模块定义或位于 Core/Shared):**
    *   `IAuthRepository` (Auth): `Future<Either<Failure, void>> logout()`, `Future<String> getCurrentUserId()`。
    *   `IFileRepository` (Core/Shared): (如果需要上传头像) 提供文件上传能力。
    *   *(可能需要 SavedItems, LikedStories 等模块的 Repository 接口来获取列表数据)*

## 3. 交互点 (Interaction Points)

### 3.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**:
    *   依赖通用的 `Failure`, UI 组件, 导航服务 (`NavigationService`), 网络客户端, 本地缓存 (可能)。
*   **`Auth` 模块**:
    *   强依赖，需要 `userId`，并调用 `logout` 功能。
*   **`Orders` 模块**:
    *   提供导航入口。Profile 不直接调用其业务逻辑。
*   **`Seller` 模块**:
    *   提供切换到卖家模式的导航入口。
*   **`Wallet`, `Saved`, `LikedStory`, `TimeManage` 模块 (如果存在)**:
    *   提供导航入口。Profile 模块需要直接调用这些模块的 API/Repository 接口获取所需信息 (如钱包摘要)。
*   **`Notification` 模块 (如果存在)**:
    *   提供导航入口，用户设置可能影响其行为。

### 3.2. 导航需求 (Navigation Needs)

`Profile` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央 `NavigationService` 实现):

*   `navigateToLogin()`: (`/(outer)/login`)
*   `navigateToSellerScreens()`: (`/(sellerscreens)`)
*   `navigateToOrders({status: orderStatus})`: (`/(tabs)/profile/orders`)
*   `navigateToSavedList()`: (`/(tabs)/profile/saved_list`)
*   `navigateToLikedStories()`: (`/(tabs)/profile/likedStory`)
*   `navigateToTimeManage()`: (`/(tabs)/profile/timeManage`)
*   `navigateToWallet()`: (`/(tabs)/profile/wallet`)
*   `navigateToNotifications()`: (`/(tabs)/profile/notification`)
*   `navigateToAccountSafety()`: (`/(tabs)/profile/accountSafe`)
*   `navigateToHelpCenter()`: (具体路径待定)
*   `navigateToBecomeSeller()`: (`/sellerApply/applyHome`)
*   `logoutAndNavigateToLogin()`: (执行登出逻辑后导航到 `/login`)

## 4. 下一步

*   确认 `UserProfile` 实体的最终字段 (基于 API `/api/user/member/profile` 和 Redux 状态)。
*   确认 `UserSettings` 的具体结构和字段，以及其数据是包含在 `UserProfile` API 中，还是需要单独获取/更新。
*   确认 Profile 页面所需展示的其他模块摘要信息（如收藏列表、点赞笔记列表）的 API 端点和数据结构。
*   明确各个导航目标的具体路由路径和参数传递。
*   明确头像上传 (`/api/common/public/upload`) 和处理流程。
