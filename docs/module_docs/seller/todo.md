# Seller 模块开发 TODO 清单 (细化版)

本清单基于模块边界定义、API 规范、现有代码分析和开发流程制定。

## 阶段 0: 准备工作

-   [x] **分析模块边界与范围**: 确认 Seller 模块的核心职责、包含与排除的功能。
    *   参考: `docs/BD/seller_boundary_definition.md`
-   [x] **分析 API 规范**: 理解 Seller 模块所需的数据接口，识别待确认的 API。
    *   参考: `docs/module_docs/seller/seller_api_specs.md`
-   [x] **分析参考代码**: 阅读 RN Demo 和 HTML 原型，理解现有 UI、业务逻辑和 API 使用情况。
    *   参考:
        *   RN: `design-info/demo-repository/app/(sellerscreens)/` (特别是 `profile/index.tsx`, `post/index.tsx`, `profile/authentication/index.tsx`, `profile/timeManage.tsx`)
        *   HTML: `design-info/HTML原型/HTML-new/sellerscreens/` (特别是 `profile/`, `post/` 目录下的文件)
-   [x] **确认缺失/待定 API**: 与后端团队沟通或进一步分析，明确所有"待定"或"需确认"的 API 细节 (端点、方法、请求/响应结构)。
    *   参考: `docs/module_docs/seller/seller_api_specs.md` (所有API现已完成确认)
-   [x] **创建模块目录结构**: 根据规范创建 `lib/features/seller/` 及其子目录 (`presentation`, `domain`, `data`)。
    *   参考: `docs/目录结构参考.md`
-   [x] **准备 Mock 实现**: 为依赖的外部接口 (如 `IOrderRepository`, `IChatRepository`, `IFileRepository`, `INavigationService` 等) 创建 Mock 类（使用 Mockito），用于隔离开发和单元测试。
    *   参考: `docs/BD/seller_boundary_definition.md` (依赖接口列表), Mockito 文档

## 阶段 1: Domain 层 (核心业务逻辑与契约)

-   **Entities Definition**: 在 `lib/features/seller/domain/entities/` 下创建实体类。
    -   [x] Create `seller_dashboard_data.dart`.
    -   [x] Create `seller_store_profile.dart`.
    -   [x] Create `seller_managed_product.dart` (定义与 `core/Product` 的关系).
    -   [x] Create `seller_notification.dart` (包含 `NotificationType` 枚举).
    -   [x] Create `seller_authentication_info.dart` (含 `AuthenticationType`, `AuthenticationStatus` 枚举).
    -   [x] Create `auto_reply_settings.dart` (参考 `Member` 定义中的 `recoverFlag`, `recoverContent` 字段).
    -   [x] Create `time_settings.dart` (含 `TimeSlot` 类，参考 `Member` 定义中的 `onlineFlag` 字段).
    -   [x] Create `enums/product_status.dart`.
    -   [x] Create `enums/order_refund_state.dart`.
        *   参考: `design-info/api/backend-api.json` 中的 `OrderRefund` 模型定义以及 API 文档
    -   [x] Create `enums/refund_type.dart`.
        *   参考: `design-info/api/backend-api.json` 中的 `OrderRefund` 模型定义以及 API 文档
    -   [x] Create `order_refund.dart`.
        *   参考: `design-info/api/backend-api.json` 中的 `OrderRefund` 模型定义以及 API 文档
    -   [x] Create `order_product_item.dart`.
        *   参考: `design-info/api/backend-api.json` 中的相关模型定义以及 API 文档
    -   [x] Create supporting classes/enums: `SellerProductFilter`, `ProductCreationData`, `ProductUpdateData`, `StoreProfileUpdateData`, `AuthenticationApplicationData`, `TimeSettingsData`.
    *   参考: `docs/BD/seller_boundary_definition.md` (3.1 节和"数据结构"部分), 新确认的 `docs/module_docs/seller/seller_api_specs.md` (Member与OrderRefund模型)
-   **Repository Interface Definition**:
    -   [x] Create `i_seller_repository.dart` in `lib/features/seller/domain/repositories/`.
    -   [x] Define all required methods within `ISellerRepository` (如 `getDashboardData`, `getSellerProductList`, `getNotificationList`, `updateOnlineStatus` 等)。
    *   参考: `docs/BD/seller_boundary_definition.md` (3.3 节), `docs/module_docs/seller/seller_api_specs.md` (现已确认的所有API)
