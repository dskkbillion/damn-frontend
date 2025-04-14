# 卖家仪表盘模块重构任务清单

本文档跟踪 `SellerDashboard` 模块按照 Flutter Clean Architecture 增量重构方法论进行的具体任务。

**当前分支**: `refactor/seller-dashboard-module` (建议)

## 核心工作流步骤

- [x] **2. 定义模块边界**

  - [x] 明确 `SellerDashboard` 模块的核心业务能力：展示卖家的关键运营统计数据，包括核心指标、升级进度、财务指标和待处理任务概览。
  - [x] 识别核心要素 (`Domain` 层)：
    - [x] 列出主要 `Use Cases`：`GetSellerDashboardData` (聚合三个 API 的数据:获取并提供仪表盘完整数据)。
    - [x] 定义核心 `Entities`：`SellerDashboardData` (包含 `heatPercent`, `recoverPercent`, `completePercent`, `goodPercent`, `days` [目标], `orderNum` [目标], `orderPrice` [目标], `totalDays` [进度], `upgradeProgressOrderCount` [进度,来自/upgradeLevel], `totalOrderPrice` [进度], `totalEarnings`, `thisMonthTotalEarnings`, `overallTotalOrderCount` [来自/index], `activeOrderNum`, `pendingOrderNum`, `receiptOrderNum`, `earlyTime`, `latenessTime` 等字段)。
    - [x] 定义所需的 `Repository Interfaces`：`ISellerDashboardRepository`。
  - [x] 识别交互点：
    - [x] 确定需要调用的其他模块 `Domain` 接口：`IAuthRepository` 或类似接口，用于获取请求所需的 `Authorization` token。
    - [x] 确定需要触发的导航事件：暂无明确的从仪表盘 _出发_ 的导航需求（主要通过底部 Tab 导航 _至_ 此页面）。
  - [ ] (可选) 产出初步设计笔记/图表。

- [x] **3. 分析参考代码 (验证与细化)**

  - [x] 深入研究 RN 项目 `app/(sellerscreens)/index.tsx` 和 `design-info/frontend.md` 的总结 (并结合目标 UI 图片 `@2741743048073_.pic.jpg`)。
  - [x] 验证/调整步骤 2 中定义的边界和核心要素。

  * [x] **提取业务逻辑 (`Domain` 层)**: 确认 `GetSellerDashboardData` Use Case 主要负责调用 Repository 获取数据。数据聚合和字段修正逻辑下沉到 `Data` 层（Repository 实现）。
  * [x] **提取数据交互 (`Data` 层)**:
    - 记录 API 端点：`POST /api/project/statistics/percent`, `POST /api/project/statistics/upgradeLevel`, `POST /api/project/statistics/index` (确认全部使用 POST)。
    - 记录请求 Header: 需要 `Authorization` (需要设计以便于注入真实或 Mock Token)。
    - 记录响应格式：参考 `seller_dashboard.openapi.json`。
    - 记录字段处理要点：
      - `copyWritingDays` 等旧前端字段不使用。
      - `totalOrderNum` 需区分映射为 `upgradeProgressOrderCount` 和 `overallTotalOrderCount`。
      - `earlyTime`/`latenessTime`: 按后端返回的 `integer` 类型处理，具体业务含义待后端澄清，UI 层按 `earlyTime / latenessTime` 格式展示。
  * [x] **提取 UI 流程与交互 (`Presentation` 层)**:
    - 记录页面结构：顶部核心指标（4 个圆圈），升级进度模块，指标模块，待处理模块 (参考目标图片 `@2741743048073_.pic.jpg`)。
    - 记录 UI 状态：加载中、加载成功、加载失败。
    - 记录用户事件：页面加载触发数据获取，可能需要下拉刷新。

- [x] **4. 精化 `Domain` 层接口**

  - [x] 在 `lib/features/seller_dashboard/domain/` 目录下创建/完善 `.dart` 文件 (包括 `entities/`, `repositories/`, `usecases/` 子目录)。
  - [x] 编写最终的 `SellerDashboardData` Entity 定义。
  - [x] 编写最终的 `GetSellerDashboardData` Use Case 抽象类/接口。
  - [x] 编写最终的 `ISellerDashboardRepository` 接口定义 (可能包含一个 `Future<Either<Failure, SellerDashboardData>> getDashboardData()` 方法)。
  - [x] 添加详细的文档注释 (`///`)。

