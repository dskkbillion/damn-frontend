import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Import getIt
// Import AI Docs routes
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.app_dev_menu_title),
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

                _buildSectionTitle(l10n.app_dev_common_entries),
                _buildNavButton(context, l10n.nav_home, '/home'),
                _buildNavButton(context, l10n.app_dev_dskk, '/discover'),
                _buildNavButton(context, l10n.nav_messages, '/chat'),
                _buildNavButton(context, l10n.nav_profile, '/profile'),
                const Divider(),

                _buildSectionTitle(l10n.app_dev_order_module_buyer),
                _buildNavButton(context, l10n.app_dev_order_list, '/orders'),
                _buildNavButton(context, l10n.app_dev_order_detail_example, '/orderDetail/mock_order_1'),
                const Divider(),

                _buildSectionTitle(l10n.app_dev_order_module_seller),
                _buildNavButton(context, l10n.app_dev_seller_order_list, '/seller/orders'),
                 _buildNavButton(context, l10n.app_dev_seller_order_detail_example, '/seller/orders/mock_seller_order_1'),
                // TODO: Add other seller order actions/views if needed
                const Divider(),

                // ---> ADDED: Seller Module Section <---
                _buildSectionTitle(l10n.app_dev_seller_module),
                _buildNavButton(context, l10n.app_dev_seller_center, '/seller'), // Navigate to Seller Home
                // TODO: Add other seller entry points as needed (e.g., notifications, settings)
                const Divider(),
                // --------------------------------------

                // Add entry points for AI Docs Module
                _buildSectionTitle(l10n.app_dev_ai_docs_module),
                _buildNavButton(context, l10n.app_dev_ai_chat, '/ai_chat'), // Use string literal path
                const Divider(),

                // TODO: Add entry points for other modules as they are merged

                _buildSectionTitle(l10n.app_dev_test_other),
                // Add any other specific test routes here if needed
                // _buildNavButton(context, '登录页 (如果存在)', '/login'),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.app_dev_current_credentials, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('User ID: ${_userId ?? "Not found"}'),
            const SizedBox(height: 4),
            Text('Token: ${_token ?? "Not found"}', maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(l10n.app_dev_temp_injection, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
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
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.app_dev_navigation_failed(path, e.toString()))),
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