# 订单列表 (OrderList) 缓存实现细节

## 1. 引言

本文档详细描述了 `Orders` 模块中订单列表 (`OrderList`) 功能的具体缓存实现机制。本文档是对主要缓存与本地存储策略文档 (`docs/caching_and_local_storage_strategy_cn.md`) 中关于订单列表策略的细化和补充。

## 2. 目标

为订单列表实现缓存的主要目标是：

*   显著提升用户二次加载订单列表时的界面响应速度。
*   在网络不稳定或请求失败时，能够展示上次成功加载的数据，提供基础的离线查看能力。
*   减少不必要的网络请求，节省用户流量和设备资源。

## 3. 技术选型

根据项目整体策略，订单列表的本地持久化缓存采用了 `drift` 数据库技术。

## 4. 缓存策略概述

订单列表采用了 **"缓存优先，网络回填" (Cache First, Network Fallback / Background Update)** 的策略。核心思想是：

1.  **优先读缓存**: 当请求加载订单列表时，首先尝试从本地 `drift` 数据库读取对应状态和分页的缓存数据。
2.  **快速响应**: 如果缓存中存在有效数据，则**立即**将缓存数据返回给上层 (Bloc/UI)，以实现快速的界面加载。
3.  **后台更新**: 在返回缓存数据的**同时**（或之后），启动一个**后台**网络请求去获取最新的数据。
4.  **网络回填**: 获取到最新的网络数据后，将其写入（覆盖或更新）本地 `drift` 数据库缓存。
5.  **网络优先 (缓存未命中)**: 如果首次加载或缓存读取失败/为空，则直接执行网络请求，获取成功后写入缓存，并将网络数据返回给上层。

## 5. 实现细节

### 5.1. 数据存储

*   **数据库表**: 在 `drift` 中定义了 `Orders` 表 (`lib/core/database/tables/orders_table.dart`)。
*   **数据类**: `drift_dev` 根据 `Orders` 表生成了 `OrderCache` 数据类 (`app_database.g.dart` 的一部分)。
*   **存储内容**: 为了优化存储和查询效率，`Orders` 表仅存储用于列表展示的**订单摘要信息**，而非完整的 `Order` 实体。包含的主要字段有：`id` (主键), `orderSn`, `state` (订单状态字符串), `firstItemName`, `firstItemImage`, `totalPrice` (字符串格式), `createdAt`。

### 5.2. 工作流程 (`OrderRepositoryImpl.getOrderList`)

1.  **确定查询条件**: 根据传入的 `status` (OrderStatus?) 和分页参数 (`page`, `limit`) 计算出数据库查询所需的 `stateKey` (将 `null` 状态映射为 `'all'`) 和 `offset`。
2.  **读取缓存**: 调用 `IOrderLocalDataSource` 的相应方法 (`getAllOrders` 或 `getOrdersByState`) 查询 `drift` 数据库。
3.  **缓存命中处理**: 
    *   如果 `localDataSource` 返回 `Right(cachedOrders)` 且 `cachedOrders` 不为空：
        *   立即 `return Right(cachedOrders)` 给调用方 (Bloc)。
        *   异步调用私有方法 `_fetchAndUpdateCache` 启动后台网络请求。
4.  **缓存未命中/为空处理**: 
    *   如果 `localDataSource` 返回 `Left(failure)` 或 `Right([])`：
        *   继续执行网络请求。
5.  **网络请求**: 调用 `IOrderRemoteDataSource.getOrderList` 获取网络数据 (`List<OrderModel>`)。
6.  **数据转换与缓存**: 
    *   将 `List<OrderModel>` 映射为 `List<Order>` (领域实体)。
    *   将 `List<Order>` 映射为 `List<OrderCache>` (数据库数据类)。
    *   调用 `IOrderLocalDataSource.cacheOrders` 将 `List<OrderCache>` 写入数据库（采用 `InsertMode.insertOrReplace` 模式，插入或替换已有记录）。
