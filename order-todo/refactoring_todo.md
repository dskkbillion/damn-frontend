# Orders 模块重构 TODO 清单

本清单遵循 `docs/模块开发核心工作流.md`，并结合对 RN 代码和 API 的具体分析结果 (`order-todo/rn_analysis_summary.md`, `order-todo/orders_boundary_definition_final.md`)，指导 `Orders` 模块的 Flutter 重构过程。

**目标:** 实现一个功能完整、代码清晰、可测试、遵循 Clean Architecture 的 Flutter `Orders` 模块。

---

**前期准备 (已完成)**

*   [x] **步骤 1: 选择模块:** 已确定重构 `Orders` 模块。
*   [x] **步骤 2: 定义模块边界 (初步):** 已完成初步边界定义 (`docs/BD/orders_boundary_definition.md`)。
*   [x] **步骤 3: 分析参考代码:** 已完成 RN 代码 (`design-info/demo-repository`) 和 API (`design-info/api/backend-api.json`) 的分析。
*   [x] **步骤 2/4: 定义/精化模块边界 (最终):** 已生成最终边界定义 (`order-todo/orders_boundary_definition_final.md`) 和分析总结 (`order-todo/rn_analysis_summary.md`)。

---

**Flutter 实现阶段**

**步骤 4: 精化 `Domain` 层接口 (Flutter)**

*   `lib/features/orders/domain/entities/`
    *   [ ] 定义 `order_status.dart`: 创建 `OrderStatus` 枚举，包含最终确定的状态值 (如 `awaitingPayment`, `awaitingSubmission`, ...)，建议包含一个从字符串转换的工厂构造函数或方法。添加 DartDoc。
    *   [ ] 定义 `order_action.dart`: 创建 `OrderAction` 枚举，包含最终确定的操作值 (如 `cancel`, `confirmReceipt`, ...)。添加 DartDoc。
    *   [ ] 定义 `address.dart`: 定义 `Address` 实体 (如果尚未在 `Core/Shared` 中定义)，包含 `recipientName`, `phone`, `areaId`, `detailAddress`。添加 DartDoc。
    *   [ ] 定义 `order_item.dart`: 创建 `OrderItem` 实体，包含 `id`, `orderId`, `productId`, `productName`, `skuId`, `skuName`, `imageUrl`, `quantity`, `price`, `totalPrice`。添加 DartDoc。
    *   [ ] 定义 `order_shipping_info.dart`: 创建 `OrderShippingInfo` 实体，包含 `logisticsId` (int?), `logisticsNo` (String?), `deliveryTime` (DateTime?)。**注意: 不包含 `trackingUpdates`。** 添加 DartDoc。
    *   [ ] 定义 `order_payment_info.dart`: 创建 `OrderPaymentInfo` 实体，包含 `payStatus` (bool), `payTime` (DateTime?), `payChannelCode` (String?)。添加 DartDoc。
    *   [ ] 定义 `order_price_summary.dart`: 创建 `OrderPriceSummary` 实体，包含 `totalPrice`, `discountPrice`, `deliveryPrice`, `payPrice` (均为 Decimal/double)。添加 DartDoc。
    *   [ ] 定义 `order.dart`: 创建核心 `Order` 实体，整合所有字段 (`id`, `orderSn`, `state` (OrderStatus), `orderType`, `items` (List<OrderItem>), `shippingAddress` (Address), `priceSummary`, `paymentInfo`, `shippingInfo`, `createdAt`, `completeTime`, `cancelTime`, `buyerRemark` 等)。**不包含 `actions` 字段 (应在 Presentation 推断)。** 添加 DartDoc。
*   `lib/features/orders/domain/repositories/`
    *   [ ] 定义 `i_order_repository.dart`: 创建 `IOrderRepository` 接口，定义方法：
        *   `Future<Either<Failure, List<Order>>> getOrderList({OrderStatus? status, String? keyword, required int page, required int limit})`
        *   `Future<Either<Failure, Order>> getOrderDetail(int orderId)`
        *   `Future<Either<Failure, void>> cancelOrder(int orderId)`
        *   `Future<Either<Failure, void>> confirmOrderReceipt(int orderId)`
        *   `Future<Either<Failure, void>> deleteOrder(int orderId)`
        *   *(可选: 根据需要添加其他方法，如 `submitMaterials`, `evaluate`)*
        *   确保所有方法签名和返回类型正确。添加清晰的 DartDoc。
