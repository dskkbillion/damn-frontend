# Seller 模块边界定义 (Boundary Definition)

本文档基于初步分析、React Native 源代码、HTML 原型、API 文档以及卖家中心业务特点，定义了 `Seller` 模块的边界。

## 1. 模块名称

`Seller` (卖家中心)

## 2. 核心业务能力 (Business Capability)

提供卖家管理其在线店铺、商品信息、店铺公开资料、与买家进行初级沟通（聊天列表、自动回复）以及查看关键业务指标（如销售概览、待处理订单数）所需的核心功能。**核心的订单管理（包括订单列表、订单详情和订单状态扭转等操作）、完整的聊天室功能、钱包及提现功能由其他专业模块提供。故事功能暂时不做。** Seller 模块在需要这些功能时，会通过导航跳转到其他模块提供的页面，或调用其他模块提供的接口获取概览数据。

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`SellerDashboardData`**: 卖家仪表盘展示的核心数据，包含从其他模块（如 Orders, Chat, Payment）汇总的概览信息。这部分集成了数据分析的概览能力。具体属性需根据 Dashboard API (待定) 和其他模块接口确定。
    *   `pendingOrderCount`: (int) 待处理订单数 (来自 Orders 模块，通过 `IOrderRepository` 获取)。
    *   `unreadMessageCount`: (int) 未读消息数 (来自 Chat 模块，通过 `IChatRepository` 获取)。
    *   `revenueToday`: (Decimal) 今日销售额 (来自 Orders/Payment 模块，通过 `IOrderRepository`/`IPaymentRepository` 获取)。
    *   `revenueThisWeek`: (Decimal) 本周销售额 (来自 Orders/Payment 模块，通过 `IOrderRepository`/`IPaymentRepository` 获取)。
    *   `quickLinks`: (`List<QuickLink>`) 常用功能快捷入口 (如发布商品、**查看订单列表 - 导航到 Orders 模块**)。
    *   *(需要定义 `QuickLink` Entity 的结构)*
*   **`SellerStoreProfile`**: 卖家店铺公开信息。具体属性需根据店铺资料相关 API (待定) 和 RN 代码确定。
    *   `storeId`: (String) 店铺唯一标识。
    *   `storeName`: (String) 店铺名称。
    *   `logoUrl`: (String?) 店铺 Logo URL。
    *   `description`: (String?) 店铺描述。
    *   `contactInfo`: (`ContactInfo`?) 联系方式。
    *   `policies`: (`StorePolicies`?) 店铺政策 (退换货等)。
    *   `onlineFlag`: (bool?) 卖家在线状态 (可能属于用户通用属性，通过 `IAuthRepository`/用户 API 获取)。
    *   *(需要定义 `ContactInfo` 和 `StorePolicies` Entities 的结构)*
*   **`SellerManagedProduct`**: 卖家管理的商品实体 (可能扩展自 `Product/Item` 模块的 `Product` 实体，或为其包装器)，包含卖家管理所需的额外信息。具体属性需根据商品 API (`/api/shop/product/...`) 和 RN 代码确定。
    *   `productId`: (String) 商品 ID。
    *   `title`: (String) 商品标题。
    *   `coverImageUrl`: (String?) 封面图。
    *   `price`: (Decimal) 价格。
    *   `stock`: (int) 库存数量。
    *   `status`: (`ProductStatus`) 商品状态 (如 `draft`, `published`, `archived`, `outOfStock`)。
    *   `salesCount`: (int?) 累计销量 (可选)。
    *   `createdAt`: (DateTime?) 创建时间。
    *   `updatedAt`: (DateTime?) 更新时间。
    *   *(包含 `Product` 的核心字段，加上管理所需的状态和统计信息。需要定义 `ProductStatus` 枚举和与 `Product` 的关系)*
