# Home 模块边界定义 (Boundary Definition)

本文档基于初步分析、React Native 源代码、HTML 原型以及通用首页设计模式，定义了 `Home` 模块的边界。

## 1. 模块名称

`Home` (首页)

## 2. 核心业务能力 (Business Capability)

作为用户进入应用的主要入口之一，负责聚合展示应用的核心内容概览，例如 Banner 广告、功能/分类入口、以及一个主要的内容信息流（如帖子、商品推荐等）。提供到应用内其他主要区域（搜索、分类详情、内容详情页）的导航入口。

## 3. 核心要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`Banner`**: 表示首页的横幅广告或推广位。
    *   `id`: (String) 唯一标识。
    *   `imageUrl`: (String) 图片 URL。
    *   `targetType`: (枚举: `post`, `product`, `category`, `url`, `none`) 点击后的目标类型。
    *   `targetValue`: (String) 目标的具体值（如帖子 ID、商品 ID、分类 ID、外部链接 URL）。
*   **`HomeCategory`**: 表示首页展示的快速分类入口。
    *   `id`: (String) 分类唯一标识。
    *   `name`: (String) 分类名称。
    *   `iconUrl`: (String) 图标 URL。
    *   `targetType`: (枚举: `category`, `search`, `feature`) 点击后的目标类型 (跳转到分类页、带关键词的搜索页、某个特定功能页等)。
    *   `targetValue`: (String) 目标的具体值。
*   **`HomeFeedItem`**: 表示首页信息流中的单个项目 (这是一个抽象概念，具体可以是帖子、商品等的预览)。
    *   `id`: (String) 项目唯一标识。
    *   `type`: (枚举: `post`, `product`, `advertisement`, etc.) 项目类型。
    *   `title`: (String) 标题。
    *   `coverImageUrl`: (String) 封面图片 URL。
    *   *(具体类型如 `PostPreview` 或 `ProductPreview` 会扩展此基础，并包含各自特有的预览信息，例如作者、价格等。这些具体类型可能定义在各自的模块中，`Home` 模块使用它们的接口或简化版本)*
*   **`HomePageData`**: 聚合首页所需的所有动态数据。
    *   `banners`: `List<Banner>`
    *   `categories`: `List<HomeCategory>`
    *   `feedItems`: `List<HomeFeedItem>` (首屏信息流数据)

### 3.2. `Use Cases` (主要功能点/用户故事)

*   **`GetHomePageDataUseCase`**: 获取首屏所需的聚合数据（Banner、分类、第一页信息流）。
    *   输入: `void`
    *   输出: `Either<Failure, HomePageData>`
*   **`GetHomeFeedUseCase`**: 获取首页信息流的后续分页数据。
    *   输入: `page` (int), `limit` (int) (或其他分页参数)
    *   输出: `Either<Failure, List<HomeFeedItem>>`

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IHomeRepository`**: 定义为 `Home` 模块获取聚合数据的数据访问接口。
    *   `Future<Either<Failure, HomePageData>> getHomePageData()`: 实现获取首页所有区域的初始数据。
    *   `Future<Either<Failure, List<HomeFeedItem>>> getHomeFeed(int page, int limit)`: 实现获取信息流的分页数据。

*   **(依赖接口 - 由其他模块定义，供 `IHomeRepository` 实现层使用):**
    *   `IBannerRepository` (可能来自 `Core` 或 `Marketing` 模块): 提供获取 Banner 列表的功能。
    *   `ICategoryRepository` (可能来自 `Core` 或 `Product` 模块): 提供获取分类列表的功能。
    *   `IPostRepository` (来自 `Post` 模块): 提供获取帖子预览列表的功能。
    *   `IProductRepository` (来自 `Product`/`Item` 模块): 提供获取商品预览列表的功能。
    *   *(注意: `Home` 模块的 `Data` 层 `HomeRepositoryImpl` 将负责调用这些底层 Repository 获取数据并聚合成 `HomePageData` 或 `HomeFeedItem` 列表)*

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   **`Core/Shared` 模块**:
    *   依赖通用的 `Failure` 定义。
    *   依赖网络请求客户端抽象或实现。
    *   可能依赖基础的 Repository 实现或帮助类。
*   **各内容源模块 (如 `Post`, `Product`, `Category`, `Marketing`)**:
    *   依赖这些模块定义的 `Domain` 层 Repository *接口* (如 `IPostRepository`, `IProductRepository` 等)，以便 `Home` 模块的 `Data` 层可以调用它们获取数据。
    *   可能依赖这些模块定义的 `Domain` 层 `Entity` (如 `PostPreview`, `ProductPreview`) 用于 `HomeFeedItem` 的具体表示。
*   **`Auth` 模块**:
    *   可能需要依赖 `GetAuthStatusUseCase` 来检查用户登录状态，以便展示个性化内容或判断某些操作是否需要登录。

### 4.2. 导航需求 (Navigation Needs)

`Home` 模块的 `Presentation` 层需要触发以下导航事件 (通过中央导航服务实现):

*   `navigateToSearch(initialQuery: String?)`: 点击搜索栏或搜索推荐时。
*   `navigateToCategoryDetail(categoryId: String)`: 点击分类图标时 (如果目标是分类详情)。
*   `navigateToPostDetail(postId: String)`: 点击信息流中的帖子预览时。
*   `navigateToProductDetail(productId: String)`: 点击信息流中的商品预览时。
*   `navigateToUrl(url: String)`: 点击指向外部链接的 Banner 时。
*   `navigateToFeature(featureRoute: String)`: 点击指向特定功能页面的分类或 Banner 时。
*   `navigateToLogin()`: 当执行需要登录的操作（如个性化推荐交互）但用户未登录时。

---

**待确认/后续步骤:**

*   明确首页信息流 (`HomeFeedItem`) 具体包含哪些类型的内容（帖子？商品？混合？），以及每种类型需要展示哪些预览信息。
*   确认获取首页聚合数据 (`HomePageData`) 的具体 API 调用方式（是一个统一接口还是需要客户端多次调用？）。
*   确认 Banner 和分类的具体跳转逻辑和目标类型。 