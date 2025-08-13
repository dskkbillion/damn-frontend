# Issue #93 Fix Summary

## Problem
国内开发入口(`main_domestic_dev.dart`)点击商品无法跳转到详情页

## Root Cause
- 国内开发入口注册了`SimpleHomeNavigationService`（模拟实现），只打印日志不执行真实导航
- 缺少`RealHomeNavigationService`的注册，该服务需要GoRouter实例才能工作

## Solution
修改`main_domestic_dev.dart`，添加真实导航服务的注册：

```dart
// 新增导入
import 'package:dskk_flutter_refactor/features/home/presentation/navigation/home_navigation_di.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';

// 修改应用启动代码
runApp(
  ProviderScope(
    child: Builder(
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final router = ref.read(goRouterProvider);
            
            // 注册真实导航服务
            WidgetsBinding.instance.addPostFrameCallback((_) {
              HomeNavigationDI.registerRealNavigationService(getIt, router);
            });
            
            return const MyApp();
          },
        );
      },
    ),
  ),
);
```

## Testing
1. 运行: `flutter run -t lib/main_domestic_dev.dart`
2. 点击首页任意商品
3. 应能成功跳转到商品详情页

## Files Changed
- `lib/main_domestic_dev.dart` - 添加真实导航服务注册