# Seller 模块 API 规范

本文档记录 Seller 模块 Data 层实现所需的后端 API 详细规范。
**注:** 本文档基于 `design-info/api/backend-api.json` OpenAPI 文件和 RN 代码分析进行更新。

## 1. 仪表盘/统计 (Dashboard/Statistics)

*   **获取核心统计指标**
    *   **Endpoint:** `POST /api/project/statistics/index`
    *   **Method:** POST
    *   **Description:** 获取卖家仪表盘核心统计数据 (如收入、订单数等)。*(OpenAPI 文件中未找到此接口，需进一步确认)*
    *   **Request Body:** 空 (Empty)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string, "data": any }` (**`data` 字段具体结构待确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **(可选) 获取百分比统计**
    *   **Endpoint:** `POST /api/project/statistics/percent`
    *   **Method:** POST
    *   **Description:** 获取卖家仪表盘的百分比相关统计数据 (如增长率等)。*(OpenAPI 文件中未找到此接口，需进一步确认)*
    *   **Request Body:** 空 (Empty)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string, "data": any }` (**`data` 字段具体结构待确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **(可选) 获取升级相关统计**
    *   **Endpoint:** `POST /api/project/statistics/upgradeLevel`
    *   **Method:** POST
    *   **Description:** 获取卖家升级相关的数据或条件。*(OpenAPI 文件中未找到此接口，需进一步确认)*
    *   **Request Body:** 空 (Empty)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string, "data": any }` (**`data` 字段具体结构待确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

## 2. 商品管理 (Product Management)

*   **获取卖家商品列表 (已发布/全部)**
    *   **Endpoint:** `POST /api/shop/product/myList` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 获取卖家发布的商品列表，可通过请求体中的字段筛选。
    *   **Request Body:** 基于 `PageDomain` 定义。RN 代码传递 `{ "state": "..." }`，可能还支持分页参数 (`pageNum`, `pageSize`)。(**PageDomain 定义需参考 OpenAPI**)
    *   **Response Body (200 OK):** 基于 `TableDataInfo` 定义，包含 `total` (总数) 和 `rows` (列表)。(**`rows` 中商品对象 DTO 结构在 TableDataInfo 定义中未明确指定，需进一步确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **获取卖家商品列表 (草稿箱)**
    *   **Endpoint:** `POST /api/shop/product/myDraft` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 获取卖家草稿箱中的商品列表 (分页)。
    *   **Request Body:** 基于 `PageDomain` 定义。RN 代码传递 `{ "pageNum": number, "pageSize": number }`。(**PageDomain 定义需参考 OpenAPI**)
    *   **Response Body (200 OK):** 基于 `TableDataInfo` 定义，包含 `total` (总数) 和 `rows` (列表)。(**`rows` 中草稿对象 DTO 结构在 TableDataInfo 定义中未明确指定，需进一步确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **获取商品详情**
    *   **Endpoint:** `GET /api/shop/product/get` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 根据商品 ID 获取商品详细信息。
    *   **Request Query Parameters:** `{ "id": number }` (必需) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构，包含 `code`, `msg`, `data`。(**`data` 字段类型为 `object`，但其内部属性在 OpenAPI 定义中为空 `{}`，需进一步确认商品详情 DTO 结构**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **商品上架/下架**
    *   **Endpoint:** `POST /api/shop/product/edit` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 更新指定商品的状态 (上下架)。
    *   **Request Body:** 基于 `Product` 定义。RN 代码行为表明主要传递 `id` 和 `state` 字段 (`state` 可取 "NORMAL", "DISABLED")。(**Product 定义需参考 OpenAPI**)
    *   **Response Body (200 OK):** 基于 `AjaxResult` 定义。(**AjaxResult 定义不完整，推测含 code/msg**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **创建商品**
    *   **Endpoint:** `POST /api/shop/product/create` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 创建一个新的商品。
    *   **Request Body:** 基于 `Product` 定义，包含 `name`, `images`, `description`, `variants`, `productMaterials` 等字段。(**Product 定义需参考 OpenAPI，特别是 `variants` 和 `productMaterials` 的嵌套结构**)
    *   **Response Body (200 OK):** 基于 `AjaxResult` 定义，不包含新商品 ID 或对象。(**AjaxResult 定义不完整**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **编辑商品 (全量更新)**
    *   **Endpoint:** `POST /api/shop/product/update` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 更新指定商品的详细信息。
    *   **Request Body:** 基于 `Product` 定义，包含需要更新的所有字段。(**Product 定义需参考 OpenAPI**)
    *   **Response Body (200 OK):** 基于 `AjaxResult` 定义。(**AjaxResult 定义不完整**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **删除商品**
    *   **Endpoint:** `POST /api/shop/product/delete` (**根据 OpenAPI 新增**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 删除指定的一个或多个商品。
    *   **Request Body:** `integer[]` (商品 ID 数组) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** 基于 `AjaxResult` 定义。(**AjaxResult 定义不完整**)
    *   **Response Body (Error):** `AjaxResult` 结构

## 3. 订单管理 (Order Management - Seller 相关)

*   **获取卖家订单列表**
    *   **Endpoint:** `POST /api/shop/order/list` (**已在 RN 代码中确认**)
    *   **Method:** POST (**已在 RN 代码中确认**)
    *   **Description:** 获取当前卖家的订单列表，支持分页、搜索和状态过滤。
    *   **Request Body:** 
        ```json
        {
          "pageNum": number, // 必需
          "pageSize": number, // 必需
          "type": "seller", // 必需, 固定值
          "keyword": string, // 可选, 搜索关键词
          "states": string[] // 可选, 订单状态数组 (e.g., ["awaitingVerification"], ["completed", "toBeEvaluated"])
        }
        ```
        (**已在 RN 代码中确认**)
    *   **Response Body (200 OK):** 分页 `AjaxResult` 结构:
        ```json
        {
          "code": 200,
          "msg": string,
          "total": number, // 总记录数
          "rows": [ // 订单对象数组 (orderDetail 结构)
            {
              "id": number,
              "orderSn": string,
              "state": string, // 订单状态
              "payPrice": number,
              "buyer": { /* buyerInfo */ },
              "tenant": { /* tenantInfo */ },
              "items": [ { /* orderItem */ } ],
              // ... 更多 orderDetail 字段
            }
          ]
        }
        ```
        (**已在 RN 代码中确认**)
    *   **Response Body (Error):** `AjaxResult` 结构: `{ "code": number (非200), "msg": string, ... }` 或 `{ "message": string }` (网络错误等)

*   **获取订单详情**
    *   **Endpoint:** `GET /api/shop/order/detail` (**已在 RN 代码中确认**)
    *   **Method:** GET (**已在 RN 代码中确认**)
    *   **Description:** 根据订单 ID 获取订单详细信息。
    *   **Request Query Parameters:** `{ "id": number }` (**已在 RN 代码中确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string, "data": object }` (data 为 `orderDetail` 结构) (**已在 RN 代码中确认**)
    *   **Response Body (Error):** `AjaxResult` 结构: `{ "code": number (非200), "msg": string, ... }` 或 `{ "message": string }` (网络错误等)

