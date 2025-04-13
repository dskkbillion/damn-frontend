# Orders 模块重构 TODO 清单

本清单遵循 `docs/模块开发核心工作流.md`，并结合对 RN 代码和 API 的具体分析结果 (`order-todo/rn_analysis_summary.md`, `order-todo/orders_boundary_definition_final.md`)，指导 `Orders` 模块的 Flutter 重构过程。

**目标:** 实现一个功能完整、代码清晰、可测试、遵循 Clean Architecture 的 Flutter `Orders` 模块 (**包含买/卖家视角，并整合基础的服务交付和售后功能**)。

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
    *   [x] 定义 `order_status.dart`: 创建 `OrderStatus` 枚举，包含最终确定的状态值 (如 `awaitingPayment`, `awaitingSubmission`, ...)，建议包含一个从字符串转换的工厂构造函数或方法。添加 DartDoc。
    *   [x] 定义 `order_action.dart`: 创建 `OrderAction` 枚举，包含最终确定的操作值 (如 `cancel`, `confirmReceipt`, ...)。添加 DartDoc。
    *   [x] 定义 `address.dart`: 定义 `Address` 实体 (如果尚未在 `Core/Shared` 中定义)，包含 `recipientName`, `phone`, `areaId`, `detailAddress`。添加 DartDoc。
    *   [x] 定义 `order_item.dart`: 创建 `OrderItem` 实体，包含 `id`, `orderId`, `productId`, `productName`, `skuId`, `skuName`, `imageUrl`, `quantity`, `price`, `totalPrice`。添加 DartDoc。
    *   [x] 定义 `order_shipping_info.dart`: 创建 `OrderShippingInfo` 实体，包含 `logisticsId` (int?), `logisticsNo` (String?), `deliveryTime` (DateTime?)。**注意: 不包含 `trackingUpdates`。** 添加 DartDoc。
    *   [x] 定义 `order_payment_info.dart`: 创建 `OrderPaymentInfo` 实体，包含 `payStatus` (bool), `payTime` (DateTime?), `payChannelCode` (String?)。添加 DartDoc。
    *   [x] 定义 `order_price_summary.dart`: 创建 `OrderPriceSummary` 实体，包含 `totalPrice`, `discountPrice`, `deliveryPrice`, `payPrice` (均为 Decimal/double)。添加 DartDoc。
    *   [x] 定义 `order.dart`: 创建核心 `Order` 实体，整合所有字段 (`id`, `orderSn`, `state` (OrderStatus), `orderType`, `items` (List<OrderItem>), `shippingAddress` (Address), `priceSummary`, `paymentInfo`, `shippingInfo`, `createdAt`, `completeTime`, `cancelTime`, `buyerRemark` 等)。**不包含 `actions` 字段 (应在 Presentation 推断)。** 添加 DartDoc。
    *   [ ] (`OrderStatus` 枚举) 确认并统一 `AfterSaleRejection` 的命名风格。
    *   [ ] (`OrderStatus` 枚举) 澄清 `sellerSupplementaryMaterials`, `applyForRefuse` 等状态的确切含义。
    *   [x] (**实体层**) 根据 API 响应和 UI 需求，决定是否/如何定义 `DeliveryInfo` / `DeliveryRecord` 实体，或将交付信息直接添加到 `Order` / `OrderShippingInfo`。
    *   [x] (**售后实体**) 定义售后相关的实体，例如 `AfterSalesApplication` (`lib/features/after_sales/domain/entities/after_sales_application.dart`)。
*   `lib/features/orders/domain/repositories/`
    *   [x] 定义 `i_order_repository.dart`: 创建 `IOrderRepository` 接口，定义方法：
        *   `Future<Either<Failure, List<Order>>> getOrderList({OrderStatus? status, String? keyword, required int page, required int limit})`
        *   `Future<Either<Failure, Order>> getOrderDetail(int orderId)`
        *   `Future<Either<Failure, void>> cancelOrder(int orderId)`
        *   `Future<Either<Failure, void>> confirmOrderReceipt(int orderId)`
        *   `Future<Either<Failure, void>> deleteOrder(int orderId)`
        *   *(可选: 根据需要添加其他方法，如 `submitMaterials`, `evaluate`)*
        *   确保所有方法签名和返回类型正确。添加清晰的 DartDoc。
        *   [x] 添加 `saveRequirementDraft` 和 `submitRequirements` 方法签名。
        *   [x] (**扩展 `IOrderRepository`**) 添加售后相关操作的方法 (如 `applyRefund`, `getAfterSaleStatus`)。 (注：现已独立为 `IAfterSalesRepository`)
        *   [x] (**售后仓库接口**) 创建 `IAfterSalesRepository` (`lib/features/after_sales/domain/repositories/i_after_sales_repository.dart`) 定义核心售后操作接口。
    *   [x] (**扩展 `IOrderRepository`**) 根据需要（如果 API 没有在订单详情中返回足够信息），添加获取交付详情/历史的方法。