-   **Use Cases Definition & Implementation**: 在 `lib/features/seller/domain/usecases/` 下创建 Use Case 文件。
    -   [x] Implement `GetSellerDashboardDataUseCase` (注入 `ISellerRepository`, 可能还有 `IOrderRepository`, `IChatRepository`).
    -   [x] Implement `GetSellerProductListUseCase` (注入 `ISellerRepository`).
    -   [x] Implement `GetSellerProductDetailUseCase` (注入 `ISellerRepository`).
    -   [x] Implement `CreateProductUseCase` (注入 `ISellerRepository`, `IFileRepository`).
    -   [x] Implement `UpdateProductUseCase` (注入 `ISellerRepository`, `IFileRepository`).
    -   [x] Implement `UpdateProductStatusUseCase` (注入 `ISellerRepository`).
    -   [x] Implement `DeleteProductUseCase` (注入 `ISellerRepository`).
    -   [x] Implement `GetStoreProfileUseCase` (注入 `ISellerRepository`).
    -   [x] Implement `UpdateStoreProfileUseCase` (注入 `ISellerRepository`, `IFileRepository`).
    -   [x] Implement `UpdateSellerOnlineStatusUseCase` (使用 `/api/member/update` API，注入 `ISellerRepository` 或 `IAuthRepository`).
    -   [x] Implement `SetAutoReplyUseCase` (使用 `/api/member/update` API，注入 `ISellerRepository`).
    -   [x] Implement `GetAutoReplyUseCase` (使用 `/api/member/info` API，注入 `ISellerRepository`).
    -   [x] Implement `UpdateSellerTimeSettingsUseCase` (使用 `/api/member/update` API，注入 `ISellerRepository`).
    -   [x] Implement `GetSellerTimeSettingsUseCase` (使用 `/api/member/info` API，注入 `ISellerRepository`).
    -   [x] Implement `GetSellerNotificationListUseCase` (使用 `/api/member/notification/messages` API，注入 `ISellerRepository`).
    -   [x] Implement `MarkNotificationAsReadUseCase` (使用 `/api/member/notification/read` API，注入 `ISellerRepository`).
    -   [x] Implement `MarkAllNotificationsAsReadUseCase` (使用 `/api/member/notification/mark-read` API，注入 `ISellerRepository`).
    -   [x] Implement `GetUnreadNotificationCountUseCase` (使用 `/api/member/notification/unreads` API，注入 `ISellerRepository`).
    -   [x] Implement `GetSellerAuthenticationStatusUseCase` (注入 `ISellerRepository`).
    -   [x] Implement `SubmitAuthenticationApplicationUseCase` (注入 `ISellerRepository`, `IFileRepository`).
    -   [x] Implement `AddOrderDeliveryUseCase` (注入 `ISellerRepository`, `IFileRepository`).
    -   [x] Implement `GetTenantAuditListUseCase` (使用 `/api/shop/order-refund/tenantAudit` API，注入 `ISellerRepository`).
    -   [x] Implement `AuditRefundUseCase` (使用 `/api/shop/order-refund/audit` API，注入 `ISellerRepository`).
    -   [x] Implement `GetChatRoomListUseCase` (使用 `/api/msg/getChatRoomList` 或 `/model/chat/list` API，注入 `IChatRepository`).
    *   确保所有 Use Case 添加 `@injectable` 注解。
    *   参考: `docs/BD/seller_boundary_definition.md` (3.2 节), `docs/module_docs/seller/seller_api_specs.md` (所有已确认API), `docs/模块开发核心工作流.md`, `docs/tech_stack.md` (DI 选型)

## 阶段 2: Data 层 (数据获取与实现)

