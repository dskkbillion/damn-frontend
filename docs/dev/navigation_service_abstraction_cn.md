# 导航服务抽象层模式

## 1. 目标

本文档旨在阐述一种使用抽象接口 (`INavigationService`) 来处理应用内导航的模式。其核心目标是：

*   **解耦业务逻辑与导航实现:** 使业务逻辑层（如 Bloc、UseCase）不直接依赖具体的路由库（如 GoRouter）或 Flutter UI 框架的 `BuildContext`。
*   **提高可测试性:** 允许在单元测试中轻松地模拟 (Mock) 导航行为，验证业务逻辑中的导航意图。
*   **提升代码可维护性:** 将导航的具体实现细节封装起来，使得更换路由库或修改导航逻辑更加集中。

这种模式是对基础的 UI 驱动导航 (`context.go()` 或 `GoRouter.of(context).go()`) 的一种架构改进，特别适用于需要从非 UI 代码层发起导航的场景。

## 2. 核心组件

该模式主要包含以下组件：

1.  **导航服务接口 (`INavigationService`):** 定义导航操作的契约（方法签名）。它不关心具体的实现方式。
2.  **导航服务实现 (`NavigationServiceImpl`):** 实现 `INavigationService` 接口。其内部持有并使用具体的路由工具（如 `GoRouter` 实例）来执行页面跳转。
3.  **依赖注入 (DI):** 使用 `GetIt` 和 `Injectable` 等工具，将 `NavigationServiceImpl` 注册为 `INavigationService` 的实现，并将其注入到需要发起导航的业务逻辑组件（如 Bloc）中。
4.  **路由工具 (`GoRouter`):** 底层的路由库，负责实际的页面管理和切换。

## 3. 实现示例

**导航服务接口 (`lib/core/navigation/services/i_navigation_service.dart`)**

```dart
abstract class INavigationService {
  Future<void> navigateToOrderDetail(String orderId);
  Future<void> navigateToPayment(String orderId);
  // ... 其他特定导航方法 ...
  Future<void> navigateToChat(dynamic chatArgs);
  
  /// 返回上一页
  void goBack(); 

  /// 通用导航方法
  Future<void> navigateTo(String path, {Object? extra});
}
```

**导航服务实现 (`lib/core/navigation/services/navigation_service_impl.dart`)**

```dart
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'i_navigation_service.dart';
// 导入模块路由常量（可选但推荐）
import 'package:dskk_flutter_refactor/features/orders/presentation/routes/order_routes.dart'; 

@LazySingleton(as: INavigationService) // 注册为接口的实现
class NavigationServiceImpl implements INavigationService {
  final GoRouter _router; // 通过构造函数注入 GoRouter

  NavigationServiceImpl(this._router);

  @override
  Future<void> navigateToOrderDetail(String orderId) async {
    // 使用 GoRouter 执行实际导航
    // 推荐使用命名路由和路由常量
    _router.pushNamed('orderDetail', pathParameters: {'orderId': orderId});
    // 或 _router.push(OrderRoutes.orderDetail.replaceFirst(':orderId', orderId));
  }

  // ... 实现其他接口方法 ...

  @override
  void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  @override
  Future<void> navigateTo(String path, {Object? extra}) async {
    _router.push(path, extra: extra);
  }
}
```

**业务逻辑层使用 (示例: `SomeBloc`)**

```dart
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';

// 假设的 Bloc 事件和状态
// ...

@injectable // 标记 Bloc 可被注入
class SomeBloc extends Bloc<SomeEvent, SomeState> {
  final INavigationService _navigationService; // 依赖接口
  // ... 其他依赖

  SomeBloc(this._navigationService /*, other dependencies */) : super(InitialState()) {
    on<LoginSucceededEvent>((event, emit) async {
      // ... 处理登录逻辑 ...
      
      // 登录成功后，调用导航服务接口进行跳转
      await _navigationService.navigateTo('/home'); // 或者 navigateToHome()
      
      // ... 更新状态 ...
    });
    
    on<GoToDetailsEvent>((event, emit) {
       _navigationService.navigateToOrderDetail(event.orderId);
    });
  }
}
```

**依赖注入配置 (`lib/app/di/injection_container.dart`)**

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/navigation_service_impl.dart';
// ... 其他导入 ...

final getIt = GetIt.instance;

