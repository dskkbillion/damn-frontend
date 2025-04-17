# AI Docs 模块集成指南

本文档旨在说明如何将独立的 `ai_docs` 模块集成到主应用程序中。

## 1. 模块目标

`ai_docs` 模块提供了一个与 AI 进行多模态（文本、语音、图片）交互的聊天界面，并包含会话管理和相关服务推荐/分配功能。

## 2. 集成准备

在集成之前，请确保以下工作已完成或正在进行中：

*   **依赖注入**: 主应用需要运行 `configureDependencies()` 来注册 `ai_docs` 模块所需的服务和 Bloc (已在 `main_ai_docs_preview.dart` 中配置)。
*   **环境变量**: 主应用的 `main` 函数需要在 `configureDependencies()` **之前**调用 `await dotenv.load(fileName: ".env");` 来加载包含 `MODEL_BASE_URL` 和 `BACKEND_BASE_URL` 的 `.env` 文件 (已在 `main_ai_docs_preview.dart` 中配置)。`.env` 文件需要放在项目根目录并包含在 `pubspec.yaml` 的 `assets` 中。
*   **硬编码值替换**: 参考 `ai-docs-todo/hardcoded_values.md`，将临时的硬编码值（如 Auth Token, User ID, version Header）替换为从主应用状态或配置中动态获取的逻辑。
*   **外部依赖确认**: 参考 `ai-docs-todo/INTEGRATION_POINTS.md` (待创建或使用上一条消息内容)，确认用户认证、API 授权、推荐系统等外部依赖的状态和接口已准备就绪。

## 3. 导航集成

`ai_docs` 模块的主要入口点是 `ChatPage` Widget (`lib/features/ai_docs/presentation/pages/chat_page.dart`)。你需要使用主应用的导航解决方案（例如 `GoRouter`, `Navigator 2.0`）来配置一个路由，使得用户可以导航到这个页面。

**示例 (使用 GoRouter):**

假设你的 GoRouter 配置在 `lib/app/router/app_router.dart` 或类似文件中。

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // DI instance
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/pages/chat_page.dart';
// ... other imports for your main app routes

final GoRouter router = GoRouter(
  routes: [
    // ... your existing routes (e.g., for home, profile, etc.)

    // --- Add route for AI Docs Chat ---
    GoRoute(
      path: '/ai-chat', // Define a path for the chat page
      builder: (context, state) {
        // Use BlocProvider here to ensure a fresh Bloc instance is created
        // when navigating TO this route, or manage scope differently if needed.
        // Ensure getIt<AiChatBloc>() is registered correctly by configureDependencies()
        return BlocProvider(
           // Create a new instance or provide an existing one based on desired scope
           create: (_) => getIt<AiChatBloc>()..add(LoadConversations()), // Load initial conversations
           child: const ChatPage(),
        );
      },
      // Add sub-routes if needed within the AI Docs module
    ),

    // ... other routes
  ],
  // ... other GoRouter configurations (errorBuilder, etc.)
);

```

**导航触发点**:

你需要在主应用的某个 UI 元素上触发导航到 `/ai-chat` 路径。常见的位置包括：

*   **底部导航栏 (Bottom Navigation Bar)**: 添加一个新的 Tab，点击后执行 `context.go('/ai-chat');`。
*   **侧边栏菜单 (Drawer)**: 添加一个菜单项，点击后执行 `context.go('/ai-chat');`。
*   **主页上的按钮或卡片**: 点击后执行 `context.go('/ai-chat');`。

**示例 (在 BottomNavigationBar 中添加):**

```dart
// Inside your main Scaffold widget with BottomNavigationBar

BottomNavigationBarItem(
  icon: Icon(Icons.chat_bubble_outline), // Or a more specific AI icon
  label: 'AI 助手', // Or appropriate label
),

// In the onTap handler for the BottomNavigationBar:
onTap: (index) {
  if (index == your_ai_chat_tab_index) { // Replace with the correct index
     context.go('/ai-chat');
  } else {
     // Handle navigation for other tabs
  }
},
```

## 4. 状态传递 (可选)

如果 `ai_docs` 模块需要来自主应用的其他状态（除了 User ID 和 Token），你可能需要考虑：

*   **通过路由参数传递**: 在 `GoRoute` 定义和 `context.go()` 调用时传递参数。
*   **共享 Bloc/Provider**: 让 `ai_docs` 模块能够访问主应用中更高层级的 Bloc 或 Provider。

## 5. 注意事项

*   **Bloc 范围**: 上述 GoRouter 示例在每次导航到 `/ai-chat` 时创建了一个新的 `AiChatBloc` 实例。如果希望在 Tab 切换间保持状态，可能需要将 BlocProvider 提升到更高的层级（例如，在管理底部导航栏的 Widget 之上），或者使用其他状态管理策略。
*   **资源清理**: 确保在用户离开 `ai_docs` 模块或应用关闭时，相关的资源（如 Bloc, StreamSubscriptions）被正确清理。`AiChatBloc` 已包含 `close` 方法来取消 SSE 订阅。

请根据你的主应用架构和导航方案调整具体的集成代码。 