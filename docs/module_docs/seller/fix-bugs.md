## 认证管理页面 (AuthManagementPage) 出现 ProviderNotFoundException

**现象:**

进入认证管理页面时，应用崩溃并抛出 `ProviderNotFoundException`，错误日志指示 `BlocBuilder<AuthManagementBloc, AuthManagementState>` 无法找到所需的 `AuthManagementBloc` 实例。

**分析过程:**

1.  **初步尝试:** 检查路由配置 (`seller_routes.dart`)，确认 `BlocProvider` 是否正确提供。尝试将路由的 `builder` 修改为 `pageBuilder`，并移除了 Bloc 事件创建时的 `const` 关键字，但问题仍然存在。
2.  **深入分析:** 堆栈跟踪显示异常发生在 `BlocBuilder` 的 `initState` 方法中。这表明问题发生在 Widget 状态初始化阶段，此时 `BlocBuilder` 尝试通过 `context.read<AuthManagementBloc>()` 获取 Bloc 实例，但其所处的 `BuildContext` 链条上并未包含该 Bloc 的 Provider。即使在路由层级提供了 Bloc，也可能因为路由跳转、页面构建或 `Scaffold` 等复杂 Widget 内部的上下文传递问题，导致 `BlocBuilder` 初始化时使用的 `BuildContext` 无法访问到 Provider。
3.  **确定方案:** 为了保证 `BlocBuilder` 能够稳定访问到 Bloc 实例，决定改变 Bloc 的提供范围。将 `AuthManagementBloc` 的 `BlocProvider` 从路由配置层级下移到 `AuthManagementPage` 内部，直接包裹页面主体内容（如 `Scaffold`）。

**解决方案:**

1.  **重构 `AuthManagementPage`:**
    *   将 `AuthManagementPage` 从 `StatefulWidget` 修改为 `StatelessWidget`。
    *   在其 `build` 方法内部，使用 `BlocProvider<AuthManagementBloc>` 包裹 `Scaffold`。
    *   在 `BlocProvider` 的 `create` 回调中使用 `GetIt.I<AuthManagementBloc>()` 获取 Bloc 实例，并触发初始加载事件 `LoadAuthenticationList`。
    *   确保 `BlocBuilder` 及其内部回调（如 `onRefresh`、`onRetryPressed`）使用 `BlocBuilder` 的 `builder` 函数提供的 `BuildContext` 来访问 Bloc（例如 `innerContext.read<AuthManagementBloc>()`）。
2.  **修改路由配置 (`seller_routes.dart`):**
    *   移除 `seller_authentication` 路由 `pageBuilder` 中的 `BlocProvider` 包装，因为 `AuthManagementPage` 现在自行提供 Bloc。
3.  **执行 Hot Restart:** 应用修改后，必须执行 Hot Restart（而非 Hot Reload）以确保路由和 Provider 状态完全更新。

**结果:**

修改后，`ProviderNotFoundException` 不再出现，认证管理页面可以正常加载（显示"暂无认证项目"或加载状态），表明 Bloc 实例能够被 `BlocBuilder` 正确找到和使用。
## 时间管理页面 (TimeManagementPage) 出现 ProviderNotFoundException

**现象:**

进入时间管理页面时，应用崩溃并抛出 `ProviderNotFoundException`，错误日志指示在 `TimeManagementPage` (具体是其 State 的 `initState` 方法) 中无法找到所需的 `TimeManagementBloc` 实例。

**分析过程:**

此问题与之前 `AuthManagementPage` 遇到的情况完全相同。`initState` 方法在 Widget 初始化早期执行，其 `BuildContext` 可能无法访问到由上层路由提供的 Provider。

**解决方案:**

采用与 `AuthManagementPage` 相同的策略：

1.  **重构 `TimeManagementPage`:**
    *   将 `TimeManagementPage` 从 `StatefulWidget` 修改为 `StatelessWidget`。
    *   在其 `build` 方法内部，使用 `BlocProvider<TimeManagementBloc>` 包裹页面主体 (`Scaffold`)。
    *   在 `BlocProvider` 的 `create` 回调中使用 `GetIt.I<TimeManagementBloc>()` 获取 Bloc 实例，并触发初始加载事件 `LoadTimeSettings`。
    *   确保页面内部需要访问 Bloc 的地方（如 `BlocConsumer`, `Switch` 的 `onChanged` 回调, 保存按钮的 `onPressed` 回调）使用正确的 `BuildContext` 来访问 Bloc (通常是 `BlocProvider` 子树下的 `context`)。
2.  **检查路由配置 (`seller_routes.dart`):**
    *   确认 `seller_time_management` 路由的 `pageBuilder` 中没有 `BlocProvider` 包装（如果之前有，则移除）。
3.  **执行 Hot Restart:** 应用修改后，执行 Hot Restart。

**结果:**

修改后，`ProviderNotFoundException` 不再出现，时间管理页面可以正常加载并显示 Bloc 的状态。

## 自动回复页面 (AutoReplyPage) 出现 ProviderNotFoundException

**现象:**

进入自动回复设置页面时，应用抛出 `ProviderNotFoundException`，错误日志指示 `BlocConsumer<AutoReplyBloc, AutoReplyState>` (在 `AutoReplyBody` 内部) 无法找到所需的 `AutoReplyBloc` 实例。

**分析过程:**

此问题与 `AuthManagementPage` 和 `TimeManagementPage` 类似。虽然 `AutoReplyPage` 本身是 `StatelessWidget`，但其子 Widget `AutoReplyBody` 是 `StatefulWidget`，并且在其 State 的 `initState` 中尝试访问 Bloc，导致了错误。

**解决方案:**

继续采用将 Bloc 提供下移到页面级 Widget 的策略：

1.  **修改 `AutoReplyPage`:**
    *   在其 `build` 方法内部，使用 `BlocProvider<AutoReplyBloc>` 包裹 `Scaffold`。
    *   在 `BlocProvider` 的 `create` 回调中使用 `GetIt.I<AutoReplyBloc>()` 获取 Bloc 实例，并触发初始加载事件 `LoadAutoReplySettings`。
2.  **修改 `AutoReplyBody`:**
    *   移除其 State (`_AutoReplyBodyState`) 的 `initState` 方法中调用 `context.read<AutoReplyBloc>().add(LoadAutoReplySettings())` 的代码，因为 Bloc 的创建和初始事件的触发已移至 `AutoReplyPage`。
3.  **检查路由配置 (`seller_routes.dart`):**
    *   确认 `seller_auto_reply` 路由的 `pageBuilder` 中没有 `BlocProvider` 包装。
4.  **执行 Hot Restart:** 应用修改后，执行 Hot Restart。

**结果:**

修改后，`ProviderNotFoundException` 不再出现，自动回复设置页面可以正常加载并与 `AutoReplyBloc` 交互。