*   **确认接单 (Verify Order)**
    *   **Endpoint:** `/api/shop/order/verify?orderId={订单ID}` (**已在 RN 代码中确认**)
    *   **Method:** POST (**已在 RN 代码中确认** - 注意：虽然是 POST，但订单 ID 在 Query 参数中传递)
    *   **Description:** 卖家确认接受订单。
    *   **Request URL Query Parameter:** `orderId={订单ID}` (必需) (**已在 RN 代码中确认**)
    *   **Request Body:** `{}` (空对象) (**已在 RN 代码中确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string }` (**已在 RN 代码中确认**)
    *   **Response Body (Error):** `AjaxResult` 结构: `{ "code": number (非200), "msg": string, ... }` 或 `{ "message": string }` (网络错误等)

*   **完成订单 (Complete Order)**
    *   **Endpoint:** `GET /api/shop/order/complete` (**已在 RN 代码中确认**)
    *   **Method:** GET (**已在 RN 代码中确认**)
    *   **Description:** 卖家确认订单完成。
    *   **Request Query Parameters:** `{ "orderId": number }` (必需) (**已在 RN 代码中确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string }` (**已在 RN 代码中确认**)
    *   **Response Body (Error):** `AjaxResult` 结构: `{ "code": number (非200), "msg": string, ... }` 或 `{ "message": string }` (网络错误等)

