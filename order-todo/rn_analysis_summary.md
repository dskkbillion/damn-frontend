# Order 模块 RN 代码分析总结

本文档记录了在为 Flutter 重构 `Orders` 模块进行边界定义时，对 React Native 参考代码 (`design-info/demo-repository`) 的分析过程和关键发现。

## 分析目标

验证和细化初步的边界定义 (`docs/BD/orders_boundary_definition.md`)，明确 API 细节、状态管理、核心实体结构、用户操作流程和模块交互。

## 分析文件路径

*   **API 定义:** `design-info/api/backend-api.json` (提供了基础参考，但部分与代码实现不一致)
*   **订单列表 Slice:** `design-info/demo-repository/src/slices/orderListSlice.ts`
*   **订单相关 Actions/Thunks:** `design-info/demo-repository/src/util/orderActions.ts` (关键文件，定义了 API 调用和状态映射)
*   **订单详情 Slice:** `design-info/demo-repository/src/slices/orderSlice.ts` (推测管理详情状态)
*   **订单列表页面:** `design-info/demo-repository/app/(tabs)/profile/orders/index.tsx`
*   **订单详情页面:** `design-info/demo-repository/app/(tabs)/profile/orders/[transaction_id]/index.tsx`
*   **订单详情底部按钮:** `design-info/demo-repository/components/orders/fixed_bottom_buyer.tsx`
*   **物流/交付组件:** `design-info/demo-repository/components/orders/delivery_comp.tsx`

## 关键发现

1.  **API 与代码实现优先:**
    *   分析发现 API 文档 (`backend-api.json`) 与实际代码 (`orderActions.ts`) 中调用的端点、方法存在不一致。例如，获取订单列表实际使用 `POST /api/shop/order/list`，获取详情使用 `GET /api/shop/order/detail`。
    *   **结论: Flutter 实现应以 `orderActions.ts` 中确认的实际 API 调用为准。**

2.  **`orderInfo` 类型定义不准确:**
    *   `orderActions.ts` 中为订单详情 API (`GET /api/shop/order/detail`) 定义的 `orderInfo` TypeScript 接口缺少关键字段，如 `state` (订单状态字符串) 和 `items` (商品列表)。
    *   然而，订单详情页 (`index.tsx`) 的 RN 代码明确使用了这些字段 (`orderData.state`, `order.items`)，表明 API 实际返回了这些数据。
    *   **结论: API 实际返回的订单详情结构比 `orderInfo` 类型定义更完整，接近列表项使用的 `orderDetail` 类型。Flutter 的 `OrderModel` 和 `Order` 实体应基于这个更完整的实际结构进行设计。**

3.  **`OrderStatus` 状态值确认:**
    *   后端通过字符串形式返回订单状态。
    *   通过分析 `orderActions.ts` (Thunk 中的状态映射) 和订单详情页组件的逻辑，确认了实际使用的状态字符串值，例如: `awaitingPayment`, `awaitingSubmission`, `awaitingDelivery`, `awaitingConfirmation`, `orderCompleted`, `canceled`, `afterSale` 等。
    *   **结论: 这些字符串应作为 Flutter `Domain` 层 `OrderStatus` 枚举的基础，并需实现相应的映射。**

4.  **`OrderAction` 操作映射确认:**
    *   RN 代码通过判断 `order.state` 来决定显示哪些操作按钮。
    *   分析 `fixed_bottom_buyer.tsx` 组件确认了关键操作的映射关系：
        *   "确认收货" 按钮 (`awaitingConfirmation` 或 `applyForRefuse` 状态下) 触发 `completeOrder` Thunk，调用 `PUT /api/shop/order/complete` API。
        *   "取消订单" 按钮 (`awaitingStart` 状态下) 触发 `cancelOrder` Thunk，调用 `PUT /api/shop/order/cancel` API。
    *   `orderActions.ts` 中还定义了其他操作（如提交材料、评价、删除等）对应的 Thunks 和 API 调用。
    *   **结论: Flutter `Presentation` 层需要根据 `Order.state` 推断可用的 `OrderAction`，并将按钮事件连接到相应的 `UseCase` 调用。**

5.  **实体结构 (`Order` / `OrderSummary`)**:
    *   分析表明，订单列表 API (`POST /api/shop/order/list`) 返回的 `rows` 数组中的每个对象，以及订单详情 API (`GET /api/shop/order/detail`) 返回的对象，都包含了丰富的订单信息 (包括 `items`, `state`, 地址字段等)。
    *   **建议: Flutter 的核心 `Order` 实体直接映射这个详细结构。用于列表展示的 `OrderSummary` 在 `Domain` 层可以与 `Order` 结构保持一致（因为 API 未提供简化版本），或者在需要时由 `Repository` 或 `UseCase` 进行投影简化。**

6.  **物流信息处理方式:**
    *   分析物流相关的组件 (`delivery_comp.tsx`) 未发现独立的 API 调用来获取实时物流轨迹。
    *   推测基础的物流信息 (如物流单号 `logisticsNo`) 已包含在 `GET /api/shop/order/detail` 的响应中。
    *   **结论: 该 App 很可能未实现详细的实时物流跟踪功能。Flutter 的 `OrderShippingInfo` 实体应只包含确认存在的字段 (如 `logisticsId`, `logisticsNo`)，移除或标记 `trackingUpdates` 字段为未实现/可选。相应的 `GetOrderTrackingInfoUseCase` 也不再需要。**
    *   `createQueryOrderDelivery` (`GET /api/project/order/queryOrderDelivery`) Thunk 的实际用途在此模块中未明确，可能用于其他流程或已废弃。

7.  **状态管理与流程:**
    *   RN 使用 Redux Toolkit Slices (`orderListSlice`, `orderSlice`) 管理状态。
    *   使用 Redux Thunk (`orderActions.ts`) 处理异步 API 调用和副作用。
    *   页面 UI 根据 Redux 状态 (`order.state`) 动态渲染不同的组件和按钮。

## 待办与不确定性

*   `GET /api/shop/order/detail` 返回的**精确**字段列表：虽然分析表明其结构详细，但完整的字段清单最好由后端确认或通过抓包获取。不过，现有信息足以进行 Flutter 设计。
*   `createQueryOrderDelivery` API 的**真实**用途：在当前订单流程中未找到其调用点。
*   部分 `OrderStatus` 字符串 (如 `applyForRefuse`, `sellerSupplementaryMaterials`) 的**确切**业务含义和流转条件：需要在实现过程中结合业务需求进一步明确。

## 下一步

基于本分析总结和最终确定的边界定义 (`order-todo/orders_boundary_definition_final.md`)，可以开始进行 Flutter `Orders` 模块的 `Domain` 层接口精化和 `Data` 层实现。参考 `order-todo/refactoring_todo.md` 进行过程控制。 