*   `lib/features/orders/domain/usecases/`
    *   [x] 定义 `get_order_list_use_case.dart`: 创建 `GetOrderListUseCase` 抽象类/接口及其 `call` 方法。
    *   [x] 定义 `get_order_detail_use_case.dart`: 创建 `GetOrderDetailUseCase` 抽象类/接口及其 `call` 方法。
    *   [x] 定义 `cancel_order_use_case.dart`: 创建 `CancelOrderUseCase` 抽象类/接口及其 `call` 方法。
    *   [x] 定义 `confirm_order_receipt_use_case.dart`: 创建 `ConfirmOrderReceiptUseCase` 抽象类/接口及其 `call` 方法。
    *   [x] 定义 `delete_order_use_case.dart`: 创建 `DeleteOrderUseCase` 抽象类/接口及其 `call` 方法。
    *   [x] (**添加 `@injectable`**) 为所有相关的 UseCase (GetOrderList, GetOrderDetail, CancelOrder, ConfirmOrderReceipt, DeleteOrder) 添加注解。
    *   [x] (**定义/实现 UseCase**) 创建 `SaveRequirementDraftUseCase` 和 `SubmitRequirementsUseCase` 骨架 (包含 Params, @injectable)。
        *   [ ] (**重构/移除**) 根据 DataSource 层 `saveRequirementDraft` 的处理方式 (改为本地存储)，调整或移除 `SaveRequirementDraftUseCase`。
    *   [x] (**实现 UseCase 逻辑**) 实现 `SaveRequirementDraftUseCase` 和 `SubmitRequirementsUseCase` 调用 Repository 方法。
    *   [ ] (**定义交付 UseCase?**) 在 `usecases/delivery/` 子目录下创建获取交付信息的 UseCase (依赖 `IOrderRepository`)。
    *   [x] (**定义售后 UseCase**) 在 `usecases/after_sale/` 子目录下创建处理售后申请、获取状态等的 UseCase (依赖 `IAfterSalesRepository`)
        *   [x] 创建 `apply_for_after_sale_use_case.dart` (包含 Params 类)。
        *   [x] 创建 `get_after_sales_list_use_case.dart` (包含 Params 类)。
        *   [x] 创建 `get_after_sales_detail_use_case.dart` (包含 Params 类)。
        *   [x] 创建 `cancel_after_sales_use_case.dart` (包含 Params 类)。
        *   [x] 创建 `delete_after_sales_use_case.dart` (包含 Params 类)。
        *   [ ] 创建 `respond_to_after_sale_use_case.dart` (卖家视角, 包含 Params 类)。
        *   [ ] 创建 `apply_for_mediation_use_case.dart` (包含 Params 类)。
        *   [x] 为所有已创建的售后 UseCase 添加 `@injectable` 注解。
    *   [ ] (**定义/实现 UseCase**) 定义并实现 获取交付物 等 UseCase，并添加 `@injectable`。
    *   添加清晰的 DartDoc。

**步骤 5: 实现 Flutter `Data` 层**

*   `lib/features/orders/data/models/`
    *   [x] 定义 `order_item_model.dart`: 创建匹配 API `items` 结构的 `OrderItemModel`，实现 `fromJson` 和 `toEntity()`。
    *   [x] 定义 `order_model.dart`: 创建匹配 API 响应 (`GET /api/shop/order/detail` 和 `POST /api/shop/order/list` 中 `rows` 的项) 的 `OrderModel`。
        *   包含所有 API 字段 (包括 `state` 字符串、扁平化的地址字段、支付字段、物流字段、`items` (List<OrderItemModel>) 等)。
        *   实现 `fromJson` 工厂构造函数。
        *   实现 `toEntity()` 方法，正确映射到 `Order` 实体 (包括 `state` 字符串到 `OrderStatus` 枚举的转换，地址字段到 `Address` 实体的映射)。
    *   [x] (**数据模型修正**) 根据 API 文档调整 `OrderModel`, `OrderItemModel`, 创建 `AddressModel`。
    *   [ ] (**售后模型 - 真实实现推迟**) 定义匹配 API 响应的售后数据模型 `AfterSalesApplicationModel` (`lib/features/after_sales/data/models/after_sales_application_model.dart`)，实现 `fromJson` 和 `toEntity` (文件已创建，待完善真实API对接)。