*   **`SellerNotification`**: 卖家收到的通知。具体属性需根据通知 API (待定，可能 `/api/notification/list`) 和 RN 代码确定。
    *   `notificationId`: (String)。
    *   `type`: (`NotificationType`) 通知类型。
    *   `title`: (String).
    *   `content`: (String).
    *   `isRead`: (bool) 是否已读。
    *   `createdAt`: (DateTime).
    *   `relatedEntityId`: (String?) 关联的实体ID (订单ID, 聊天ID等)。
    *   *(需要定义 `NotificationType` 枚举)*
*   **`SellerAuthenticationInfo`**: 卖家认证信息。具体属性需根据认证 API (`/api/project/authentication/list`) 和 RN 代码确定。
    *   `authenticationId`: (String).
    *   `type`: (`AuthenticationType`) 认证类型 (如 `person`, `school`)。
    *   `status`: (`AuthenticationStatus`) 认证状态 (如 `pending`, `approved`, `rejected`)。
    *   `fields`: (`Map<String, dynamic>`) 提交的字段，具体结构取决于认证类型。
    *   `rejectionReason`: (String?) 拒绝原因。
    *   `submittedAt`: (DateTime).
    *   *(需要定义 `AuthenticationType`, `AuthenticationStatus` 枚举)*
*   **`AutoReplySettings`**: 卖家自动回复设置。具体属性需根据自动回复 API (待定，可能 `/api/notification/autoReply`) 和 RN 代码确定。
    *   `isEnabled`: (bool) 是否启用。
    *   `message`: (String) 自动回复内容。
*   **`TimeSettings`**: 卖家时间管理设置。具体属性需根据时间设置 API (待定) 和 RN 代码确定。
    *   `isOnline`: (bool) 在线状态 (可能通过用户通用API设置)。
    *   `availableTimeSlots`: (`List<TimeSlot>`) 可用时间段设置。
    *   *(需要定义 `TimeSlot` Entity 的结构)*
*   **(复用或依赖的实体)**:
    *   `Order`, `OrderStatus`, `OrderItem` (来自 `Orders` 模块 - 在 Dashboard, Quick Links 中可能引用，通过 `IOrderRepository` 获取概览数据，**导航到 Orders 模块详情页**)
    *   `Product` (来自 `Product/Item` 模块 - SellerManagedProduct 是其扩展，通过 `IProductRepository` 获取底层数据)
    *   `ChatSession` (来自 `Chat` 模块 - 聊天列表展示，通过 `IChatRepository` 获取)
    *   `ChatMessage` (来自 `Chat` 模块 - 聊天列表展示最后一条消息，通过 `IChatRepository` 获取)
    *   `Address` (来自 `Core/Shared` - 在联系方式等处引用)
    *   `Failure` (来自 `Core/Shared`)
    *   *(其他 Core/Shared 的 Entities)*

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`GetSellerDashboardDataUseCase`**: 获取卖家仪表盘数据，编排调用 `IOrderRepository`, `IChatRepository`, `IPaymentRepository` 等获取概览数据。
    *   输入: `void`
    *   输出: `Either<Failure, SellerDashboardData>`
*   **`GetSellerProductListUseCase`**: 获取卖家管理的商品列表 (分页、筛选)。依赖 `ISellerRepository` (`getSellerProductList`)。
    *   输入: `filter` (按状态 `ProductStatus`, 关键词等，需要定义 `SellerProductFilter`), `page`, `limit`
    *   输出: `Either<Failure, List<SellerManagedProduct>>`
*   **`GetSellerProductDetailUseCase`**: 获取卖家管理的商品详情。依赖 `ISellerRepository` (`getSellerProductDetail`)。
    *   输入: `productId`
    *   输出: `Either<Failure, SellerManagedProduct>`
*   **`CreateProductUseCase`**: 卖家创建新商品。依赖 `ISellerRepository` (`createProduct`) 和 `IFileRepository` (上传图片)。
    *   输入: `productData` (包含名称、描述、价格、库存、图片等，需要定义 `ProductCreationData`)
    *   输出: `Either<Failure, SellerManagedProduct>`