@InjectableInit(...)
Future<void> configureDependencies({required String backendBaseUrl}) async {
  // 1. 确保 GoRouter 实例被注册到 GetIt
  //    (可以在这里注册，或在创建 GoRouter 的地方注册，例如 app_router.dart 或 main.dart)
  //    例子： getIt.registerSingleton<GoRouter>(_createGoRouterInstance());
  
  // 2. 运行 Injectable 的初始化函数
  await init(getIt); 
  //    Injectable 会自动找到 NavigationServiceImpl 并处理其 GoRouter 依赖
}

@module
abstract class CoreRegisterModule {
  // ... 其他注册 ...

  // 不再需要手动注册 MockNavigationService 或 NavigationServiceImpl
  // @LazySingleton(as: INavigationService) 注解会处理
}
```

## 4. 对比 UI 驱动导航

| 特点         | UI 驱动 (`context.go()`)        | 服务抽象 (`INavigationService`)               |
| :----------- | :---------------------------- | :------------------------------------------ |
| **触发点**   | UI Widget (事件回调)        | **Bloc/UseCase** (主要), UI Widget (次要) |
| **导航调用** | `context.go()`                | `navigationService.method()`              |
| **核心依赖** | `BuildContext`                | `INavigationService` (注入)                 |
| **可测试性** | 导航逻辑测试困难              | **容易** (Mock 接口)                        |
| **耦合度**   | UI 与导航实现耦合             | **低耦合** (业务逻辑与导航实现解耦)         |

## 5. 优点

*   **解耦:** 业务逻辑层不关心具体的导航实现细节。
*   **可测试性:** 极大地简化了 Bloc/UseCase 中导航逻辑的单元测试。
*   **代码清晰:** 将导航意图（接口调用）与导航执行（实现类）分开。
*   **可维护性:** 导航相关的修改（如更换库、添加通用逻辑）集中在 `NavigationServiceImpl`。

## 6. 注意事项与现状

*   **GoRouter 注入:** 需要确保 `GoRouter` 实例在 `NavigationServiceImpl` 实例化之前被正确创建并注册到 DI 容器 (`GetIt`) 中，或者 `Injectable` 能够正确处理其构造函数注入。
*   **接口方法定义:** `INavigationService` 接口需要根据应用实际的导航需求进行定义和扩展。
*   **当前状态:** 虽然此模式是推荐的架构，但在项目当前阶段可能并未完全或普遍采用。部分导航可能仍通过 UI 驱动方式实现。未来在进行重构或开发新功能时，可以考虑采用此模式以提升代码质量。 
 

## 1. 目标

本文档旨在阐述一种使用抽象接口 (`INavigationService`) 来处理应用内导航的模式。其核心目标是：

*   **解耦业务逻辑与导航实现:** 使业务逻辑层（如 Bloc、UseCase）不直接依赖具体的路由库（如 GoRouter）或 Flutter UI 框架的 `BuildContext`。
*   **提高可测试性:** 允许在单元测试中轻松地模拟 (Mock) 导航行为，验证业务逻辑中的导航意图。
*   **提升代码可维护性:** 将导航的具体实现细节封装起来，使得更换路由库或修改导航逻辑更加集中。

这种模式是对基础的 UI 驱动导航 (`context.go()` 或 `GoRouter.of(context).go()`) 的一种架构改进，特别适用于需要从非 UI 代码层发起导航的场景。

## 2. 核心组件

该模式主要包含以下组件：

1.  **导航服务接口 (`INavigationService`):** 定义导航操作的契约（方法签名）。它不关心具体的实现方式。
2.  **导航服务实现 (`NavigationServiceImpl`):** 实现 `INavigationService` 接口。其内部持有并使用具体的路由工具（如 `GoRouter` 实例）来执行页面跳转。
3.  **依赖注入 (DI):** 使用 `GetIt` 和 `Injectable` 等工具，将 `NavigationServiceImpl` 注册为 `INavigationService` 的实现，并将其注入到需要发起导航的业务逻辑组件（如 Bloc）中。
4.  **路由工具 (`GoRouter`):** 底层的路由库，负责实际的页面管理和切换。

## 3. 实现示例

**导航服务接口 (`lib/core/navigation/services/i_navigation_service.dart`)**

```dart
abstract class INavigationService {
  Future<void> navigateToOrderDetail(String orderId);
  Future<void> navigateToPayment(String orderId);
  // ... 其他特定导航方法 ...
  Future<void> navigateToChat(dynamic chatArgs);
  
  /// 返回上一页
  void goBack(); 

  /// 通用导航方法
  Future<void> navigateTo(String path, {Object? extra});
}
```

**导航服务实现 (`lib/core/navigation/services/navigation_service_impl.dart`)**

```dart
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'i_navigation_service.dart';
// 导入模块路由常量（可选但推荐）
import 'package:dskk_flutter_refactor/features/orders/presentation/routes/order_routes.dart'; 