*   `lib/features/orders/data/datasources/`
    *   [x] 定义 `i_order_remote_data_source.dart`: 定义接口，包含与 `IOrderRepository` 方法对应的 API 调用方法 (返回 `Future<List<OrderModel>>`, `Future<OrderModel>`, `Future<void>`)。
        *   [x] (**API 核对**) 确认核心订单操作 (list, detail, complete, cancel, delete) 的正确 API 路径和 HTTP 方法。
        *   [x] (**API 核对**) 确认提交评价 API 为 `POST /api/shop/evaluate/add`。
        *   [x] (**API 核对**) 确认提交要求 API 为 `POST /api/project/orderMaterials/add`。
        *   [x] (**API 核对**) 确认无单独的保存草稿 API，逻辑应在客户端处理。
    *   [x] 定义 `order_remote_data_source_impl.dart`: 实现接口。
        *   注入 `Core` HTTP Client (`Dio`)。
        *   实现 `getOrderList`: 调用 `POST /api/shop/order/list`，正确构造请求体 (分页、状态字符串映射、keyword)。处理响应。
            *   [x] (**修正**) 根据 API 文档/示例，修正 `OrderStatus` 到 `states` 数组参数的映射逻辑。
        *   实现 `getOrderDetail`: 调用 `GET /api/shop/order/detail`，传递 `id`。处理响应。
        *   实现 `cancelOrder`: 调用 `PUT /api/shop/order/cancel`。
        *   实现 `confirmOrderReceipt`: 调用 `PUT /api/shop/order/complete`。
        *   实现 `deleteOrder`: 调用 `DELETE /api/shop/order/delete`。
        *   [ ] (**修改实现**) 根据 API 核对结果，修正 `confirmOrderReceipt`, `cancelOrder`, `deleteOrder` 的 HTTP 方法。
        *   [ ] (**修改实现**) 修改 `addEvaluation` 实现以匹配 `POST /api/shop/evaluate/add` (Body 对象)。
        *   [ ] (**修改实现**) 修改 `submitRequirements` 实现以匹配 `POST /api/project/orderMaterials/add` (Body 对象)。
        *   [ ] (**重构/移除**) 移除 `saveRequirementDraft` 或改为本地存储实现。
        *   处理网络和 API 错误，抛出特定异常 (如 `ServerException` - 已改为 ServerFailure)。
        *   [x] 添加 `saveRequirementDraft` 和 `submitRequirements` 方法签名。
        *   [x] (**调试**) 成功连接 `getOrderList` API，解决请求头(`clienttype`, `client`, `version`, `Authorization`)和响应解析 (`rows`) 问题。
    *   [x] (**数据模型修正**) 根据 API 文档调整 `OrderModel`, `OrderItemModel`, 创建 `AddressModel`。
    *   [x] 定义 `i_order_remote_data_source.dart`: ... (添加 `addEvaluation`)
    *   [x] 定义 `order_remote_data_source_impl.dart`: ... (根据 API 调整实现, 添加 `addEvaluation`, 添加 `@injectable`)
        *   [x] 添加 `saveRequirementDraft` 和 `submitRequirements` 的占位符实现。
    *   [ ] (**售后数据源接口 - 真实实现推迟**) 定义 `IAfterSalesRemoteDataSource` 接口 (`lib/features/after_sales/data/datasources/i_after_sales_remote_data_source.dart`) (文件已创建，待完善真实API对接)。
    *   [ ] (**售后数据源实现 - 真实实现推迟**) 定义 `AfterSalesRemoteDataSourceImpl` (`lib/features/after_sales/data/datasources/after_sales_remote_data_source.dart`)，实现接口，注入 `CoreDioClient`，调用后端 API (文件已创建基础，待完善真实API对接和错误处理)。
    *   [x] 定义 `i_order_local_data_source.dart`: 定义接口，包含获取、缓存、清除订单的方法。
    *   [x] 定义 `order_local_data_source_impl.dart`: 实现接口，注入 DAO/DB，处理实体/数据类映射。