*   `lib/features/orders/domain/usecases/`
    *   [ ] 定义 `get_order_list_use_case.dart`: 创建 `GetOrderListUseCase` 抽象类/接口及其 `call` 方法。
    *   [ ] 定义 `get_order_detail_use_case.dart`: 创建 `GetOrderDetailUseCase` 抽象类/接口及其 `call` 方法。
    *   [ ] 定义 `cancel_order_use_case.dart`: 创建 `CancelOrderUseCase` 抽象类/接口及其 `call` 方法。
    *   [ ] 定义 `confirm_order_receipt_use_case.dart`: 创建 `ConfirmOrderReceiptUseCase` 抽象类/接口及其 `call` 方法。
    *   [ ] 定义 `delete_order_use_case.dart`: 创建 `DeleteOrderUseCase` 抽象类/接口及其 `call` 方法。
    *   *(可选: 定义其他 Use Case 接口)*
    *   添加清晰的 DartDoc。

**步骤 5: 实现 Flutter `Data` 层**

*   `lib/features/orders/data/models/`
    *   [ ] 定义 `order_item_model.dart`: 创建匹配 API `items` 结构的 `OrderItemModel`，实现 `fromJson` 和 `toEntity()`。
    *   [ ] 定义 `order_model.dart`: 创建匹配 API 响应 (`GET /api/shop/order/detail` 和 `POST /api/shop/order/list` 中 `rows` 的项) 的 `OrderModel`。
        *   包含所有 API 字段 (包括 `state` 字符串、扁平化的地址字段、支付字段、物流字段、`items` (List<OrderItemModel>) 等)。
        *   实现 `fromJson` 工厂构造函数。
        *   实现 `toEntity()` 方法，正确映射到 `Order` 实体 (包括 `state` 字符串到 `OrderStatus` 枚举的转换，地址字段到 `Address` 实体的映射)。
*   `lib/features/orders/data/datasources/`
    *   [ ] 定义 `i_order_remote_data_source.dart`: 定义接口，包含与 `IOrderRepository` 方法对应的 API 调用方法 (返回 `Future<List<OrderModel>>`, `Future<OrderModel>`, `Future<void>`)。
    *   [ ] 定义 `order_remote_data_source_impl.dart`: 实现接口。
        *   注入 `Core` HTTP Client (`Dio`)。
        *   实现 `getOrderList`: 调用 `POST /api/shop/order/list`，正确构造请求体 (分页、状态字符串映射、keyword)。处理响应。
        *   实现 `getOrderDetail`: 调用 `GET /api/shop/order/detail`，传递 `id`。处理响应。
        *   实现 `cancelOrder`: 调用 `PUT /api/shop/order/cancel`。
        *   实现 `confirmOrderReceipt`: 调用 `PUT /api/shop/order/complete`。
        *   实现 `deleteOrder`: 调用 `DELETE /api/shop/order/delete`。
        *   处理网络和 API 错误，抛出特定异常 (如 `ServerException`)。
*   `lib/features/orders/data/repositories/`
    *   [ ] 定义 `order_repository_impl.dart`: 实现 `IOrderRepository`。
        *   注入 `IOrderRemoteDataSource` (和网络状态检查器，如果需要)。
        *   实现所有接口方法。
        *   在方法内部调用 `DataSource` 的对应方法。
        *   使用 `try-catch` 捕获 `DataSource` 抛出的异常，并将其映射为 `Domain` 层的 `Failure` 对象 (如 `ServerFailure`)。
        *   调用 `model.toEntity()` 将 `OrderModel` / `List<OrderModel>` 转换为 `Order` / `List<Order>`。
        *   返回 `Either<Failure, ResultType>`。

**步骤 6: 实现 Flutter `Domain` 逻辑 (Use Cases)**

*   `lib/features/orders/domain/usecases/`
    *   [ ] 实现 `get_order_list_use_case.dart`: 实现 `GetOrderListUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.getOrderList()`。
    *   [ ] 实现 `get_order_detail_use_case.dart`: 实现 `GetOrderDetailUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.getOrderDetail()`。
    *   [ ] 实现 `cancel_order_use_case.dart`: 实现 `CancelOrderUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.cancelOrder()`。
    *   [ ] 实现 `confirm_order_receipt_use_case.dart`: 实现 `ConfirmOrderReceiptUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.confirmOrderReceipt()`。
    *   [ ] 实现 `delete_order_use_case.dart`: 实现 `DeleteOrderUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.deleteOrder()`。
    *   *(可选: 实现其他 Use Case)*

**步骤 7: 实现 Flutter `Presentation` 层**

*   `lib/features/orders/presentation/bloc/` (或 `cubit/`, `provider/`)
    *   [ ] 实现 `order_list_state.dart`: 定义订单列表页的状态 (loading, error, hasMore, orders list, current status filter)。
    *   [ ] 实现 `order_list_bloc/cubit.dart`: 管理列表状态。注入 `GetOrderListUseCase`。处理加载、加载更多、切换状态 Tab 的事件。
    *   [ ] 实现 `order_detail_state.dart`: 定义订单详情页的状态 (loading, error, order object)。
    *   [ ] 实现 `order_detail_bloc/cubit.dart`: 管理详情状态。注入 `GetOrderDetailUseCase` 及相关操作 Use Cases (`CancelOrderUseCase`, etc.)。处理加载详情、执行订单操作的事件。
