# Home 模块重构任务清单

本文档跟踪 `Home` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。

**当前分支**: `refactor/home-module`

## 核心工作流步骤

- [x] **2. 定义模块边界**
    - [x] 明确 `Home` 模块的核心业务能力：聚合展示应用的核心内容概览，提供导航入口。
    - [x] 识别核心要素 (`Domain` 层)：
        - [x] 列出主要 `Use Cases` (`GetHomePageDataUseCase`, `GetHomeFeedUseCase`)。
        - [x] 定义核心 `Entities` (`Banner`, `HomeCategory`, `HomeFeedItem`, `HomePageData`)。
        - [x] 定义所需的 `Repository Interfaces` (`IHomeRepository`)。
    - [x] 识别交互点：
        - [x] 确定需要调用的其他模块 `Domain` 接口 (`IBannerRepository`, `ICategoryRepository`, `IProductRepository`)。
        - [x] 确定需要触发的导航事件 (如 `navigateToProductDetail`, `showRecommendConfirmation`)。
    - [x] 产出初步设计文档 (home_boundary_definition.md)。

- [x] **3. 分析参考代码 (验证与细化)**
    - [x] 深入研究 demo-repository 中的 Home 相关代码 (waterfallLayout.tsx, top_carousel.tsx 等)。
    - [x] 验证/调整步骤 2 中定义的边界和核心要素。
    - [x] **提取业务逻辑 (`Domain` 层)**:
        - [x] 记录首页数据加载逻辑
        - [x] 记录轮播图和服务列表的交互逻辑
    - [x] **提取数据交互 (`Data` 层)**:
        - [x] 记录 API 端点 (`/api/shop/product/recommend/detail`, `/api/content/banner/list`)
        - [x] 记录请求/响应格式
        - [x] 记录错误处理方式
    - [x] **提取 UI 流程与交互 (`Presentation` 层)**:
        - [x] 记录页面布局和组件结构
        - [x] 记录状态管理逻辑
        - [x] 记录用户事件处理

- [x] **4. 精化 `Domain` 层接口**
    - [x] 在 `lib/features/home/domain/` 目录下创建/完善 `.dart` 文件。
    - [x] 编写最终的 `Entities`:
        - [x] `Banner` 实体
        - [x] `HomeCategory` 实体
        - [x] `HomeFeedItem` 实体
        - [x] `HomePageData` 实体
    - [x] 编写最终的 `Use Cases`:
        - [x] `GetHomePageDataUseCase`
        - [x] `GetHomeFeedUseCase`
    - [x] 编写最终的 `Repository Interfaces`:
        - [x] `IHomeRepository`
    - [x] 添加详细的文档注释 (`///`)。

- [x] **5. 实现 Flutter `Data` 层**
    - [x] 在 `lib/features/home/data/repositories/` 下创建 `HomeRepositoryImpl`。
    - [x] 在 `lib/features/home/data/datasources/` 下创建:
        - [x] `HomeRemoteDataSource` - 处理 API 调用
        - [x] `HomeLocalDataSource` - 处理本地缓存
    - [x] 在 `lib/features/home/data/models/` 下定义 `DTOs`:
        - [x] `BannerModel`
        - [x] `HomeCategoryModel`
        - [x] `HomeFeedItemModel`
        - [x] `HomePageDataModel`
    - [x] 实现与 `Entities` 的映射逻辑
    - [x] 处理数据层错误并映射到 `Domain` `Failures`。
    - [x] 创建 Mock `DataSource` 用于预览。

- [x] **6. 实现 Flutter `Domain` 逻辑**
    - [x] 在 `lib/features/home/domain/usecases/` 下创建 `Use Case` 实现类:
        - [x] `GetHomePageDataUseCase` 实现
        - [x] `GetHomeFeedUseCase` 实现
    - [x] 注入 `Repository` 接口。
    - [x] 实现核心业务逻辑。

- [x] **7. 实现 Flutter `Presentation` 层**
    - [x] 在 `lib/features/home/presentation/pages/` 下创建页面 `Widgets`:
        - [x] `HomePage` - 首页主页面
    - [x] 在 `lib/features/home/presentation/widgets/` 下创建可复用组件:
        - [x] `BannerCarousel` - 轮播图组件
        - [x] `HomeFeedList` - 信息流列表组件
        - [x] `ProductCard` - 商品/服务卡片组件
        - [x] 搜索框 - 集成在 HomePage 的 AppBar 中
    - [x] 在 `lib/features/home/presentation/bloc/` 下创建状态管理类:
        - [x] `HomeBloc` - 管理首页状态
        - [x] `HomeEvent` - 定义首页事件
        - [x] `HomeState` - 定义首页状态
    - [x] 状态管理类依赖 `Use Case` 接口。
    - [x] 实现状态管理逻辑和 UI 事件处理。
    - [x] UI `Widgets` 监听状态并触发事件。

- [x] **8. 识别并配置外部依赖 (隔离开发)**
    - [x] 确定需要调用的导航服务方法:
        - [x] `navigateToProductDetail`
        - [x] `navigateToSearch`
        - [x] `showRecommendConfirmation`
    - [x] 确定需要依赖的其他模块 `Domain` 接口:
        - [x] `IBannerRepository`
        - [x] `ICategoryRepository`
        - [x] `IProductRepository`
    - [x] (在预览/测试环境中) 配置 Mock 依赖注入。

    - [ ] 检查测试覆盖率。

- [x] **9. 在模块预览环境中调试和验证**
    - [x] 创建并运行 `main_home_preview.dart`。
    - [x] 确保 Mock 依赖已注入。
    - [x] 手动验证 UI 和交互流程:
        - [x] 验证顶部搜索框
        - [x] 验证轮播图滚动和点击
        - [x] 验证服务卡片点击
        - [x] 验证"让ta看看"按钮
        - [x] 验证下拉刷新和加载更多
        - [x] 验证错误处理

- [ ] **10. (模块完成后) 集成准备**
    - [ ] 确认满足 DoD (Definition of Done)。
    - [ ] 完成代码评审 (PR/MR)。
    - [ ] 确保主开发分支为最新。

- [ ] **11. 执行集成**
    - [ ] 合并 `refactor/home-module` 分支到主开发分支。
    - [ ] 在主工程中更新 DI 配置 (替换 Mock)。
    - [ ] 在主工程中更新导航配置 (注册真实路由)。
    - [ ] 执行集成验证 (模块间交互)。

- [ ] **12. 重复**
    - [ ] (可选) 删除特性分支。
    - [ ] 选择下一个模块。

## 设计变更记录

### 2025/4/13 - 根据用户反馈的 UI 调整
1. **添加搜索框**：在顶部 AppBar 中添加了搜索框，用于搜索服务
2. **移除分类列表**：移除了轮播图下方的分类列表（小圆框的分类），直接让轮播图底下是瀑布流