*   `lib/features/orders/data/repositories/`
    *   [x] 定义 `order_repository_impl.dart`: 实现 `IOrderRepository`。
        *   注入 `IOrderRemoteDataSource` (和网络状态检查器，如果需要)。
        *   实现所有接口方法。
        *   在方法内部调用 `DataSource` 的对应方法。
        *   使用 `try-catch` 捕获 `DataSource` 抛出的异常，并将其映射为 `Domain` 层的 `Failure` 对象 (如 `ServerFailure`)。
        *   调用 `model.toEntity()` 将 `OrderModel` / `List<OrderModel>` 转换为 `Order` / `List<Order>`。
        *   返回 `Either<Failure, ResultType>`。
        *   [x] 实现 `saveRequirementDraft` 和 `submitRequirements` (调用 DataSource)。
        *   [x] (**缓存**) 根据 `docs/caching_and_local_storage_strategy_cn.md`，实现使用 `drift` 的订单列表缓存逻辑 ("缓存优先，网络回填")。
        *   [ ] (**缓存 - 下一步**) 实现订单详情的 `drift` 缓存逻辑。
    *   [x] 定义 `mocks/mock_order_repository.dart`: 添加基础 Mock 数据，包括 `awaitingConfirmation` 状态。
    *   [x] (`Mock 数据完善`) 添加 `MOCK004` (待收货)。
    *   [x] (`Mock 数据完善`) 添加 `MOCK005` (待提交)。
    *   [x] (**DI 配置**) 使用 `@injectable` 和 `@module` 完成核心依赖注册。
    *   [x] (**运行 `build_runner`**) 成功生成 `injection_container.config.dart`。
    *   [x] (**配置预览环境**) 在 `main_orders_preview.dart` 中覆盖 `IOrderRepository` 使用 Mock。
    *   [x] 实现 `saveRequirementDraft` 和 `submitRequirements` (Mock 实现)。
    *   [ ] (**实现 `OrderRepositoryImpl` - 真实实现推迟**) 实现订单相关的其他方法（如售后调用占位，未来可能移除或调整）。
    *   [ ] (**实现 `MockOrderRepository`**) 实现订单相关的其他方法 (Mock 逻辑)。
    *   [x] (**售后 Mock 实现**) 创建 `MockAfterSalesRepository` (`lib/features/after_sales/data/repositories/mocks/mock_after_sales_repository.dart`)，实现 `IAfterSalesRepository` 并提供 Mock 数据。
    *   [x] (**售后 Mock DI**) 配置依赖注入 (`injection.dart`)，在 `dev`/`test` 环境下注入 `MockAfterSalesRepository` 作为 `IAfterSalesRepository` 的实现 (通过注解和默认注册实现)。
    *   [ ] (**售后真实实现 - 推迟**) 创建 `AfterSalesRepositoryImpl` (`lib/features/after_sales/data/repositories/after_sales_repository_impl.dart`)，实现 `IAfterSalesRepository`，注入 `IAfterSalesRemoteDataSource` 和 `NetworkInfo` (文件待创建)。
    *   [ ] (**售后真实 DI - 推迟**) 配置依赖注入 (`injection.dart`)，在 `prod` 环境下注入 `AfterSalesRepositoryImpl`。
    *   [ ] (**NetworkInfo - 推迟**) 创建 `NetworkInfo` 接口和实现 (`lib/core/network/network_info.dart`)，使用 `connectivity_plus` 包。
    *   [ ] (**CoreDioClient - 推迟**) 配置 `CoreDioClient` (`lib/core/network/core_dio_client.dart`) 中的真实 `_baseUrl` 和认证拦截器。
        *   [x] (**初步配置**) 使用 `.env` 读取 Base URL。
        *   [x] (**初步配置**) 添加认证拦截器 (使用硬编码测试 Token)。
        *   [x] (**完善配置**) 实现从本地存储读取真实 Token 的逻辑。

**步骤 6: 实现 Flutter `Domain` 逻辑 (Use Cases)**

*   `lib/features/orders/domain/usecases/`
    *   [x] 实现 `get_order_list_use_case.dart`: 实现 `GetOrderListUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.getOrderList()`。
    *   [x] 实现 `get_order_detail_use_case.dart`: 实现 `GetOrderDetailUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.getOrderDetail()`。
    *   [x] 实现 `cancel_order_use_case.dart`: 实现 `CancelOrderUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.cancelOrder()`。
    *   [x] 实现 `confirm_order_receipt_use_case.dart`: 实现 `ConfirmOrderReceiptUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.confirmOrderReceipt()`。
    *   [x] 实现 `delete_order_use_case.dart`: 实现 `DeleteOrderUseCase`。注入 `IOrderRepository`。`call` 方法调用 `repository.deleteOrder()`。
    *   [x] (**实现 UseCase**) 实现 `SaveRequirementDraftUseCase`, `SubmitRequirementsUseCase` (调用 Repository)。
    *   [ ] (**实现交付 UseCase?**) 实现获取交付信息的 UseCase (如果定义了)。
    *   [x] (**实现售后 UseCase**) 实现 `usecases/after_sale/` 子目录下的 UseCase 逻辑 (调用 Repository) (已创建)。
    *   [ ] (**实现 UseCase**) 实现 获取交付物 等 UseCase 逻辑。

**步骤 7: 实现 Flutter `Presentation` 层**

