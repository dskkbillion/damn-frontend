# Home模块路由系统维护文档

本文档记录Home模块路由系统的实施过程、设计考量和合并策略。

## 1. 设计目标

- **模块化**: 路由定义和导航逻辑封装在Home模块内部
- **可测试性**: 使用依赖注入和接口，便于单元测试
- **易合并**: 设计成易于合并到主应用的中央路由系统
- **解耦**: 业务逻辑不直接依赖路由实现

## 2. 文件结构

```
lib/features/home/presentation/
  ├── navigation/
  │   ├── home_navigation_service.dart     # 导航服务接口
  │   ├── home_navigation_service_impl.dart # 导航服务实现
  │   ├── home_preview_router.dart         # 预览环境路由配置
  │   └── home_routes_maintenance.md       # 本文档
  ├── routes/
  │   └── home_routes.dart                 # 路由定义
  ├── pages/
  │   ├── home_page.dart                   # 已存在
  │   └── product_detail_page.dart         # 产品详情页面
  └── bloc/
      └── home_bloc.dart                   # 更新以使用导航服务
```

## 3. 实施过程

### 3.1 创建产品详情页面

首先创建产品详情页面，它将接收产品ID作为参数，并显示产品详情。在预览阶段，使用mock数据；在生产环境，将从API获取数据。

### 3.2 创建路由定义

定义Home模块的所有路由路径、名称和对应的页面构建器。这些路由将来会注册到主应用的中央路由系统中。

### 3.3 创建导航服务

创建导航服务接口和实现，用于处理Home模块内的导航逻辑。这样，业务逻辑（如HomeBloc）可以通过依赖注入使用导航服务，而不直接依赖路由实现。

### 3.4 创建预览路由配置

为预览环境创建路由配置，使用Home模块的路由定义。这样，Home模块可以独立运行和测试。

### 3.5 更新依赖注入

更新依赖注入配置，注册导航服务和其他依赖。

### 3.6 更新HomeBloc

修改HomeBloc，使用导航服务处理用户交互事件。

## 4. 合并策略

当需要将Home模块合并到主应用时，我们采用以下策略：

### 4.1 路由注册

在主应用的中央路由系统中，导入Home模块的路由定义，并将其路由列表添加到中央路由器的routes参数中：

```dart
// lib/app/navigation/app_router.dart
import 'package:dskk_flutter_refactor/features/home/presentation/routes/home_routes.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      ...HomeRoutes.routes,  // 添加Home模块的路由
      // 其他模块路由
    ],
    // 全局配置
  );
}
```

### 4.2 导航服务实现替换

创建一个新的导航服务实现，使用中央路由系统：

```dart
// lib/features/home/presentation/navigation/home_navigation_service_prod_impl.dart
class HomeNavigationServiceProdImpl implements HomeNavigationService {
  final GoRouter router;

  HomeNavigationServiceProdImpl({required this.router});

  @override
  void navigateToProductDetail(String productId) {
    router.goNamed(
      HomeRoutes.productDetailName,
      pathParameters: {'productId': productId},
    );
  }
  
  // 其他方法实现
}
```

### 4.3 依赖注入配置更新

在主应用的依赖注入配置中，注册生产环境的导航服务实现：

```dart
// lib/app/di/injection_container.dart
sl.registerLazySingleton<HomeNavigationService>(
  () => HomeNavigationServiceProdImpl(router: AppRouter.router),
);
```

### 4.4 集成测试

合并后，进行集成测试，确保Home模块的导航功能在主应用中正常工作。

## 5. 维护注意事项

1. **路由命名冲突**: 确保不同模块的路由名称不冲突，可以使用模块前缀
2. **路由参数一致性**: 确保路由参数的定义和使用一致
3. **导航服务接口稳定性**: 尽量保持导航服务接口稳定，避免频繁修改
4. **文档更新**: 当修改路由定义或导航服务时，更新本文档

## 6. 参考资料

- [GoRouter文档](https://pub.dev/packages/go_router)
- [Flutter导航最佳实践](https://flutter.dev/docs/cookbook/navigation)
- [Clean Architecture导航模式](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)