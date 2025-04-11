# AfterSale 模块边界定义

## 1. 模块名称

`AfterSale` (售后服务 / 退款)

## 2. 核心业务能力

处理用户（通常是买家，有时也可能是卖家）在订单超出简单取消范围后，针对特定订单项发起的退款或退货请求。这包括提交申请、提供原因和证据、卖家/平台审核与响应（同意/拒绝），以及跟踪请求的状态。

## 3. 核心领域要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`AfterSaleApplication` / `RefundRequest`**: 代表一个售后/退款请求。
    *   `id`: (String) 请求的唯一 ID。
    *   `orderId`: (String) 关联的订单 ID。
    *   `orderItemId`: (String) 关联的订单项 ID。
    *   `refundSn`: (String?) 退款交易号。
    *   `requestorRole`: (Enum: `buyer`, `seller`?) 发起者角色。
    *   `type`: (Enum: `refundOnly` - 仅退款, `returnAndRefund` - 退货退款) 请求类型。
    *   `status`: (`AfterSaleStatus`) 请求当前状态。
    *   `reason`: (String) 用户提供的理由类别/代码。
    *   `explanation`: (String) 详细说明。
    *   `images`: (`List<String>`?) 上传凭证图片的 URL。
    *   `requestedAmount`: (Decimal) 请求退款的金额。
    *   `approvedAmount`: (Decimal?) 实际批准的金额。
    *   `createdAt`: (DateTime) 请求创建时间。
    *   `updatedAt`: (DateTime) 最后更新时间。
    *   `auditInfo`: (`AuditInfo`?) 审核过程信息。
    *   `returnInfo`: (`ReturnInfo`?) 退货所需信息 (如适用)。
*   **`AfterSaleStatus`**: 请求状态 (枚举)。
    *   `pendingAudit` (待审核)
    *   `auditRejected` (审核拒绝)
    *   `pendingReturn` (待退货 - 适用于退货退款类型)
    *   `returnShipped` (买家已发货 - 适用于退货退款类型)
    *   `pendingRefund` (待退款 - 审核通过或收到退货后)
    *   `refundCompleted` (退款成功)
    *   `closed` / `cancelled` (已关闭/已取消)
    *   *(具体值基于 API `refundState`)*
*   **`AuditInfo`**: 审核详情。
    *   `auditorId`: (String?)
    *   `auditTime`: (DateTime?)
    *   `decision`: (Enum: `approved`, `rejected`)
    *   `comments`: (String?)
*   **`ReturnInfo`**: 退货物流详情。
    *   `returnAddress`: (`Address`?) 退货地址。
    *   `instructions`: (String?) 退货说明。
    *   `returnTrackingNumber`: (String?) 退货物流单号。

### 3.2. `Use Cases` (主要功能点)

*   `ApplyForAfterSaleUseCase(orderId, orderItemId, type, reason, explanation, images?, amount?)`: 用户提交请求。
*   `GetAfterSaleDetailUseCase(requestId)`: 获取特定请求的详情。
*   `GetAfterSaleListUseCase(filter?, page, limit)`: 获取用户的请求列表。
*   `CancelAfterSaleUseCase(requestId)`: 用户取消请求。
*   `SubmitReturnInfoUseCase(requestId, trackingNumber)`: 用户提交退货信息。
*   `(Admin/Seller) RespondToAfterSaleUseCase(requestId, decision, comments?, approvedAmount?)`: 处理请求。

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IAfterSaleRepository`**: 数据访问接口。
    *   `Future<Either<Failure, String>> apply(applicationData)`: 提交申请，返回请求 ID。
    *   `Future<Either<Failure, AfterSaleApplication>> getDetail(String requestId)`.
    *   `Future<Either<Failure, List<AfterSaleApplication>>> getList(filter?, page, limit)`.
    *   `Future<Either<Failure, void>> cancel(String requestId)`.
    *   `Future<Either<Failure, void>> submitReturnInfo(String requestId, String trackingNumber)`.
    *   *(如需)* `respond(...)` (管理员/卖家方法)。

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   `Core/Shared`: 通用工具、Failure、Address 实体、HTTP 客户端。
*   `Auth`: 获取当前用户 ID/角色。
*   `Order`: 需要 `orderId`, `orderItemId` 来关联请求，可能需要订单详情作为上下文。
*   `Navigation`: 用于在售后屏幕之间导航。
*   `FilePicker/Uploader`: 用于上传凭证图片。

### 4.2. 导航需求 (由 `INavigationService` 提供)

*   `navigateToAfterSaleApplication(orderId, orderItemId)`: 由 `Orders` 调用以启动流程。
*   `navigateToAfterSaleDetail(requestId)`: 查看特定请求（例如从通知或列表进入）。
*   `navigateToAfterSaleList()`: 查看所有请求。
*   `pop()` / `goBack()`.

### 4.3. 事件 (监听或发出)

*   可能监听 `OrderCompletedEvent` (只允许在完成后进行售后?)。
*   可能发出 `AfterSaleStatusChangedEvent` (用于通知或更新订单状态)。

## 5. 表示层 (Presentation Layer - 高层级)

*   **Screens**: 申请表单、详情视图、列表视图。
*   **State Management**: `AfterSaleApplicationCubit`, `AfterSaleDetailCubit`, `AfterSaleListCubit`。
*   **Widgets**: 原因选择器、图片上传器、状态时间线。

## 6. 数据层 (Data Layer - 高层级)

*   **DataSource**: `IAfterSaleRemoteDataSource` (调用 `/api/shop/order-refund/...` 等 API 端点)。
*   **Models**: `AfterSaleApplicationModel` 等 (匹配 API 响应/请求结构)。
*   **Repository Impl**: `AfterSaleRepositoryImpl` (实现 `IAfterSaleRepository`, 调用 DataSource)。 