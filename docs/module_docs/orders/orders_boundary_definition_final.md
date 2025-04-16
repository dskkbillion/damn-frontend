# Orders 模块边界定义 (最终版)

本文档基于初步分析、React Native 源代码 (`design-info/demo-repository`)、API 文档 (`design-info/api/backend-api.json`) 及实际代码调用分析，最终确定了 `Orders` 模块的边界。

## 1. 模块名称

`Orders` (订单)

## 2. 核心业务能力 (Business Capability)

负责用户查询和管理自己的历史订单及当前订单。核心功能包括：按状态筛选和分页查看订单列表、查看特定订单的详细信息（商品、价格、地址、状态、基础物流信息）、执行订单操作（如取消订单、确认收货、申请售后、评价、删除等）。

*(注意：订单的创建（下单）流程由 `Cart/Checkout` 模块负责。支付由独立的 `Payment` 模块/API 处理。)*

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`Order`**: 订单核心实体 (基于 `GET /api/shop/order/detail` 的实际返回结构)。
    *   `id`: (int) 订单唯一标识。
    *   `orderSn`: (String) 订单号。
    *   `state`: (`OrderStatus`) 订单当前状态 (后端返回字符串，前端映射为枚举)。
    *   `orderType`: (String?) 订单类型 (如 "NORMAL", "SECKILL")。
    *   `items`: (`List<OrderItem>`) 订单包含的商品项 (API 直接返回)。
    *   `shippingAddress`: (`Address`) 收货地址信息 (从 API 返回的扁平字段映射)。
        *   `receiverName`: (String)
        *   `receiverMobile`: (String)
        *   `receiverAreaId`: (String) 地区 ID
        *   `receiverDetailAddress`: (String) 详细地址
    *   `priceSummary`: (`OrderPriceSummary`) 价格明细。
        *   `totalPrice`: (Decimal) 商品总金额。
        *   `discountPrice`: (Decimal) 优惠金额。
        *   `deliveryPrice`: (Decimal) 运费。
        *   `payPrice`: (Decimal) 支付金额。
    *   `paymentInfo`: (`OrderPaymentInfo`) 支付相关信息。
        *   `payStatus`: (bool) 是否支付。
        *   `payTime`: (DateTime?) 支付时间。
        *   `payChannelCode`: (String?) 支付渠道 (如 "wx_lite", "alipay_app")。
    *   `shippingInfo`: (`OrderShippingInfo`) 物流配送信息 (基础信息，无实时轨迹)。
        *   `logisticsId`: (int?) 物流 ID。
        *   `logisticsNo`: (String?) 物流单号。
        *   `deliveryTime`: (DateTime?) 发货时间。
    *   `createdAt`: (DateTime) 订单创建时间。
    *   `completeTime`: (DateTime?) 订单完成时间。
    *   `cancelTime`: (DateTime?) 订单取消时间。
    *   `buyerRemark`: (String?) 买家备注。
    *   `actions`: (`List<OrderAction>`) 当前状态下允许用户执行的操作 (由前端根据 `state` 推断)。
    *   *(其他可能的字段，如卖家信息、售后标志等根据需要添加)*
*   **`OrderItem`**: 订单中的商品项 (基于 API 返回的 `items` 结构)。
    *   `id`: (int) 订单项 ID。
    *   `orderId`: (int) 关联的订单 ID。
    *   `productId`: (int) 关联的产品 ID (spuId)。
    *   `productName`: (String) 商品名称 (spuName)。
    *   `skuId`: (int) 商品规格 ID。
    *   `skuName`: (String?) 规格描述 (properties)。
    *   `imageUrl`: (String) 商品图片 URL (picUrl)。
    *   `quantity`: (int) 购买数量。
    *   `price`: (Decimal) 商品单价。
    *   `totalPrice`: (Decimal) 商品总价 (price * quantity)。
    *   *(其他可能的字段，如商品快照信息)*
*   **`OrderStatus`**: 订单状态 (枚举，映射后端字符串)。
    *   `awaitingPayment` (待付款)
    *   `awaitingSubmission` (买家待提交材料)
    *   `buyAwaitingSubmission` (卖家要求买家重传材料)
    *   `awaitingStart` (卖家待开始)
    *   `awaitingDelivery` (卖家待交付/待发货)
    *   `awaitingConfirmation` (买家待确认收货)
    *   `sellerSupplementaryMaterials` (卖家要求补充材料 - 平台介入前?)
    *   `applyForRefuse` (买家申请平台介入/拒绝?)
    *   `awaitingEvaluation` (待评价)
    *   `orderCompleted` (已完成)
    *   `canceled` (已取消)
    *   `afterSale` (售后中)
    *   `AfterSaleRejection` (售后拒绝)
    *   `applyingForMediation` (申请平台介入)
    *   *(注意: 需要根据业务逻辑进一步梳理和确认状态的完整性及流转关系)*
