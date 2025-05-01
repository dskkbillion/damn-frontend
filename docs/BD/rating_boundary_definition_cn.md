# Rating 模块边界定义

## 1. 模块名称

`Rating` (评价 / 评论)

## 2. 核心业务能力

允许用户（通常是买家）为已完成的订单/服务提交反馈，包括量化评分（例如星级）、文字评论和可选图片。提供查看与特定订单、商品或卖家相关的评价视图。

## 3. 核心领域要素 (`Domain` 层)

### 3.1. `Entities` (核心业务对象)

*   **`Evaluation` / `Review`**: 代表一个用户的评价。
    *   `id`: (String) 评价的唯一 ID。
    *   `orderId`: (String) 关联的订单 ID。
    *   `productId`: (String) 关联的商品/服务 ID。
    *   `sellerId`: (String) 关联的卖家 ID。
    *   `buyerId`: (String) 提交评价的用户 ID。
    *   `score`: (int) 数字评分 (例如 1-5)。
    *   `comment`: (String?) 文字评论。
    *   `images`: (`List<String>`?) 上传图片的 URL。
    *   `isAnonymous`: (bool) 是否匿名评价。
    *   `createdAt`: (DateTime) 提交时间。
    *   `reply`: (`EvaluationReply`?) 卖家的回复 (可选)。
*   **`EvaluationReply`**: 卖家对评价的回复。
    *   `sellerId`: (String)
    *   `replyText`: (String)
    *   `repliedAt`: (DateTime)
*   **`RatingSummary`**: 聚合的评分统计（例如针对商品或卖家）。
    *   `averageScore`: (double) 平均分。
    *   `totalCount`: (int) 总评价数。
    *   `scoreDistribution`: (Map<int, int>?) 各评分等级（1-5星）的数量分布。

### 3.2. `Use Cases` (主要功能点)

*   `SubmitEvaluationUseCase(orderId, score, comment?, images?, isAnonymous?)`: 提交订单评价。
*   `GetEvaluationForOrderUseCase(orderId)`: 获取特定订单的评价。
*   `GetEvaluationsForProductUseCase(productId, filter?, page, limit)`: 获取商品相关的评价列表。
*   `(可选) GetEvaluationsForUserUseCase(userId, filter?, page, limit)`: 获取用户提交的评价列表。
*   `(可选) GetRatingSummaryForProductUseCase(productId)`: 获取商品的聚合评分统计。

### 3.3. `Repository Interfaces` (数据操作契约)

*   **`IRatingRepository`**: 数据访问接口。
    *   `Future<Either<Failure, void>> submitEvaluation(evaluationData)`。
    *   `Future<Either<Failure, Evaluation?>> getEvaluationForOrder(String orderId)`.
    *   `Future<Either<Failure, List<Evaluation>>> getEvaluationsForProduct(String productId, filter?, page, limit)`.
    *   `Future<Either<Failure, RatingSummary>> getRatingSummaryForProduct(String productId)`.
    *   *(根据需要添加其他方法)*

## 4. 交互点 (Interaction Points)

### 4.1. 对外依赖 (Dependencies)

*   `Core/Shared`: 通用工具、Failure、HTTP 客户端。
*   `Auth`: 获取当前用户 ID（用于提交）。
*   `Order`: 需要 `orderId`。从订单详情页发起提交流程。
*   `Product`: 需要 `productId` 用于商品相关的评价。
*   `User/Profile`: 需要用户信息（头像、昵称）来显示评价。
*   `Navigation`: 用于在评价相关屏幕之间导航。
*   `FilePicker/Uploader`: 用于上传评价图片。

### 4.2. 导航需求 (由 `INavigationService` 提供)

*   `navigateToSubmitEvaluation(orderId)`: 由 `Orders` 调用以打开评价表单。
*   `navigateToProductReviews(productId)`: 由 `Product` 模块调用以显示商品的所有评价。
*   `navigateToUserEvaluations(userId)`: 由 `Profile` 模块调用以显示用户提交的评价。
*   `pop()` / `goBack()`.

### 4.3. 事件 (监听或发出)

*   监听 `OrderCompletedEvent` 或 `OrderBecameEvaluableEvent` 以知晓订单何时可以评价。
*   可能发出 `EvaluationSubmittedEvent`。

## 5. 表示层 (Presentation Layer - 高层级)

*   **Screens**: 评价提交表单、商品评价列表、用户评价列表。
*   **State Management**: `EvaluationSubmitCubit`, `ProductReviewsCubit`, `UserEvaluationsCubit`。
*   **Widgets**: 星级评分输入、评论文本域、图片上传器、匿名开关、评价卡片。

## 6. 数据层 (Data Layer - 高层级)

*   **DataSource**: `IRatingRemoteDataSource` (调用 `/api/shop/evaluate/...` 等 API 端点)。
*   **Models**: `EvaluationModel` 等。
*   **Repository Impl**: `RatingRepositoryImpl`。 