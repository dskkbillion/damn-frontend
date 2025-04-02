# DSKK-Flutter 重构项目指南

本指南旨在指导你完成 DSKK-Flutter 重构项目的初始准备工作，搭建基础的"主工程"框架，为后续逐个模块的增量重构打下基础。

## 阶段 0: 准备与高阶分析

**目标**: 明确重构范围，确认模块划分，熟悉现有材料，准备开发环境。

- [x] **任务 0.1: 高阶审阅 RN 项目代码** (design-info/demo-repository)
  - 快速浏览 React Native 项目的整体结构、主要功能模块和用户流程
  - 对现有代码库的规模和复杂度有一个初步印象
  - *(初步分析已记录在 docs/preliminary_analysis.md)*

- [x] **任务 0.2: 审阅 HTML 原型** (design-info/HTML原型)
  - 查看 HTML 原型，了解目标应用的 UI 布局、视觉风格和基本的页面跳转关系
  - 注意原型与 RN 实现可能存在的差异
  - *(初步分析已记录在 docs/preliminary_analysis.md)*

- [x] **任务 0.3: 确认/精化 Flutter 模块列表**
  - 结合 RN 代码分析和 HTML 原型展示的功能，最终确认 Flutter 项目要划分的核心模块列表
  - *(详细分析和复杂度评估见 docs/preliminary_analysis.md)*
  - 最终确认模块列表：`Auth`, `Home`, `Profile`, `Orders`, `Chat`, `AI_Docs`, `Seller`, `Cart`, `Core/Shared`

- [ ] **任务 0.4: 搭建开发环境**
  - 确保 Flutter SDK 已正确安装并配置
  - 配置好 IDE (如 VS Code, Android Studio) 及相关 Flutter/Dart 插件
  - 初始化 Git 仓库用于项目版本控制（如果尚未创建）

- [x] **任务 0.5: 确定核心技术选型**
  - 最终确定状态管理库 (Riverpod)
  - 最终确定依赖注入库 (get_it + injectable)
  - 最终确定导航库 (go_router)
  - *(详细选型及原因见 docs/tech_stack.md)*

## 阶段 1: 初始化"主工程"框架 (对应方法论第 3 节)

**目标**: 创建一个可运行的基础 Flutter 应用"空壳"，包含必要的配置和基础设施。

- [x] **任务 1.1: 创建 Flutter 项目**
  - 运行 `flutter create your_project_name` 命令创建项目（如果你还没有这样做）

- [x] **任务 1.2: 定义基础目录结构**
  - 在 `lib/` 目录下创建规划好的顶层文件夹，例如：
    - `features/` (或 `modules/`): 用于存放各个功能模块
    - `core/` (或 `shared/`): 用于存放应用级共享代码
    - `app/`: 可能用于存放应用启动、配置相关代码
  - 这是你提到的"主工程结构还没有设置"的关键一步

- [x] **任务 1.3: 配置核心依赖** (pubspec.yaml)
  - 添加 Flutter SDK 依赖
  - 添加并配置选定的状态管理、DI、导航库 (Riverpod, GetIt+Injectable, GoRouter)
  - 添加其他可能需要的基础库（如 http, shared_preferences 等）- *后续按需添加*
  - 运行 `flutter pub get`

- [x] **任务 1.4: 实现最小化应用入口** (main.dart)
  - 创建 `main()` 函数
  - 使用 `ProviderScope` (Riverpod) 包裹 `runApp`
  - 调用 DI 初始化 (`configureDependencies`)
  - 运行 `runApp()` 启动根 Widget (如 MyApp)

