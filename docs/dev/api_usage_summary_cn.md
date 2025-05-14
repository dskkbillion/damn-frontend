# API 调用方式与数据结构总结 (中文)

本文档总结了项目前端与后端 API 交互的关键信息，基于对 `design-info/api/backend-api.json` 的分析和实际测试结果。

## 1. 通用约定

*   **基础 URL**: 从 `.env` 文件中的 `BACKEND_BASE_URL` 读取。
*   **认证**: 
    *   需要认证的接口，在请求头 (Header) 中添加 `Authorization` 字段。
    *   `Authorization` 头的值为从安全存储 (`flutter_secure_storage`, key: `'user_token'`) 中读取到的**原始 Token 字符串** (登录时获取)，**不需要** `Bearer ` 前缀。
    *   示例: `Authorization: eyJhbGciOiJIUzUxMiJ9...`
*   **响应结构**: 大部分接口（尤其操作类接口）遵循 `{"code": <状态码>, "msg": "<消息>", "data": <实际数据>}` 的结构。前端在处理响应时应优先检查 `code` 字段 (例如 `code == 200` 代表业务成功)，并从 `data` 字段中提取所需信息（如果 `data` 非 null）。HTTP 状态码 `200` 通常表示请求被服务器成功处理，但不代表业务逻辑一定成功。

## 2. 接口详解

### 2.1. `/api/shop/order/list` (订单列表)

*   **方法**: `POST`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求体 (JSON)**:
    ```json
    {
      "pageNum": <integer>, // 页码 (必需)
      "pageSize": <integer>, // 每页数量 (必需)
      "keyword": "<string>", // 关键词 (可选)
      "state": "<string>" // 状态筛选 (可选, 需映射 OrderStatus)
    }
    ```
*   **成功响应 (`data` 字段结构)**:
    ```json
    {
      "total": <integer>,
      "rows": [ // 订单对象数组
        {
          "id": <integer>,
          "orderSn": "<string>",
          "state": "<string>",
          // ... totalPrice, payPrice 等为 integer
          "address": { ... }, // Address 对象
          "buyer": { ... }, // Buyer 信息
          "tenant": { ... }, // Tenant 信息
          "items": [ // 订单项数组
            {
              "id": <integer>,
              "productId": <integer>,
              "productName": "<string>",
              "variantId": <integer>,
              "variantName": "<string>",
              "quantity": <integer>,
              "unitPrice": <integer>,
              "totalPrice": <integer>,
              "payPrice": <integer>,
              // !!! 注意: 此接口响应的 item 中似乎缺少图片 URL (productImage/picUrl) !!!
            }
          ]
        }
      ]
    }
    ```
*   **前端模型/实现**: `OrderModel`, `OrderItemModel`, `OrderRemoteDataSourceImpl.getOrderList`
    *   模型已更新，解析逻辑基本匹配。价格字段 (`integer` -> `double`) 解析无误。
    *   `OrderItemModel.imageUrl` 待运行时确认来源。

### 2.2. `/api/shop/order/detail` (订单详情)

*   **方法**: `GET`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求参数 (Query)**: `id=<integer>` (订单 ID, 必需)
*   **成功响应 (`data` 字段结构)**:
    *   预期为单个 `Order` 对象 JSON，结构应与列表接口中的单个 `rows` 对象类似。
    *   **重点待确认**: `data.items` 数组中的对象是否包含 `productImage` 或 `picUrl`？
*   **前端模型/实现**: `OrderModel`, `OrderRemoteDataSourceImpl.getOrderDetail`
    *   实现已按 `response.data['data']` 结构处理。
    *   `OrderModel` 基本能处理此结构，但 `OrderItem` 的图片来源需运行时验证。

### 2.3. `/api/project/orderMaterials/add` (提交需求/材料)