-   **定义 Models/DTOs**: 在 `lib/features/seller/data/models/` 创建匹配 API 响应的 Dart 类，实现 `fromJson` 构造函数，并添加 `toEntity()` 方法用于转换为 Domain Entity。
    -   [x] 创建 `member_dto.dart` - 基于已确认的 `Member` 模型定义
        *   参考: `design-info/api/backend-api.json` 中的 `Member` 模型定义
    -   [x] 创建 `order_refund_dto.dart` - 基于已确认的 `OrderRefund` 模型定义
        *   参考: `design-info/api/backend-api.json` 中的 `OrderRefund` 模型定义以及 `/api/shop/order-refund/` 相关接口
    -   [x] 创建 `order_product_item_dto.dart` - 基于已确认的订单商品项模型定义
        *   参考: `design-info/api/backend-api.json` 中的相关模型定义以及 API 文档
    -   [x] 创建 `notification_dto.dart` - 基于通知API响应结构
        *   参考: `design-info/api/backend-api.json` 中的通知相关接口响应结构
    -   [x] 创建 `seller_managed_product_dto.dart` - 基于商品API响应结构
        *   参考: `design-info/api/backend-api.json` 中的商品相关接口响应结构
    -   [x] 创建 `seller_dashboard_dto.dart` - 基于仪表盘API响应结构
        *   参考: `/api/shop/dashboard/data` API响应结构
    -   [x] 创建 `seller_store_profile_dto.dart` - 基于店铺资料API响应结构
        *   参考: `/api/member/info` API响应结构
    -   [x] 创建 `authentication_info_dto.dart` - 基于认证API响应结构
        *   参考: `/api/member/authentication/status` API响应结构
    *   参考: `docs/module_docs/seller/seller_api_specs.md` 中已确认的API响应结构和模型定义
-   **DataSources Implementation**: 在 `lib/features/seller/data/datasources/` 创建接口和实现。
    -   [x] Define `ISellerRemoteDataSource` interface.
    -   [x] Implement `SellerRemoteDataSourceImpl` (注入 `Dio` from `core/network`), 实现调用各 Seller API 的方法，包括新确认的所有通知、聊天、在线状态、售后等API。添加 `@Injectable` 注解。
    -   [x] (If caching needed) Define `ISellerLocalDataSource` interface.
    -   [x] (If caching needed) Implement `SellerLocalDataSourceImpl` (注入 `AppDatabase` 或 `SharedPreferences` from `core`), 实现本地读写方法。添加 `@Injectable` 注解。
    *   参考: `docs/module_docs/seller/seller_api_specs.md` 中已确认的所有API, `docs/caching_and_local_storage_strategy_cn.md`, `docs/tech_stack.md` (DI)
-   **Repository Implementation**:
    -   [x] Create `seller_repository_impl.dart` in `lib/features/seller/data/repositories/`.
    -   [x] Implement `ISellerRepository` interface (注入 `ISellerRemoteDataSource`, `ISellerLocalDataSource` (if exists)).
    -   [x] 实现所有接口方法，编排对 DataSource 的调用，处理错误映射，实现缓存策略。
    -   [x] 添加 `@LazySingleton(as: ISellerRepository)` 注解。
    *   参考: `ISellerRepository` 接口定义, `docs/caching_and_local_storage_strategy_cn.md`, `docs/tech_stack.md` (DI)
-   [x] **更新依赖注入配置**: 运行 `flutter pub run build_runner build --delete-conflicting-outputs` 命令，确保 `injectable` 生成的配置包含新的 Seller 模块依赖。
    *   参考: `lib/app/di/injection_container.dart`, Injectable 文档

## 阶段 3: Presentation 层 (UI 与状态管理)

*注意: 在实现每个页面时，需要考虑并处理加载中 (Loading)、错误 (Error)、空数据 (Empty) 状态的 UI 展示。*

-   [x] **创建模块内可复用 Widgets**: 在 `lib/features/seller/presentation/widgets/` 目录下创建通用的 UI 组件 (如商品卡片、功能列表项、状态标签等)。
    *   已创建: `status_tag.dart` - 状态标签组件
    *   已创建: `product_card.dart` - 商品卡片组件
    *   已创建: `empty_state.dart` - 空状态组件
    *   已创建: `loading_state.dart` - 加载状态组件
    *   参考: RN/HTML 代码中的 UI 模式, `design-info/HTML原型/HTML-new/sellerscreens/` 中的组件样式
