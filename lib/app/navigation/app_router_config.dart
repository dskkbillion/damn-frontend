import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用路由配置类，用于控制路由行为
class AppRouterConfig {
  /// 是否显示开发tab
  static bool _showDevTab = true;

  /// 设置是否显示开发tab
  static void setShowDevTab(bool show) {
    _showDevTab = show;
  }

  /// 获取是否显示开发tab的状态
  static bool get showDevTab => _showDevTab;
}

/// 提供显示开发tab状态的Provider
final showDevTabProvider = Provider<bool>((ref) => AppRouterConfig.showDevTab); 