*   **核心参考:** **`design-info/HTML原型/HTML-new`** 和 **买家/卖家视角截图**。
*   `lib/features/orders/presentation/bloc/`
    *   [x] 实现 `order_list_state.dart`: 定义订单列表页的状态 (loading, error, hasMore, orders list, current status filter)。
    *   [x] 实现 `order_list_bloc.dart`: 管理列表状态。注入 `GetOrderListUseCase`。处理加载、**加载更多**、切换状态 Tab 的事件。
        *   [x] (**分页**) 实现 `LoadMoreOrders` 事件及处理逻辑，追加数据并管理 `hasReachedMax`。
    *   [x] 实现 `order_detail_state.dart`: 定义订单详情页的状态 (loading, error, order object)。
        *   [x] 添加 `OrderDetailActionLoading`, `OrderDetailActionSuccess`, `OrderDetailActionFailure` 状态。
        *   [x] 在 `OrderDetailActionSuccess` 中添加 `actionType` 字段。
    *   [x] 实现 `order_detail_bloc.dart`: 管理详情状态。注入 `GetOrderDetailUseCase` 及相关操作 Use Cases (`CancelOrderUseCase`, etc.)。处理加载详情、执行订单操作的事件。
        *   [x] 添加 `OrderAction` 枚举值 (`submitRequirements`, `saveDraft`, `submitEvaluation`)。
        *   [x] (**实现动作处理**) 在 `_onOrderActionRequested` 中处理 Confirm/Cancel/Delete 事件，调用 UseCase 并发出 `ActionLoading/Success/Failure` 状态。
        *   [x] (**实现动作处理**) 在 `_onSubmitRequirementsSubmitted`, `_onSaveRequirementDraftRequested`, `_onSubmitEvaluationRequested` 成功时发出 `ActionSuccess` 状态 (包含 `actionType`)。
        *   [x] 添加 `@injectable` 注解。
        *   [x] (`OrderDetailBloc`) 添加 处理要求提交/保存草稿/提交评价 的事件和处理器骨架。
        *   [x] (`OrderDetailBloc`) **实现处理器逻辑:** (评价提交, 要求提交, 保存草稿) 已调用相应的 UseCase 并处理结果 (使用 Mock/Placeholder)。
        *   [ ] (**完善动作处理**) 完善 Bloc 中动作成功/失败后的状态更新逻辑。
        *   [ ] (**UI 反馈**) 在 `OrderDetailPage` 使用 `BlocListener` 处理 `ActionSuccess/Failure` 状态，显示提示并根据 `actionType` 执行刷新/导航。
        *   [ ] (`OrderDetailBloc`) 添加处理售后相关事件 (如 `AfterSaleApplyRequested`, `MediationApplyRequested`, `CancelAfterSaleRequested`)。
    *   [ ] (`OrderDetailState`) 可能需要添加更详细的售后状态字段 (如 `afterSaleInfo`, `isApplyingForMediation`)。
    *   [ ] (`OrderDetailBloc DI`) 确认并添加需要的外部依赖注入 (Rating, Payment, Navigation)。
*   `lib/features/orders/presentation/widgets/`
    *   [x] 实现 `order_item_card.dart`: 用于在列表中显示单个订单摘要的 Widget。**参考 HTML 原型中的列表项样式。**
    *   [x] 实现 `order_status_widget.dart`: 根据 `OrderStatus` 显示不同文本和样式的 Widget。
    *   [x] 实现 `order_action_buttons.dart`: 根据当前订单状态 (`Order.state`) 推断并显示可用的操作按钮 (取消、确认收货、评价等)。**参考 HTML 原型中的按钮样式和布局。**
        *   [x] (**交互**) 为确认收货、取消订单、删除订单添加确认对话框。
    *   [ ] (**逻辑核对**) 根据截图核对各状态下按钮的显示逻辑。
    *   [ ] (**功能连接**) 将按钮点击连接到 `OrderDetailBloc` 的事件。 (确认收货/取消/删除已连接，待完善 Bloc 处理)
    *   [x] 实现 `order_detail_item_tile.dart`: ...
    *   [x] 实现 `order_status_timeline_header.dart`: (已实现基础视觉和逻辑)
        *   [ ] (**逻辑完善**) 精确映射 `_getCurrentStepIndex`。
        *   [ ] (**文本完善**) 确保 `_getStatusTitle` / `_getStatusSubtitle` 文本与原型一致。
    *   [x] (**时间格式化**) 使用 `intl` 包格式化所有显示的日期时间。
    *   [x] (**创建新 Widgets**) 创建 `OrderRequirementSubmissionForm`, `DeliveryConfirmationArea`, `OrderEvaluationForm` (骨架)。
    *   [x] (**创建新 Widgets**) 创建 等待状态指示器 (`WaitingActionArea`)、已完成/取消信息区 Widget (`OrderCompletionSummary`)。
    *   [x] (**完善 `OrderRequirementSubmissionForm`**) 添加附件 UI 骨架、连接 Bloc 事件。
    *   [x] (**完善 `DeliveryConfirmationArea`**) 改进文件列表显示。
    *   [x] (**完善 `OrderEvaluationForm`**) 添加星级评分、图片上传 UI 骨架。
    *   [x] (**完善 `WaitingActionArea`**) 改进消息、图标、显示买家备注。
    *   [x] (**完善 `OrderCompletionSummary`**) 添加图标、调整样式、添加分隔线。
    *   [x] (**创建新 Widgets**) 创建 售后处理区域 (`AfterSaleInfoArea`) 的骨架。
    *   [ ] (**完善 `AfterSaleInfoArea`**) 根据真实的售后状态和数据 (来自 Bloc State) 显示详细信息（进度、原因、金额、协商记录等），添加必要的操作按钮（取消申请、申请介入等）并连接 Bloc 事件。
    *   [ ] (**完善 `OrderActionButtons`**) 确保"申请售后"按钮在合适的时机显示，并能触发 `AfterSaleApplyRequested` 事件。
    *   [ ] (**创建售后申请表单?**) 可能需要创建一个新的 Widget/Page 用于填写详细的售后申请信息（原因、说明、上传凭证等）。
