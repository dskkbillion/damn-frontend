# Profile 模块边界定义 (Boundary Definition)

本文档基于初步分析、React Native 源代码、HTML 原型、API 文档以及用户个人中心业务特点，定义了 `Profile` 模块的边界。

## 1. 模块名称

`Profile` (个人中心/用户资料)

## 2. 核心业务能力 (Business Capability)

负责管理用户的个人身份信息、账户设置、收货地址等核心数据。提供用户查看和修改其个人资料、管理应用偏好设置、管理收货地址的功能，并作为入口访问其他用户相关的模块（如订单历史、帮助中心等）。

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`UserProfile`**: 用户的详细个人资料。
    *   `userId`: (String) 用户唯一标识 (关联 `Auth` 模块的 `AuthenticatedUser.userId`)。
    *   `nickname`: (String) 昵称。
    *   `avatarUrl`: (String?) 头像 URL。
    *   `bio`: (String?) 个人简介。
    *   `gender`: (枚举: `male`, `female`, `other`, `unknown`?) 性别。
    *   `birthday`: (DateTime?) 生日。
    *   `phoneNumber`: (String?) 手机号 (可能部分脱敏显示)。
    *   `email`: (String?) 邮箱地址 (可能部分脱敏显示)。
    *   `registrationDate`: (DateTime?) 注册日期。
    *   *(可能还有：用户等级、积分、实名认证状态等，具体依赖业务和 API)*
*   **`UserAddress`**: 用户收货地址 (可复用 `Core/Shared.Address` 并添加额外属性)。
    *   `id`: (String) 地址唯一标识。
    *   `recipientName`: (String) 收件人姓名。
    *   `phone`: (String) 联系电话。
    *   `street`: (String) 详细街道地址。
    *   `city`: (String) 城市。
    *   `state`: (String) 省份/州。
    *   `postalCode`: (String) 邮政编码。
    *   `country`: (String) 国家。
    *   `isDefault`: (bool) 是否为默认地址。
    *   `label`: (String?) 地址标签 (如"家", "公司")。
*   **`UserSettings`**: 应用相关的用户偏好设置。
    *   `userId`: (String)
    *   `notificationPreferences`: (`NotificationSettings`) 通知设置 (如新消息、促销活动、订单状态更新)。
    *   `privacySettings`: (`PrivacySettings`) 隐私设置 (如个人资料可见性、数据共享选项)。
    *   `language`: (String) 应用语言偏好。
    *   `theme`: (枚举: `light`, `dark`, `system`) 应用主题偏好。
    *   *(具体设置项依赖应用功能)*
*   **`NotificationSettings`**: (嵌套对象或独立实体) 通知偏好细节。
    *   `allowPushNotifications`: (bool)
    *   `notifyNewMessages`: (bool)
    *   `notifyOrderUpdates`: (bool)
    *   `notifyPromotions`: (bool)
*   **`PrivacySettings`**: (嵌套对象或独立实体) 隐私偏好细节。
    *   `profileVisibility`: (枚举: `public`, `friendsOnly`, `private`)

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`GetUserProfileUseCase`**: 获取当前用户的个人资料。
    *   输入: `void` (隐式使用当前 `userId`)
    *   输出: `Either<Failure, UserProfile>`
*   **`UpdateUserProfileUseCase`**: 更新用户的个人资料。
    *   输入: `updatedProfileData` (如 `nickname`, `avatarUrl`, `bio`, `gender`, `birthday`)
    *   输出: `Either<Failure, UserProfile>`
*   **`GetUserAddressListUseCase`**: 获取用户的收货地址列表。
    *   输入: `void`
    *   输出: `Either<Failure, List<UserAddress>>`
*   **`AddUserAddressUseCase`**: 添加新的收货地址。
    *   输入: `newAddressData` (不含 `id`, `isDefault` 可能可选)
    *   输出: `Either<Failure, UserAddress>` (返回包含 ID 的新地址)
*   **`UpdateUserAddressUseCase`**: 更新已存在的收货地址。
    *   输入: `addressId`, `updatedAddressData`
    *   输出: `Either<Failure, UserAddress>`
*   **`DeleteUserAddressUseCase`**: 删除一个收货地址。
    *   输入: `addressId`
    *   输出: `Either<Failure, void>`
*   **`SetDefaultUserAddressUseCase`**: 设置默认收货地址。
    *   输入: `addressId`
    *   输出: `Either<Failure, void>` (成功后需刷新地址列表状态)
