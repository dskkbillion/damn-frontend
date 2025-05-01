# 依赖注入风格 B：注解驱动与代码生成

本文档介绍项目中推荐使用的依赖注入 (DI) 风格，主要利用 `injectable` 包提供的注解和 `build_runner` 进行代码生成，配合 `get_it` 服务定位器实现。

## 核心库

*   **`get_it`**: 服务定位器，用于注册和获取依赖实例。
*   **`injectable`**: 提供注解，简化 `get_it` 的注册代码编写。
*   **`build_runner`**: Dart 代码生成工具，用于运行 `injectable_generator`。

## 关键概念

1.  **注解 (Annotations):**
    *   `@Injectable`, `@Singleton`, `@LazySingleton`, `@FactoryMethod`: 标记类，告诉 `injectable` 如何注册这个类的实例（作用域、是否懒加载等）。
    *   `@Injectable(as: InterfaceType)`: 将实现类注册为其实现的抽象接口类型。
    *   `@module`: 标记一个抽象类，该类的方法可以提供无法直接注解的依赖项（例如第三方库实例或需要复杂配置的对象）。
    *   `@Named('instanceName')`: 用于注册或注入**同类型但不同用途**的实例（例如多个不同的 `String` 配置）。
    *   `@preResolve`: 用于注册返回 `Future` 的工厂方法，`injectable` 会等待 Future 完成后再注册结果。

2.  **代码生成:**
    *   运行 `flutter pub run build_runner build --delete-conflicting-outputs` 命令。
    *   `injectable_generator` 会扫描项目中的注解，自动生成注册逻辑到 `lib/app/di/injection_container.config.dart` 文件 (或其他指定位置)。
    *   我们**不应手动修改**这个 `.config.dart` 文件。

3.  **初始化:**
    *   通常在 `lib/app/di/injection_container.dart` 文件中定义一个 `configureDependencies` 函数。
    *   此函数负责调用由 `injectable` 生成的 `init` (或其他指定名称) 函数，该函数会执行 `.config.dart` 中所有的注册逻辑。
    *   应用入口 (`main.dart` 或 `main_*.dart`) 在启动时调用 `configureDependencies`。

## 为 Feature 模块配置 DI (风格 B 步骤)

以 Profile 模块为例：

1.  **注解 Domain 层 Use Cases:**
    *   在每个 Use Case 类 (如 `GetUserProfileUseCase`) 上方添加 `@lazySingleton` 或 `@injectable` 注解。
    *   确保 Use Case 的构造函数只依赖于 Repository **接口** (如 `IUserProfileRepository`)。

2.  **注解 Data 层 Repositories 实现:**
    *   在 Repository 实现类 (如 `UserProfileRepositoryImpl`) 上方添加 `@Injectable(as: IUserProfileRepository)` 注解。
    *   确保 Repository 实现类的构造函数只依赖于 DataSource **接口** (如 `ProfileRemoteDataSource`, `ProfileLocalDataSource`) 和其他已注册的核心服务 (如 `NetworkInfo`)。

3.  **注解 Data 层 DataSources 实现:**
    *   在 DataSource 实现类 (如 `ProfileRemoteDataSourceImpl`, `ProfileLocalDataSourceImpl`) 上方添加 `@Injectable(as: ProfileRemoteDataSource)` 或 `@Injectable(as: ProfileLocalDataSource)` 注解。
    *   确保 DataSource 实现类的构造函数只依赖于已注册的核心服务 (如 `Dio`, `SharedPreferences`)。 **通常不直接依赖 Token/UserID 字符串，认证由拦截器处理。**

4.  **注解 Presentation 层 Blocs/Cubits:**
    *   在 Bloc/Cubit 类 (如 `ProfileBloc`) 上方添加 `@injectable` 或 `@factoryMethod` 注解 (Bloc 通常用 `@factoryMethod`，因为它们有状态)。
    *   确保 Bloc 的构造函数只依赖于 Use Case **接口** (或抽象类)。

5.  **运行代码生成:**
    *   执行 `flutter pub run build_runner build --delete-conflicting-outputs`。
    *   检查生成的 `.config.dart` 文件是否包含了 Profile 模块相关类的注册逻辑。
    *   解决 `build_runner` 输出的任何警告或错误 (通常是依赖缺失或类型不匹配)。

6.  **使用:**
    *   在需要的地方 (例如 Widget 中创建 `BlocProvider`)，使用 `GetIt.instance<YourBlocType>()` 或 `getIt<YourBlocType>()` 来获取实例。

## 网络请求认证处理 (风格 B)

采用此风格时，通常在核心 DI 配置 (`lib/app/di/injection_container.dart` 中的 `CoreRegisterModule`) 中：

1.  注册配置好的 `Dio` 单例实例。
2.  在创建 `Dio` 实例时，添加一个**认证拦截器** (如 `AuthInterceptor`)。
3.  这个拦截器负责在每个请求发出前，从 `FlutterSecureStorage` (或其他安全存储) 读取最新的 Token，并将其添加到请求头中。
4.  因此，各个模块的 `RemoteDataSource` 实现类只需要依赖注入配置好的 `Dio` 实例即可，无需关心 Token 的获取和添加。

## 优点

*   **减少模板代码:** 无需手动编写大量的 `sl.register...` 代码。
*   **类型安全:** 依赖关系在代码生成阶段进行检查，有助于提前发现错误。
*   **依赖关系清晰:** 通过注解可以更容易地理解类的依赖关系和作用域。
*   **易于维护:** 添加新依赖通常只需要添加注解并重新运行生成器。

## 与风格 A (手动注册) 的比较

项目中部分早期模块 (如 Home, Favorites) 可能采用了风格 A，即创建专门的 `di.dart` 文件并在其中手动调用 `GetIt.instance.register...` 方法。虽然功能上等效，但风格 B (注解驱动) 通常被认为是更现代、更少出错的方式，推荐在新模块和重构旧模块时采用，以保持项目整体一致性。 