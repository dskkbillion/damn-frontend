# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter e-commerce app (多少看看 DSKK), being refactored from React Native under Clean Architecture. The codebase grows module-by-module: each feature is first developed against mocks, then integrated into the unified entry.

- Flutter SDK: `>=3.4.0 <4.0.0`
- Package name: `dskk_flutter_refactor`
- Single unified entry point for all regions/environments (see below)

## Commands

### Run / Build
```bash
# Dev & prod share the same entry — environment differences come from .env
flutter run  -t lib/main_unified.dart
flutter build apk -t lib/main_unified.dart --release
flutter build ios -t lib/main_unified.dart --release

# Switch env file (defaults to .env). Used e.g. for local debug:
flutter run -t lib/main_unified.dart --dart-define=ENV_FILE=.env.local-debug
```
`lib/main_unified.dart` reads `ENV_FILE` via `String.fromEnvironment`, then loads it with `flutter_dotenv`. Legacy/per-region entries live in `lib/archived_entries/` and are excluded from `flutter analyze` via `analysis_options.yaml`.

### Code generation (freezed / json_serializable / injectable / drift)
```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
```
Re-run after changes to: `@freezed` / `@JsonSerializable` models, `@injectable` classes, Drift tables/DAOs.

### Test / Analyze / i18n
```bash
flutter test                                    # all tests
flutter test test/features/<module>/foo_test.dart   # single file
flutter test --coverage
flutter test integration_test/
flutter analyze                                 # ALWAYS run after editing a .dart file
dart fix --apply
flutter gen-l10n                                # after editing lib/l10n/*.arb
```

## Architecture

### Layers (Clean Architecture)
Every feature in `lib/features/<name>/` is split into:
- `domain/` — entities, repository interfaces, use cases (pure Dart, no Flutter deps)
- `data/` — DTOs (`*_model.dart`), `datasources/` (remote/local), repository impls
- `presentation/` — pages, widgets, BLoC/Cubit + routes

Cross-feature plumbing lives in `lib/core/`. Key subsystems:
- `network/` — `CoreDioClient` + interceptors (auth header, logging, cache). **All remote data sources go through `CoreDioClient`.**
- `database/` — Drift SQLite DB at `app_database.dart` (version 1, order cache etc.)
- `di/` — project-wide GetIt container helpers
- `router/` + `lib/app/navigation/` — Go Router config (`app_router_config.dart`)
- `cache/` — HTTP/data caching strategy, background refresh
- `events/` — cross-module event bus
- `currency/`, `config/region_config.dart` — region & currency (defaults to USD in unified entry)
- `payment/`, `platform/` — native bridges
- `analytics/`, `error/`, `secure_storage_repository.dart`

### Dependency Injection
`get_it` + `injectable`. Top-level wiring: `lib/app/di/injection_container.dart`. Each feature owns `lib/features/<name>/di/<name>_di.dart` and is registered from `main_unified.dart`. Mock bindings are used when a feature runs in isolation.

### State Management
Primary: **flutter_bloc** (BLoC for multi-event state, Cubit for simple state). `flutter_riverpod` is present for a few specific use cases — prefer BLoC for new feature work to stay consistent.

### Navigation
Go Router. Main config: `lib/app/navigation/app_router_config.dart`. Per-feature routes under `presentation/routes/`. Use `context.go()` / `context.push()`.

### Modules
`auth`, `home`, `orders`, `chat`, `profile`, `seller`, `ai_docs`, `favorites`, `after_sales`, `payment`, `common`.

## API / Backend Contract (must-read, non-negotiable)

The frontend must stay byte-compatible with backend controllers. These rules are absolute — any new API call that ignores them will be rejected in review.

### Before adding ANY API call

1. **Confirm the endpoint exists** in the backend controller sources (`duoshaokk_api/xunman-shop/...`). Do not assume — grep the controller.
2. **Verify** HTTP method, exact path, auth requirement, request/response DTO, error format.
3. **Match request field names exactly** to the backend DTO (Long/Integer/String/Boolean types must line up).
4. Use `OrderRemoteDataSourceImpl` (`lib/features/orders/data/datasources/order_remote_data_source_impl.dart`) as the reference implementation pattern.
5. Confirm the function has not been disabled on the backend before wiring a UI entry point.

### Confirmed backend endpoints

Treat this as the ground truth until verified otherwise. New endpoints must be added here once confirmed.

**Order (`OrderApiController`)**
- `POST /api/shop/order/create` — 创建订单
- `POST /api/shop/order/list` — 订单列表
- `GET  /api/shop/order/detail` — 订单详情
- `GET  /api/shop/order/cancel` — 取消订单
- `GET  /api/shop/order/complete` — 确认收货
- `POST /api/shop/order/verify` — 确认接单
- `POST /api/shop/order/ship` — 发货
- `GET  /api/shop/order/remind` — 提醒发货
- `POST /api/shop/order/delete` — 删除订单（买家）
- `POST /api/shop/order/sellerDelete` — 删除记录（卖家）
- `POST /api/shop/order/invite` — 邀请评价（含重复检测+消息通知）

