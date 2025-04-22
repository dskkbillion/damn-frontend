# Favorites 模块边界定义 (Boundary Definition)

> 注意：本文档原名为cart_boundary_definition.md，现已重写为"我的收藏"(Favorites)功能的边界定义文档。

本文档基于HTML原型、API文档以及收藏功能的业务逻辑，定义了 `Favorites`（我的收藏）模块的边界。

## 1. 模块名称

`Favorites` (我的收藏)

## 2. 核心业务能力 (Business Capability)

提供用户管理其收藏内容的功能。包括：查看收藏的服务和卖家列表、添加收藏、删除收藏、查询是否已收藏、关注卖家、取消关注卖家等功能。

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

* **`Favorite`**: 收藏实体。
  * `id`: (int) 收藏记录唯一标识。
  * `type`: (String) 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等。
  * `memberId`: (int) 用户ID。
  * `objectId`: (int) 收藏对象ID。
  * `feature`: (Map<String, dynamic>?) 收藏对象的特征信息（可选）。
  * `sort`: (int?) 排序值（可选）。
  * `createTime`: (DateTime) 创建时间。
  * `updateTime`: (DateTime) 更新时间。

* **`FavoriteService`**: 收藏的服务项目。
  * `id`: (int) 服务ID。
  * `title`: (String) 服务标题。
  * `description`: (String?) 服务描述。
  * `imageUrl`: (String?) 服务图片URL。
  * `price`: (double) 服务价格。
  * `isFavorite`: (bool) 是否已收藏。

* **`FavoriteSeller`**: 收藏的卖家/服务机构。
  * `id`: (int) 卖家ID。
  * `referId`: (int) 关联ID。
  * `nickName`: (String) 卖家昵称。
  * `trueName`: (String?) 卖家真实姓名（可选）。
  * `avatar`: (String?) 卖家头像URL。
  * `mobile`: (String?) 卖家手机号（可选）。
  * `gender`: (String?) 性别（MALE, FEMALE, NONE）（可选）。
  * `type`: (String) 用户类型（MEMBER, TENANT, ANONYMOUS, ADMIN）。
  * `status`: (String?) 用户状态（NORMAL, FORBIDDEN, DELETE）（可选）。
  * `isFavorite`: (bool) 是否已关注。

* **`CommonUser`**: 用户信息（用于关注卖家API）。
  * `id`: (int?) 用户ID（可选）。
  * `referId`: (int) 关联ID（必填）。
  * `nickName`: (String?) 昵称（可选）。
  * `trueName`: (String?) 真实姓名（可选）。
  * `avatar`: (String?) 头像URL（可选）。
  * `mobile`: (String?) 手机号（可选）。
  * `gender`: (String?) 性别（可选）。
  * `type`: (String) 用户类型（必填）。
  * `status`: (String?) 用户状态（可选）。
  * `tenantId`: (int?) 租户ID（可选）。

### 3.2. `Use Cases` (主要功能点/用户故事)

* **`GetFavoriteServicesUseCase`**: 获取收藏的服务列表。
  * 输入: `pageNum` (int, 可选), `pageSize` (int, 可选)
  * 输出: `Either<Failure, List<FavoriteService>>`

* **`GetFavoriteSellersUseCase`**: 获取收藏的卖家列表。
  * 输入: `pageNum` (int, 可选), `pageSize` (int, 可选)
  * 输出: `Either<Failure, List<FavoriteSeller>>`

* **`AddToFavoritesUseCase`**: 添加收藏（服务）。
  * 输入: `type` (String), `objectId` (int), `feature` (Map<String, dynamic>?)
  * 输出: `Either<Failure, void>`

* **`RemoveFromFavoritesUseCase`**: 从收藏中移除（服务）。
  * 输入: `favoriteId` (int) 或 `List<int>`
  * 输出: `Either<Failure, void>`

* **`CheckIsFavoriteUseCase`**: 检查对象是否已收藏。
  * 输入: `type` (String), `objectIds` (List<int>)
  * 输出: `Either<Failure, Map<int, bool>>` (对象ID到是否收藏的映射)