*   **`UpdateProductUseCase`**: 卖家更新商品信息。依赖 `ISellerRepository` (`updateProduct`) 和 `IFileRepository` (上传图片)。
    *   输入: `productId`, `updatedProductData` (需要定义 `ProductUpdateData`)
    *   输出: `Either<Failure, SellerManagedProduct>`
*   **`UpdateProductStatusUseCase`**: 卖家修改商品状态 (上架/下架/归档/删除)。依赖 `ISellerRepository` (`updateProductStatus`/`deleteProduct`)。
    *   输入: `productId`, `newStatus` (`ProductStatus`)
    *   输出: `Either<Failure, void>`
*   **`DeleteProductUseCase`**: 卖家删除商品。依赖 `ISellerRepository` (`deleteProduct`)。*(与 UpdateProductStatusUseCase 合并或独立需进一步确认)*
    *   输入: `productId`
    *   输出: `Either<Failure, void>`
*   **`GetStoreProfileUseCase`**: 获取卖家店铺资料。依赖 `ISellerRepository` (`getStoreProfile`)。
    *   输入: `void` (隐式使用当前卖家 ID)
    *   输出: `Either<Failure, SellerStoreProfile>`
*   **`UpdateStoreProfileUseCase`**: 更新卖家店铺资料。依赖 `ISellerRepository` (`updateStoreProfile`) 和 `IFileRepository` (上传Logo)。
    *   输入: `updatedProfileData` (需要定义 `StoreProfileUpdateData`)
    *   输出: `Either<Failure, SellerStoreProfile>`
*   **`UpdateSellerOnlineStatusUseCase`**: 更新卖家在线状态。依赖 `ISellerRepository` (`updateSellerOnlineStatus`) 或 `IAuthRepository`。
    *   输入: `isOnline` (bool)
    *   输出: `Either<Failure, void>`
*   **`GetSellerChatSessionsUseCase`**: 获取卖家相关的聊天会话列表 (不包含聊天消息本身，只获取会话概览)。依赖 `IChatRepository` (`getChatSessions`，需要卖家ID过滤)。
    *   输入: `void`
    *   输出: `Either<Failure, List<ChatSession>>` (复用 `Chat` 模块的实体，数据源是过滤后的)
*   **`SetAutoReplyUseCase`**: 设置卖家自动回复。依赖 `ISellerRepository` (`setAutoReply`)。
    *   输入: `isEnabled` (bool), `message` (String)
    *   输出: `Either<Failure, void>`
*   **`GetAutoReplyUseCase`**: 获取卖家自动回复设置。依赖 `ISellerRepository` (`getAutoReply`)。
    *   输入: `void`
    *   输出: `Either<Failure, AutoReplySettings>`
*   **`UpdateSellerTimeSettingsUseCase`**: 更新卖家时间设置。依赖 `ISellerRepository` (`updateSellerTimeSettings`)。
    *   输入: `timeSettingsData` (需要定义 `TimeSettingsData`)
    *   输出: `Either<Failure, void>`
*   **`GetSellerTimeSettingsUseCase`**: 获取卖家时间设置。依赖 `ISellerRepository` (`getSellerTimeSettings`)。
    *   输入: `void`
    *   输出: `Either<Failure, TimeSettings>`
*   **`GetSellerNotificationListUseCase`**: 获取卖家通知列表 (分页)。依赖 `ISellerRepository` (`getSellerNotificationList`)。
    *   输入: `page`, `limit`
    *   输出: `Either<Failure, List<SellerNotification>>`
*   **`MarkNotificationAsReadUseCase`**: 标记通知为已读。依赖 `ISellerRepository` (`markNotificationAsRead`)。
    *   输入: `notificationId`
    *   输出: `Either<Failure, void>`
