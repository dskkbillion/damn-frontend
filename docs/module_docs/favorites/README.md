# 收藏模块 (Favorites)

## 1. 模块概述 (Brief Overview)

* **一句话描述:** 管理用户收藏的服务和卖家，包括查看、添加、删除收藏以及关注/取消关注卖家。

* **主要功能点:**
  * 查看收藏的服务列表
  * 查看收藏的卖家列表
  * 添加/删除收藏
  * 关注/取消关注卖家
  * 检查服务或卖家是否已收藏

## 2. 路由入口与参数 (Routing Entry Points & Parameters)

* **如何进入本模块:**
  * 路径: `/favorites`, 名称: `favorites` (收藏页面，无需参数)

* **必需参数:** 无需参数即可进入收藏页面。

* **参考:** 路由定义在 `lib/features/favorites/presentation/routes/favorites_routes.dart` 文件中。

## 3. 外部依赖说明 (External Dependencies)

* **核心服务依赖:**
  * `NetworkInfo` (用于检查网络连接状态)
  * `http.Client` (通过 Repository 间接依赖，用于网络请求)
  * 认证服务 (通过 `getToken` 和 `getUserId` 函数获取认证信息)

* **跨模块依赖:** 无直接依赖其他功能模块。

## 4. 调用的主要 API (APIs Consumed)

* **接口列表:**
  * `GET /api/collect/list?type=org_product&memberId={userId}&pageNum={pageNum}&pageSize={pageSize}` (获取收藏的服务列表)
  * `GET /api/collect/list?type=org&memberId={userId}&pageNum={pageNum}&pageSize={pageSize}` (获取收藏的卖家列表)
  * `GET /api/shop/product/get?id={serviceId}` (获取服务详情)
  * `GET /api/member/info?id={sellerId}` (获取卖家详情)
  * `POST /api/collect/add` (添加收藏)
  * `POST /api/collect/delete` (删除收藏)
  * `POST /api/collect/isCollect` (检查是否已收藏)
  * `POST /api/invitation/collectionMember` (关注卖家)
  * `POST /api/invitation/cancelCollectionMember` (取消关注卖家)

## 5. 对外暴露的服务/接口 (Exposed Services/Interfaces)

* 本模块不直接向其他模块提供服务或接口。所有功能通过 Repository 和 UseCase 层封装，不直接暴露给其他模块。

## 6. 注意事项/配置要求

* 本模块需要用户已登录才能正常使用，依赖认证模块提供的 token 和 userId。
* 在网络不可用的情况下，会显示缓存的数据或空状态。

## 7. 依赖包使用说明 (Package Dependencies)

* **依赖包清单:**
  * `flutter_bloc: ^8.1.3` - 用于状态管理，在 FavoritesBloc 中使用
  * `equatable: ^2.0.5` - 用于简化相等性比较，在所有实体类和状态类中使用
  * `http: ^1.1.0` - 用于网络请求，在 FavoritesRemoteDataSourceImpl 中使用
  * `cached_network_image: ^3.2.3` - 用于带缓存的图片加载，在 FavoriteServiceItem 和 FavoriteSellerItem 中使用
  * `drift: ^2.10.0` - 用于本地数据缓存，在 FavoritesLocalDataSourceImpl 中使用

## 8. 资源管理说明 (Resource Management)

* **模块资源列表:** 本模块主要使用通用图标和样式，没有特定的资源文件。
* **资源命名规范:** 如需添加特定资源，建议使用 `favorites_` 前缀，如 `favorites_empty_state.png`。
* **资源存放位置:** 通用图标使用 `assets/images/common/` 目录。
* **资源使用方式:** 通过 `Assets.images.common.xxx.image()` 方式引用（使用了assets_gen生成的访问器）。

## 9. 已知问题与解决方案 (Known Issues & Solutions)

* **已知限制:** 
  * 在认证失败的情况下，API 会返回 HTTP 200 但业务状态码为 401，此时会显示模拟数据。
  * 图片加载可能会因为网络问题失败，导致显示占位图。

* **临时解决方案:** 
  * 对于认证失败，当前使用模拟数据作为回退方案，确保UI不会崩溃。
  * 使用 `cached_network_image` 包的错误处理机制显示占位图。

* **修复计划:** 
  * 计划在下一版本中实现更完善的认证刷新机制。
  * 优化图片加载策略，添加重试机制。

* **开发者注意事项:** 
  * 在使用本模块时，需确保认证模块正常工作，否则会显示模拟数据。
  * 本模块的缓存策略遵循项目全局缓存策略，详见 `docs/caching_and_local_storage_strategy_cn.md`。

## 10. 跨模块通信机制 (Cross-Module Communication)

* **输出事件/通知:** 
  * 当用户添加或删除收藏时，可能会发出 `FavoriteChangedEvent`，其他模块可以监听此事件更新UI。
  * 当用户关注或取消关注卖家时，可能会发出 `SellerFollowStatusChangedEvent`。

* **输入事件/通知:** 
  * 本模块监听 `UserLogoutEvent` 以清除当前用户的收藏缓存。
  * 本模块可能监听 `ServiceViewedEvent` 或 `SellerViewedEvent` 以更新收藏状态。

* **通信方式:** 
  * 使用事件总线机制实现跨模块通信，相关代码位于 `lib/core/event/app_events.dart`。

* **直接依赖:** 
  * 本模块不直接依赖其他模块的服务或数据，通过事件总线和核心服务实现解耦。