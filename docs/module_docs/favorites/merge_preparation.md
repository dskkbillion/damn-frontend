# 收藏模块合并准备说明

本文档提供将收藏(Favorites)模块合并到主项目的详细步骤和注意事项。

## 1. 模块概述

收藏模块负责管理用户收藏的服务和卖家，包括查看、添加、删除收藏以及关注/取消关注卖家等功能。该模块遵循Clean Architecture架构，包含完整的数据层、领域层和表示层实现。

## 2. 目录结构

收藏模块的代码位于 `lib/features/favorites/` 目录下，包含以下主要部分：

```
lib/features/favorites/
├── data/
│   ├── datasources/
│   │   ├── favorites_local_data_source.dart
│   │   ├── favorites_local_data_source_impl.dart
│   │   ├── favorites_remote_data_source.dart
│   │   └── favorites_remote_data_source_impl.dart
│   ├── models/
│   │   ├── common_user_model.dart
│   │   ├── favorite_model.dart
│   │   ├── favorite_seller_model.dart
│   │   └── favorite_service_model.dart
│   └── repositories/
│       └── favorites_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── common_user.dart
│   │   ├── favorite.dart
│   │   ├── favorite_seller.dart
│   │   └── favorite_service.dart
│   ├── repositories/
│   │   └── i_favorites_repository.dart
│   └── usecases/
│       ├── add_to_favorites_usecase.dart
│       ├── check_is_favorite_usecase.dart
│       ├── follow_seller_usecase.dart
│       ├── get_favorite_sellers_usecase.dart
│       ├── get_favorite_services_usecase.dart
│       ├── remove_from_favorites_usecase.dart
│       └── unfollow_seller_usecase.dart
├── presentation/
│   ├── bloc/
│   │   ├── favorites_bloc.dart
│   │   ├── favorites_event.dart
│   │   └── favorites_state.dart
│   ├── pages/
│   │   └── favorites_page.dart
│   ├── routes/
│   │   └── favorites_routes.dart
│   └── widgets/
│       ├── empty_favorites.dart
│       ├── favorite_seller_item.dart
│       └── favorite_service_item.dart
└── di/
    └── favorites_di.dart
```

## 3. 依赖注入

收藏模块使用依赖注入模式，所有依赖在 `favorites_di.dart` 文件中注册。合并时需要确保以下依赖正确注册：

```dart
// 在应用启动时注册
void initFavoritesDependencies() {
  // 数据源
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(database: sl()),
  );
  
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(
      client: sl(),
      baseUrl: sl(instanceName: 'baseUrl'),
      getToken: () async {
        final tokenGetter = sl<Future<String?> Function()>(instanceName: 'getAuthToken');
        return await tokenGetter() ?? '';
      },
      getUserId: () async {
        final userIdGetter = sl<Future<String?> Function()>(instanceName: 'getUserId');
        return await userIdGetter() ?? '';
      },
    ),
  );
  
  // 仓库
  sl.registerLazySingleton<IFavoritesRepository>(
    () => FavoritesRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // 用例
  sl.registerLazySingleton(() => GetFavoriteServicesUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoriteSellersUseCase(sl()));
  sl.registerLazySingleton(() => AddToFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => CheckIsFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => FollowSellerUseCase(sl()));
  sl.registerLazySingleton(() => UnfollowSellerUseCase(sl()));
}
```

## 4. 路由集成

收藏模块的路由定义在 `favorites_routes.dart` 文件中。合并时需要将其集成到主项目的路由系统中：

1. 在主项目的路由文件中导入收藏模块的路由：
```dart
import 'package:dskk_flutter_refactor/features/favorites/presentation/routes/favorites_routes.dart';
```

2. 在 GoRouter 配置中添加收藏模块的路由：
```dart
final router = GoRouter(
  routes: <RouteBase>[
    // 其他模块的路由...
    
    // 收藏模块路由
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    
    // 其他模块的路由...
  ],
);
```

## 5. 缓存策略

收藏模块遵循项目的全局缓存策略（详见 `docs/caching_and_local_storage_strategy_cn.md`）：

1. **内存缓存**：收藏列表数据在内存中短暂缓存，设置TTL或在关键操作后失效。
2. **本地存储**：使用 `drift` 数据库存储收藏列表数据，实现"缓存优先，网络回填"策略。
3. **图片缓存**：使用 `cached_network_image` 处理所有网络图片。

## 6. API调用

收藏模块调用以下API端点：

- `GET /api/collect/list` - 获取收藏列表
- `GET /api/shop/product/get` - 获取服务详情
- `GET /api/member/info` - 获取卖家详情
- `POST /api/collect/add` - 添加收藏
- `POST /api/collect/delete` - 删除收藏
- `POST /api/collect/isCollect` - 检查是否已收藏
- `POST /api/invitation/collectionMember` - 关注卖家
- `POST /api/invitation/cancelCollectionMember` - 取消关注卖家

所有API调用都在 `FavoritesRemoteDataSourceImpl` 类中实现，并添加了详细的日志记录和错误处理。

## 7. 认证处理

收藏模块需要用户认证才能正常工作。它通过依赖注入获取 `getToken` 和 `getUserId` 函数，这些函数应由认证模块提供。合并时需要确保这些函数正确注册：

```dart
// 在认证模块初始化时注册
sl.registerLazySingleton<Future<String?> Function()>(
  () => () async => await authService.getToken(),
  instanceName: 'getAuthToken',
);

sl.registerLazySingleton<Future<String?> Function()>(
  () => () async => await authService.getUserId(),
  instanceName: 'getUserId',
);
```

## 8. 已知问题与解决方案

1. **认证失败处理**：当API返回401认证错误时，模块会返回模拟数据。这是一个临时解决方案，未来应实现更完善的认证刷新机制。

2. **图片加载失败**：使用 `cached_network_image` 的错误处理机制显示占位图。

## 9. 测试

收藏模块包含单元测试和集成测试，确保在合并前运行所有测试：

```bash
flutter test test/features/favorites/
```

## 10. 合并检查清单

在完成合并前，请检查以下项目：

- [ ] 所有依赖已正确注册
- [ ] 路由已正确集成到主项目
- [ ] 认证函数已正确提供
- [ ] 所有测试通过
- [ ] 本地运行测试无错误
- [ ] 文档已更新（包括README.md）

## 11. 联系人

如有任何问题或需要帮助，请联系模块负责人。