- [x] **任务 1.5: 实现根 Widget (`App`) 与顶层 UI 框架 (详细清单)**
  - [x] **1.5.1:** 创建 `MyApp` Widget 文件（`lib/app/app.dart`）。
  - [x] **1.5.2:** 在 `MyApp` 中，构建并返回 `MaterialApp` (或 `CupertinoApp`)。*注意: 后续集成 GoRouter 时需改为 `MaterialApp.router`*。
  - [x] **1.5.3:** 在 `MaterialApp` 中配置基础主题 `theme` (`ThemeData`)。
  - [x] **1.5.4:** 创建了一个主要的"壳"页面 Widget (`MainShellPage`)，包含 `Scaffold` 和 `BottomNavigationBar`。
  - [x] **1.5.5:** 在 `MainShellPage` 中：
    - [x] 实现 `Scaffold` 结构。
    - [x] 实现 `BottomNavigationBar`，并添加了代表主要功能模块的 `BottomNavigationBarItem` (多少看看, 主页, 消息, 我的)。
    - [x] 使用 `StatefulWidget` 和 `setState` 实现了基础的标签页切换逻辑。
    - [x] 在 `Scaffold` 的 `body` 中，根据当前选中的 `currentIndex` 显示对应的占位符 Widget。
  - [x] **1.5.6:** 集成并初始化导航服务 (`go_router`)：
    - [x] 创建 GoRouter 配置 (`lib/app/navigation/app_router.dart`)。
    - [x] 使用 `StatefulShellRoute` 定义了基础路由和底部导航状态管理。
    - [ ] 将 GoRouter 实例注册到 DI 容器。 *(暂缓，使用 Riverpod Provider)*
    - [x] 修改 `MyApp` 使用 `MaterialApp.router` 并传入 GoRouter 配置。
    - [x] `MainShellPage` 中旧的 `setState` 导航逻辑已由 `StatefulShellRoute` 替代。

- [x] **任务 1.6: 初始化依赖注入** (DI)
  - 创建 DI 配置文件（`lib/app/di/injection_container.dart`）
  - 编写初始化函数 (`configureDependencies`)，设置 DI 容器（GetIt 实例）
  - 使用 `@InjectableInit` 和 `build_runner` 生成配置
  - 在 `main()` 函数中调用 DI 初始化函数
  - （可选）注册一些早期的、应用级的单例服务（如导航服务实例）- *后续按需添加*

- [ ] **任务 1.7: (可选) 搭建 Core/Shared 模块基础**
  - 在 `lib/core/` 目录下创建子目录（如 theme, constants, navigation, di, network, utils）
  - 添加基础的主题定义、全局常量文件、日志工具等 - *后续按需添加*

- [x] **任务 1.8: 验证构建与运行**
  - 确保这个基础的"主工程"能够成功编译、构建，并在模拟器或真机上运行起来（已显示占位符页面）

## 阶段 2: 准备第一个模块的重构

**目标**: 选定第一个要重构的模块，并为其创建独立的工作环境。

- [ ] **任务 2.1: 选择第一个重构模块**
  - 根据优先级标准（如：依赖少、核心模块、问题最多、能快速看到效果等），确定首先要重构哪个模块（例如 Auth 模块）

- [ ] **任务 2.2: 创建特性分支**
  - 在 Git 中基于主开发分支（如 develop）创建一个新的特性分支（例如 `refactor/auth-module`）
  - 后续该模块的所有重构代码都在此分支进行

- [ ] **任务 2.3: (可选) 配置模块预览环境**
  - 如果计划使用独立的预览环境，此时可以进行相关配置
  - 例如，创建一个单独的 `main_auth_preview.dart` 文件，用于独立运行 Auth 模块的页面，并注入 Mock 依赖

---

## 目录结构参考