* **`FollowSellerUseCase`**: 关注卖家。
  * 输入: `CommonUser` (包含referId, type等信息)
  * 输出: `Either<Failure, void>`

* **`UnfollowSellerUseCase`**: 取消关注卖家。
  * 输入: `CommonUser` (包含referId, type等信息)
  * 输出: `Either<Failure, void>`

### 3.3. `Repository Interfaces` (数据操作契约)

* **`IFavoritesRepository`**: 定义收藏模块的数据访问接口。
  * `Future<Either<Failure, List<FavoriteService>>> getFavoriteServices({int? pageNum, int? pageSize})`: 获取收藏的服务列表。
  * `Future<Either<Failure, List<FavoriteSeller>>> getFavoriteSellers({int? pageNum, int? pageSize})`: 获取收藏的卖家列表。
  * `Future<Either<Failure, void>> addToFavorites(String type, int objectId, Map<String, dynamic>? feature)`: 添加收藏。
  * `Future<Either<Failure, void>> removeFromFavorites(List<int> favoriteIds)`: 从收藏中移除。
  * `Future<Either<Failure, Map<int, bool>>> checkIsFavorite(String type, List<int> objectIds)`: 检查对象是否已收藏。
  * `Future<Either<Failure, void>> followSeller(CommonUser user)`: 关注卖家。
  * `Future<Either<Failure, void>> unfollowSeller(CommonUser user)`: 取消关注卖家。

* **(依赖接口 - 由其他模块定义或位于 Core/Shared):**
  * `IAuthRepository` (Auth): 获取当前用户ID。
  * `IServiceRepository` (Service): 获取服务详情信息。
  * `ISellerRepository` (Seller): 获取卖家详情信息。

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

* **`Core/Shared` 模块**:
  * 依赖通用的 `Failure` 定义, 网络客户端, 本地缓存。

* **`Auth` 模块**:
  * 强依赖，需要用户认证状态和 `userId` 来管理其收藏。

* **`Service` 模块**:
  * 依赖服务信息，用于显示收藏的服务详情。

* **`Seller` 模块**:
  * 依赖卖家信息，用于显示收藏的卖家详情。

### 4.2. 导航需求 (Navigation Needs)

`Favorites` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

* `navigateToServiceDetail(serviceId: int)`: 从收藏列表点击服务项目，跳转到服务详情页。
* `navigateToSellerDetail(sellerId: int)`: 从收藏列表点击卖家，跳转到卖家详情页。
* `navigateToLogin()`: 用户尝试访问或操作收藏但未登录时。
* `navigateBack()`: 返回上一页。

## 5. API 接口

### 5.1. 收藏服务相关API

#### 5.1.1. 收藏列表

* **接口**: `GET /api/collect/list`
* **参数**:
  * `type`: (String, 可选) 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等
  * `memberId`: (String, 可选) 用户ID
  * `pageNum`: (int, 可选) 页码，默认为1
  * `pageSize`: (int, 可选) 每页数量，默认为10
* **响应**:
  ```json
  {
    "total": 1,
    "rows": [
      {
        "id": 4,
        "type": "funder",
        "memberId": 2,
        "objectId": 1,
        "feature": null,
        "sort": 0,
        "createTime": "2021-10-10T10:36:25.000+0800",
        "updateTime": "2021-10-10T10:36:25.000+0800"
      }
    ],
    "code": 200,
    "msg": "查询成功"
  }
  ```
* **错误响应**:
  ```json
  {
    "code": 403,
    "msg": "未授权访问"
  }
  ```

#### 5.1.2. 添加收藏

* **接口**: `POST /api/collect/add`
* **参数**:
  ```json
  {
    "memberId": 15,
    "objectId": 1,
    "type": "org_product",
    "feature": {}
  }
  ```
* **响应**:
  ```json
  {
    "msg": "收藏成功",
    "code": 200
  }
  ```
* **错误响应**:
  ```json
  {
    "code": 403,
    "msg": "未授权访问"
  }
  ```