*   **方法**: `POST`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求体 (JSON - 对应 `OrderMaterials` 定义)**:
    ```json
    {
      "orderId": <integer>,     // 订单 ID
      "productId": <integer>,   // 商品 ID
      "feature": [              // 问题及答案 (List<Map<String, String>>)
        {"question": "...", "answer": "..."}, 
        ...
      ],
      "files": ["<string>", ...] // 附件 URL 列表
    }
    ```
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)，`data` 可能为 null。
*   **前端实现**: `OrderRemoteDataSourceImpl.submitRequirements`
    *   当前实现发送的数据结构与 API 定义匹配。

### 2.4. `/api/shop/evaluate/add` (提交评价)

*   **方法**: `POST`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求体 (JSON)**:
    *   **API 文档歧义**: 文档定义为 `array` of objects，结构未定义。与常见实践不符。
    *   **前端实现 (假设)**: 当前按发送**单个** object 实现:
    ```json
    {
      "orderItemId": <integer>,   // 订单项 ID (核心)
      "score": <double>,        // 评分
      "remark": "<string>",       // 评价内容
      "images": ["<string>", ...], // 图片 URL 列表
      "anonumityFlag": <boolean> // 是否匿名 (API 拼写?) 
      // "orderId": <integer>?   // 是否需要 orderId? 待确认
    }
    ```
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)，`data` 可能为 null。
*   **前端实现**: `OrderRemoteDataSourceImpl.addEvaluation`
    *   按单对象发送，并检查业务 `code`。
    *   **待确认**: 单对象是否正确？是否需要 `orderId`？

### 2.5. `/api/shop/order/cancel` (取消订单)

*   **方法**: `GET`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求参数 (Query)**: `orderId=<string/integer>` (订单 ID, 必需)
*   **请求体**: 无
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)，`data` 为 null。
*   **前端实现**: `OrderRemoteDataSourceImpl.cancelOrder` (已更新检查 `code`)

### 2.6. `/api/shop/order/complete` (确认收货)

*   **方法**: `GET`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求参数 (Query)**: `orderId=<string/integer>` (订单 ID, 必需)
*   **请求体**: 无
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)，`data` 为 null。
*   **前端实现**: `OrderRemoteDataSourceImpl.confirmOrderReceipt` (已更新检查 `code`)

### 2.7. `/api/shop/order/delete` (删除订单)

*   **方法**: `POST`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求参数 (Query)**: `orderId=<string/integer>` (订单 ID, 必需)
*   **请求体**: 无 (实现中发送空 `{}`)
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)，`data` 为 null。
*   **前端实现**: `OrderRemoteDataSourceImpl.deleteOrder` (已更新检查 `code`)

### 2.8. `/api/project/orderDemand/add` (卖家: 拒绝接单 / 请求补充材料)

*   **用途**: 卖家用于提交拒绝接单或请求买家补充材料的申请。
*   **方法**: `POST`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求体 (JSON)**:
    ```json
    {
      "orderId": <integer>,     // 订单 ID (必需)
      "type": "<string>",       // 申请类型 (必需, "refuse" 或 "material")
      "reasonValue": "<string>",  // 原因代码 (必需, e.g., "materialLack")
      "reasonLabel": "<string>",  // 原因标签 (必需, e.g., "材料缺失")
      "remarks": "<string>"     // 补充说明 (必需? API 文档如此)
      // "files": ?             // API 文档未定义 files，若需附件需确认
    }
    ```
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)，`data` 可能为 null 或空对象。
*   **前端实现**: `OrderRemoteDataSourceImpl.addOrderDemand` (需要实现)

### 2.9. `/api/project/orderDelivery/add` (卖家: 交付订单)

*   **用途**: 卖家提交最终交付物。
*   **方法**: `POST`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求体 (JSON)**:
    ```json
    {
      "orderId": <integer>,   // 订单 ID (必需)
      "content": "<string>",    // 交付内容文本 (可选?)
      "files": "<string>"     // 交付附件 (可选?, **类型待确认: 文档为 string, RN 为 string[]**)
    }
    ```
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)，`data` 可能为 null 或空对象。
*   **前端实现**: `OrderRemoteDataSourceImpl.deliverOrder` (需要实现)
*   **注意**: `files` 参数类型需与后端确认。

