# Logistics 模块边界定义

## 1. 模块名称

`Logistics` (物流 / 追踪)

## 2. 核心业务能力

向用户提供追踪其实物商品订单的物流状态和历史轨迹的能力。这涉及从承运商获取追踪信息，并以用户友好的方式（可能包括时间线）展示这些信息。

## 3. 核心领域要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`TrackingInfo`**: 包含与订单（或订单的一部分）关联的货运的整体物流信息。
    *   `orderId`: (String) 关联的订单 ID。
    *   `shipmentId`: (String?) 可选的货运 ID (如果一个订单有多个包裹)。
    *   `carrierName`: (String?) 物流承运商名称 (例如, "顺丰速运", "EMS")。
    *   `trackingNumber`: (String?) 承运商提供的追踪号码。
    *   `currentStatus`: (`TrackingStatus`) 最新的已知状态。
    *   `statusDescription`: (String?) 当前状态的文字描述。
    *   `estimatedDelivery`: (DateTime?) 预计送达日期。
    *   `events`: (`List<TrackingEvent>`) 按时间顺序排列的追踪更新事件列表。
*   **`TrackingEvent`**: 代表货运过程中的单个更新事件。
    *   `timestamp`: (DateTime) 事件发生时间。
    *   `status`: (`TrackingStatus`?) 与事件关联的状态码。
    *   `description`: (String) 事件描述 (例如, "已揽收", "运输中", "派送中", "已签收")。
    *   `location`: (String?) 事件发生的地点 (例如, "上海转运中心")。
*   **`TrackingStatus`**: 货运或事件的状态 (枚举)。
    *   `pending` / `infoReceived` (信息已收到/待揽收)
    *   `inTransit` (运输中)
    *   `outForDelivery` (派送中)
    *   `delivered` (已签收)
    *   `exception` / `alert` (异常)
    *   `failedAttempt` (派送失败)
    *   *(具体值可能取决于承运商或聚合服务)*

### 3.2. `Use Cases` (主要功能点)

*   `GetTrackingInfoUseCase(orderId, shipmentId?)`: 获取订单/货运的追踪信息。
*   `(可选) RefreshTrackingInfoUseCase(orderId, shipmentId?)`: 强制从承运商更新信息。

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`ILogisticsRepository`**: 数据访问接口。
    *   `Future<Either<Failure, TrackingInfo>> getTrackingInfo(String orderId, String? shipmentId)`。
    *   *(可选)* `Future<Either<Failure, TrackingInfo>> refreshTrackingInfo(String orderId, String? shipmentId)`。

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   `Core/Shared`: 通用工具、Failure、HTTP 客户端。
*   `Order`: 需要 `orderId` (以及可能最初在 `Order.shippingInfo` 中提供的 `shipmentId` 或 `trackingNumber`) 来获取详情。导航通常从订单详情页发起。
*   `Navigation`: 用于可能导航到一个专门的物流详情屏幕。

### 4.2. 导航需求 (由 `INavigationService` 提供)

*   `navigateToTrackingDetail(orderId, shipmentId?)`: 由 `Orders` 调用以查看物流详情。
*   `pop()` / `goBack()`.

### 4.3. 事件 (监听或发出)

*   监听 `OrderShippedEvent` (可能包含初始追踪号和承运商信息)。
*   可能发出 `TrackingStatusUpdatedEvent` (用于通知)。

## 5. 表示层 (Presentation Layer - 高层级)

*   **Screens/Widgets**: 物流追踪详情视图（可以是独立屏幕，也可以是在订单详情页内显示的底部弹窗/对话框）。
*   **State Management**: `TrackingInfoCubit`。
*   **Widgets**: 用于追踪事件的时间线视图、地图视图 (可选)。

## 6. 数据层 (Data Layer - 高层级)

*   **DataSource**: `ILogisticsRemoteDataSource` (调用提供追踪数据的后端 API 端点 - 端点需根据 API 规范分析或澄清确定)。
*   **Models**: `TrackingInfoModel`, `TrackingEventModel`。
*   **Repository Impl**: `LogisticsRepositoryImpl`。 