*   `lib/features/orders/presentation/pages/`
    *   [x] 实现 `order_list_page.dart`:
        *   [x] 构建 UI，包含状态切换 Tabs (全部、待付款、处理中、待评价等)。**严格参考 HTML 原型布局。**
        *   [x] 使用 `BlocBuilder`/`Consumer` 连接 `OrderListBloc/Cubit`。
        *   [x] 显示订单列表 (`ListView`/`InfiniteScrollView`)，使用 `OrderItemCard`。
        *   [x] 实现下拉刷新和**上拉加载更多** (滚动监听、触发事件、加载指示器)。
        *   [x] 实现导航到 `OrderDetailPage` (传递 `order.id`)。
        *   [x] 实现 `TabBar` 基础结构和 Bloc 连接。
        *   [x] 添加 "待提交" Tab 并使 `TabBar` 可滚动。
        *   [x] 添加 "售后中" Tab 并连接 Bloc 事件。
        *   [x] 实现从列表中的售后订单导航到 `AfterSalesDetailPage`。
        *   [ ] (**待办**) 实现从列表中的售后订单卡片按钮导航到 `SelectAfterSalesTypePage` (需要修改 `OrderItemCardActionButtons`)。
    *   [x] 实现 `order_detail_page.dart`:
        *   [x] 构建基础 UI 框架，集成 `OrderDetailBloc`。
        *   [x] 实现状态 Header (`OrderStatusTimelineHeader`)。
        *   [x] 实现地址信息 (`ListTile`)。
        *   [x] 实现商品列表 (`OrderDetailItemTile`)。
        *   [x] 实现价格信息 (`_buildPriceRow`)。
        *   [x] 实现订单时间戳信息 (`_buildInfoRow`)。
        *   [x] 实现操作按钮区域 (`OrderActionButtons` Widget 已放置)。
        *   [x] (**重构 UI**) 根据原型截图大幅重构页面结构：状态时间轴、状态描述卡片、动态内容区域切换、底部固定按钮等。
        *   [x] (**实现动态内容切换**) 在 `_buildDynamicContentSection` 中添加 `switch(order.state)`，使用骨架 Widget (大部分状态已覆盖)。
        *   [x] 实现从底部按钮导航到 `SelectAfterSalesTypePage`。
        *   [ ] (**填充内容**) 继续实现/完善各状态下的具体内容 Widget (主要是售后状态)。
    *   [ ] (**卖家视角**) 分析卖家视角原型/截图/代码。
    *   [ ] (**卖家视角**) 实现卖家视角的订单列表和详情页（调整现有 Widget 或创建新 Widget/Page）。
*   `lib/features/after_sales/presentation/pages/` (New Section)
    *   [x] 创建 `after_sales_list_page.dart`: 显示售后申请列表 (基础骨架和 Bloc 连接)。
        *   [x] (**修复**) 修正 `AfterSalesListError` 状态中字段 `message` 的引用为 `errorMessage`。
    *   [x] 创建 `after_sales_detail_page.dart`: 显示售后申请详情 (基础骨架和 Bloc 连接)。
        *   [x] (**修复**) 修正 `AfterSalesDetailLoading` 和 `AfterSalesDetailError` 状态中字段 `id`/`message` 的引用为 `loadingId`/`errorMessage`。
    *   [x] 创建 `select_after_sales_type_page.dart`: 选择售后类型页面 (骨架和导航)。
    *   [x] 创建 `after_sales_apply_page.dart`: 售后申请表单页面 (骨架和导航)。
*   `lib/core/router/`
    *   [x] 添加 `/afterSalesDetail/:id` 路由。
    *   [x] 添加 `/selectAfterSalesType/:orderItemId` 路由。
    *   [x] 添加 `/afterSalesApply` 路由 (带查询参数)。
*   `lib/features/after_sales/presentation/bloc/` (New Section)
    *   [x] 创建 `after_sales_bloc.dart`, `after_sales_event.dart`, `after_sales_state.dart` 文件骨架。
    *   [x] 定义核心的售后列表、详情、操作（申请、取消、删除）相关的 Bloc 事件 (Events) 和状态 (States)。
    *   [x] 实现 `AfterSalesBloc` 的基本结构，注入 UseCases，并添加事件处理器骨架。
    *   [x] 实现 `LoadAfterSalesListRequested` 事件处理器，调用 UseCase 并处理分页逻辑 (Mock)。
    *   [x] 实现 `LoadAfterSalesDetail` 事件处理器，调用 UseCase (Mock)。
    *   [x] 实现 `ApplyForAfterSalesSubmitted` 事件处理器，调用 UseCase (Mock)。
    *   [x] 实现 `CancelAfterSalesRequested` 和 `DeleteAfterSalesRequested` 事件处理器 (Mock)。
    *   [x] (**修复**) 解决 `after_sales_state.dart` 中 `part of` 指令和 `import` 语句冲突的问题。
    *   [x] (**修复**) 修正 `_onApplyForAfterSalesSubmitted` 处理器中 `refundId` (int) 到 `newId` (String?) 的类型转换错误。