@LazySingleton(as: INavigationService) // 注册为接口的实现
class NavigationServiceImpl implements INavigationService {
  final GoRouter _router; // 通过构造函数注入 GoRouter

  NavigationServiceImpl(this._router);

  @override
  Future<void> navigateToOrderDetail(String orderId) async {
    // 使用 GoRouter 执行实际导航
    // 推荐使用命名路由和路由常量
    _router.pushNamed('orderDetail', pathParameters: {'orderId': orderId});
    // 或 _router.push(OrderRoutes.orderDetail.replaceFirst(':orderId', orderId));
  }

  // ... 实现其他接口方法 ...

  @override
  void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  @override
  Future<void> navigateTo(String path, {Object? extra}) async {
    _router.push(path, extra: extra);
  }
}
```

**业务逻辑层使用 (示例: `SomeBloc`)**

```dart
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';

// 假设的 Bloc 事件和状态
// ...

@injectable // 标记 Bloc 可被注入
class SomeBloc extends Bloc<SomeEvent, SomeState> {
  final INavigationService _navigationService; // 依赖接口
  // ... 其他依赖

  SomeBloc(this._navigationService /*, other dependencies */) : super(InitialState()) {
    on<LoginSucceededEvent>((event, emit) async {
      // ... 处理登录逻辑 ...
      
      // 登录成功后，调用导航服务接口进行跳转
      await _navigationService.navigateTo('/home'); // 或者 navigateToHome()
      
      // ... 更新状态 ...
    });
    
    on<GoToDetailsEvent>((event, emit) {
       _navigationService.navigateToOrderDetail(event.orderId);
    });
  }
}
```

**依赖注入配置 (`lib/app/di/injection_container.dart`)**

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/navigation_service_impl.dart';
// ... 其他导入 ...

final getIt = GetIt.instance;

@InjectableInit(...)
Future<void> configureDependencies({required String backendBaseUrl}) async {
  // 1. 确保 GoRouter 实例被注册到 GetIt
  //    (可以在这里注册，或在创建 GoRouter 的地方注册，例如 app_router.dart 或 main.dart)
  //    例子： getIt.registerSingleton<GoRouter>(_createGoRouterInstance());
  
  // 2. 运行 Injectable 的初始化函数
  await init(getIt); 
  //    Injectable 会自动找到 NavigationServiceImpl 并处理其 GoRouter 依赖
}

@module
abstract class CoreRegisterModule {
  // ... 其他注册 ...

  // 不再需要手动注册 MockNavigationService 或 NavigationServiceImpl
  // @LazySingleton(as: INavigationService) 注解会处理
}
```

## 4. 对比 UI 驱动导航

| 特点         | UI 驱动 (`context.go()`)        | 服务抽象 (`INavigationService`)               |
| :----------- | :---------------------------- | :------------------------------------------ |
| **触发点**   | UI Widget (事件回调)        | **Bloc/UseCase** (主要), UI Widget (次要) |
| **导航调用** | `context.go()`                | `navigationService.method()`              |
| **核心依赖** | `BuildContext`                | `INavigationService` (注入)                 |
| **可测试性** | 导航逻辑测试困难              | **容易** (Mock 接口)                        |
| **耦合度**   | UI 与导航实现耦合             | **低耦合** (业务逻辑与导航实现解耦)         |

## 5. 优点

*   **解耦:** 业务逻辑层不关心具体的导航实现细节。
*   **可测试性:** 极大地简化了 Bloc/UseCase 中导航逻辑的单元测试。
*   **代码清晰:** 将导航意图（接口调用）与导航执行（实现类）分开。
*   **可维护性:** 导航相关的修改（如更换库、添加通用逻辑）集中在 `NavigationServiceImpl`。

## 6. 注意事项与现状

*   **GoRouter 注入:** 需要确保 `GoRouter` 实例在 `NavigationServiceImpl` 实例化之前被正确创建并注册到 DI 容器 (`GetIt`) 中，或者 `Injectable` 能够正确处理其构造函数注入。
*   **接口方法定义:** `INavigationService` 接口需要根据应用实际的导航需求进行定义和扩展。
*   **当前状态:** 虽然此模式是推荐的架构，但在项目当前阶段可能并未完全或普遍采用。部分导航可能仍通过 UI 驱动方式实现。未来在进行重构或开发新功能时，可以考虑采用此模式以提升代码质量。 
 