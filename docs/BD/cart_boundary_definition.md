# Cart 模块边界定义 (Boundary Definition)

本文档基于初步分析、React Native 源代码、HTML 原型、API 文档以及购物车业务逻辑，定义了 `Cart` 模块的边界。

## 1. 模块名称

`Cart` (购物车)

## 2. 核心业务能力 (Business Capability)

提供用户管理其意向购买商品集合的功能。包括：将商品添加到购物车、查看购物车中的商品列表、修改商品数量、移除商品、查看购物车摘要信息（如总价、商品数量），并最终启动结算（Checkout）流程。

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`Cart`**: 购物车整体状态实体。
    *   `id`: (String) 购物车唯一标识 (可能与用户 ID 关联)。
    *   `items`: (`List<CartItem>`) 购物车中的商品项列表。
    *   `summary`: (`CartSummary`) 购物车摘要信息。
    *   `appliedCoupon`: (`Coupon`?) 当前应用的优惠券 (可选)。
    *   `availableCoupons`: (`List<Coupon>`?) 可用的优惠券列表 (可选)。
*   **`CartItem`**: 购物车中的单个商品项。
    *   `id`: (String) 购物车项唯一标识。
    *   `productId`: (String) 商品 ID。
    *   `skuId`: (String?) 商品规格 ID (如果适用)。
    *   `quantity`: (int) 数量。
    *   `productSnapshot`: (`CartItemProductSnapshot`) 加入购物车时的商品信息快照。
    *   `currentPrice`: (Decimal?) 当前实时单价 (可选，可能从后端获取)。
    *   `lineTotal`: (Decimal?) 当前实时行总价 (可选)。
    *   `isAvailable`: (bool?) 当前是否可购买/有库存 (可选)。
    *   `validationMessages`: (`List<String>`?) 针对此项的验证信息 (如"库存不足", "价格已变更")。
*   **`CartItemProductSnapshot`**: 加入购物车时的商品信息快照，用于展示，避免因商品信息变更导致混乱。
    *   `name`: (String) 商品名称。
    *   `imageUrl`: (String?) 商品主图 URL。
    *   `skuDescription`: (String?) 规格描述。
    *   `priceAtAddition`: (Decimal) 加入时的单价。
*   **`CartSummary`**: 购物车摘要信息。
    *   `itemCount`: (int) 商品总数 (种类数)。
    *   `totalQuantity`: (int) 商品总件数。
    *   `subtotal`: (Decimal) 商品金额小计。
    *   `discountAmount`: (Decimal) 折扣金额。
    *   `shippingEstimate`: (Decimal?) 运费估算 (可选)。
    *   `taxEstimate`: (Decimal?) 税费估算 (可选)。
    *   `total`: (Decimal) 最终合计金额。
*   **`Coupon`**: (可选) 优惠券实体 (可能定义在 `Promotion` 或 `Core` 模块)。
    *   `id`, `code`, `description`, `discountValue`, `conditions`, etc.
*   **`CartValidationResult`**: (可选) 购物车整体校验结果。
    *   `isValidForCheckout`: (bool)
    *   `globalMessages`: (`List<String>`) 全局提示 (如"部分商品已失效")。
    *   `itemValidationResults`: (Map<String, List<String>>?) 各项商品的校验结果。

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`GetCartUseCase`**: 获取当前用户的购物车内容和状态。
    *   输入: `void`
    *   输出: `Either<Failure, Cart>` (可能返回 Stream 以便实时更新)
*   **`AddToCartUseCase`**: 将指定商品（及规格）添加到购物车。
    *   输入: `productId` (String), `skuId` (String?), `quantity` (int)
    *   输出: `Either<Failure, void>` (成功后需要触发购物车状态更新)
*   **`UpdateCartItemQuantityUseCase`**: 更新购物车中某项商品的数量。
    *   输入: `cartItemId` (String), `newQuantity` (int)
    *   输出: `Either<Failure, void>` (成功后需触发更新)
*   **`RemoveFromCartUseCase`**: 从购物车中移除一项或多项商品。
    *   输入: `cartItemIds` (`List<String>`)
    *   输出: `Either<Failure, void>` (成功后需触发更新)
*   **`ClearCartUseCase`**: 清空购物车。
    *   输入: `void`
    *   输出: `Either<Failure, void>` (成功后需触发更新)