### 2.10. `/api/project/orderDelivery/save` (卖家: 保存交付草稿)

*   **用途**: 卖家保存交付内容的草稿。
*   **方法**: `POST`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求体 (JSON)**: 与 `/api/project/orderDelivery/add` 结构相同。
    ```json
    {
      "orderId": <integer>,
      "content": "<string>",
      "files": "<string>" // **类型待确认: 文档为 string, RN 为 string[]**
    }
    ```
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)，`data` 可能为 null 或空对象。
*   **前端实现**: 需要添加对应 DataSource 方法 (例如 `saveDeliveryDraft`)
*   **注意**: `files` 参数类型需与后端确认。

### 2.11. `/api/shop/order/sellerDelete` (卖家: 删除订单记录)

*   **用途**: 卖家删除自己的订单记录视图。
*   **方法**: `POST`
*   **认证**: 需要 `Authorization` 头 (原始 Token)。
*   **请求参数 (Query)**: `orderId=<integer>` (订单 ID, 必需)
*   **请求体**: 无
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)，`data` 为空对象 `{}`。
*   **前端实现**: `OrderRemoteDataSourceImpl.deleteSellerOrderRecord` (需要实现)

### 2.12. `/api/afterSale/...` (卖家: 售后处理)

*   **用途**: 卖家处理售后申请的多个操作。
*   **详见端点**: 
    *   `POST /api/afterSale/agreeRefund` (同意退款): 请求体 `{"id": <售后单 ID>}`
    *   `POST /api/afterSale/refuseRefund` (拒绝退款): 请求体 `{"id": <售后单 ID>, "refuseReason": "<string>"}`
    *   `POST /api/afterSale/agreeReturn` (同意退货): 请求体 `{"id": <售后单 ID>}`
    *   `POST /api/afterSale/refuseReturn` (拒绝退货): 请求体 `{"id": <售后单 ID>, "refuseReason": "<string>", "refuseImages": "<string>"}` (images 为逗号分隔)
    *   `PUT /api/afterSale/confirmReceipt` (确认收到退货): 请求体 `{"id": <售后单 ID>}`
*   **认证**: 均需要 `Authorization` 头。
*   **成功响应**: 标准 wrapper (`code`, `msg`, `data`)。
*   **前端实现**: 需要在 `AfterSalesRemoteDataSourceImpl` 中实现对应方法。

### 待确认 API

*   **卖家确认接单**: 
    *   **RN Action**: `verifyOrder`
    *   **方法/路径**: **POST `/api/shop/order/verify`** (已从 RN 代码确认)
    *   **请求参数**: `orderId=<integer>` (作为 Query Parameter)
    *   **请求体**: 空对象 `{}`
    *   **状态**: **已确认** (但未在 API 文档 JSON 中找到)
*   **卖家邀请评价**: 
    *   **RN Action**: `inviteComment` (来自 `item` slice)
    *   **方法/路径**: 未在 API 文档中找到明确端点。
    *   **预期参数**: `orderId`
    *   **状态**: **待确认**

---

**待确认/待办事项:**

*   **`imageUrl` 来源**: 确认订单列表/详情接口中 `items` 是否返回 `productImage` 或 `picUrl`。
*   **评价接口 `/evaluate/add`**: 确认请求体是单个对象还是数组？是否需要 `orderId`？
*   **交付/草稿 `files` 类型**: 确认 `/api/project/orderDelivery/add` 和 `save` 的 `files` 参数实际类型 (string vs string[])。
*   **卖家确认接单 API**: 与后端确认此操作的实现方式。
*   **卖家邀请评价 API**: 与后端确认此操作的实现方式。
*   **字段完整性**: 在运行时测试，进一步确认 `OrderModel/ItemModel` 与 API 响应的所有字段匹配。

*(后续将补充其他接口的分析结果)* 

---

*(移除之前的卖家 API 总结表格)* 