**Order Demand (`OrderDemandApiController`)**
- `POST /api/project/orderDemand/add` — 申请上报
- `POST /api/project/orderDemand/audit` — 卖家审核
- `POST /api/project/orderDemand/buyerList` — 买家申请列表
- `POST /api/project/orderDemand/list` — 通用申请列表
- `GET  /api/project/orderDemand/get` — 详情

**Order Refund / After-sales (`OrderRefundApiController`)**
- `POST /api/shop/order-refund/apply` — 申请售后
- `POST /api/shop/order-refund/audit` — 审核售后
- `POST /api/shop/order-refund/list` — 买家售后列表
- `POST /api/shop/order-refund/listTenant` — 卖家售后列表

**Evaluate (`MemberEvaluateApiController`)**
- `POST /api/shop/evaluate/add` — 添加评价
- `POST /api/shop/evaluate/list` — 评价列表

**FxRate (`FxRateApiController`)** — #348 多币种双显示（白名单免登录）
- `GET /api/fx/rates?base=USD&targets=cny,eur,vnd` — 汇率查询
  - `base` 仅支持 `USD`（存储币种恒 USD），传其它值返回 `code != 200`
  - `targets` 逗号分隔 ISO 4217（大小写不敏感），为空返回全部缓存币种
  - 响应：`{ code:200, msg, data:{ base:"USD", rates:{ "cny":7.12, "eur":0.92, ... } } }`
  - 后端定时每小时刷新（Fawaz Currency API → Redis 2h TTL）；数据源故障返回 `code != 200`，**不静默兜底**
  - ⚠️ 仅用于「展示折算」，不参与结算（结算恒 USD via Stripe）

### Mandatory request conventions

- **Pagination:** `pageNum` + `pageSize`. Never `pageIndex` / `size` / `count`.
- **Order role filter:** `type: 'buyer'` or `type: 'seller'`.
- **Status filter:** `states` is an **array**, e.g. `params['states'] = [status.toJsonString()]`. Even single-status filters use the array form.
- **Time format:** ISO 8601.
- **Order demand request body** (buyer-initiated example):
  ```dart
  {
    'orderId': orderId,            // Long, must belong to current user
    'type': 'replenishment',       // or 'reform'
    'reasonValue': reasonCode,     // String, required
    'reasonLabel': reasonText,     // String, required
    'remarks': userRemarks,        // String, optional
  }
  ```
  Backend rejects duplicate pending requests on the same order.
- **Seller audit demand request body:**
  ```dart
  { 'id': demandId, 'status': 'SUCCESS' /* or 'FAIL' */ }
  ```

### Mandatory response handling

Every response MUST be validated against the backend business code, not just the HTTP status:

```dart
try {
  final response = await coreDioClient.post(endpoint, data: requestData);
  if (response.statusCode == 200 &&
      response.data != null &&
      response.data['code'] == 200) {
    // success — parse response.data['data'] here
    return;
  }
  throw ServerFailure(message: response.data?['msg'] ?? 'API调用失败');
} on DioException catch (e) {
  final message = e.response?.data?['msg'] ?? e.message ?? '网络错误';
  throw ServerFailure(message: message);
} catch (e) {
  if (e is ServerFailure) rethrow;
  throw ServerFailure(message: '意外错误: ${e.toString()}');
}
```

All API responses follow `{ "code": 200, "msg": "...", "data": {...} }`. `code == 200` is the only success signal. Translate backend messages into user-friendly text at the UI layer, not in the data source.

### Order domain specifics

**Status enum** (`lib/features/orders/domain/entities/order_status.dart`) must match backend `OrderStatusEnum` exactly. Keep `fromString` / `toJsonString` in sync. Known values:

```
awaitingPayment              // 待付款
awaitingSubmission           // 等待提交要求
buyAwaitingSubmission        // 买家材料重传
awaitingStart                // 等待开始
awaitingDelivery             // 等待卖家交付
awaitingConfirmation         // 交付待确认
sellerSupplementaryMaterials // 卖家重新交付
applyForRefuse               // 申请拒绝
afterSale                    // 售后中
AfterSaleRejection           // 售后拒绝
applyingForMediation         // 平台介入 (⚠️ disabled)
awaitingEvaluation           // 等待评价
orderCompleted               // 订单成功结束
canceled                     // 已取消
```

**Order demand types:**
- `replenishment` — buyer requests supplement
- `reform` — buyer requests rework
- `replenish_materials` — seller requests supplement from buyer
- `refuse` — seller refuses to accept the order
- `platform` — ⚠️ **disabled on backend**, do not expose as a user entry point