- [x] **5. 实现 Flutter `Data` 层**

  - [x] 在 `lib/features/seller_dashboard/data/repositories/` 下创建 `SellerDashboardRepositoryImpl`。
  - [x] 在 `lib/features/seller_dashboard/data/datasources/` 下创建 `SellerDashboardRemoteDataSource` (目前不需要 LocalDataSource)。
  - [x] 在 `lib/features/seller_dashboard/data/models/` 下定义 `DTOs` (`PercentDataDto`, `UpgradeLevelDataDto`, `IndexDataDto`) 并实现与 `Entities` 的映射 (映射逻辑将在 Repository 实现)。
  - [x] 处理数据层错误（网络错误、解析错误、API 业务错误）并映射到 `Domain` `Failures` (概念确认，具体代码在实现 DataSource/Repository 时添加)。
  - [x] 创建 Mock `SellerDashboardRemoteDataSource` 用于测试。

- [x] **6. 实现 Flutter `Domain` 逻辑**

  - [x] 在 `lib/features/seller_dashboard/domain/usecases/` 下创建 `GetSellerDashboardData` 实现类。
  - [x] 注入 `ISellerDashboardRepository` 接口 (通过构造函数)。
  - [x] 实现调用 `repository.getDashboardData()` 的逻辑。

- [x] **7. 实现 Flutter `Presentation` 层**

  - [x] 在 `lib/features/seller_dashboard/presentation/pages/` 下创建 `SellerDashboardPage` Widget。
  - [x] 在 `lib/features/seller_dashboard/presentation/widgets/` 下创建可复用组件 (`PerformanceMetricsWidget`, `UpgradeProgressWidget`, `IndicatorsWidget`, `PendingTasksWidget`) 的骨架。
  - [x] 在 `lib/features/seller_dashboard/presentation/providers/` (或 `bloc/`, `cubit/`) 下创建状态管理类 (`SellerDashboardState`, `SellerDashboardNotifier`) 的骨架。
  - [x] 状态管理类依赖 `GetSellerDashboardData` Use Case 接口 (已在骨架中体现)。
  - [x] 实现状态管理逻辑和 UI 事件处理 (基本逻辑已在 Notifier 骨架中体现，具体 UI 调用待实现)。
  - [x] UI `Widgets` 监听状态并触发事件 (基本结构已在 Page Widget 中实现，子 Widget 渲染待填充)。

- [x] **8. 识别并配置外部依赖 (隔离开发)**

  - [x] 确定需要依赖的 `IAuthRepository` (或类似) 接口以获取 Token (已在 Repository 实现中要求注入)。
  - [x] 确定导航服务接口 (如果需要处理导航事件) (当前模块无此需求)。
  - [x] (在预览/测试环境中) 配置 Mock 依赖注入 (例如 Mock `IAuthRepository`, Mock `SellerDashboardRemoteDataSource`) 和 DI 容器 (概念完成, 具体配置在测试/预览入口实现)。

- [ ] **9. 编写单元/Widget 测试**

  - [ ] **`Domain` 层**: 测试 `GetSellerDashboardData` Use Case。
  - [ ] **`Data` 层**: 测试 `SellerDashboardRepositoryImpl`, `SellerDashboardRemoteDataSource` (使用 Mock Dio/Http)。
  - [ ] **`Presentation` 层**: 测试状态管理逻辑 (`Riverpod Notifier`/`Bloc`), 关键 `Widgets`。
  - [ ] 检查测试覆盖率。

- [ ] **10. 在模块预览环境中调试和验证**

  - [ ] (可选但推荐) 创建并运行 `main_seller_dashboard_preview.dart` (使用命令: `flutter run -t lib/main_previews/main_seller_dashboard_preview.dart`)。
  - [ ] 确保 Mock 依赖已注入。
  - [ ] 手动测试 UI 和交互流程。

- [ ] **11. (模块完成后) 集成准备**

  - [ ] 确认满足 DoD (Definition of Done)。
  - [ ] 完成代码评审 (PR/MR)。
  - [ ] 确保主开发分支为最新。

- [ ] **12. 执行集成与测试**

  - [ ] 合并 `refactor/seller-dashboard-module` 分支到主开发分支。
  - [ ] 在主工程中更新 DI 配置 (替换 Mock `DataSource`/`Repository` 和 Mock `Auth`)。
  - [ ] 在主工程中更新导航配置 (确保 Tab 导航能正确加载此页面)。
  - [ ] 执行集成测试 (模块间交互、E2E、回归)。

- [ ] **13. 重复**
  - [ ] (可选) 删除特性分支。
  - [ ] 选择下一个模块。