*   **`GetSellerAuthenticationStatusUseCase`**: 获取卖家认证状态。依赖 `ISellerRepository` (`getSellerAuthenticationStatus`)。
    *   输入: `void`
    *   输出: `Either<Failure, List<SellerAuthenticationInfo>>` (可能返回多种认证类型的状态)
*   **`SubmitAuthenticationApplicationUseCase`**: 提交卖家认证申请。依赖 `ISellerRepository` (`submitAuthenticationApplication`) 和 `IFileRepository` (上传认证材料)。
    *   输入: `authenticationType` (String), `applicationData` (需要定义 `AuthenticationApplicationData`)
    *   输出: `Either<Failure, void>`
*   **(由 Orders 模块提供，Seller 模块仅依赖和导航):** 这些 Use Cases 及其实现位于 `Orders` 模块，Seller 模块仅在需要时触发导航到 Orders 模块的页面。
    *   `AcceptOrderUseCase` (接受订单)
    *   `RejectOrderUseCase` (拒绝订单)
    *   `ShipOrderUseCase` (标记发货)
    *   `CompleteOrderUseCase` (完成订单)
    *   `AddOrderDemandUseCase` (添加订单需求)
    *   `DeleteSellerOrderRecordUseCase` (删除卖家订单记录)
    *   `InviteEvaluationUseCase` (邀请评价)

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`ISellerRepository`**: 定义卖家中心模块的核心数据访问接口。职责聚焦于卖家自身的数据和管理，例如卖家仪表盘概览数据聚合、卖家管理的商品数据、卖家店铺资料、卖家通知、卖家认证信息、卖家时间/在线状态设置、卖家自动回复设置。**`ISellerRepository` 不包含完整的订单管理、聊天消息、钱包等数据操作方法。这些操作属于其他模块的 Repository。Seller 模块的 Use Cases 在需要时会直接依赖并调用 `IOrderRepository` 来处理订单相关的核心数据访问和操作。**
    *   `Future<Either<Failure, SellerDashboardData>> getDashboardData()`: 获取仪表盘概览数据。**API: `POST /api/project/statistics/index`** (以及可能的 `/api/project/statistics/percent`, `/api/project/statistics/upgradeLevel`)。*(可能还需要聚合调用 `IOrderRepository`, `IChatRepository` 等获取其他概览数据)*
    *   `Future<Either<Failure, List<SellerManagedProduct>>> getSellerProductList(SellerProductFilter filter, int page, int limit)`: 获取卖家商品列表。**API: `POST /api/shop/product/myList`, `POST /api/shop/product/myDraft`**
    *   `Future<Either<Failure, SellerManagedProduct>> getSellerProductDetail(String productId)`: 获取卖家商品详情。**API: `GET /api/shop/product/get?id={productId}`** (假设是 GET 请求，需确认)
    *   `Future<Either<Failure, SellerManagedProduct>> createProduct(ProductCreationData data)`: 创建商品。**API: `POST /api/shop/product/create`**
    *   `Future<Either<Failure, SellerManagedProduct>> updateProduct(String productId, ProductUpdateData data)`: 更新商品。**API: `POST /api/shop/product/update` 或 `POST /api/shop/product/edit`**
    *   `Future<Either<Failure, void>> updateProductStatus(String productId, ProductStatus newStatus)`: 更新商品状态 (上架/下架/归档)。*(API 可能通过 `/api/shop/product/edit` 或 `/api/shop/product/update` 实现)*
    *   `Future<Either<Failure, void>> deleteProduct(String productId)`: 删除商品。**API: `POST /api/shop/product/delete`**
    *   `Future<Either<Failure, SellerStoreProfile>> getStoreProfile()`: 获取店铺资料。*(API 待定，可能通过 Auth 模块获取的用户信息接口，或专门的 `/api/shop/profile` 或 `/api/member/profile` 接口)*
    *   `Future<Either<Failure, SellerStoreProfile>> updateStoreProfile(StoreProfileUpdateData data)`: 更新店铺资料。*(API 待定，可能使用 `POST /api/member/edit` 更新部分字段如名称/头像，或 `POST /api/member/update` 更新其他字段如描述等)*
    *   `Future<Either<Failure, void>> updateSellerOnlineStatus(bool isOnline)`: 更新卖家在线状态。**API: `POST /api/member/update`** (传递 `onlineFlag` 参数)
    *   `Future<Either<Failure, List<ChatSession>>> getSellerChatSessions()`: 获取卖家相关聊天会话概览。*(API 待定, RN 代码中可能使用了 `/api/msg/getChatRoomList`)*
    *   `Future<Either<Failure, void>> setAutoReply(bool isEnabled, String message)`: 设置自动回复。**API: `POST /api/member/update`** (传递 `recoverFlag`, `recoverContent` 参数)
    *   `Future<Either<Failure, AutoReplySettings>> getAutoReply()`: 获取自动回复设置。*(API 待定，可能随用户/店铺资料一起返回，或有单独的 GET 接口，如 `/api/member/settings` 或 `/api/notification/autoReply/get`)*
    *   `Future<Either<Failure, void>> updateSellerTimeSettings(TimeSettingsData data)`: 更新时间设置。*(API 待定，可能通过 `POST /api/member/update` 或单独接口)*
    *   `Future<Either<Failure, TimeSettings>> getSellerTimeSettings()`: 获取时间设置。*(API 待定，可能随用户/店铺资料一起返回，或有单独 GET 接口)*
    *   `Future<Either<Failure, List<SellerNotification>>> getSellerNotificationList(int page, int limit)`: 获取通知列表。*(API 待定，可能类似 `/api/notification/list`)*
    *   `Future<Either<Failure, void>> markNotificationAsRead(String notificationId)`: 标记通知为已读。*(API 待定)*
    *   `Future<Either<Failure, SellerAuthenticationInfo>> getSellerAuthenticationStatus()`: 获取认证状态。**API: `POST /api/project/authentication/list`**
    *   `Future<Either<Failure, void>> submitAuthenticationApplication(String authenticationType, AuthenticationApplicationData data)`: 提交认证申请。**API: `POST /api/project/authenticationAudit/add`**
