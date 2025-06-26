import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

/// 支付宝配置管理类（服务端托管模式）
/// 简化配置，移除客户端不需要的密钥相关配置
class AlipayConfig {
  static AlipayConfig? _instance;
  
  final String environment;
  final bool mockPayment;
  final Map<String, String> display;
  
  AlipayConfig._({
    required this.environment,
    required this.mockPayment,
    required this.display,
  });
  
  /// 获取配置实例（单例模式）
  static Future<AlipayConfig> getInstance() async {
    _instance ??= await _loadConfig();
    return _instance!;
  }
  
  /// 从配置文件加载配置
  static Future<AlipayConfig> _loadConfig() async {
    try {
      // 从配置文件加载
      final configString = await rootBundle.loadString('config/alipay_config.yaml');
      final config = loadYaml(configString);
      
      final alipayConfig = config['alipay'];
      
      return AlipayConfig._(
        environment: alipayConfig['environment'] ?? 'production',
        mockPayment: alipayConfig['development']['mock_payment'] ?? false,
        display: Map<String, String>.from(alipayConfig['display'] ?? {
          'name': '支付宝支付',
          'icon': 'alipay', 
          'description': '安全便捷的支付方式'
        }),
      );
    } catch (e) {
      print('加载支付宝配置失败: $e');
      // 返回默认配置
      return AlipayConfig._(
        environment: 'production',
        mockPayment: false,
        display: {
          'name': '支付宝支付',
          'icon': 'alipay',
          'description': '安全便捷的支付方式'
        },
      );
    }
  }
  
  /// 是否为生产环境
  bool get isProduction => environment == 'production';
  
  /// 是否为沙箱环境
  bool get isSandbox => environment == 'sandbox';
  
  /// 获取显示名称
  String get displayName => display['name'] ?? '支付宝支付';
  
  /// 获取图标
  String get displayIcon => display['icon'] ?? 'alipay';
  
  /// 获取描述
  String get displayDescription => display['description'] ?? '安全便捷的支付方式';
  
  /// 重置实例（用于测试）
  static void resetInstance() {
    _instance = null;
  }
  
  @override
  String toString() {
    return 'AlipayConfig{environment: $environment, mockPayment: $mockPayment, mode: server-hosted}';
  }
} 