*   **`OrderAction`**: 订单允许的操作 (枚举，由前端逻辑根据 `OrderStatus` 推断)。
    *   `pay` (去支付 - 调用支付模块)
    *   `cancel` (取消订单 - 调用 `PUT /api/shop/order/cancel`)
    *   `submitMaterials` (提交材料 - 调用 `POST /api/project/orderMaterials/add`)
    *   `repostMaterials` (重传材料 - 导航)
    *   `confirmReceipt` (确认收货 - 调用 `PUT /api/shop/order/complete`)
    *   `viewTracking` (查看物流 - 可能仅展示 `logisticsNo`，无独立 API 调用)
    *   `requestRefund` (申请售后/退款 - 导航到售后模块/页面)
    *   `requestMediation` (申请平台介入 - 导航)
    *   `evaluate` (评价晒单 - 导航或调用 `POST /api/shop/order-evaluate/add`)
    *   `delete` (删除订单 - 调用 `DELETE /api/shop/order/delete`)
    *   `rebuy` (再次购买 - 调用购物车模块)
    *   `contactSeller` (联系卖家 - 调用聊天模块)
*   **`Address`**: 地址信息 (共享实体或在此定义)。
    *   `recipientName`: (String)
    *   `phone`: (String)
    *   `areaId`: (String) // 可能需要映射为省市区
    *   `detailAddress`: (String)
*   **`OrderFilter`**: 订单列表筛选条件。
    *   `status`: (`OrderStatus`?) 按状态筛选。
    *   `keyword`: (String?) 按订单号、商品名称搜索。
    *   *(注意: RN 实现中按状态筛选是通过不同索引/标签页实现的，`keyword` 仅在 "全部" 状态下使用)*

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`GetOrderListUseCase`**: 获取用户订单列表（分页）。
    *   输入: `status` (OrderStatus?), `keyword` (String?), `page` (int), `limit` (int)
    *   输出: `Either<Failure, List<Order>>` (API 直接返回详细订单列表)
*   **`GetOrderDetailUseCase`**: 获取指定订单的详细信息。
    *   输入: `orderId` (int)
    *   输出: `Either<Failure, Order>` (API 返回完整信息)
*   **`CancelOrderUseCase`**: 用户请求取消订单。
    *   输入: `orderId` (int)
    *   输出: `Either<Failure, void>`
*   **`ConfirmOrderReceiptUseCase`**: 用户确认收到订单货品。
    *   输入: `orderId` (int)
    *   输出: `Either<Failure, void>`
*   **`DeleteOrderUseCase`**: 用户删除订单。
    *   输入: `orderId` (int)
    *   输出: `Either<Failure, void>`
*   **(潜在/需要其他模块支持的 Use Cases)**
    *   `SubmitOrderMaterialsUseCase` (调用 `/api/project/orderMaterials/add`)
    *   `EvaluateOrderUseCase` (调用 `/api/shop/order-evaluate/add`)
    *   `RebuyOrderUseCase` (调用 `Cart` 模块)
    *   `ContactSellerUseCase` (调用 `Chat` 模块)
    *   `RequestRefundUseCase` (调用 `AfterSale/Refund` 模块)

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IOrderRepository`**: 定义订单模块的数据访问接口。
    *   `Future<Either<Failure, List<Order>>> getOrderList({OrderStatus? status, String? keyword, required int page, required int limit})`: 获取订单列表。
    *   `Future<Either<Failure, Order>> getOrderDetail(int orderId)`: 获取订单详情。
    *   `Future<Either<Failure, void>> cancelOrder(int orderId)`: 调用 API 取消订单。
    *   `Future<Either<Failure, void>> confirmOrderReceipt(int orderId)`: 调用 API 确认收货 (`/complete`)。
    *   `Future<Either<Failure, void>> deleteOrder(int orderId)`: 调用 API 删除订单。
    *   *(其他接口根据需要添加，如提交材料、评价等)*

*   **(依赖接口 - 由其他模块定义，供 `IOrderRepository` 实现层使用):**
    *   `IAuthRepository` / `IUserRepository` (来自 `Auth` / `Profile` 模块): 获取当前用户 ID 或 Token。
    *   *(注意: 获取商品信息不需要依赖 `Product` 模块，API 已返回)*

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**: 依赖通用的 `Failure`, `Address` 实体 (如果共享), 网络客户端 (`Dio`), 日期/金额格式化工具等。
*   **`Auth` 模块**: 强依赖。需要用户认证状态和 Token 进行 API 调用。
*   **`Payment` 模块/API (`/api/payment`)**: "去支付"操作需要调用此模块/API。
*   **`AfterSale/Refund` 模块/API (`/api/shop/order-refund/*`)**: "申请售后/退款"、"申请平台介入" 操作会导航或调用此模块/API。订单状态包含退款相关状态。
*   **`Rating/Review` 模块/API (`/api/shop/order-evaluate/*`)**: "评价晒单" 操作会导航或调用此模块/API。
*   **`Cart` 模块**: "再次购买" 操作需要调用此模块。
*   **`Chat` 模块**: "联系卖家" 操作需要调用此模块。
*   **`File/Upload` 模块/API**: "提交材料" 等操作可能涉及文件上传。

### 4.2. 导航需求 (Navigation Needs)

`Orders` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToOrderDetail(orderId: int)`: 从订单列表跳转到详情。
*   `navigateToProductDetail(productId: int)`: 从订单项跳转到商品详情。
*   `navigateToPayment(orderId: int)`: 对于待支付订单，跳转到支付流程。
*   `navigateToAfterSale(orderId: int, type: String)`: 跳转到售后申请/平台介入页面。
*   `navigateToRating(orderId: int)`: 跳转到评价页面。
*   `navigateToChat(sellerId: String)`: 跳转到与卖家的聊天页面。
*   `navigateToRepostMaterials(orderId: int)`: 跳转到重传材料页面。
*   `navigateToLogin()`: 访问订单相关页面但未登录时。