*   **(依赖接口 - 由其他模块定义或位于 Core/Shared):** Seller 模块的 Use Cases 或 `ISellerRepository` 实现可能需要依赖这些接口。**Seller 模块不会在自身 Repository 中重复实现这些接口提供的数据操作。**
    *   `IProductRepository` (Product/Item): 提供基础的商品数据访问。
    *   **`IOrderRepository` (Orders): 提供订单相关的核心数据访问和操作，包括获取买家/卖家视角的订单列表/详情，以及执行订单状态扭转操作。Seller 模块的 Use Cases 在需要获取订单概览数据时会依赖 `IOrderRepository`。完整的订单列表、详情和操作功能由 `Orders` 模块提供，Seller 模块仅导航到 `Orders` 模块的页面。**
    *   `IChatRepository` (Chat): 提供聊天会话和消息的查询能力。Seller 模块依赖其获取聊天会话列表。
    *   `IAuthRepository` (Auth): 获取卖家用户 ID 和认证状态，获取基础用户/成员信息（可能包含店铺资料、自动回复、时间设置等）。
    *   `IFileRepository` (Core/Shared): 提供文件上传能力。
    *   `INavigationService` (Core/Navigation): 导航服务接口。
    *   `IPaymentRepository` (Payment): 提供支付/销售数据访问。
    *   `IProfileRepository` (Profile): 提供钱包、交易记录等数据访问。

### 数据结构 (Data Structures) - 需要在 Domain 层定义

以下是文档中引用但在 Domain 层需要具体定义的实体、枚举和数据传输对象 (DTOs)。它们的具体属性和值需要根据 API 文档和现有代码（特别是 RN demo 的数据结构）来完善。

