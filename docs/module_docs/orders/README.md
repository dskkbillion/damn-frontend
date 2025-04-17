# 订单模块 (Orders) 核心说明文档

**最后更新:** 2024-08-01 (请根据实际日期修改)

---

## 1. 模块概述 (Brief Overview)

*   **一句话描述:** 处理买家和卖家视角的订单全生命周期管理，包括订单列表展示、订单详情查看、订单操作（如取消、提交需求、评价）、**售后处理（申请、查看、跟踪）**以及相关的本地缓存和状态管理。
*   **(可选) 主要功能点:**
    *   买家订单列表（支持分页、多状态筛选）
    *   买家订单详情
    *   卖家订单列表（支持分页、多状态筛选）
    *   卖家订单详情
    *   订单取消
    *   订单需求提交与查看
    *   (待实现) 订单评价
    *   **售后申请与处理**
    *   **查看售后详情与进度**
    *   订单列表本地缓存与后台更新

## 2. 路由入口与参数 (Routing Entry Points & Parameters)

*   **如何进入本模块:**
    *   路径: `/orders`, 名称: `orders` (买家订单列表，无需参数)
    *   路径: `/orderDetail/:orderId`, 名称: `orderDetail` (买家订单详情，需要路径参数 `orderId` (String)。需求提交功能和售后入口在此页面内实现。)
    *   路径: `/seller/orders`, 名称: `sellerOrders` (卖家订单列表，无需参数)
    *   路径: `/seller/orders/:orderId`, 名称: `sellerOrderDetail` (卖家订单详情，需要路径参数 `orderId` (String))
    *   路径: `/selectAfterSalesType/:orderItemId`, 名称: `selectAfterSalesType` (选择售后类型页面，需要路径参数 `orderItemId` (String) **并**通过 `extra` 传递 `OrderItem` 对象)
    *   路径: `/afterSalesApply`, 名称: `afterSalesApply` (申请售后页面，需要查询参数 `itemId` (String), `type` (String) **并**通过 `extra` 传递 `OrderItem` 对象)
    *   路径: `/afterSalesDetail/:id`, 名称: `afterSaleDetail` (售后详情页面，需要路径参数 `id` (String))
    *   路径: `/afterSales`, 名称: `afterSales` (售后列表页面，无需参数)
    *   (**注意:** 填写退货物流等其他售后流程的路由需确认是否已实现或如何实现)
*   **必需参数:** 见上述各路由说明。
*   **参考:** 订单核心路由定义在 `lib/features/orders/presentation/routes/order_routes.dart`；售后相关路由定义在 `lib/features/after_sales/presentation/routes/after_sales_routes.dart`。两者均通过核心路由文件 (`lib/app/navigation/app_router.dart`) 聚合。遵循 `docs/modular_routing_strategy_cn.md` 规范。

## 3. 外部依赖说明 (External Dependencies)

*   **核心服务依赖:**
    *   `CoreDioClient` (通过 Repository 间接依赖，用于所有网络请求，其内部会处理 Token 的添加)
    *   `INavigationService` (用于模块内部导航)
    *   `AppDatabase` / `Drift` (通过 LocalDataSource 依赖，用于本地数据缓存)
    *   `IAuthRepository` (用于获取当前用户 ID 和认证状态，部分 UseCase 可能需要用户ID作为参数)
*   **跨模块依赖:**
    *   订单模块 (包含售后) 旨在成为一个内聚的功能单元，**不应**依赖其他 **Feature** 模块。
    *   (若未来有其他模块需要订单/售后数据，应优先考虑通过核心服务或事件总线暴露，而非直接依赖)

## 4. 调用的主要 API (APIs Consumed)

