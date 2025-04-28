import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Import getIt
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/routes/ai_docs_routes.dart'; // Import AI Docs routes

// Change to StatefulWidget to read storage in initState
class DevMenuPage extends StatefulWidget {
  const DevMenuPage({super.key});

  @override
  State<DevMenuPage> createState() => _DevMenuPageState();
}

class _DevMenuPageState extends State<DevMenuPage> {
  String? _userId;
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    try {
      final storage = getIt<FlutterSecureStorage>();
      _userId = await storage.read(key: 'user_id');
      _token = await storage.read(key: 'user_token');
    } catch (e) {
      print('[DevMenuPage] Error reading credentials: $e');
      // Handle error, maybe set default values or show error message
      _userId = 'Error loading ID';
      _token = 'Error loading token';
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开发调试菜单'),
        backgroundColor: Colors.amber[100], // Give it a distinct color
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                // Display current credentials
                _buildInfoCard(),
                const SizedBox(height: 16), // Add some spacing

                _buildSectionTitle('常用入口'),
                _buildNavButton(context, '主页', '/home'),
                _buildNavButton(context, '多少看看', '/discover'),
                _buildNavButton(context, '消息', '/chat'),
                _buildNavButton(context, '我的', '/profile'),
                const Divider(),

                _buildSectionTitle('订单模块 (买家)'),
                _buildNavButton(context, '订单列表', '/orders'),
                _buildNavButton(context, '订单详情 (示例)', '/orderDetail/mock_order_1'),
                const Divider(),

                _buildSectionTitle('订单模块 (卖家)'),
                _buildNavButton(context, '卖家订单列表', '/seller/orders'),
                 _buildNavButton(context, '卖家订单详情 (示例)', '/seller/orders/mock_seller_order_1'),
                // TODO: Add other seller order actions/views if needed
                const Divider(),

                // ---> ADDED: Seller Module Section <---
                _buildSectionTitle('卖家模块 (Seller)'),
                _buildNavButton(context, '卖家中心 (首页)', '/seller'), // Navigate to Seller Home
                // TODO: Add other seller entry points as needed (e.g., notifications, settings)
                const Divider(),
                // --------------------------------------

                // Add entry points for AI Docs Module
                _buildSectionTitle('AI Docs 模块'),
                _buildNavButton(context, 'AI 聊天', '/ai_chat'), // Use string literal path
                const Divider(),

                // TODO: Add entry points for other modules as they are merged

                _buildSectionTitle('测试/其他'),
                // Add any other specific test routes here if needed
                // _buildNavButton(context, '登录页 (如果存在)', '/login'),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前测试凭证 (硬编码): ', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('User ID: ${_userId ?? "Not found"}'),
            const SizedBox(height: 4),
            Text('Token: ${_token ?? "Not found"}', maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('(临时注入，将在 Auth 模块合并后移除)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () {
          try {
            context.go(path);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('跳转失败: $path - $e')),
            );
          }
        },
        child: Text(title),
      ),
    );
  }

   Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }
} 