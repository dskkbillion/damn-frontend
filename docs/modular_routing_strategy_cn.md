# 模块化路由策略 (GoRouter)

## 1. 目标

随着应用功能的增加，将所有路由规则都集中在单一的核心路由文件 (`lib/core/router/app_router.dart`) 中会导致该文件变得臃肿、难以维护和理解。为了提高代码的组织性、可维护性和可扩展性，我们采用模块化的路由策略。

核心目标是：

*   **解耦:** 每个功能模块（Feature）独立管理自己的路由，减少模块间的依赖。
*   **代码组织:** 路由定义与其关联的页面（Pages）和状态管理逻辑（Blocs）位于同一模块内。
*   **可扩展性:** 添加新模块时，只需创建并注册该模块的路由，核心路由文件改动最小。
*   **可读性:** 核心路由文件更简洁，只负责组装和全局配置。

## 2. 策略概述

我们使用 `go_router` 包来实现路由。

基本策略是：

1.  **模块内定义:** 在每个功能模块（例如 `orders`, `after_sales`, `auth`）的 `presentation` 目录下，创建一个 `routes` 子目录。在此子目录中，创建一个路由文件（例如 `order_routes.dart`），用于定义该模块的所有 `GoRoute` 对象。
2.  **暴露路由列表:** 该模块的路由文件通过一个静态 getter 或常量，将包含其所有 `GoRoute` 定义的列表 (`List<RouteBase>`) 暴露出来。
3.  **核心路由聚合:** 在核心路由文件 (`lib/core/router/app_router.dart`) 中，导入各个功能模块的路由文件，并在 `GoRouter` 构造函数的 `routes` 参数中，使用列表扩展操作符 (`...`) 将所有模块的路由列表聚合进来。

## 3. 目录结构示例

```
lib/
├── core/
│   └── router/
│       └── app_router.dart      # 核心路由器，聚合模块路由
├── features/
│   ├── orders/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   ├── order_list_page.dart
│   │       │   └── order_detail_page.dart
│   │       ├── routes/
│   │       │   └── order_routes.dart    # 定义订单模块的路由
│   │       └── widgets/
│   ├── after_sales/
│   │   └── presentation/
│   │       ├── routes/
│   │       │   └── after_sales_routes.dart # 定义售后模块的路由
│   │       └── ...
│   └── ... (其他模块)
└── ...
```

## 4. 实现示例

**模块路由文件 (`lib/features/orders/presentation/routes/order_routes.dart`)**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 导入本模块需要用到的页面
import '../pages/order_list_page.dart';
import '../pages/order_detail_page.dart';
// ... 其他订单相关页面 ...

class OrderRoutes {
  // 私有构造函数，防止实例化
  OrderRoutes._();

  // 通过静态 getter 暴露路由列表
  static List<RouteBase> get routes => _routes;

  // 模块内部路由定义
  static final List<RouteBase> _routes = [
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrderListPage(),
    ),
    GoRoute(
      path: '/orderDetail/:orderId',
      name: 'orderDetail',
      builder: (BuildContext context, GoRouterState state) {
        final String orderId = state.pathParameters['orderId'] ?? 'invalid';
        // TODO: Add validation for orderId
        return OrderDetailPage(orderId: orderId);
      },
    ),
    // ... 其他订单模块路由 ...
  ];
}
```

**核心路由文件 (`lib/core/router/app_router.dart`)**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 导入模块路由
import 'package:dskk_flutter_refactor/features/orders/presentation/routes/order_routes.dart';
import 'package:dskk_flutter_refactor/features/after_sales/presentation/routes/after_sales_routes.dart';
// ... 导入其他模块路由 ...

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/', // 或者任何你想要的初始路径
    routes: <RouteBase>[
      // 使用扩展操作符聚合所有模块的路由
      ...OrderRoutes.routes,
      ...AfterSalesRoutes.routes,
      // ... 其他模块路由 ...

      // 这里可以放置不属于任何特定模块的全局路由，例如：
      // GoRoute(path: '/settings', builder: ...),
    ],
    // 全局错误处理等配置
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Error: ${state.error}')),
    ),
    // ... 其他 GoRouter 配置 ...
  );
}
```

## 5. 优点总结

*   **高内聚:** 功能模块的路由、页面、逻辑保持在一起。
*   **低耦合:** 模块间路由不直接依赖，核心路由只做聚合。
*   **易维护:** 修改或添加模块内路由，只需关注模块自身文件。
*   **可扩展:** 添加新模块对核心路由影响小。
*   **职责清晰:** 核心路由负责全局配置和组装，模块路由负责具体实现。
