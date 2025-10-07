import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'app/di/injection_container.dart';
import 'core/constants/env_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/services/auth_token_service.dart';
import 'generated/app_localizations.dart';
import 'app/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize dependency injection
  await initializeDependencies();
  
  // Auto-login for testing
  final authService = sl<AuthTokenService>();
  await authService.saveToken('test_token_for_chat_testing');
  await authService.saveUserId(1); // Test user ID
  
  runApp(const ChatTestApp());
}

class ChatTestApp extends StatelessWidget {
  const ChatTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chat Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      routerConfig: _router,
    );
  }
}

// Custom router for testing
final _router = GoRouter(
  initialLocation: '/test',
  routes: [
    GoRoute(
      path: '/test',
      builder: (context, state) => const ChatTestHomePage(),
    ),
    // Include all app routes
    ...AppRouter.routes,
  ],
);

class ChatTestHomePage extends StatelessWidget {
  const ChatTestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天模块测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '聊天重构测试',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '新版本使用 flutter_chat_ui 组件库',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        const Text('离线消息支持'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        const Text('WebSocket自动重连'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        const Text('性能优化'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              '选择测试方式:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // 新版聊天
            ElevatedButton.icon(
              onPressed: () {
                // 使用一个测试聊天ID
                context.push('/chat/refactored/1');
              },
              icon: const Icon(Icons.rocket_launch),
              label: const Text('测试新版聊天（推荐）'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // 旧版聊天
            ElevatedButton.icon(
              onPressed: () {
                context.push('/chat/1');
              },
              icon: const Icon(Icons.chat),
              label: const Text('测试旧版聊天（对比）'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // 聊天列表
            ElevatedButton.icon(
              onPressed: () {
                context.push('/chat');
              },
              icon: const Icon(Icons.list),
              label: const Text('查看聊天列表'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const Spacer(),
            
            // 测试说明
            Card(
              color: Colors.amber.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '测试步骤：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('1. 点击"测试新版聊天"进入'),
                    Text('2. 发送文本、图片、语音消息'),
                    Text('3. 测试消息撤回（长按消息）'),
                    Text('4. 断网测试离线队列'),
                    Text('5. 对比新旧版本性能'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}