**步骤 8: 定义和配置外部依赖接口 (隔离开发)**

*   [ ] 识别 `Orders` 模块的**所有**外部依赖接口（除了已定义的 Auth, AfterSale, Rating, Logistics, Navigation, Payment，还需考虑 Cart, Product, Chat 等）。
*   [x] 在 `lib/core/<domain>/` 目录下按领域定义核心接口的**初始版本**:
    *   [x] `lib/core/error/failures.dart`: 定义基础 `Failure` 类。
    *   [x] `lib/core/auth/repositories/i_auth_repository.dart`: 定义 `IAuthRepository`。
    *   [x] `lib/core/aftersale/repositories/i_aftersale_repository.dart`: 定义 `IAfterSaleRepository`。
    *   [x] `lib/core/rating/repositories/i_rating_repository.dart`: 定义 `IRatingRepository`。
    *   [x] `lib/core/navigation/services/i_navigation_service.dart`: 定义 `INavigationService`。
    *   [x] `lib/core/payment/services/i_payment_service.dart`: 定义 `IPaymentService`.
    *   [ ] ... (其他接口如 `IProductRepository`, `IChatRepository` 等待根据需要定义)。
*   [x] (测试阶段) 为已定义的接口创建 Mock 实现 (使用 `Mockito` 或手动创建)。
    *   [x] `MockAuthRepository`
    *   [x] `MockAfterSaleRepository`
    *   [x] `MockRatingRepository`
    *   [x] `MockNavigationService`
    *   [x] `MockPaymentService`
    *   [x] `MockOrderRepository` (Internal Mock for preview)
*   [x] (预览阶段) 配置 DI 容器 (`GetIt`)，注入 Mock 实现 (`main_orders_preview.dart`) (已移除 Logistics)。
*   [x] (**DI 配置**) 使用 `@injectable` 和 `@module` 完成核心依赖注册。
    *   [x] (**数据库 DI**) 配置 `AppDatabase` 的依赖注入。
*   [x] (**运行 `build_runner`**) 成功生成 `injection_container.config.dart`。
*   [x] (**配置预览环境**) 在 `main_orders_preview.dart` 中覆盖 `IOrderRepository` 使用 Mock。

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
*   [ ] (**核心订单操作 - Bloc 处理**) 在 `OrderDetailBloc` 中完整实现 `ConfirmReceiptRequested`, `CancelOrderRequested`, `DeleteOrderRequested` 事件处理器，包括调用 UseCase、更新状态和处理错误/成功反馈。
    *   **(进行中)** Bloc 已能调用 UseCase 并发出 `ActionLoading/Success/Failure` 状态。
    *   [ ] (**UI 反馈**) UI 层需要监听状态并响应 (SnackBar, 刷新/导航)。
*   [ ] (**售后流程深化 - UI**) 完善 `AfterSaleInfoArea`，根据 `AfterSalesBloc` 状态动态显示售后详情和操作按钮。

**步骤 10: 在模块预览环境中调试和验证**

*   [x] 创建 `main_orders_preview.dart`，配置使用 Mock 依赖的 DI。
*   [x] 运行预览 App。
*   [x] 手动测试订单列表的加载、滚动、筛选 (包括不同状态 Tab)。
*   [ ] 手动测试导航到订单详情。
*   [ ] 手动测试订单详情在不同状态下的显示和操作按钮的可用性/行为。
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

**通用/架构待办:**

*   [x] **主题 (`AppTheme`):** 创建统一主题文件 `app_theme.dart` 并应用于主入口和预览入口。
*   [ ] **主题 (`AppTheme`):** 在 `app_theme.dart` 中定义更详细的主题配置 (textTheme, buttonTheme, appBarTheme, tabBarTheme)。
*   [ ] **主题 (`AppTheme`):** 实现并测试深色主题 (`darkTheme`)。
*   [ ] **文档:** 完成 `Rating` 模块的边界定义文档 (中文版)。
*   [ ] **文档:** 检查并完成 `AfterSale` 模块的边界定义文档 (中文版)。
*   [ ] (**日志**) (可选) 记录 `PrettyLogInterceptor` Linter 问题及当前使用的 `LogInterceptor` 替代方案。

---

## 下一步重点 (Next Focus)

*   [x] **API 集成测试 - 订单详情与操作 (Order Detail & Actions API Integration Testing)**
    *   [x] 测试 `getOrderDetail` API (`/api/shop/order/detail`)
    *   [x] 测试 `cancelOrder` API (`/api/shop/order/cancel`) 及 UI 反馈 (SnackBar, 返回列表)
    *   [x] 测试 `confirmOrderReceipt` API (`/api/shop/order/complete`) 及 UI 反馈 (SnackBar, 刷新详情)
    *   [x] 测试 `deleteOrder` API (`/api/shop/order/delete`) 及 UI 反馈 (SnackBar, 返回列表)
    *   [x] 测试 `submitRequirements` API (`/api/project/orderMaterials/add`) 及 UI 反馈 (SnackBar, 刷新详情)
