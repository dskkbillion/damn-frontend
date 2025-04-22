# 我的收藏功能开发任务清单

> 注意：本功能是"我的收藏"(Favorites)功能，请参考 `docs/BD/cart_boundary_definition.md` 文档。

## 1. 领域层 (Domain)

### 1.1 实体 (Entities)

- [x] 创建 `Favorite` 实体
  - 包含：id, type, memberId, objectId, feature, sort, createTime, updateTime

- [x] 创建 `FavoriteService` 实体
  - 包含：id, title, description, imageUrl, price, isFavorite

- [x] 创建 `FavoriteSeller` 实体
  - 包含：id, referId, nickName, trueName, avatar, mobile, gender, type, status, isFavorite

- [x] 创建 `CommonUser` 实体（用于关注卖家API）
  - 包含：id, referId, nickName, trueName, avatar, mobile, gender, type, status, tenantId

### 1.2 仓库接口 (Repository Interfaces)

- [x] 创建 `IFavoritesRepository` 接口
  - 定义 `getFavoriteServices` 方法
  - 定义 `getFavoriteSellers` 方法
  - 定义 `addToFavorites` 方法
  - 定义 `removeFromFavorites` 方法
  - 定义 `checkIsFavorite` 方法
  - 定义 `followSeller` 方法
  - 定义 `unfollowSeller` 方法

### 1.3 用例 (Use Cases)

- [x] 创建 `GetFavoriteServicesUseCase`
- [x] 创建 `GetFavoriteSellersUseCase`
- [x] 创建 `AddToFavoritesUseCase`
- [x] 创建 `RemoveFromFavoritesUseCase`
- [x] 创建 `CheckIsFavoriteUseCase`
- [x] 创建 `FollowSellerUseCase`
- [x] 创建 `UnfollowSellerUseCase`

## 2. 数据层 (Data)

### 2.1 模型 (Models)

- [x] 创建 `FavoriteModel` 类（对应 `Favorite` 实体）
- [x] 创建 `FavoriteServiceModel` 类（对应 `FavoriteService` 实体）
- [x] 创建 `FavoriteSellerModel` 类（对应 `FavoriteSeller` 实体）
- [x] 创建 `CommonUserModel` 类（对应 `CommonUser` 实体）

### 2.2 数据源 (Data Sources)

- [x] 创建 `FavoritesRemoteDataSource` 接口
  - 定义与API对应的方法
- [x] 创建 `FavoritesRemoteDataSourceImpl` 实现类
  - 实现 `GET /api/collect/list` API调用
  - 实现 `POST /api/collect/add` API调用
  - 实现 `POST /api/collect/isCollect` API调用
  - 实现 `POST /api/collect/delete` API调用
  - 实现 `POST /api/invitation/collectionMember` API调用
  - 实现 `POST /api/invitation/cancelCollectionMember` API调用

- [x] 创建 `FavoritesLocalDataSource` 接口（可选，用于缓存）
- [x] 创建 `FavoritesLocalDataSourceImpl` 实现类（可选，用于缓存）

### 2.3 仓库实现 (Repository Implementations)

- [x] 创建 `FavoritesRepositoryImpl` 类
  - 实现 `IFavoritesRepository` 接口的所有方法
  - 处理数据转换（Model <-> Entity）
  - 处理错误处理和异常映射

## 3. 表示层 (Presentation)

### 3.1 状态管理 (State Management)

- [x] 创建 `FavoritesEvent` 类
  - 定义所有事件类型（加载收藏列表、添加收藏、删除收藏等）
- [x] 创建 `FavoritesState` 类
  - 定义所有状态（初始、加载中、加载成功、加载失败等）
- [x] 创建 `FavoritesBloc` 类
  - 处理所有事件并更新状态

### 3.2 页面 (Pages)

- [x] 创建 `FavoritesPage` 类
  - 实现标签页切换（服务/卖家）
  - 实现空状态展示
  - 实现下拉刷新和上拉加载更多

### 3.3 组件 (Widgets)

- [x] 创建 `FavoriteServiceItem` 组件
  - 展示服务图片、标题、描述和价格
- [x] 创建 `FavoriteSellerItem` 组件
  - 展示卖家头像、名称和描述
- [x] 创建 `EmptyFavorites` 组件
  - 展示"暂无关注"的空状态

### 3.4 路由 (Routes)

- [x] 创建 `favorites_routes.dart` 文件
  - 定义收藏页面的路由
  - 处理导航逻辑

## 4. 依赖注入 (DI)

- [x] 创建 `favorites_di.dart` 文件
  - 注册所有实体、用例、仓库和数据源
  - 注册Bloc

## 5. 测试

### 5.1 单元测试

- [ ] 测试所有用例
- [ ] 测试仓库实现
- [ ] 测试数据源实现
- [ ] 测试Bloc

### 5.2 集成测试

- [ ] 测试完整的收藏流程
- [ ] 测试与其他模块的交互

## 6. 集成与部署

- [ ] 将收藏功能集成到主应用
- [ ] 添加到底部导航栏或个人中心
- [ ] 处理与其他模块的交互（如服务详情页的收藏按钮）

## 开发顺序建议

1. 先实现领域层，定义清晰的实体和接口
2. 实现数据层，确保API调用正常
3. 实现表示层的基本UI
4. 连接各层，实现完整功能
5. 添加错误处理和边缘情况处理
6. 优化性能和用户体验
7. 编写测试
8. 集成到主应用

## 注意事项

- 确保遵循Clean Architecture的原则
- 保持代码的可测试性
- 处理好错误情况和边缘情况
- 考虑性能优化，特别是列表滚动和图片加载
- 实现适当的缓存策略
- 确保与设计规范一致

## API接口参考

### 收藏列表
- GET /api/collect/list
- 参数: type, memberId, pageNum, pageSize

### 添加收藏
- POST /api/collect/add
- 参数: memberId, objectId, type, feature

### 查询是否收藏
- POST /api/collect/isCollect
- 参数: type, searchIds

### 删除收藏
- POST /api/collect/delete
- 参数: [favoriteIds]

### 关注卖家
- POST /api/invitation/collectionMember
- 参数: referId, type, nickName, avatar

### 取消关注卖家
- POST /api/invitation/cancelCollectionMember
- 参数: referId, type