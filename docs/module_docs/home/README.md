# Home 模块核心说明

本文档是 Home 模块的核心说明文档，提供了模块的概述、路由入口、依赖关系等关键信息，以便其他开发者能够理解和集成本模块。

## 1. 模块概述 (Brief Overview)

**一句话描述**: Home 模块负责聚合展示应用的核心内容概览，提供导航入口，是用户进入应用的主要入口之一。

**主要功能点**:
- 轮播图展示 (Banner Carousel)
- 服务/商品信息流 (瀑布流布局)
- 搜索入口
- 产品详情页面
- "让ta看看"推荐功能

Home 模块采用 Clean Architecture 架构，清晰地分离了数据层、领域层和表现层，使得模块具有高度的可测试性和可维护性。模块内部使用 BLoC 模式进行状态管理，通过依赖注入实现组件间的解耦。

## 2. 路由入口与参数 (Routing Entry Points & Parameters)

### 如何进入本模块:

- **路径**: `/home`, **名称**: `home` (首页，无需参数)
- **路径**: `/home/product/:productId`, **名称**: `productDetail` (产品详情页，需要路径参数 `productId` (String))
- **路径**: `/home/search`, **名称**: `search` (搜索页，可选查询参数 `q` (String))
- **路径**: `/home/category/:categoryId`, **名称**: `categoryDetail` (分类详情页，需要路径参数 `categoryId` (String))

### 必需参数:

- **产品详情页**: 需要路径参数 `productId` (String)，表示产品的唯一标识符
- **分类详情页**: 需要路径参数 `categoryId` (String)，表示分类的唯一标识符
- **搜索页**: 可选查询参数 `q` (String)，表示搜索关键词

路由定义位于 `lib/features/home/presentation/routes/home_routes.dart` 文件中，遵循项目的模块化路由策略。

## 3. 外部依赖说明 (External Dependencies)

### 核心服务依赖:

- **`NetworkInfo`**: 用于检查网络连接状态，决定是否从本地缓存获取数据
- **`Failure`**: 用于统一错误处理
- **`UseCase`**: 用于实现领域层用例
- **`GoRouter`**: 用于路由导航
- **`GetIt`**: 用于依赖注入

### 跨模块依赖:

Home 模块设计为最小化跨模块依赖，主要通过以下方式实现:

- 使用导航服务接口 (`HomeNavigationService`) 解耦导航逻辑
- 使用仓库接口 (`IHomeRepository`) 解耦数据获取逻辑
- 不直接依赖其他功能模块的实现，只依赖核心层提供的接口和服务

## 4. 调用的主要 API (APIs Consumed)

Home 模块调用以下后端 API 端点:

- **`GET /api/shop/product/recommend/detail?code=home`**: 获取推荐商品列表
  - 用途: 获取首页信息流数据
  - 参数: `code=home` (固定值)，`page` (页码)，`limit` (每页数量)
  
- **`POST /api/content/banner/list`**: 获取轮播图数据
  - 用途: 获取首页轮播图数据
  - 参数: `pageSize` (每页数量)，`pageNum` (页码)

API 的详细请求/响应结构可以参考 `docs/api_usage_summary_cn.md` 文档。

## 5. 对外暴露的服务/接口 (Exposed Services/Interfaces)

Home 模块不直接向其他模块提供服务或数据，而是通过以下方式与其他模块交互:

- **路由系统**: 其他模块可以通过路由系统导航到 Home 模块的页面
- **事件总线**: Home 模块可能会发布一些事件，其他模块可以订阅这些事件

Home 模块的设计原则是高内聚低耦合，尽量减少模块间的直接调用。

## 6. 注意事项/配置要求

- **网络权限**: 本模块需要网络权限来获取轮播图和商品数据
- **缓存策略**: 首页数据会在本地缓存，以便在网络不可用时仍能显示内容
- **图片加载**: 使用 `cached_network_image` 包加载网络图片，需要确保正确配置缓存策略
- **性能考量**: 首页使用瀑布流布局显示商品，需要注意滚动性能优化

