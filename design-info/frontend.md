# 卖家仪表盘前端逻辑总结 (来自 demo-repository)

本文档结合 `demo-repository` 前端代码 (`app/(sellerscreens)/`) 和 `seller_dashboard.openapi.json` 接口定义，总结了卖家仪表盘的核心逻辑，包括路由、数据流、前后端交互和渲染，以便于 Flutter 项目重构。

## 路由与页面结构

1.  **主要页面/路由:** 卖家相关功能集中在 `app/(sellerscreens)/` 目录下。

    - `app/(sellerscreens)/_layout.tsx`: 定义该屏幕组的布局，使用 `expo-router` 的 `Tabs` 组件创建底部导航栏。
    - `app/(sellerscreens)/index.tsx`: **卖家仪表盘主页**，展示核心统计数据。

2.  **路由跳转逻辑:**
    - 主要通过底部 `Tabs` 在主页、发布、消息、我的之间进行切换。
    - 仪表盘主页 (`index.tsx`) 本身未包含跳转到其他业务页面的显式逻辑。

## 前后端连接与数据流

1.  **数据获取触发时机:**

    - 仪表盘主页 (`SellerHomepage`) 组件加载时，通过 `useEffect` Hook 调用 `fetchSellerData` 函数来触发数据获取。

2.  **数据请求 API:**

    - `fetchSellerData` 函数（或 Flutter 中的等效逻辑）会调用以下三个 API 端点获取数据。**注意:** 所有请求都需要在 Header 中传递 `Authorization`。
      - POST `/api/project/statistics/percent`: 获取百分比统计数据。
      - POST `/api/project/statistics/upgradeLevel`: 获取升级相关的统计数据。
      - POST `/api/project/statistics/index`: 获取指标和待处理数据。

3.  **数据存储 (Demo):**

    - 在 `demo-repository` 中，获取的数据合并存储在 `Redux store` 的 `user.statData` 对象中。
    - 组件通过 `useSelector` 从 `store` 读取数据。

4.  **数据流向 (Flutter):**

    - Flutter 实现中，应在页面加载时调用上述三个 API。
    - 获取数据后，通过合适的状态管理方案（如 Provider, Riverpod, BLoC 等）将数据整合并提供给 UI 层进行渲染。

5.  **错误处理 (Demo):**
    - `fetchSellerData` 检查所有请求是否成功 (`isAxiosSuccess`)，失败时在控制台打印日志。
    - Flutter 实现中应有更健壮的错误处理机制，如提示用户、重试等。

## 数据渲染逻辑与接口字段映射

仪表盘 UI 使用 `Tamagui` 构建，数据从状态管理中获取并渲染。以下表格将 `openapi.json` 中的接口字段与前端展示关联：

| API 端点                                   | 接口返回字段 (`data` 对象内) | 前端对应 `statData` 字段 (RN 代码参考) | Flutter Entity 字段 (最终使用) | 前端展示/功能 (基于 index.tsx)     | Flutter 重构注意点                                                                                                                        |
| :----------------------------------------- | :--------------------------- | :------------------------------------- | :----------------------------- | :--------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------- |
| **`/api/project/statistics/percent`**      |                              |                                        |                                | **核心指标 (四个圈)**              |                                                                                                                                           |
|                                            | `heatPercent`                | `heatPercent`                          | `heatPercent`                  | 热度值 (%)                         |                                                                                                                                           |
|                                            | `recoverPercent`             | `recoverPercent`                       | `recoverPercent`               | 回复率 (%)                         |                                                                                                                                           |
|                                            | `completePercent`            | `completePercent`                      | `completePercent`              | 完成率 (%)                         |                                                                                                                                           |
|                                            | `goodPercent`                | `goodPercent`                          | `goodPercent`                  | 好评率 (%)                         |                                                                                                                                           |
| **`/api/project/statistics/upgradeLevel`** |                              |                                        |                                | **升到下一级**                     |                                                                                                                                           |
|                                            | `days`                       | (`copyWritingDays`?)                   | `days`                         | 升级目标天数 (分母)                | **重要:** RN 代码中 `copyWritingDays` 等字段与 API 不符，Flutter 应严格使用 API 返回的 `days`, `orderNum`, `orderPrice` 作为 **目标值**。 |
|                                            | `orderNum`                   | (`copyWritingOrderNum`?)               | `orderNum`                     | 升级目标订单数 (分母)              |                                                                                                                                           |
|                                            | `orderPrice`                 | (`copyWritingOrderPrice`?)             | `orderPrice`                   | 升级目标订单金额 (分母)            |                                                                                                                                           |
|                                            | `totalDays`                  | `totalDays`                            | `totalDays`                    | 当前已满足天数 (分子)              | 使用 `totalDays`, `upgradeProgressOrderCount`, `totalOrderPrice` 作为 **当前进度值**。                                                    |
|                                            | `totalOrderNum`              | `totalOrderNum`                        | `upgradeProgressOrderCount`    | 当前已满足订单数 (分子)            | **重要:** 此处 API 返回的 `totalOrderNum` 用于升级进度，Flutter Entity 中命名为 `upgradeProgressOrderCount`。                             |
|                                            | `totalOrderPrice`            | `totalOrderPrice`                      | `totalOrderPrice`              | 当前已满足订单金额 (分子)          |                                                                                                                                           |
| **`/api/project/statistics/index`**        |                              |                                        |                                | **指标 & 待处理**                  |                                                                                                                                           |
|                                            | `totalEarnings`              | `totalEarnings`                        | `totalEarnings`                | 总盈利                             |                                                                                                                                           |
|                                            | `thisMonthTotalEarnings`     | `thisMonthTotalEarnings`               | `thisMonthTotalEarnings`       | 本月盈利                           |                                                                                                                                           |
|                                            | `totalOrderNum`              | `totalOrderNum`                        | `overallTotalOrderCount`       | 总订单数 (也用于指标展示)          | **重要:** 此处 API 返回的 `totalOrderNum` 用于整体指标，Flutter Entity 中命名为 `overallTotalOrderCount`。需与 `/upgradeLevel` 的区分。   |
|                                            | `activeOrderNum`             | `activeOrderNum`                       | `activeOrderNum`               | 活跃订单数                         |                                                                                                                                           |
|                                            | `pendingOrderNum`            | `pendingOrderNum`                      | `pendingOrderNum`              | 未完成订单数                       |                                                                                                                                           |
|                                            | `receiptOrderNum`            | `receiptOrderNum`                      | `receiptOrderNum`              | 回单订单数                         |                                                                                                                                           |
|                                            | `earlyTime`                  | `earlyTime`                            | `earlyTime`                    | 距离下次递交日 (最早)              | 需确认 `earlyTime` 和 `latenessTime` 的具体含义、单位和格式。                                                                             |
|                                            | `latenessTime`               | (`latenessTime`?)                      | `latenessTime`                 | 距离下次递交日 (最晚) (前端未使用) |                                                                                                                                           |

