# Seller 模块边界定义 (Boundary Definition)

本文档基于初步分析、React Native 源代码、HTML 原型、API 文档以及卖家中心业务特点，定义了 `Seller` 模块的边界。

## 1. 模块名称

`Seller` (卖家中心)

## 2. 核心业务能力 (Business Capability)

提供卖家管理其在线店铺和业务运营所需的核心功能。包括：管理商品信息（发布、编辑、上下架）、处理和履行订单（查看、标记发货、添加物流）、查看关键业务指标、管理店铺公开资料以及与买家沟通。

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`SellerDashboardData`**: 卖家仪表盘展示的核心数据。
    *   `pendingOrderCount`: (int) 待处理订单数。
    *   `unreadMessageCount`: (int) 未读消息数。
    *   `revenueToday`: (Decimal) 今日销售额。
    *   `revenueThisWeek`: (Decimal) 本周销售额。
    *   `quickLinks`: (`List<QuickLink>`) 常用功能快捷入口 (如发布商品、查看订单)。
*   **`SellerStoreProfile`**: 卖家店铺公开信息。
    *   `storeId`: (String) 店铺唯一标识。
    *   `storeName`: (String) 店铺名称。
    *   `logoUrl`: (String?) 店铺 Logo URL。
    *   `description`: (String?) 店铺描述。
    *   `contactInfo`: (`ContactInfo`?) 联系方式。
    *   `policies`: (`StorePolicies`?) 店铺政策 (退换货等)。
*   **`SellerManagedProduct`**: 卖家管理的商品实体 (可能扩展自 `Product/Item` 模块的 `Product` 实体，或为其包装器)。
    *   `productId`: (String) 商品 ID。
    *   `title`: (String) 商品标题。
    *   `coverImageUrl`: (String?) 封面图。
    *   `price`: (Decimal) 价格。
    *   `stock`: (int) 库存数量。
    *   `status`: (枚举: `draft`, `published`, `archived`, `outOfStock`) 商品状态。
    *   `salesCount`: (int?) 累计销量 (可选)。
    *   `createdAt`: (DateTime?) 创建时间。
    *   `updatedAt`: (DateTime?) 更新时间。
    *   *(包含 `Product` 的所有核心字段，加上管理所需的状态和统计信息)*
*   **`SellerOrderSummary`**: 卖家订单列表的摘要视图 (可能扩展自 `Orders` 模块的 `OrderSummary`)。
    *   `orderId`: (String)
    *   `orderNumber`: (String)
    *   `status`: (`OrderStatus`) 订单状态。
    *   `buyerInfo`: (`BuyerInfo`) 买家信息摘要。
    *   `previewItems`: (`List<OrderItemPreview>`) 商品预览。
    *   `totalAmount`: (Decimal) 订单金额。
    *   `createdAt`: (DateTime)
    *   `sellerActions`: (`List<SellerOrderAction>`) 卖家可执行的操作。
*   **`SellerOrder`**: 卖家视角的订单详情 (可能扩展自 `Orders` 模块的 `Order`)。
    *   包含 `Order` 的所有字段。
    *   `buyerInfo`: (`BuyerInfo`) 完整的买家信息 (含收货地址)。
    *   `sellerActions`: (`List<SellerOrderAction>`) 卖家可执行的操作。
*   **`BuyerInfo`**: 买家信息摘要。
    *   `userId`: (String)
    *   `displayName`: (String)
    *   `shippingAddress`: (`Address`) (可能仅在详情中完整展示)
*   **`SellerOrderAction`**: 卖家在订单上可执行的操作 (枚举)。示例：
    *   `markAsShipped` (标记发货)
    *   `addTrackingInfo` (添加物流信息)
    *   `contactBuyer` (联系买家)
    *   `processRefund` (处理退款 - 可能链接到售后模块)
    *   *(具体值取决于业务流程和 `OrderStatus`)*
*   **(复用或依赖的实体)**:
    *   `Order`, `OrderStatus`, `OrderItem` (来自 `Orders` 模块)
    *   `Product` (来自 `Product/Item` 模块)
    *   `ChatSession`, `ChatMessage` (来自 `Chat` 模块，但数据会被过滤)
    *   `Address` (来自 `Core/Shared`)

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`GetSellerDashboardDataUseCase`**: 获取卖家仪表盘数据。
    *   输入: `void`
    *   输出: `Either<Failure, SellerDashboardData>`
*   **`GetSellerProductListUseCase`**: 获取卖家管理的商品列表 (分页、筛选)。
    *   输入: `filter` (按状态等), `page`, `limit`
    *   输出: `Either<Failure, List<SellerManagedProduct>>`
*   **`CreateProductUseCase`**: 卖家创建新商品。
    *   输入: `productData` (包含名称、描述、价格、库存、图片等)
    *   输出: `Either<Failure, SellerManagedProduct>`
*   **`UpdateProductUseCase`**: 卖家更新商品信息。
    *   输入: `productId`, `updatedProductData`
    *   输出: `Either<Failure, SellerManagedProduct>`
*   **`UpdateProductStatusUseCase`**: 卖家修改商品状态 (上架/下架/归档)。
    *   输入: `productId`, `newStatus`
    *   输出: `Either<Failure, void>`
*   **`DeleteProductUseCase`**: 卖家删除商品。
    *   输入: `productId`
    *   输出: `Either<Failure, void>`
