# Orders 模块边界定义 (Boundary Definition)

本文档基于初步分析、React Native 源代码、HTML 原型、API 文档以及电商业务特点，定义了 `Orders` 模块的边界。

## 1. 模块名称

`Orders` (订单)

## 2. 核心业务能力 (Business Capability)

负责用户查询和管理自己的历史订单及当前订单。核心功能包括：按状态筛选和分页查看订单列表、查看特定订单的详细信息（商品、价格、地址、状态、物流）、执行有限的操作（如确认收货、取消订单 - 取决于订单状态和业务规则）。

*(注意：订单的创建（下单）流程通常由 `Cart` 或 `Checkout` 模块负责，本模块专注于已存在订单的管理。)*

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`Order`**: 订单核心实体。
    *   `id`: (String) 订单唯一标识。
    *   `orderNumber`: (String) 订单号。
    *   `status`: (`OrderStatus`) 订单当前状态。
    *   `statusHistory`: (`List<OrderStatusUpdate>`) 订单状态变更历史 (可选)。
    *   `items`: (`List<OrderItem>`) 订单包含的商品项。
    *   `shippingAddress`: (`Address`) 收货地址信息。
    *   `billingAddress`: (`Address`?) 账单地址信息 (可选)。
    *   `paymentInfo`: (`OrderPaymentInfo`) 支付相关信息。
    *   `priceSummary`: (`OrderPriceSummary`) 价格明细。
    *   `shippingInfo`: (`OrderShippingInfo`) 物流配送信息。
    *   `createdAt`: (DateTime) 订单创建时间。
    *   `updatedAt`: (DateTime) 订单最后更新时间。
    *   `cancelInfo`: (`OrderCancelInfo`?) 取消信息 (如果已取消)。
    *   `actions`: (`List<OrderAction>`) 当前状态下允许用户执行的操作。
*   **`OrderSummary`**: 用于订单列表展示的简化实体。
    *   `id`: (String)
    *   `orderNumber`: (String)
    *   `status`: (`OrderStatus`)
    *   `previewItems`: (`List<OrderItemPreview>`) 商品预览 (可能仅第一个或前几个)。
    *   `totalAmount`: (Decimal) 订单总金额。
    *   `itemCount`: (int) 商品总数。
    *   `createdAt`: (DateTime)
    *   `actions`: (`List<OrderAction>`)
*   **`OrderItem`**: 订单中的商品项。
    *   `id`: (String) 订单项唯一标识。
    *   `productId`: (String) 关联的产品 ID。
    *   `productName`: (String) 商品名称。
    *   `skuId`: (String?) 商品规格 ID (如有)。
    *   `skuDescription`: (String?) 规格描述 (如"红色，XL")。
    *   `imageUrl`: (String) 商品图片 URL。
    *   `quantity`: (int) 购买数量。
    *   `unitPrice`: (Decimal) 商品单价。
    *   `totalPrice`: (Decimal) 商品总价。
*   **`OrderItemPreview`**: 订单列表中商品预览的更简化版本。
    *   `productId`: (String)
    *   `productName`: (String)
    *   `imageUrl`: (String)
*   **`OrderStatus`**: 订单状态 (枚举)。示例值：
    *   `pendingPayment` (待付款)
    *   `processing` (待发货/处理中)
    *   `shipped` (已发货/待收货)
    *   `delivered` (已送达 - 待确认收货)
    *   `completed` (已完成)
    *   `cancelled` (已取消)
    *   `pendingRefund` (退款中)
    *   `refunded` (已退款)
    *   *(具体值需根据业务和 API 确定)*
*   **`OrderAction`**: 订单允许的操作 (枚举)。示例值：
    *   `pay` (去支付)
    *   `cancel` (取消订单)
    *   `confirmReceipt` (确认收货)
    *   `viewTracking` (查看物流)
    *   `requestRefund` (申请售后/退款)
    *   `rebuy` (再次购买)
    *   `rate` (评价晒单)
    *   *(具体值和可用性取决于 `OrderStatus`)*
*   **`Address`**: 地址信息 (可能为 `Core/Shared` 模块的共享实体)。
    *   `recipientName`, `phone`, `street`, `city`, `state`, `postalCode`, `country`, etc.
*   **`OrderPaymentInfo`**: 支付信息。
    *   `method`: (String) 支付方式 (如"微信支付", "支付宝", "银行卡")。
    *   `status`: (枚举: `paid`, `unpaid`, `refunded`) 支付状态。
    *   `transactionId`: (String?) 支付流水号。
    *   `paidAt`: (DateTime?) 支付时间。
*   **`OrderPriceSummary`**: 价格汇总。
    *   `itemsTotal`: (Decimal) 商品总价。
    *   `shippingFee`: (Decimal) 运费。
    *   `discountAmount`: (Decimal) 优惠金额。
    *   `taxAmount`: (Decimal) 税费 (如有)。
    *   `totalAmount`: (Decimal) 订单总计金额。
*   **`OrderShippingInfo`**: 物流配送信息。
    *   `method`: (String) 配送方式 (如"快递", "自提")。
    *   `carrier`: (String?) 承运商。
    *   `trackingNumber`: (String?) 物流单号。
    *   `estimatedDeliveryDate`: (DateTime?) 预计送达日期。
    *   `trackingUpdates`: (`List<TrackingUpdate>`?) 物流轨迹更新。
*   **`TrackingUpdate`**: 单条物流轨迹信息。
    *   `timestamp`: (DateTime)
    *   `location`: (String?)
    *   `description`: (String)