*   **接口列表与目的:**
    *   **订单核心 API:**
        *   `POST /api/shop/order/list` (获取买家/卖家订单列表，通过 `type` 参数区分)
        *   `GET /api/shop/order/detail` (获取买家/卖家订单详情)
        *   `GET /api/shop/order/cancel` (买家取消订单)
        *   `POST /api/project/orderMaterials/add` (买家提交订单需求/材料)
        *   `GET /api/shop/order/complete` (买家确认收货)
        *   `POST /api/shop/evaluate/add` (买家添加评价)
        *   `POST /api/shop/order/delete` (买家删除订单)
        *   `POST /api/shop/order/verify` (卖家确认接单)
        *   `POST /api/project/orderDemand/add` (卖家添加订单需求/拒绝理由)
        *   `POST /api/project/orderDelivery/add` (卖家发货)
        *   `POST /api/shop/order/sellerDelete` (卖家删除订单记录)
    *   **售后相关 API (实现位于 `features/after_sales` 目录下，但属于本模块):**
        *   `GET /api/shop/order-refund/detail` (获取售后详情，需带 `?id=` 参数)
        *   `POST /api/shop/order-refund/apply` (提交售后申请)
        *   `POST /api/shop/order-refund/list` (获取售后列表)
        *   `POST /api/shop/order-refund/cancel` (取消售后申请)
        *   `POST /api/shop/order-refund/delete` (删除售后申请)
        *   (**注意:** 填写退货物流、卖家处理、平台介入等 API 需确认端点)
    *   **未实现/未知:** 邀请评价 API 端点未知。
*   **细节参考:** 详细的请求/响应结构、认证要求等请参考全局的 `docs/api_usage_summary_cn.md` 文档。

## 5. (可选) 对外暴露的服务/接口 (Exposed Services/Interfaces)

*   目前订单模块不直接对外暴露服务或接口供其他模块调用。模块间交互主要通过路由跳转和（未来可能引入的）事件总线。

## 6. (可选) 注意事项/配置要求 (Notes/Configuration Requirements)

*   **后端API依赖:** 本模块功能强依赖于后端API的可用性和正确性。请确保本地开发或测试环境已正确配置API基地址 (`.env` 文件)并能够访问服务。
*   **模拟数据:** 在无法连接后端或进行UI预览时，可考虑使用 `MockOrderRepository` (具体实现需维护) 提供模拟数据。相关配置在预览入口文件 (如 `main_orders_preview.dart`) 的DI设置中。
*   **代码生成:** 本模块使用了 `build_runner` 进行代码生成 (如 `Drift` 的数据库代码, `Injectable` 的DI配置)。在修改相关类后，需要运行 `flutter pub run build_runner build --delete-conflicting-outputs` 来更新生成的文件。
*   **权限:** 目前核心功能不需要特殊的设备权限。若未来增加如"扫码发货"等功能，可能需要相机权限。

### 7. 依赖包使用说明 (Package Dependencies)

*   **`flutter_bloc: ^8.1.5`**: 用于实现业务逻辑与UI分离的状态管理 (Bloc/Cubit)。遍布 `presentation/bloc` 目录及相关UI文件。
*   **`equatable: ^2.0.5`**: 用于简化 Bloc 的 State 和 Event 类以及 Domain 层 Entity 的值比较。在相关的 State/Event/Entity 文件中使用。
*   **`get_it: ^7.7.0` & `injectable: ^2.4.1`**: 用于依赖注入，解耦各层实现。在 `di` 配置及各层类的构造函数中使用。
*   **`dio: ^5.4.3+1`**: 作为 `CoreDioClient` 的底层依赖，用于网络请求。主要在 `data/datasources` 层间接使用。
*   **`drift: ^2.26.0` & `sqlite3_flutter_libs: ^0.5.32` & `path_provider: ^2.1.3` & `path: ^1.9.0`**: 用于实现订单列表的本地数据库缓存。主要在 `data/datasources/local` 和 `core/database` 相关文件中使用。
*   **`go_router: ^14.1.0`**: 作为核心导航服务 `INavigationService` 的底层依赖，用于声明式路由。在 `presentation/routes` 和需要导航的地方间接使用。
*   **`intl: (来自 Flutter SDK)`**: 用于日期、数字格式化等国际化处理。可能在显示订单时间、金额等UI Widget中使用。
*   **`image_picker: ^1.1.2` & `file_picker: ^8.0.5`**: 用于订单需求提交时选择图片/文件。
*   **`shared_preferences: ^2.2.3`**: (若实现草稿功能) 用于本地存储草稿数据。

### 8. 资源管理说明 (Resource Management)

*   **模块资源列表:**
    *   推测可能需要：订单状态图标、商品占位图、空状态/错误状态插画等。
    *   **当前分析:** 代码库中未发现明确使用本地图片资源 (`assets/images/` 或 `Assets.images` 等模式)。可能所有图片均来自网络，或尚未添加本地资源。