-   **Seller Home/Dashboard Page Implementation** (`lib/features/seller/presentation/pages/seller_home_page.dart`):
    -   [x] Build UI Layout: 顶部信息栏, 订单概览入口, 功能列表项。
    -   [x] Setup Bloc (`seller_home_bloc.dart`): Define States/Events, 使用 `flutter_bloc`, 添加 `@injectable`.
    -   [x] Integrate Use Cases: 在 Bloc 中注入并调用 `GetSellerDashboardDataUseCase`, `GetUserProfileUseCase` (from Auth/Profile) 等。
    -   [x] Handle States & UI Updates: 使用 `BlocBuilder`/`BlocListener` 连接 Bloc 和 UI。
    -   [x] Implement Navigation: 使用 `context.go()` 或 `context.push()` (GoRouter) 跳转。
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/profile/index.html`, `design-info/demo-repository/app/(sellerscreens)/profile/index.tsx`; Logic: `GetSellerDashboardDataUseCase`, `docs/BD/seller_boundary_definition.md`; Tech: `docs/tech_stack.md`
-   **Product Management Page Implementation** (`lib/features/seller/presentation/pages/product_management_page.dart`):
    -   [x] Build UI Layout: 实现 TabBar/TabView ("在卖", "草稿", "已下架").
    -   [x] Build List & Item UI: 商品列表 Widget (`ListView`/`FlashList`), 商品卡片 Widget (`lib/.../widgets/product_list_item.dart`).
    -   [x] Setup Bloc (`product_management_bloc.dart`): States/Events (列表数据, 加载, 错误, Tab切换), 添加 `@injectable`.
    -   [x] Integrate Use Cases: 调用 `GetSellerProductListUseCase` (带过滤参数), `UpdateProductStatusUseCase`.
    -   [x] Implement Actions: 处理编辑按钮 (导航), 上下架按钮 (触发 Bloc 事件), 发布按钮 (导航)。
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/post/index.html`, `design-info/demo-repository/app/(sellerscreens)/post/index.tsx`; Logic: `GetSellerProductListUseCase`, `UpdateProductStatusUseCase`
-   **Product Create/Edit Page Implementation** (`lib/features/seller/presentation/pages/product_edit_page.dart`):
    -   [x] Build UI Layout: 创建包含所有字段的表单 Widget.
    -   [x] Setup Bloc (`product_edit_bloc.dart`): States/Events (加载数据, 表单状态, 保存中, 成功, 失败), 添加 `@injectable`.
    -   [x] Integrate Use Cases: 调用 `GetSellerProductDetailUseCase` (编辑时), `CreateProductUseCase`, `UpdateProductUseCase`.
    -   [x] Handle Form & Image Upload: 管理表单状态, 处理图片选择和上传逻辑 (调用 `IFileRepository`).
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/post/id/edit.html`, `design-info/demo-repository/app/(sellerscreens)/post/[id]/edit.tsx`; Logic: `CreateProductUseCase`, `UpdateProductUseCase`, `GetSellerProductDetailUseCase`
-   **Authentication Management Page Implementation** (`lib/features/seller/presentation/pages/auth_management_page.dart`):
    -   [x] Build UI Layout: 列表展示已认证项和状态, 网格展示开放认证项。
    -   [x] Setup Bloc (`auth_management_bloc.dart`): States/Events (列表数据, 加载, 错误), 添加 `@injectable`.
    -   [x] Integrate Use Case: 调用 `GetSellerAuthenticationStatusUseCase`.
    -   [x] Implement Navigation: 跳转到具体认证流程页面。
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/profile/authentication/index.html`, `design-info/demo-repository/app/(sellerscreens)/profile/authentication/index.tsx`; Logic: `GetSellerAuthenticationStatusUseCase`
-   **Authentication Application Page(s) Implementation** (`lib/features/seller/presentation/pages/auth_application_page.dart` - 可能需要动态或多个):
    -   [x] Build UI Layout: 根据认证类型动态生成表单。
    -   [x] Setup Bloc (`auth_application_bloc.dart`): States/Events (表单状态, 提交中, 成功, 失败), 添加 `@injectable`.
    -   [x] Integrate Use Case: 调用 `SubmitAuthenticationApplicationUseCase`.
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/profile/authentication/apply.html`; Logic: `SubmitAuthenticationApplicationUseCase`
-   **Time Management Page Implementation** (`lib/features/seller/presentation/pages/time_management_page.dart`):
    -   [x] Build UI Layout: 在线开关, 时间段设置界面。
    -   [x] Setup Bloc (`time_management_bloc.dart`): States/Events (当前设置, 更新中, 成功, 失败), 添加 `@injectable`.
    -   [x] Integrate Use Cases: 调用 `GetSellerTimeSettingsUseCase` (使用 `/api/member/info`), `UpdateSellerTimeSettingsUseCase` (使用 `/api/member/update`), `UpdateSellerOnlineStatusUseCase` (使用 `/api/member/update`).
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/profile/time_settings.html`, `design-info/demo-repository/app/(sellerscreens)/profile/timeManage.tsx`; Logic: Member模型的onlineFlag字段, `docs/module_docs/seller/seller_api_specs.md`
-   **Notification List Page Implementation** (`lib/features/seller/presentation/pages/notification_list_page.dart`):
    -   [x] Build UI Layout: 通知列表, 通知详情, 标记已读按钮。
    -   [x] Setup Bloc (`notification_list_bloc.dart`): States/Events (列表数据, 分页, 加载, 错误), 添加 `@injectable`.
    -   [x] Integrate Use Cases: 调用 `GetSellerNotificationListUseCase` (使用 `/api/member/notification/messages`), `MarkNotificationAsReadUseCase` (使用 `/api/member/notification/read`), `MarkAllNotificationsAsReadUseCase` (使用 `/api/member/notification/mark-read`), `GetUnreadNotificationCountUseCase` (使用 `/api/member/notification/unreads`).
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/profile/notification/seller_notification.html`; Logic: 相关 Use Cases, `docs/module_docs/seller/seller_api_specs.md`
-   **Auto Reply Settings Page Implementation** (`lib/features/seller/presentation/pages/auto_reply_page.dart`):
    -   [x] Build UI Layout: 开关, 文本输入框。
    -   [x] Setup Bloc (`auto_reply_bloc.dart`): States/Events (当前设置, 更新中, 成功, 失败), 添加 `@injectable`.
    -   [x] Integrate Use Cases: 调用 `GetAutoReplyUseCase` (使用 `/api/member/info`的recoverFlag和recoverContent字段), `SetAutoReplyUseCase` (使用 `/api/member/update`).
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/profile/auto_reply.html`; Logic: Member模型的recoverFlag和recoverContent字段, `docs/module_docs/seller/seller_api_specs.md`
-   **Order Delivery Feature Implementation**: (集成到订单流程中)
    -   [x] Design UI Flow: 决定在何处触发和展示交付物提交界面。
    -   [x] Build UI Component: 文本输入, 文件选择/上传 Widget.
    -   [x] Setup Bloc/State Logic: 处理提交事件, 调用 `AddOrderDeliveryUseCase` (使用 `/api/project/orderDelivery/add` API).
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/profile/orders/seller_order_detail.html`; Logic: `AddOrderDeliveryUseCase`, `OrderDelivery`模型, `docs/module_docs/seller/seller_api_specs.md`
-   **After-Sales Review Feature Implementation**: (列表和审核操作)
    -   [x] Build UI Layout (`after_sales_review_page.dart`): 售后申请列表及详情展示。
    -   [x] Setup Bloc (`after_sales_review_bloc.dart`): States/Events (列表数据, 审核中, 成功, 失败), 添加 `@injectable`.
    -   [x] Integrate Use Cases: 调用 `GetTenantAuditListUseCase` (使用 `/api/shop/order-refund/tenantAudit` API), `AuditRefundUseCase` (使用 `/api/shop/order-refund/audit` API).
    *   参考: UI: `design-info/HTML原型/HTML-new/sellerscreens/profile/orders/seller_order_refund.html`; Logic: 相关 Use Cases, `OrderRefund`模型, `docs/module_docs/seller/seller_api_specs.md`
-   **Route Configuration**:
    -   [x] Create `seller_routes.dart` in `lib/features/seller/presentation/routes/`.
    -   [x] Define `GoRoute` objects for all Seller pages, linking paths to page Widgets. Expose `List<RouteBase>`.
    *   参考: `docs/modular_routing_strategy_cn.md`, `go_router` 文档
    -   [x] Modify `lib/core/router/app_router.dart`: Import `seller_routes.dart` and add `...SellerRoutes.routes` to the main routes list.
    *   参考: `