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

---

**待确认/待办事项:**

*   **`imageUrl` 来源**: 确认订单列表/详情接口中 `items` 是否返回 `productImage` 或 `picUrl`。
*   **评价接口 `/evaluate/add`**: 确认请求体是单个对象还是数组？是否需要 `orderId`？
*   **字段完整性**: 在运行时测试，进一步确认 `OrderModel/ItemModel` 与 API 响应的所有字段匹配。

*(后续将补充其他接口的分析结果)* 