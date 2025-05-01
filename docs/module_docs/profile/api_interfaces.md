# Profile模块API接口文档

本文档详细说明Profile模块与后端服务交互的API接口，包括请求路径、参数、响应格式等信息。

## 基础信息

- **基础URL**: `https://api.example.com/v1`
- **认证方式**: Bearer Token
- **请求头**:
  - `Authorization: Bearer {token}`
  - `Content-Type: application/json`

## 用户资料接口

### 1. 获取用户资料

获取当前登录用户的详细资料。

- **URL**: `/user/profile`
- **方法**: `GET`
- **请求参数**: 无
- **成功响应**:
  ```json
  {
    "code": 200,
    "message": "success",
    "data": {
      "id": "123456",
      "username": "user123",
      "nickname": "用户昵称",
      "avatarUrl": "https://example.com/avatar/123.jpg",
      "phone": "13800138000",
      "email": "user@example.com",
      "gender": 1,
      "birthday": "1990-01-01",
      "bio": "这是用户的个人简介",
      "isSellerMode": false,
      "createdAt": "2023-01-01T12:00:00Z",
      "updatedAt": "2023-06-01T15:30:00Z"
    }
  }
  ```
- **错误响应**:
  ```json
  {
    "code": 401,
    "message": "未授权，请先登录",
    "data": null
  }
  ```

### 2. 更新用户资料

更新当前登录用户的个人资料。

- **URL**: `/user/profile`
- **方法**: `PUT`
- **请求体**:
  ```json
  {
    "nickname": "新昵称",
    "gender": 1,
    "birthday": "1990-01-01",
    "bio": "新的个人简介"
  }
  ```
- **成功响应**:
  ```json
  {
    "code": 200,
    "message": "更新成功",
    "data": {
      "id": "123456",
      "username": "user123",
      "nickname": "新昵称",
      "avatarUrl": "https://example.com/avatar/123.jpg",
      "phone": "13800138000",
      "email": "user@example.com",
      "gender": 1,
      "birthday": "1990-01-01",
      "bio": "新的个人简介",
      "isSellerMode": false,
      "createdAt": "2023-01-01T12:00:00Z",
      "updatedAt": "2023-08-15T10:25:00Z"
    }
  }
  ```
- **错误响应**:
  ```json
  {
    "code": 400,
    "message": "参数错误",
    "data": {
      "errors": {
        "nickname": "昵称长度必须在2-20之间"
      }
    }
  }
  ```

### 3. 上传用户头像

上传用户头像图片。

- **URL**: `/user/avatar`
- **方法**: `POST`
- **Content-Type**: `multipart/form-data`
- **请求参数**:
  - `file`: 图片文件，支持jpg, png, jpeg格式，大小不超过5MB
- **成功响应**:
  ```json
  {
    "code": 200,
    "message": "上传成功",
    "data": {
      "avatarUrl": "https://example.com/avatar/new123.jpg"
    }
  }
  ```
- **错误响应**:
  ```json
  {
    "code": 400,
    "message": "文件格式不支持",
    "data": null
  }
  ```

### 4. 用户模式切换

切换用户的身份模式（买家/卖家）。

- **URL**: `/user/switch-mode`
- **方法**: `POST`
- **请求体**:
  ```json
  {
    "isSellerMode": true
  }
  ```
- **成功响应**:
  ```json
  {
    "code": 200,
    "message": "切换成功",
    "data": {
      "isSellerMode": true,
      "updatedAt": "2023-08-15T11:30:00Z"
    }
  }
  ```
- **错误响应**:
  ```json
  {
    "code": 403,
    "message": "您还不是卖家，无法切换到卖家模式",
    "data": null
  }
  ```

## 钱包接口

### 1. 获取钱包摘要

获取当前用户的钱包余额摘要信息。

- **URL**: `/wallet/summary`
- **方法**: `GET`
- **请求参数**: 无
- **成功响应**:
  ```json
  {
    "code": 200,
    "message": "success",
    "data": {
      "balance": 1000.50,
      "frozenAmount": 100.00,
      "totalIncome": 5000.00,
      "currency": "CNY",
      "lastUpdated": "2023-08-15T12:00:00Z"
    }
  }
  ```
- **错误响应**:
  ```json
  {
    "code": 401,
    "message": "未授权，请先登录",
    "data": null
  }
  ```

### 2. 获取钱包交易记录

获取用户钱包的交易历史记录。

- **URL**: `/wallet/transactions`
- **方法**: `GET`
- **请求参数**:
  - `page`: 页码，默认为1
  - `size`: 每页条数，默认为20
  - `type`: 交易类型，可选值：all, income, expense，默认为all
- **成功响应**:
  ```json
  {
    "code": 200,
    "message": "success",
    "data": {
      "total": 56,
      "page": 1,
      "size": 20,
      "list": [
        {
          "id": "tx123456",
          "amount": 150.00,
          "type": "income",
          "description": "商品销售收入",
          "status": "completed",
          "createdAt": "2023-08-10T15:30:00Z"
        },
        {
          "id": "tx123455",
          "amount": -20.50,
          "type": "expense",
          "description": "平台服务费",
          "status": "completed",
          "createdAt": "2023-08-09T12:15:00Z"
        }
        // 更多交易记录...
      ]
    }
  }
  ```
- **错误响应**:
  ```json
  {
    "code": 400,
    "message": "参数错误",
    "data": {
      "errors": {
        "type": "交易类型参数错误"
      }
    }
  }
  ```

## 错误码说明

| 错误码 | 说明 |
| ------ | ---- |
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权，用户未登录或Token已过期 |
| 403 | 权限不足，禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

## 数据模型

### UserProfile

| 字段 | 类型 | 描述 |
| ---- | ---- | ---- |
| id | String | 用户ID |
| username | String | 用户名 |
| nickname | String | 用户昵称 |
| avatarUrl | String | 头像URL |
| phone | String | 手机号 |
| email | String | 邮箱 |
| gender | Integer | 性别（0-未知，1-男，2-女） |
| birthday | String | 生日，格式：YYYY-MM-DD |
| bio | String | 个人简介 |
| isSellerMode | Boolean | 是否为卖家模式 |
| createdAt | String | 创建时间，ISO 8601格式 |
| updatedAt | String | 更新时间，ISO 8601格式 |

### WalletSummary

| 字段 | 类型 | 描述 |
| ---- | ---- | ---- |
| balance | Double | 可用余额 |
| frozenAmount | Double | 冻结金额 |
| totalIncome | Double | 总收入 |
| currency | String | 货币类型，如CNY |
| lastUpdated | String | 最后更新时间，ISO 8601格式 |

### Transaction

| 字段 | 类型 | 描述 |
| ---- | ---- | ---- |
| id | String | 交易ID |
| amount | Double | 交易金额（正数为收入，负数为支出） |
| type | String | 交易类型（income: 收入, expense: 支出） |
| description | String | 交易描述 |
| status | String | 交易状态（pending: 处理中, completed: 已完成, failed: 失败） |
| createdAt | String | 交易创建时间，ISO 8601格式 |

## 版本控制

当前API版本为V1，未来可能会有变更。API变更将遵循以下原则：
1. 路径中的主版本号变更（如从v1到v2）表示不兼容的API变更
2. 同一版本号下的API，将保持向后兼容
3. 新增字段不视为破坏性变更
4. 弃用的API将提前公告

  - `400`: 请求错误