7.  **返回网络结果**: `return Right(networkOrders)` (将第 6 步转换出的 `List<Order>` 返回)。
8.  **后台网络更新 (`_fetchAndUpdateCache`)**: 
    *   执行与步骤 5、6 类似的网络请求和缓存写入操作。
    *   此方法**不**向上返回数据或错误，仅负责更新缓存。失败时打印日志。
9.  **网络错误处理**: 
    *   如果在执行步骤 5 时发生网络错误 (`ServerFailure` 等)：
        *   检查之前是否已通过步骤 3 返回了缓存数据。
        *   如果**已返回缓存**，则捕获并记录网络错误，但**抑制**该错误，仍然让整个 `getOrderList` 调用成功返回（返回的是之前的缓存数据）。
        *   如果**未返回缓存**，则将网络错误包装为 `Left(failure)` 返回给调用方。

### 5.3. 状态处理

*   **状态映射**: `OrderRepositoryImpl` 在调用 `localDataSource` 和 `remoteDataSource` 时，会根据传入的 `OrderStatus? status` 来决定：
    *   如果 `status` 为 `null` (对应 UI 的"全部" Tab)，则调用 `localDataSource.getAllOrders` 查询所有状态的缓存。
    *   如果 `status` 不为 `null`，则将其转换为字符串 `stateKey` (如 `'awaitingPayment'`)，并调用 `localDataSource.getOrdersByState` 查询特定状态的缓存。
*   **缓存写入**: 写入缓存时，存储的是订单的**具体状态字符串** (`order.state.toJsonString()`)。

### 5.4. 分页处理

*   `OrderRepositoryImpl` 将 `page` 和 `limit` 参数转换为 `limit` 和 `offset`。
*   `IOrderLocalDataSource` 的查询方法 (`getOrdersByState`, `getAllOrders`) 接收 `limit` 和 `offset`，并在数据库查询 (`AppDatabase` 中的方法) 中应用 `..limit(limit, offset: offset)`。

### 5.5. 数据映射

*   **`OrderCache` -> `Order`**: 通过定义在 `lib/core/database/database_extensions.dart` 中的 `OrderCacheMapping` extension 的 `toEntity()` 方法实现。由于 `OrderCache` 只包含摘要信息，此方法会为缺失的 `Order` 字段（如 `items` 列表、详细地址等）填充占位符或默认值。
*   **`Order` -> `OrderCache`**: 通过 `OrderLocalDataSourceImpl` 中的私有辅助方法 `_mapOrderToOrderCache` 实现，提取 `Order` 实体中的关键信息来构建 `OrderCache` 对象。

## 6. 当前限制与未来改进

*   **UI 自动刷新**: 当前实现下，当后台网络请求成功并更新缓存后，如果数据有变动，UI **不会**自动刷新以显示最新数据。用户需要手动刷新（如下拉）或重新进入页面才能看到更新。未来可以考虑让 Repository 返回 `Stream` 或通过其他机制通知 Bloc 更新。
*   **缓存失效策略**: 目前没有实现明确的缓存失效机制 (如 TTL 或基于用户操作的失效)。缓存数据会一直存在，直到被新的网络数据覆盖或手动清除。
*   **错误处理**: 后台缓存更新失败时仅打印日志，没有重试或其他处理机制。
*   **覆盖范围**: 目前仅实现了订单列表的缓存，订单详情等其他数据的缓存尚未实现。
*   **数据一致性**: 在"缓存优先，网络回填"模式下，用户可能会先看到旧的缓存数据，然后（如果实现了自动刷新）数据再更新为最新的，这可能导致短暂的视觉不一致。

## 7. 相关文件

*   `docs/caching_and_local_storage_strategy_cn.md` (主策略文档)
*   `lib/core/database/app_database.dart` (Drift 数据库定义)
*   `lib/core/database/tables/orders_table.dart` (订单缓存表定义)
*   `lib/core/database/database_extensions.dart` (数据映射逻辑)
*   `lib/features/orders/data/datasources/i_order_local_data_source.dart` (本地数据源接口)
*   `lib/features/orders/data/datasources/order_local_data_source_impl.dart` (本地数据源实现)
*   `lib/features/orders/data/repositories/order_repository_impl.dart` (缓存策略核心实现) 