*   **资源命名规范 (推荐):** 遵循全局规范，模块特定资源使用 `order_` 或 `ic_order_` 前缀。
*   **资源存放位置 (推荐):** 共享资源放 `assets/.../common/`，模块专属放 `assets/.../orders/`。
*   **资源使用方式 (推荐):** 通过 `assets_gen` 生成的访问器类引用。

### 9. 已知问题与解决方案 (Known Issues & Solutions)

*   **已知限制:**
    *   订单列表在快速滚动或频繁切换筛选条件时，可能因并发请求或状态更新不及时导致显示异常（需持续优化）。
    *   **售后详情获取依赖的后端接口 `/api/shop/order-refund/detail` 目前不稳定，影响订单详情页内嵌的售后信息展示 (后端修复中)。**
    *   部分UI细节（如Timeline样式、按钮交互、售后流程页面）可能与最终设计稿存在差异。
    *   图片加载可能因URL问题（如相对路径）失败 (需要后端配合规范化URL)。
*   **临时解决方案/规避措施:**
    *   为网络图片加载添加明确的错误占位符/处理逻辑。
    *   暂时屏蔽或弱化对不稳定售后接口的依赖（如在订单详情页隐藏售后入口或显示加载失败提示）。
*   **修复计划:**
    *   **待后端修复售后接口问题后，联调验证售后流程。**
    *   持续优化订单列表的Bloc逻辑和UI更新机制。
    *   根据UI/UX反馈迭代视觉样式。
*   **开发者注意事项:**
    *   修改订单状态流转逻辑时，需同时考虑买家和卖家视图，**以及关联的售后状态**，并与后端API定义保持一致。
    *   测试时注意覆盖不同的订单状态、**售后类型和状态**以及边缘场景。

### 10. 跨模块通信机制 (Cross-Module Communication)

*   **输出事件/通知:**
    *   (未来可能) 订单或售后状态发生关键变化时（如支付成功、发货完成、退款成功），可以通过全局事件总线发出事件。
*   **输入事件/通知:**
    *   当前分析: 未发现监听特定跨模块事件（如用户登出）的逻辑。
    *   (未来可能) 监听支付模块发出的支付成功/失败事件，以更新订单状态。
*   **通信方式:**
    *   **主要:** 通过 `go_router` 进行页面跳转和参数传递。
    *   **次要/未来:** 考虑引入 `event_bus` 或利用全局状态管理处理更复杂的跨模块状态同步。
*   **直接依赖:**
    *   明确**不应**直接 `import` 其他 **Feature** 模块的内部类。
    *   对核心服务 (`CoreDioClient`, `IAuthRepository`, `INavigationService`, `AppDatabase`) 的依赖通过DI注入。

### 11. 预览与测试入口 (Preview & Testing Entry Points)

*   **目的:** 为了方便独立开发和预览订单模块（包含售后）的UI和基本流程，项目提供了特定的入口文件，这些文件会配置依赖注入以使用 Mock 数据。
*   **买家视角预览:**
    *   **文件:** `lib/main_orders_preview.dart`
    *   **用途:** 作为买家视角订单相关功能（列表、详情、售后入口等）的预览入口。
    *   **运行:** `flutter run -t lib/main_orders_preview.dart -d <你的设备ID>`
    *   **说明:** 此入口会配置依赖注入容器，使用 `MockOrderRepository` 和 `MockAfterSalesRepository` (如果存在) 来提供模拟数据，绕过真实的网络请求。
*   **卖家视角预览:**
    *   **文件:** `lib/main_seller_orders_preview.dart` (假设存在，请确认文件名)
    *   **用途:** 作为卖家视角订单相关功能（列表、详情、发货、处理售后请求等）的预览入口。
    *   **运行:** `flutter run -t lib/main_seller_orders_preview.dart -d <你的设备ID>`
    *   **说明:** 同样配置DI使用 Mock 数据，专注于卖家工作流程。

---

**请确保在模块开发完成后，及时更新此 `README.md` 文档，保持其准确性。** 这将极大地帮助其他同事理解和集成你的工作成果。 