*   **`OrderFilter`**: 订单列表筛选条件。
    *   `status`: (`OrderStatus`?) 按状态筛选。
    *   `searchTerm`: (String?) 按订单号、商品名称搜索。
    *   `dateRange`: (`DateRange`?) 按下单时间范围筛选。

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`GetOrderListUseCase`**: 获取用户订单列表（分页）。
    *   输入: `filter` (OrderFilter), `page` (int), `limit` (int)
    *   输出: `Either<Failure, List<OrderSummary>>`
*   **`GetOrderDetailUseCase`**: 获取指定订单的详细信息。
    *   输入: `orderId` (String)
    *   输出: `Either<Failure, Order>`
*   **`CancelOrderUseCase`**: 用户请求取消订单 (仅在特定状态下允许)。
    *   输入: `orderId` (String), `reason` (String?)
    *   输出: `Either<Failure, void>` (成功后需要刷新订单详情或列表)
*   **`ConfirmOrderReceiptUseCase`**: 用户确认收到订单货品。
    *   输入: `orderId` (String)
    *   输出: `Either<Failure, void>` (成功后需要刷新订单详情或列表)
*   **`GetOrderTrackingInfoUseCase`**: 获取订单的实时物流跟踪信息。
    *   输入: `orderId` (String)
    *   输出: `Either<Failure, OrderShippingInfo>` (或 `List<TrackingUpdate>`)
*   **(潜在/可选 Use Cases)**
    *   `RebuyOrderUseCase`: 将某个订单的商品重新加入购物车。
    *   `GetOrderActionsUseCase`: 获取某个订单当前允许的操作列表 (如果 `Order` 实体不直接包含)。

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IOrderRepository`**: 定义订单模块的数据访问接口。
    *   `Future<Either<Failure, List<OrderSummary>>> getOrderList(OrderFilter filter, int page, int limit)`: 获取订单摘要列表。
    *   `Future<Either<Failure, Order>> getOrderDetail(String orderId)`: 获取订单详情。
    *   `Future<Either<Failure, void>> cancelOrder(String orderId, String? reason)`: 调用 API 取消订单。
    *   `Future<Either<Failure, void>> confirmOrderReceipt(String orderId)`: 调用 API 确认收货。
    *   `Future<Either<Failure, OrderShippingInfo>> getOrderTrackingInfo(String orderId)`: 调用 API 获取物流信息。
    *   *(可能需要监听订单状态变更的推送或提供刷新机制)*

*   **(依赖接口 - 由其他模块定义，供 `IOrderRepository` 实现层使用):**
    *   `IProductRepository` (来自 `Product/Item` 模块): 可能需要调用此接口来补充订单项中缺失的商品信息（如果 API 不返回完整信息）。
    *   `IAuthRepository` / `IUserRepository` (来自 `Auth` / `Profile` 模块): 获取当前用户 ID 以便 API 调用时过滤订单。

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**:
    *   依赖通用的 `Failure`, `Address` 实体 (如果共享), 网络客户端, 日期/金额格式化工具等。
*   **`Auth` 模块**:
    *   强依赖。需要获取当前登录用户的 `userId` 以便查询其名下的订单。
*   **`Product/Item` 模块**:
    *   依赖 `productId`。可能需要通过 `IProductRepository` 获取最新的商品信息（如名称、图片）用于展示，或者依赖订单 API 返回足够的信息。
*   **`Payment` 模块 (如果存在)**:
    *   订单状态（如从未支付到处理中）可能依赖于 `Payment` 模块的支付成功事件/回调。
    *   订单详情中"去支付"操作可能需要调用 `Payment` 模块的接口。
*   **`AfterSale/Refund` 模块 (如果存在)**:
    *   订单详情中的"申请售后/退款"操作会导航或调用此模块。
    *   订单状态可能包含退款相关的状态。
*   **`Rating/Review` 模块 (如果存在)**:
    *   订单详情中的"评价晒单"操作会导航或调用此模块。

### 4.2. 导航需求 (Navigation Needs)

`Orders` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToOrderDetail(orderId: String)`: 从订单列表跳转到详情。
*   `navigateToProductDetail(productId: String)`: 从订单项跳转到商品详情。
*   `navigateToTrackingDetail(orderId: String)`: 查看物流详情。
*   `navigateToPayment(orderId: String)`: 对于待支付订单，跳转到支付流程。
*   `navigateToAfterSale(orderId: String, orderItemId: String?)`: 跳转到售后申请页面。
*   `navigateToRating(orderId: String)`: 跳转到评价页面。
*   `navigateToHelp/Support(orderId: String)`: 跳转到客服或帮助中心。
*   `navigateToLogin()`: 访问订单相关页面但未登录时。

---

**待确认/后续步骤:**

*   精确定义 `OrderStatus` 的所有可能值及其流转规则。
*   精确定义 `OrderAction` 的所有可能值以及它们在不同 `OrderStatus` 下的可用性。
*   确认订单列表和详情 API 返回的具体数据结构，特别是 `OrderSummary` 和 `Order` 实体的最终字段。
*   确认订单取消、确认收货、获取物流等操作的 API 端点和参数。
*   明确订单创建流程与 `Cart/Checkout` 模块的分工。
*   明确支付流程与 `Payment` 模块（如果独立）的交互方式。
*   明确售后/退款流程与 `AfterSale/Refund` 模块（如果独立）的交互方式。
*   明确评价流程与 `Rating/Review` 模块（如果独立）的交互方式。 