## 7. 依赖包使用说明 (Package Dependencies)

- **`flutter_bloc: ^8.1.3`**: 用于状态管理，在 `HomeBloc` 中使用
- **`get_it: ^7.7.0`**: 用于依赖注入，在 `home_preview_di.dart` 中使用
- **`go_router: ^12.1.1`**: 用于路由管理，在 `home_routes.dart` 和 `home_navigation_service_impl.dart` 中使用
- **`dartz: ^0.10.1`**: 用于函数式编程和错误处理，在 `IHomeRepository` 和 `UseCase` 实现中使用
- **`equatable: ^2.0.5`**: 用于简化相等性比较，在所有实体类和状态类中使用
- **`cached_network_image: ^3.3.0`**: 用于带缓存的图片加载，在 `BannerCarousel` 和 `ProductCard` 中使用
- **`http: ^1.1.0`**: 用于网络请求，在 `HomeRemoteDataSourceImpl` 中使用
- **`carousel_slider: ^4.2.1`**: 用于实现轮播图，在 `BannerCarousel` 中使用

## 8. 资源管理说明 (Resource Management)

### 模块资源列表:

Home 模块主要使用网络图片资源，不包含本地图片资源。使用的图标主要来自 Flutter 的 Material Icons。

### 资源命名规范:

- 所有与 Home 模块相关的资源应使用 `home_` 前缀
- 图标资源应使用 `icon_home_` 前缀
- 图片资源应使用 `img_home_` 前缀

### 资源存放位置:

- 模块特有图标存放在 `assets/icons/home/` 目录下
- 模块特有图片存放在 `assets/images/home/` 目录下
- 共享图标使用 `assets/icons/common/` 目录下的资源

### 资源使用方式:

```dart
// 使用图标
Icon(Icons.home)

// 使用图片
Image.asset('assets/images/home/placeholder.png')
```

## 9. 已知问题与解决方案 (Known Issues & Solutions)

### 已知限制:

- **首次加载时间**: 在网络较慢的情况下，首页加载可能需要较长时间
- **图片加载失败**: 某些情况下网络图片可能加载失败
- **搜索页面**: 当前搜索页面是占位实现，将来需要替换为实际的搜索页面
- **分类详情页**: 当前分类详情页是占位实现，将来需要替换为实际的分类详情页面

### 临时解决方案:

- 使用骨架屏 (Skeleton) 解决首次加载时间长的问题
- 使用占位图解决图片加载失败问题
- 使用本地缓存解决网络不可用时的数据显示问题

### 修复计划:

- 计划在 v2.0 版本通过预加载方式解决首次加载缓慢问题
- 计划在 v2.0 版本实现完整的搜索页面和分类详情页面

### 开发者注意事项:

- 轮播图点击后的导航逻辑依赖于 `targetType` 和 `targetValue`，需要确保这些值正确
- "让ta看看"按钮的功能依赖于对话框确认，需要确保对话框正确显示

## 10. 跨模块通信机制 (Cross-Module Communication)

### 输出事件/通知:

- **`ProductViewedEvent`**: 当用户查看产品详情时发出，其他模块可能需要响应此事件以更新推荐算法
- **`ProductRecommendedEvent`**: 当用户点击"让ta看看"按钮并确认时发出，AI 助手模块需要监听此事件以接收推荐

### 输入事件/通知:

- **`UserLogoutEvent`**: 当用户登出时，Home 模块需要清除个性化推荐数据
- **`ThemeChangedEvent`**: 当应用主题改变时，Home 模块需要更新 UI 样式

### 通信方式:

Home 模块使用事件总线机制实现跨模块通信，相关代码位于 `lib/core/event/app_events.dart`。

### 直接依赖:

Home 模块不直接依赖其他模块的服务或数据，而是通过以下方式实现解耦:

- 使用依赖注入注册和获取服务
- 使用接口定义而非具体实现
- 使用事件总线进行松耦合通信