*   **`GetStoreProfileUseCase`**: 获取卖家店铺资料。
    *   输入: `void` (隐式使用当前卖家 ID)
    *   输出: `Either<Failure, SellerStoreProfile>`
*   **`UpdateStoreProfileUseCase`**: 更新卖家店铺资料。
    *   输入: `updatedProfileData`
    *   输出: `Either<Failure, SellerStoreProfile>`
*   **`GetSellerOrderListUseCase`**: 获取卖家订单列表 (分页、筛选)。
    *   输入: `filter` (按状态、买家、日期等), `page`, `limit`
    *   输出: `Either<Failure, List<SellerOrderSummary>>`
*   **`GetSellerOrderDetailUseCase`**: 获取卖家视角的订单详情。
    *   输入: `orderId`
    *   输出: `Either<Failure, SellerOrder>`
*   **`ShipOrderUseCase`**: 卖家标记订单发货并提供物流信息。
    *   输入: `orderId`, `carrier`, `trackingNumber`
    *   输出: `Either<Failure, void>` (成功后需刷新订单状态)
*   **`GetSellerChatSessionsUseCase`**: 获取卖家相关的聊天会话列表。
    *   输入: `void`
    *   输出: `Either<Failure, List<ChatSession>>` (复用 `Chat` 模块的实体，但数据源是过滤后的)

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`ISellerRepository`**: 定义卖家中心模块的核心数据访问接口。
    *   `Future<Either<Failure, SellerDashboardData>> getDashboardData()`
    *   `Future<Either<Failure, List<SellerManagedProduct>>> getSellerProductList(ProductFilter filter, int page, int limit)`
    *   `Future<Either<Failure, SellerManagedProduct>> createProduct(ProductCreationData data)`
    *   `Future<Either<Failure, SellerManagedProduct>> updateProduct(String productId, ProductUpdateData data)`
    *   `Future<Either<Failure, void>> updateProductStatus(String productId, ProductStatus newStatus)`
    *   `Future<Either<Failure, void>> deleteProduct(String productId)`
    *   `Future<Either<Failure, SellerStoreProfile>> getStoreProfile()`
    *   `Future<Either<Failure, SellerStoreProfile>> updateStoreProfile(StoreProfileUpdateData data)`
    *   `Future<Either<Failure, List<SellerOrderSummary>>> getSellerOrderList(SellerOrderFilter filter, int page, int limit)`
    *   `Future<Either<Failure, SellerOrder>> getSellerOrderDetail(String orderId)`
    *   `Future<Either<Failure, void>> shipOrder(String orderId, String carrier, String trackingNumber)`
*   **(依赖接口 - 由其他模块定义或位于 Core/Shared):**
    *   `IProductRepository` (Product/Item): 可能提供基础的商品操作或验证。
    *   `IOrderRepository` (Orders): 可能提供基础的订单查询能力，`ISellerRepository` 在其上封装卖家视图。
    *   `IChatRepository` (Chat): 提供聊天会话和消息的查询能力。
    *   `IAuthRepository` (Auth): 获取卖家用户 ID。
    *   `IFileRepository` (Core/Shared): 上传商品图片、店铺 Logo 等。

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**:
    *   `Failure`, `Address`, 网络客户端, `IFileRepository`。
*   **`Auth` 模块**:
    *   强依赖，获取当前卖家用户 ID 和认证状态。
*   **`Product/Item` 模块**:
    *   依赖其 `Product` 实体定义，可能调用其 Repository 进行部分操作。
*   **`Orders` 模块**:
    *   依赖其 `Order`, `OrderStatus`, `OrderItem` 实体定义，可能调用其 Repository 获取基础订单数据。
*   **`Chat` 模块**:
    *   依赖其 `ChatSession`, `ChatMessage` 实体定义，调用其 Repository 获取过滤后的聊天数据。
*   **`Notification` 模块 (如果存在)**:
    *   新订单、新消息、退款请求等可能需要触发给卖家的通知。

### 4.2. 导航需求 (Navigation Needs)

`Seller` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToSellerProductList()`: 查看/管理商品列表。
*   `navigateToSellerProductEdit(productId?: String)`: 创建或编辑商品。
*   `navigateToSellerOrderList()`: 查看/管理订单列表。
*   `navigateToSellerOrderDetail(orderId: String)`: 查看订单详情。
*   `navigateToSellerStoreProfileEdit()`: 编辑店铺资料。
*   `navigateToSellerChatList()`: 查看卖家消息列表。
*   `navigateToChatRoom(sessionId: String)`: 进入与买家的聊天。
*   `navigateToAnalytics()`: (如果存在) 查看销售统计/分析。
*   `navigateToLogin()`: 访问卖家功能但未登录时。

---

**待确认/后续步骤:**

*   明确 `SellerManagedProduct` 与 `Product` 的具体关系（继承、组合、独立？）。
*   明确 `SellerOrderSummary`/`SellerOrder` 与 `OrderSummary`/`Order` 的具体关系。
*   确认卖家专属 API 端点（仪表盘、商品管理、店铺管理、订单管理、发货等）及其请求/响应结构。
*   细化卖家订单处理流程（除发货外，还有哪些操作？如处理退款请求）。
*   确定商品状态 (`SellerManagedProduct.status`) 的完整列表和含义。
*   确定卖家订单操作 (`SellerOrderAction`) 的完整列表和可用条件。
*   明确与 `Notification` 模块的集成方式（哪些事件需要通知卖家）。
*   确认是否有独立的卖家统计/分析功能需求。 