*   **取消订单 (Cancel Order)**
    *   **Endpoint:** `GET /api/shop/order/cancel` (**已在 RN 代码中确认**)
    *   **Method:** GET (**已在 RN 代码中确认**)
    *   **Description:** 卖家或买家取消订单。
    *   **Request Query Parameters:** `{ "orderId": string }` (必需) (**已在 RN 代码中确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string }` (**已在 RN 代码中确认**)
    *   **Response Body (Error):** `AjaxResult` 结构: `{ "code": number (非200), "msg": string, ... }` 或 `{ "message": string }` (网络错误等)

*   **卖家删除订单 (Seller Delete Order)**
    *   **Endpoint:** `/api/shop/order/sellerDelete?orderId={订单ID}` (**已在 RN 代码中确认**)
    *   **Method:** POST (**已在 RN 代码中确认** - 注意：虽然是 POST，但订单 ID 在 Query 参数中传递)
    *   **Description:** 卖家逻辑删除订单记录。
    *   **Request URL Query Parameter:** `orderId={订单ID}` (必需, number) (**已在 RN 代码中确认**)
    *   **Request Body:** `{}` (空对象) (**已在 RN 代码中确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string }` (**已在 RN 代码中确认**)
    *   **Response Body (Error):** `AjaxResult` 结构: `{ "code": number (非200), "msg": string, ... }` 或 `{ "message": string }` (网络错误等)