*   **`GetUserSettingsUseCase`**: 获取用户的应用设置。
    *   输入: `void`
    *   输出: `Either<Failure, UserSettings>`
*   **`UpdateUserSettingsUseCase`**: 更新用户的应用设置。
    *   输入: `updatedSettingsData`
    *   输出: `Either<Failure, UserSettings>`

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IUserProfileRepository`**: 定义用户资料的数据访问接口。
    *   `Future<Either<Failure, UserProfile>> getUserProfile()`: 获取用户资料。
    *   `Future<Either<Failure, UserProfile>> updateUserProfile(UserProfileUpdateData data)`: 更新用户资料。
    *   `Future<Either<Failure, String>> uploadAvatar(File imageFile)`: (可选) 上传头像文件 (返回 URL)。
*   **`IUserAddressRepository`**: 定义用户地址管理的数据访问接口。
    *   `Future<Either<Failure, List<UserAddress>>> getAddressList()`: 获取地址列表。
    *   `Future<Either<Failure, UserAddress>> addAddress(UserAddressData data)`: 添加地址。
    *   `Future<Either<Failure, UserAddress>> updateAddress(String addressId, UserAddressData data)`: 更新地址。
    *   `Future<Either<Failure, void>> deleteAddress(String addressId)`: 删除地址。
    *   `Future<Either<Failure, void>> setDefaultAddress(String addressId)`: 设置默认地址。
*   **`IUserSettingsRepository`**: 定义用户设置的数据访问接口。
    *   `Future<Either<Failure, UserSettings>> getUserSettings()`: 获取设置。
    *   `Future<Either<Failure, UserSettings>> updateUserSettings(UserSettingsData data)`: 更新设置。
*   **(依赖接口 - 由其他模块定义或位于 Core/Shared):**
    *   `IAuthRepository` (Auth): 获取当前 `userId`。
    *   `IFileRepository` (Core/Shared): (如果 `IUserProfileRepository` 不直接处理上传) 提供文件上传能力。

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**:
    *   依赖通用的 `Failure`, `Address` 实体 (或作为 `UserAddress` 基础), 网络客户端, 文件上传服务 (`IFileRepository`), 本地缓存 (可能用于缓存 Profile/Settings)。
*   **`Auth` 模块**:
    *   强依赖，需要 `userId` 来识别和操作当前用户的数据。
*   **`Orders` 模块**:
    *   `Profile` 模块通常不直接调用 `Orders`，但会提供导航入口。
*   **`Seller` 模块**:
    *   如果用户同时是卖家，`Profile` 模块可能提供导航到 `Seller` 中心的入口。用户资料与店铺资料是不同的概念。
*   **`Notification` 模块 (如果存在)**:
    *   用户在 `Profile` 中修改的通知设置 (`UserSettings`) 会影响 `Notification` 模块的行为。

### 4.2. 导航需求 (Navigation Needs)

`Profile` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToEditProfile()`: 进入编辑个人资料页面。
*   `navigateToAddressList()`: 进入收货地址管理列表页面。
*   `navigateToAddressEdit(addressId?: String)`: 进入添加或编辑地址页面。
*   `navigateToSettings()`: 进入应用设置页面。
*   `navigateToChangePassword()`: (如果密码修改在此处发起) 进入修改密码流程。
*   `navigateToLogin()`: 用户尝试访问 Profile 但未登录时，或主动登出后。
*   `navigateToOrdersList()`: 跳转到订单历史页面 (属于 `Orders` 模块)。
*   `navigateToHelpCenter()`: 跳转到帮助/客服中心。
*   `navigateToAboutUs()`: 跳转到关于我们页面。
*   `navigateToSellerCenter()`: (如果用户是卖家) 跳转到卖家中心 (属于 `Seller` 模块)。
*   `logoutAndNavigateToLogin()`: 用户点击登出按钮。

---

**待确认/后续步骤:**

*   确认 `UserProfile` 实体的完整字段列表 (根据 API 返回)。
*   确认 `UserSettings` 实体的完整结构和所有设置项。
*   确认用户资料、地址、设置相关的 API 端点及其请求/响应结构。
*   明确头像上传和处理流程。
*   确认手机号、邮箱等敏感信息的显示和修改规则。
*   密码修改流程是放在 `Profile` 模块还是 `Auth` 模块？ 