*   `lib/features/orders/presentation/widgets/`
    *   [ ] 实现 `order_item_card.dart`: 用于在列表中显示单个订单摘要的 Widget。
    *   [ ] 实现 `order_status_widget.dart`: 根据 `OrderStatus` 显示不同文本和样式的 Widget。
    *   [ ] 实现 `order_action_buttons.dart`: 根据当前订单状态 (`Order.state`) 推断并显示可用的操作按钮 (取消、确认收货、评价等)。
    *   *(可选: 实现其他通用 Widget)*
*   `lib/features/orders/presentation/pages/`
    *   [ ] 实现 `order_list_page.dart`:
        *   构建 UI，包含状态切换 Tabs (全部、待付款、处理中、待评价等)。
        *   使用 `BlocBuilder`/`Consumer` 连接 `OrderListBloc/Cubit`。
        *   显示订单列表 (`ListView`/`InfiniteScrollView`)，使用 `OrderItemCard`。
        *   实现下拉刷新和上拉加载更多。
        *   处理导航到 `OrderDetailPage`。
    *   [ ] 实现 `order_detail_page.dart`:
        *   构建 UI，参考 RN 页面布局。
        *   使用 `BlocBuilder`/`Consumer` 连接 `OrderDetailBloc/Cubit`。
        *   显示订单详细信息 (状态、商品列表、地址、价格、物流单号等)。
        *   根据状态显示 `OrderActionButtons`。
        *   将按钮事件连接到 `OrderDetailBloc/Cubit` 的相应事件。
        *   处理导航 (查看商品、联系卖家、去支付、去评价、去售后等)。

**步骤 8: 识别并配置外部依赖 (隔离开发)**

*   [ ] 识别需要 Mock 的外部依赖接口: `IAuthRepository`, `ICartRepository`, `IChatRepository`, `IAfterSaleRepository`, 导航服务等。
*   [ ] (测试阶段) 使用 `Mockito` 或类似工具生成这些接口的 Mock 类。
*   [ ] (预览阶段) 配置 DI 容器 (如 `GetIt`, `Provider`)，使其在特定环境 (如 `main_orders_preview.dart`) 下注入 Mock 实现。

**步骤 9: 编写单元/Widget 测试**

*   [ ] **Data Layer:**
    *   [ ] 测试 `OrderModel.fromJson` 和 `OrderModel.toEntity`。
    *   [ ] 测试 `OrderRepositoryImpl` (注入 Mock `DataSource`)。
    *   [ ] 测试 `OrderRemoteDataSourceImpl` (注入 Mock `DioAdapter`)。
*   [ ] **Domain Layer:**
    *   [ ] 测试所有 `UseCase` 实现 (注入 Mock `Repository`)。
*   [ ] **Presentation Layer:**
    *   [ ] 测试 `OrderListBloc/Cubit` 的状态转换 (注入 Mock `UseCases`)。
    *   [ ] 测试 `OrderDetailBloc/Cubit` 的状态转换和操作调用 (注入 Mock `UseCases`)。
    *   [ ] 编写 Widget 测试 (`OrderListPage`, `OrderDetailPage`)，验证基本渲染和交互 (注入 Mock `Blocs/Cubits`)。

**步骤 10: 在模块预览环境中调试和验证**

*   [ ] 创建 `main_orders_preview.dart`，配置使用 Mock 依赖的 DI。
*   [ ] 运行预览 App。
*   [ ] 手动测试订单列表的加载、滚动、筛选。
*   [ ] 手动测试导航到订单详情。
*   [ ] 手动测试订单详情在不同状态下的显示和操作按钮的可用性/行为 (使用 Mock 数据模拟不同状态)。
*   [ ] 验证 UI 与预期一致，交互流畅。

**步骤 11: 集成准备**

*   [ ] 确保所有 TODO 完成，测试通过，代码评审通过。
*   [ ] 准备将 `refactor/orders` 分支合并到主开发分支。

**步骤 12: 执行集成与测试**

*   [ ] 合并代码。
*   [ ] 更新主工程的 DI 配置，用真实的 Repository 实现替换 Mock。
*   [ ] 注册 `Orders` 模块的路由到主导航配置。
*   [ ] 执行集成测试和端到端 (E2E) 测试，验证 `Orders` 模块与其他模块 (Auth, Cart, Chat, AfterSale, Payment, Navigation) 的交互是否正常。

**步骤 13: 重复**

*   [ ] (可选) 清理特性分支。
*   [ ] 选择下一个要重构的模块。

---