*   **交付订单 (Order Delivery)**
    *   **Endpoint:** `POST /api/project/orderDelivery/add` (**已在 RN 代码中确认，需在 OpenAPI 确认**)
    *   **Method:** POST (**已在 RN 代码中确认**)
    *   **Description:** 卖家提交订单交付信息。
    *   **Request Body:** `{ "orderId": number, "content": string, "files": string[] }` (必需) (**已在 RN 代码中确认，需在 OpenAPI 确认结构**)
    *   **Response Body (200 OK):** `AjaxResult` 结构 (**需在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

## 3.3 售后管理 (Refund/After-sales Management - Seller 相关)

*   **查询售后详情**
    *   **Endpoint:** `GET /api/shop/order-refund/detail` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 获取售后/退款详情。
    *   **Request Query Parameters:** `{ "id": number }` (可选) (**已在 OpenAPI 确认**)
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构，包含 `data` 为 `OrderRefund` 对象 (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **买家售后列表**
    *   **Endpoint:** `POST /api/shop/order-refund/list` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 获取买家所有售后/退款列表。
    *   **Request Body:** 基于 `OrderRefundQuery` 定义 (分页参数) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `TableDataInfo` 结构，包含 `rows` 为 `OrderRefund` 数组 (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **查询卖家售后审核列表 (Fetch Tenant Refund Item List)**
    *   **Endpoint:** `POST /api/shop/order-refund/tenantAudit` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 获取待卖家审核的售后/退款列表。
    *   **Request Body:** 基于 `OrderRefundQuery` 定义，支持分页及筛选 (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `TableDataInfo` 结构，包含 `rows` 为 `OrderRefund` 对象数组 (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **卖家售后审核 (Audit Refund)**
    *   **Endpoint:** `POST /api/shop/order-refund/audit` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 卖家审核售后/退款申请。
    *   **Request Body:** `{ "id": number, "refundState": string, "auditRemark": string }` (**已在 OpenAPI 确认**)
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构 (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **取消售后申请**
    *   **Endpoint:** `GET /api/shop/order-refund/cancel` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 取消售后/退款申请。
    *   **Request Query Parameters:** `{ "refundId": string }` (必需) (**已在 OpenAPI 确认**)
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构 (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **删除售后记录**
    *   **Endpoint:** `POST /api/shop/order-refund/delete` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 删除售后/退款记录。
    *   **Request Body:** `integer[]` (售后ID数组) (**已在 OpenAPI 确认**)
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构 (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

## 4. 店铺资料 / 用户信息 (Store Profile / User Info)

*   **获取用户信息 (含部分店铺资料)**
    *   **Endpoint:** `GET /api/member/info` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 获取当前登录用户的详细信息，可能包含部分店铺资料字段。
    *   **Request Params/Body:** 无 (通过 Header Token 识别)
    *   **Response Body (200 OK):** `AjaxResult` 结构，包含 `code`, `msg`, `data`。(**`data` 字段类型为 `object`，但其内部属性在 OpenAPI 定义中为空 `{}`，推测其结构对应 `Member` 定义，需进一步确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **更新用户信息 / 设置 (含自动回复)**
    *   **Endpoint:** `POST /api/member/update` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 更新用户信息或相关设置。可用于更新昵称、头像等基础信息，以及设置自动回复。
    *   **Request Body:** 基于 `Member` 定义，包含需要更新的字段 (如 `nickName`, `avatar`, `recoverFlag`, `recoverContent`)。(**Member 定义需参考 OpenAPI**)
    *   **Response Body (200 OK):** 基于 `AjaxResult` 定义。(**AjaxResult 定义不完整**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **更新指定资料字段**
    *   **Endpoint:** `POST /api/member/edit` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 通过指定字段名和值更新资料。
    *   **Request Body:** `{ "fieldName": string, "fieldValue": string, "fieldType": integer }` (必需) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string }` (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

## 5. 卖家状态 (Seller Status)

*   **更新卖家在线状态**
    *   **Endpoint:** `/api/member/update` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 设置卖家当前的在线状态。
    *   **Request Body:** 基于 `Member` 定义的对象，包含 `onlineFlag` (boolean) 字段 (**已从 RN 代码确认**)
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": 200, "msg": string }` (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

## 6. 聊天相关 (Chat)

*   **获取聊天会话列表**
    *   **Endpoint:** `/api/msg/getChatRoomList` (**RN 代码中确认使用，OpenAPI 中定义路径为 `/model/chat/list`**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 获取与卖家相关的聊天会话列表概览。
    *   **Request Body:** `{ "user_id": number }` (**已在 API 文档中确认**)
    *   **Request Headers:** 标准 header 参数，包括 `X-Request-ID` (**已在 API 文档中确认**)
    *   **Response Body (200 OK):**
        ```json
        {
          "code": 200,
          "message": "获取成功",
          "data": {
            "total": number,
            "conversations": [
              {
                "id": number,
                "title": string,
                "user_id": number,
                "created_at": number,
                "updated_at": number
              }
            ]
          }
        }
        ```
    *   **Response Body (Error):** 错误响应结构

## 7. 自动回复 (Auto Reply)

*   **获取自动回复设置**
    *   **Endpoint:** `/api/member/info` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 获取当前卖家的自动回复设置，作为用户信息的一部分返回 `recoverFlag` 和 `recoverContent` 字段。
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构，包含 `Member` 对象，其中有 `recoverFlag` (boolean) 和 `recoverContent` (string) 字段
    *   **Response Body (Error):** `AjaxResult` 结构

*   **设置自动回复**
    *   **Endpoint:** `POST /api/member/update` (**已确认，通过更新 `Member` 对象**)
    *   **Method:** POST
    *   **Description:** 启用/禁用自动回复并设置内容。
    *   **Request Body:** 基于 `Member` 定义，传递 `recoverFlag` (boolean) 和 `recoverContent` (string)。
    *   **Response Body (200 OK):** 基于 `AjaxResult` 定义。
    *   **Response Body (Error):** `AjaxResult` 结构

## 8. 时间设置 (Time Settings)

*   **获取时间设置**
    *   **Endpoint:** `/api/member/info` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 获取当前卖家的在线时间等设置，作为用户信息的一部分返回，包含 `onlineFlag` 字段。
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构，包含 `Member` 对象
    *   **Response Body (Error):** `AjaxResult` 结构

*   **更新时间设置**
    *   **Endpoint:** `/api/member/update` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 更新卖家的在线时间等设置，通过更新 `Member` 对象的 `onlineFlag` 字段。
    *   **Request Body:** 基于 `Member` 定义，传递 `onlineFlag` (boolean)。
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构 (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

## 9. 通知 (Notifications)

*   **获取通知列表**
    *   **Endpoint:** `/api/member/notification/messages` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 获取卖家收到的通知列表。
    *   **Request Query Parameters:** `{ "messageType": string }` (可选) (**已在 OpenAPI 确认**)
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构，包含通知列表
    *   **Response Body (Error):** `AjaxResult` 结构

*   **标记通知已读**
    *   **Endpoint:** `/api/member/notification/read` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 将指定通知标记为已读。
    *   **Request Query Parameters:** `{ "id": string }` (可选) (**已在 OpenAPI 确认**)
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": number, "msg": string }` (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **标记所有通知已读**
    *   **Endpoint:** `/api/member/notification/mark-read` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 将所有通知标记为已读。
    *   **Request Query Parameters:** `{ "messageTypes": string }` (可选) (**已在 OpenAPI 确认**)
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构: `{ "code": number, "msg": string }` (**已在 OpenAPI 确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **获取未读通知数量**
    *   **Endpoint:** `/api/member/notification/unreads` (**已在 OpenAPI 确认**)
    *   **Method:** GET (**已在 OpenAPI 确认**)
    *   **Description:** 获取未读通知数量。
    *   **Request Headers:** `clienttype`, `client`, `version`, `Authorization` (可选) (**已在 OpenAPI 确认**)
    *   **Response Body (200 OK):** `AjaxResult` 结构，包含未读通知计数
    *   **Response Body (Error):** `AjaxResult` 结构

## 10. 认证 (Authentication)

*   **获取认证状态/信息列表**
    *   **Endpoint:** `POST /api/project/authentication/list` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 获取当前用户的所有认证项及其状态信息。
    *   **Request Body:** 基于 `PageDomain` 定义 (分页参数可能可选)。
    *   **Response Body (200 OK):** 基于 `TableDataInfo` 定义。(**`rows` 中认证项 DTO 结构在 TableDataInfo 定义中未明确指定，需进一步确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

*   **提交认证申请**
    *   **Endpoint:** `POST /api/project/authenticationAudit/add` (**已在 OpenAPI 确认**)
    *   **Method:** POST (**已在 OpenAPI 确认**)
    *   **Description:** 提交新的卖家认证申请。
    *   **Request Body:** 内联对象，包含 `authenticationId`, `authenticationType`, `name`, `reamrk`, `images` (string - 格式待确认), `feature` (`JSONObjectAddValidated` - 结构待确认)。(**已在 OpenAPI 确认基础结构**)
    *   **Response Body (200 OK):** 基于 `AjaxResultAddValidated` 定义。(**结构待确认**)
    *   **Response Body (Error):** `AjaxResult` 结构

## 通用模型 (Common Models - 部分来自 OpenAPI 分析)

*   **`AjaxResult`**: OpenAPI 定义不完整 (`{"key":{}}`)，推测应包含 `code` (integer), `msg` (string), 可能有 `data` (any)。
*   **`TableDataInfo`**: 包含 `total` (integer), `rows` (array)。`rows` 中对象的具体 DTO 结构未在 OpenAPI 中定义。
*   **`PageDomain`**: 包含大量字段，可能用于过滤，也可能隐式支持 `pageNum`, `pageSize` 等分页参数。
*   **`Product`**: 包含商品核心字段及对 `ProductVariant`, `ProductMaterials`, `ProductOption` 的引用。
*   **`Member`**: 用户/会员模型定义，包含以下主要字段：
    ```json
    {
      "id": number,
      "nickName": string,
      "avatar": string,
      "mobile": string,
      "status": string, // 状态：WAIT, ENABLE, DISABLE, LOGOUT, BLACKLIST
      "gender": string, // MALE, FEMALE, NONE
      "recoverFlag": boolean, // 是否自动回复
      "recoverContent": string, // 自动回复内容
      "onlineFlag": boolean, // 卖家在线状态
      "productNum": number, // 发布商品数量
      "orderNum": number, // 接单数量
      "buyOrderNum": number // 购买数量
    }
    ```
*   **`ProductVariant`**: 包含规格的价格、库存等信息。
*   **`ProductMaterials`**: 包含 `question`, `answer`, `type`。
*   **`OrderRefund`**: 售后退款数据模型，包含以下主要字段：
    ```json
    {
      "id": number,
      "creatorId": number,
      "refundState": string, // 状态：如 WAIT_AUDIT, AUDIT_PASS, AUDIT_REJECT, CANCEL 等
      "refundType": string, // 类型：如 ONLY_MONEY, MONEY_AND_PRODUCT 等
      "refundReason": string,
      "refundRemarks": string,
      "refundAmount": number,
      "auditRemark": string,
      "createTime": string,
      "images": string, // 逗号分隔的图片URL
      "order": { /* Order对象 */ },
      "orderProductItem": { /* 订单商品项对象 */ }
    }
    ```
*   **`OrderRefundQuery`**: 查询售后退款的参数模型，包含分页参数及筛选条件。
*   **`OrderDelivery`**: 订单交付数据模型，包含订单ID、交付内容、文件等信息。
*   *(其他如 `ProductOption`, `JSONObjectAddValidated`, `AjaxResultAddValidated` 等定义需进一步查找确认)*