*   **`ApplyCouponUseCase`**: (可选) 应用优惠券到购物车。
    *   输入: `couponCode` (String)
    *   输出: `Either<Failure, Cart>` (返回应用优惠券后的购物车状态)
*   **`RemoveCouponUseCase`**: (可选) 移除当前应用的优惠券。
    *   输入: `couponCode` (String)
    *   输出: `Either<Failure, Cart>`
*   **`ProceedToCheckoutUseCase`**: 启动结算流程。
    *   输入: (可能包含选中的 `cartItemIds` - 如果支持部分结算, `selectedAddressId`?, `selectedShippingMethodId`? - 取决于结算流程设计)
    *   输出: `Either<Failure, CheckoutPreview/PreOrderInfo>` (返回结算预览信息或预订单 ID，表明成功移交控制权给结算/订单流程)

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`ICartRepository`**: 定义购物车模块的数据访问接口。
    *   `Future<Either<Failure, Cart>> getCart()`: 获取购物车状态 (可能结合本地缓存和远程 API)。
    *   `Future<Either<Failure, void>> addToCart(String productId, String? skuId, int quantity)`: 调用 API 添加商品。
    *   `Future<Either<Failure, void>> updateItemQuantity(String cartItemId, int newQuantity)`: 调用 API 更新数量。
    *   `Future<Either<Failure, void>> removeItem(String cartItemId)`: 调用 API 移除单项。
    *   `Future<Either<Failure, void>> removeItems(List<String> cartItemIds)`: 调用 API 移除多项。
    *   `Future<Either<Failure, void>> clearCart()`: 调用 API 清空购物车。
    *   `Future<Either<Failure, Cart>> applyCoupon(String couponCode)`: 调用 API 应用优惠券。
    *   `Future<Either<Failure, Cart>> removeCoupon(String couponCode)`: 调用 API 移除优惠券。
    *   `Future<Either<Failure, CheckoutPreview/PreOrderInfo>> initiateCheckout(CheckoutRequestData data)`: 调用 API 启动结算。
*   **(依赖接口 - 由其他模块定义或位于 Core/Shared):**
    *   `IProductRepository` (Product/Item): 获取商品实时价格、库存、有效性等信息，用于校验和展示。
    *   `IAuthRepository` (Auth): 获取当前用户 ID。
    *   `ICouponRepository` (Promotion/Core): (如果优惠券逻辑复杂) 获取可用优惠券，验证优惠券有效性。

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**:
    *   依赖通用的 `Failure` 定义, 网络客户端, 本地缓存 (可能用于存储购物车 ID 或离线购物车)。
*   **`Auth` 模块**:
    *   强依赖，需要用户认证状态和 `userId` 来管理其购物车。
*   **`Product/Item` 模块**:
    *   依赖 `productId`, `skuId`。需要调用 `IProductRepository` 获取商品信息（特别是实时价格、库存状态、是否下架）用于展示、计算和验证。
*   **`Promotion/Coupon` 模块 (如果存在)**:
    *   如果优惠券逻辑复杂，需要依赖此模块获取和验证优惠券。

### 4.2. 导航需求 (Navigation Needs)

`Cart` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToProductDetail(productId: String)`: 从购物车项点击商品图片或名称，跳转到商品详情页。
*   `navigateToCheckout(checkoutInfo: CheckoutPreview/PreOrderInfo)`: 成功启动结算后，跳转到结算页面（可能属于 `Checkout` 或 `Orders` 模块）。
*   `navigateToLogin()`: 用户尝试访问或操作购物车但未登录时。
*   `continueShopping()`: 点击"继续购物"按钮，通常返回上一页或跳转到首页/分类页。

---

**待确认/后续步骤:**

*   确认购物车状态同步机制：是实时 API 调用，还是本地优先+后台同步？
*   确认 `GET /api/cart` 返回的完整数据结构，以及是否包含实时价格和库存。
*   确认购物车操作 API (add, update, remove) 的具体端点和参数。
*   明确库存检查的触发时机和实现方式（是在加车时检查，还是在结算前统一检查？）。
*   明确价格计算（小计、折扣、总计）是在前端估算，还是完全依赖后端 API 返回？
*   确认 `POST /api/cart/checkout` 的请求参数和响应内容，明确 `Cart` 模块的职责终点和传递给下一阶段（Checkout/Order）的数据。
*   明确优惠券应用逻辑和相关 API（如果支持）。
*   是否支持离线购物车？如果支持，缓存和同步策略是什么？ 