*   `QuickLink` (Class) - 快捷入口信息，包含图标、标题、跳转路径等。
*   `ContactInfo` (Class) - 联系方式，如电话、微信、地址等。
*   `StorePolicies` (Class) - 店铺政策，如退换货政策文本等。
*   `ProductStatus` (Enum) - 商品状态，如 `draft`, `published`, `archived`, `outOfStock` 等。
*   `SellerProductFilter` (Class) - 用于过滤卖家商品列表的参数，如状态、关键词、分类等。
*   `ProductCreationData` (Class) - 创建商品时需要提交的数据，包含商品名称、描述、价格、库存、图片列表、套餐信息等。
*   `ProductUpdateData` (Class) - 更新商品时需要提交的数据，与创建类似，可能包含 ID。
*   `NotificationType` (Enum) - 通知类型，如订单通知、消息通知、系统通知等。
*   `AuthenticationType` (Enum) - 认证类型，如 `person`, `school` 等。
*   `AuthenticationStatus` (Enum) - 认证状态，如 `pending`, `approved`, `rejected` 等。
*   `AuthenticationApplicationData` (Class) - 提交认证申请时需要提交的数据，包含认证类型及对应的表单字段信息。
*   `TimeSettingsData` (Class) - 更新时间设置时需要提交的数据，包含在线状态、可用时间段列表等。
*   `TimeSlot` (Class) - 可用时间段的结构，包含开始时间和结束时间等。
*   *(可能需要定义用于 Dashboard 数据概览的聚合类或结构)*

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**: (已在上面接口依赖中列出)
    *   `Failure`, `Address`, 网络客户端, `IFileRepository`, 数据模型映射工具等。
*   **`Auth` 模块**: (已在上面接口依赖中列出)
    *   强依赖，获取当前卖家用户 ID 和认证状态，可能依赖其提供的通用用户资料更新接口。
*   **`Product/Item` 模块**: (已在上面接口依赖中列出)
    *   依赖其 `Product` 实体定义，`ISellerRepository` 实现可能调用其 Repository 获取底层商品数据或进行部分操作。
*   **`Orders` 模块**: (已在上面接口依赖中列出)
    *   **强依赖，Seller 模块依赖其 `Order`, `OrderStatus`, `OrderItem` 实体定义，并依赖 `IOrderRepository` 获取订单概览数据。完整的订单列表、详情和操作功能由 `Orders` 模块提供，Seller 模块仅导航到 `Orders` 模块的页面，并可能调用 Orders 模块提供的少量查询接口（如仪表盘概览）。**
*   **`Chat` 模块**: (已在上面接口依赖中列出)
    *   依赖其 `ChatSession`, `ChatMessage` 实体定义，依赖 `IChatRepository` 获取聊天会话列表。Seller 模块会导航到 Chat 模块的聊天室页面。
*   **`Notification` 模块**: (已在上面接口依赖中列出)
    *   新订单、新消息、退款请求等可能需要触发给卖家的通知。Seller 模块依赖其获取通知列表，并可能依赖其提供的接口更新通知状态（如标记已读）。
*   **`Profile` 模块**: Seller 模块的某些功能（如店铺主页）可能会导航到 Profile 模块的钱包、账号安全等页面。Seller 模块可能依赖 Profile 模块提供的 Use Cases 或 Repository 来获取少量相关信息（如钱包余额概览用于仪表盘）。
*   **`Payment` 模块**: Seller 模块的 Dashboard 可能需要获取 Payment 模块的销售数据。Seller 模块依赖 Payment 模块提供的相关 Use Cases 或 Repository。
*   **`Core/Navigation` 模块**: (已在上面接口依赖中列出)
    *   依赖 `INavigationService` 接口用于页面导航。

### 4.2. 导航需求 (Navigation Needs)