```
lib/
|
├── app/                     # 应用级配置与启动相关
│   ├── navigation/          # 导航配置 (路由定义、路由守卫等)
│   ├── di/                  # 依赖注入配置 (如 GetIt 的注册)
│   ├── app.dart             # 主要的 App Widget (如 MyApp，包含 MaterialApp)
│   └── main.dart            # 应用入口，runApp()
│
├── core/                    # 共享的核心代码与基础设施
│   ├── config/              # 应用配置 (如主题 ThemeData, 环境变量)
│   ├── constants/           # 应用常量
│   ├── di/                  # (可选) Core 模块自身的依赖注册
│   ├── error/               # 自定义异常 (Failures), 错误处理
│   ├── network/             # 网络请求封装 (如 Dio 实例, 拦截器)
│   ├── platform/            # 平台相关功能 (如网络状态检查)
│   ├── usecases/            # (可选) 跨模块共享的基础 UseCase (如 BaseUseCase)
│   ├── utils/               # 通用工具类 (日期格式化, 验证器等)
│   └── widgets/             # 应用级共享 Widgets (如通用加载指示器、错误提示)
│
├── features/                # 功能模块目录 (每个子目录是一个独立的功能模块)
│   │
│   ├── auth/                # --- 认证模块示例 ---
│   │   ├── presentation/    # 表现层 (UI 相关)
│   │   │   ├── bloc/        # Blocs 或 Cubits
│   │   │   ├── pages/       # 页面/屏幕 Widgets
│   │   │   └── widgets/     # 该模块内可复用的 Widgets
│   │   │
│   │   ├── domain/          # 领域层 (核心业务逻辑)
│   │   │   ├── entities/    # 业务实体 (如 User)
│   │   │   ├── usecases/    # 用例 (如 LoginUseCase)
│   │   │   └── repositories/ # 仓库接口定义 (如 IAuthRepository)
│   │   │
│   │   └── data/            # 数据层 (数据获取与存储)
│   │       ├── datasources/ # 数据源 (如 AuthRemoteDataSource, AuthLocalDataSource)
│   │       ├── models/      # 数据传输模型 (如 UserModel, LoginRequestModel)
│   │       └── repositories/ # 仓库接口实现 (如 AuthRepositoryImpl)
│   │
│   ├── home/                # --- 首页模块示例 ---
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── orders/              # --- 订单模块示例 ---
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   └── ...                  # 其他功能模块 (Profile, Chat, etc.)
│
└── injection_container.dart # (可选) 全局依赖注入初始化入口 (或者放在 app/di/ 下)
```

## 架构说明

### 项目结构说明

- **app/**: 存放应用的整体配置、启动逻辑、导航和全局依赖注入的设置。它负责把所有东西"组装"起来。
- **core/**: 存放那些会被多个功能模块共享的代码。这有助于代码复用，并保持功能模块的独立性。注意避免让 core 变得过于臃肿，只放真正通用的东西。
- **features/**: 这是项目的主体，每个子目录代表一个相对独立的功能模块。这是实现模块化和降低认知负担的关键。

### 模块内部结构 (features/xxx/)

- 严格遵循 **Clean Architecture** 分层:
  - **presentation**: 只包含 UI 展示和状态管理逻辑
  - **domain**: 包含纯粹的业务逻辑，不依赖任何外部框架（UI, Data）。这是模块的核心
  - **data**: 负责实现 Domain 层定义的接口，处理具体的数据来源和存储

### 依赖规则

- `features/xxx/presentation` 依赖 `features/xxx/domain`
- `features/xxx/data` 依赖 `features/xxx/domain`
- `features/xxx` 可以依赖 `core`
- 严禁 `features/xxx/domain` 依赖 presentation 或 data
- 尽量避免 `features/moduleA` 直接依赖 `features/moduleB` 的 presentation 或 data 层
- 模块间交互优先通过 Domain 层接口或共享的 core 服务进行

这个结构清晰地体现了 Clean Architecture 的分层思想，并通过 features 目录实现了业务模块化，有助于降低耦合度、提高可维护性和可测试性，非常适合你正在进行的重构项目。你可以根据项目的具体规模和复杂度，对这个基础结构进行微调。

---

完成以上 To-Do List 后，你的"主工程"基础框架就搭建好了，并且你也准备好了开始对第一个选定的模块应用核心工作流（方法论第 4 节）进行具体的重构工作。祝你开工顺利！