**Order demand status:** `WAIT` / `SUCCESS` / `FAIL` / `CANCEL`

**Platform mediation (`applyingForMediation`) is currently disabled**:
- Do NOT add UI entry points that submit `type: 'platform'` or hit `apply-mediation`.
- `buyerPlatformFlag` / `sellerPlatformFlag` are read-only display booleans — they are set by the admin backend, not by a client-side state transition. Reading them for UI badges is fine; writing is not.
- On audit approval, backend transitions the order to `sellerSupplementaryMaterials`; on rejection, to `applyForRefuse`. Do not hard-code these transitions client-side.

### Key order entity fields (`Order.java`)

```
id            Long           orderSn       String
buyerId       Long           tenantId      Long
state         OrderStatusEnum totalPrice    BigDecimal
payPrice      BigDecimal     payTime       DateTime
deliveryTime  DateTime       completeTime  DateTime
buyerPlatformFlag  Boolean   sellerPlatformFlag  Boolean
```

New fields must be confirmed against the backend entity before adding them to the Dart model.

### Permissions & business constraints

- Buyers can only view/operate their own demand/refund records.
- Sellers can only audit demand/refund tied to their own orders.
- Once a buyer submits a demand, it is immutable from the buyer side.
- Same order cannot have two pending (`WAIT`) demands simultaneously — backend rejects with "该订单已有未审核申请". Translate this to a friendly "您已提交过申请，请等待处理结果" at the UI layer.

## Git Branch Strategy

- **`dev`** — 主开发分支，日常开发在此分支上进行。commit 和 push 默认目标。
- **`test`** — 测试分支，用于 QA 验证。功能开发完成后从 `dev` 合并或同步到 `test`。
- **`main`** — 生产分支，仅从 `test` 验证通过后合并。
- **`develop`** — 历史遗留默认分支（GitHub default），不再用于日常开发，勿混淆。
- 功能分支命名：`refactor/<module>`、`fix/<issue>`、`feat/<feature>`，从 `dev` 切出，完成后合并回 `dev`。

## Module Development Workflow

Detailed playbook: `docs/dev/模块开发核心工作流.md`. In short:
1. Branch `refactor/<module>`.
2. Define boundary in `docs/BD/module_boundary_definition.md`.
3. Implement Domain → Data (mock first) → Presentation → real integration.
4. Reference existing RN implementation and HTML prototypes in `design-info/`.

Other useful docs under `docs/dev/`: `caching_and_local_storage_strategy_cn.md`, `dependency_injection_and_routing_strategy_cn.md`, `internationalization_strategy_cn.md`, `modular_routing_strategy_cn.md`, `order_list_caching_details_cn.md`, `tech_stack.md`.

## Environment / Config

1. Copy `.env.example` → `.env` (the app fails fast if required keys are missing).
2. Required keys: `BACKEND_BASE_URL`, `MODEL_BASE_URL`, `WECHAT_APP_ID`, `WECHAT_UNIVERSAL_LINK` (default `https://app.duoshaokankan.com/wechat/`).
3. Assets declared in `pubspec.yaml` include `.env`, `.env.local-debug`, and `config/`.
4. Region/currency come from `core/config/region_config.dart` (unified entry defaults to USD).

## i18n
- ARB source: `lib/l10n/intl_zh.arb` (primary), `intl_en.arb`.
- Generated file: `app_localizations.dart` (via `flutter gen-l10n`).
- `flutter_intl: enabled: true` in `pubspec.yaml`.

## Payments
Payment SDKs (`fluwx`, `tobias`) are currently **commented out** in `pubspec.yaml`. Stripe is wired via WebView (`webview_flutter`) for the international flow. Google Sign-In is active. Config file: `config/wechat_config.yaml`; Android URL scheme: `com.duoshaokankan.weapp`.

## Hard rules for editing this codebase

- **Run `flutter analyze` after every Dart file edit.** Do not skip.
- **No silent fallbacks.** If a call can fail, let it throw / surface — the user's standing instruction is to expose bugs, not hide them behind defaults.
- **Single entry only.** Edit `lib/main_unified.dart`. The archived per-region entries are legacy and should not be modified.
- **Use enums, not string literals**, for any value that maps to a backend enum (status, type, etc.).
- **Don't invent API endpoints or fields** — verify in backend source first.
- When unsure, check `docs/dev/` and the backend controller sources before guessing.
- **ID 使用规则(参考 [docs/dev/id_schema_cn.md](docs/dev/id_schema_cn.md))**:
  - 写跨端 API 调用前,先查那份文档 §2 的「跨端契约清单」确认 endpoint 期望传 `member.id` 还是 `xun_common_user.id`
  - 新 endpoint 没在清单里 → **先 staging curl 抽样确认**,然后补到清单
  - 不要按变量名猜语义 — `tenantId` / `doctorId` / `memberId` / `userId` 在不同上下文里语义不同(历史教训:#355 #346)