## UI 设计参考 (基于目标图片)

根据提供的目标 UI 图片 (`@2741743048073_.pic.jpg`)，最终实现的 Flutter UI 应遵循以下结构和风格：

1.  **整体布局:** 页面使用浅灰色背景，内容模块垂直排列并有清晰间距。底部为标准 Tab 导航。
2.  **核心指标:**
    - 顶部水平排列四个圆形指标。
    - 圆形边框颜色区分：前两个（热度、回复率）为棕褐色/金色，后两个（完成、好评率）为灰色。
    - 圈内显示百分比，下方为文字标签。
3.  **内容模块 (升到下一级, 指标, 待处理):**
    - 均包含模块标题。
    - 使用带有圆角的浅白色背景卡片容纳内容。
    - 卡片内布局各有不同：
      - **升级:** 三行文字，左侧描述，右侧为 `当前值/目标值` 格式的进度分数，数值颜色突出（棕褐色/金色）。
      - **指标:** 左右两列布局，标签在左，数值在右，数值颜色突出。
      - **待处理:** 两行文字，左侧标签，右侧为数值及带括号的详细说明（如 `X (待完成) / Y (回单)`），数值颜色突出。
4.  **颜色与风格:**
    - 主色调为浅灰背景、浅白卡片、棕褐色/金色重点元素、灰色次要元素。
    - 字体大小和粗细用于区分不同信息层级（标题、标签、数值、详情）。

(此部分基于目标图片总结，细节上可能与 RN Tamagui 代码的直接映射略有不同，以此图片为准进行 Flutter UI 实现)

## 总结与 Flutter 重构建议

卖家仪表盘通过聚合三个核心 API (`/percent`, `/upgradeLevel`, `/index`) 的数据，为卖家提供运营状态的关键指标概览。

**Flutter 重构时需关注：**

1.  **API 调用:** 确认三个 API 的实际 HTTP 方法 (GET/POST)，并正确处理 Header 中的 `Authorization`。
2.  **数据整合:** 设计合理的数据模型 (Dart class) 来整合三个 API 返回的数据，方便状态管理和 UI 使用。
3.  **状态管理:** 选择合适的 Flutter 状态管理方案管理整合后的数据模型。
4.  **字段校正:** 纠正前端代码中可能存在的字段名错误 (如 `copyWritingDays` 等)，严格按照 `openapi.json` 定义的字段进行数据处理和渲染。
5.  **UI 实现:** 使用 Flutter 组件复现 `Tamagui` 实现的布局和样式。
6.  **错误处理:** 实现用户友好的错误提示和处理逻辑。
7.  **数据含义确认:** 与后端确认 `totalOrderNum` 的重复性以及 `earlyTime`/`latenessTime` 的具体含义和格式。