#### 5.1.3. 查询是否收藏

* **接口**: `POST /api/collect/isCollect`
* **参数**:
  ```json
  {
    "type": "org_product",
    "searchIds": [1, 2, 3, 4, 5, 6]
  }
  ```
* **响应**:
  ```json
  {
    "msg": "获取成功",
    "code": 200,
    "data": {
      "1": false,
      "2": true,
      "3": true,
      "4": false,
      "5": true,
      "6": true
    }
  }
  ```
* **错误响应**:
  ```json
  {
    "code": 403,
    "msg": "未授权访问"
  }
  ```

#### 5.1.4. 删除收藏

* **接口**: `POST /api/collect/delete`
* **参数**:
  ```json
  [1, 2, 3]
  ```
* **响应**:
  ```json
  {
    "msg": "删除成功",
    "code": 200
  }
  ```
* **错误响应**:
  ```json
  {
    "code": 403,
    "msg": "未授权访问"
  }
  ```

### 5.2. 关注卖家相关API

#### 5.2.1. 关注卖家

* **接口**: `POST /api/invitation/collectionMember`
* **参数**:
  ```json
  {
    "referId": 123,
    "type": "MEMBER",
    "nickName": "卖家昵称",
    "avatar": "头像URL"
  }
  ```
* **响应**:
  ```json
  {
    "msg": "关注成功",
    "code": 200
  }
  ```
* **错误响应**:
  ```json
  {
    "code": 403,
    "msg": "未授权访问"
  }
  ```

#### 5.2.2. 取消关注卖家

* **接口**: `POST /api/invitation/cancelCollectionMember`
* **参数**:
  ```json
  {
    "referId": 123,
    "type": "MEMBER"
  }
  ```
* **响应**:
  ```json
  {
    "msg": "取消关注成功",
    "code": 200
  }
  ```
* **错误响应**:
  ```json
  {
    "code": 403,
    "msg": "未授权访问"
  }
  ```

## 6. UI 界面

### 6.1. 我的收藏页面

* 顶部标题栏：显示"我的收藏"标题和返回按钮
* 标签页：
  * 服务标签页：显示收藏的服务列表
  * 卖家标签页：显示收藏的卖家列表
* 服务项目展示：
  * 服务图片
  * 服务标题
  * 服务描述
  * 服务价格
* 卖家展示：
  * 卖家头像
  * 卖家名称
  * 卖家描述
* 空状态展示：当没有收藏内容时显示"暂无关注"

### 6.2. 交互行为

* 点击服务项目：跳转到服务详情页
* 点击卖家：跳转到卖家详情页
* 下拉刷新：刷新收藏列表
* 上拉加载更多：加载更多收藏内容（分页加载）
* 长按服务项目：显示删除选项
* 长按卖家：显示取消关注选项

## 7. 收藏类型定义

收藏功能支持多种类型的对象，包括：

* `funder_product` - 金融产品
* `funder` - 金融机构
* `org` - 服务机构
* `org_product` - 服务项目
* `report` - 政策服务报告
* `footprint` - 足迹

在"我的收藏"功能中，主要关注的是服务项目（`org_product`）和服务机构/卖家（`org`）。

## 8. 错误处理

### 8.1. 常见错误码

* `200` - 成功
* `403` - 未授权访问
* `404` - 资源不存在
* `500` - 服务器内部错误

### 8.2. 错误处理策略

* 未登录错误：重定向到登录页面
* 网络错误：显示重试选项
* 服务器错误：显示友好的错误提示
* 资源不存在：显示空状态页面

---

**待确认/后续步骤:**

* 确认收藏对象的完整类型列表及其在UI中的展示方式。
* 确认收藏列表的分页机制，包括默认的pageSize和加载更多的触发条件。
* 确认收藏操作的实时反馈机制（如添加/删除收藏后的UI更新）。
* 确认是否需要支持批量操作（如批量删除收藏）。
* 确认收藏数据的本地缓存策略，包括缓存时间和更新机制。
* 确认与其他模块的交互细节，特别是与Service和Seller模块的数据同步。