`Seller` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToSellerDashboard()`: 导航到卖家仪表盘/首页。
*   `navigateToSellerProductList()`: 查看/管理商品/服务列表。
*   `navigateToSellerItemEdit(productId?: String)`: 创建或编辑商品/服务。
*   `navigateToSellerStoreProfile()`: 查看卖家店铺主页/个人资料。
*   `navigateToSellerStoreProfileEdit()`: 编辑店铺资料。
*   `navigateToSellerChatList()`: 查看卖家消息列表。
*   `navigateToSellerNotifications()`: 查看卖家通知列表。
*   `navigateToSellerAuthentication(type: String)`: 进行卖家认证 (个人/学校等)。
*   `navigateToSellerTimeManagement()`: 进行卖家时间管理/设置。
*   `navigateToSellerAutoReplySettings()`: 设置卖家自动回复。
*   **(导航到其他模块页面，由对应模块提供页面和功能 - Seller 模块仅触发导航):**
    *   `navigateToOrderList(filter?: OrderFilter)`: **导航到 Orders 模块的订单列表页面，可能带筛选参数。Seller 模块不实现此页面。**
    *   `navigateToOrderDetail(orderId: String)`: **导航到 Orders 模块的订单详情页面。Seller 模块不实现此页面。**
    *   `navigateToChatRoom(sessionId: String)`: **导航到 Chat 模块的聊天室页面。Seller 模块不实现此页面。**
    *   `navigateToWallet()`: **导航到 Profile 模块的钱包页面。Seller 模块不实现此页面。**
    *   `navigateToTransactionRecords()`: **导航到 Profile 模块的交易记录页面。Seller 模块不实现此页面。**
    *   *(可能需要导航到 Profile 模块的其他页面，如账号安全等，由 Profile 模块提供页面和功能)*
*   `navigateToLogin()`: 访问卖家功能但未登录时。

---

**待确认/后续步骤:**

*   明确 `SellerManagedProduct` 与 `Product` 的具体关系（继承、组合、独立？）以及数据同步或映射方式。
    *(初步倾向于 SellerManagedProduct 包含 Product，并增加卖家管理特有字段)*
*   **通过分析 React Native demo 代码中的网络请求部分，补充 API 文档中缺失的卖家相关 API 详细信息 (端点、请求/响应结构)，特别是店铺资料、仪表盘、通知、时间设置、自动回复、提交认证申请等接口。**
*   **根据 API 细节和 RN 代码数据结构，详细定义"数据结构 (Data Structures) - 需要在 Domain 层定义"中列出的所有类和枚举的属性和值，并创建相应的 Data 层 DTOs (Data Transfer Objects) 和映射逻辑。**
*   细化所有 Seller 模块内部 Use Cases 的具体业务逻辑、输入验证和错误处理。
*   确认与 `Notification` 模块的集成方式（哪些事件需要通知卖家）。
*   **识别并计划迁移/重写现有 codebase 中分散在 `orders`、`profile` 或其他地方的、逻辑上属于 `Seller` 模块的代码（特别是 `lib/features/orders/domain/usecases/seller/` 下的 Use Cases 及其依赖、`lib/features/orders/presentation/seller/` 下的 UI 代码中的导航逻辑，以及可能在 `profile` 下找到的卖家设置相关代码的 Use Cases 和 Repository 实现）。将 UI 导航修改为指向 Orders 模块，将业务逻辑迁移到新的 Seller 模块。**
*   确认 Dashboard 数据聚合的具体来源和逻辑，以及是 Seller Repository 负责聚合还是 Dashboard Use Case 负责编排调用。
    *(初步倾向于 Dashboard Use Case 编排调用其他模块的 Repository)*
*   明确 Seller 模块在哪些情况下需要触发对 Orders, Chat, Profile 等模块的导航，以及导航时需要传递哪些参数。
    *(初步倾向于 Dashboard Use Case 编排调用其他模块的 Repository)*
*   确认现有 codebase 中 `orders` 模块提供的卖家相关 Use Cases (`AddOrderDemandUseCase` 等) 在新的模块边界下是否仍然需要，如果需要，是应该保留在 Orders 模块由 Seller 模块调用，还是迁移到 Seller 模块。 