*   [ ] **实现订单评价流程 (Implement Order Evaluation Flow)**
    *   [ ] 定义 `SubmitEvaluationUseCase` (如果尚未完成)。
    *   [ ] 更新 `OrderDetailBloc` 添加处理评价提交的事件 (`SubmitEvaluationRequested`?) 和状态。
    *   [ ] 连接 `OrderEvaluationForm` UI 到 Bloc 事件。
    *   [ ] 测试评价提交 API (`/api/shop/order/comment/add` 或类似接口) 对接。
*   [ ] **完善/实现草稿本地存储 (Refine/Implement Draft Local Storage)**
    *   [ ] 在 `OrderRequirementSubmissionForm` 中实现使用 `SharedPreferences` 或文件存储来保存和加载草稿。
    *   [ ] 确定草稿保存/加载的时机（例如，`initState`, `dispose`, 文本/文件变化时）。
    *   [ ] 清理草稿的时机（例如，提交成功后）。
*   [ ] **实现订单详情缓存 (Implement Order Detail Caching)**
    *   [ ] 类似 `OrderList` 的缓存策略，在 `OrderRepositoryImpl` 中为 `getOrderDetail` 添加缓存逻辑。
    *   [ ] 可能需要更新 `OrderLocalDataSource` 添加 `getOrderDetailById`, `cacheOrderDetail`, `clearOrderDetailCache` 等方法。
    *   [ ] 更新 `OrderDatabase` 和 `OrderDao` 添加存储/查询单个订单详情的逻辑。
*   [ ] **核心 - Token 处理 (Core - Token Handling)**
    *   [ ] 实现 `CoreDioClient` 从本地存储（如 `SharedPreferences`）读取真实的 `Authorization` Token 并添加到请求头。
*   [ ] **代码清理与优化 (Code Cleanup & Optimization)**
    *   [ ] 审查并移除不再使用的代码、注释。
    *   [ ] 检查 UI 细节和用户体验。

**步骤 11: (进行中) 图片/文件上传**
*   [x] (**文件选择**) 使用 `file_picker` 实现本地文件选择。
*   [x] (**状态管理**) 在 Widget 状态中存储选中的文件路径。
*   [x] (**数据传递**) 将文件路径列表传递给 Bloc 事件。
*   [ ] (**核心上传逻辑 - 待办**) 实现文件内容上传到服务器 (如 S3/OSS) 并获取返回的 URL/ID 的 UseCase/Repository。
*   [ ] (**Bloc/UseCase 集成 - 待办**) 在提交业务表单前，调用上传逻辑，并将返回的 URL/ID 列表用于最终的 API 请求。

**步骤 12: (进行中) 买家视角交互完善**
*   [ ] (**核心订单操作 - Bloc 处理**) 在 `OrderDetailBloc` 中完整实现 `ConfirmReceiptRequested`, `CancelOrderRequested`, `DeleteOrderRequested` 事件处理器，包括调用 UseCase、更新状态和处理错误/成功反馈。
*   [ ] (**售后流程深化 - UI**) 完善 `AfterSaleInfoArea`，根据 `AfterSalesBloc` 状态动态显示售后详情和操作按钮。
*   [ ] (**售后流程深化 - Bloc 连接**) 连接 `AfterSaleInfoArea` 中的操作按钮 (取消申请、申请介入等) 到 `AfterSaleApplyRequested` 事件。

**步骤 13: (进行中) 真实 API 对接测试**
*   [ ] 登录获取 Token 并存入 `flutter_secure_storage`。
*   [x] 测试订单列表加载 (`getOrderList`)。
*   [ ] 测试订单详情加载 (`getOrderDetail`)。
*   [ ] 测试提交需求 (`submitRequirements`)。
*   [ ] 测试评价提交 (`addEvaluation`) (需要在 UI/Bloc 中触发)。
*   [ ] 测试取消、确认收货、删除订单。

**步骤 14: 添加缓存与本地存储策略文档**
*   [x] 添加缓存与本地存储策略文档 (`docs/caching_and_local_storage_strategy_cn.md`)。
*   [x] 添加订单列表缓存实现细节文档 (`docs/order_list_caching_details_cn.md`)。

**关键决策点:**

*   `saveRequirementDraft` 功能转为本地存储。
*   `submitRequirements` API 参数结构已变更。
*   `addEvaluation` API 确认使用 `orderItemId`。
*   Token 存储使用 `flutter_secure_storage`。

**后续计划 (已调整):**

1.  实现评价相关的 UseCase、Bloc 事件/状态和 UI。
2.  完善草稿清除逻辑。
3.  实现其他待办任务。