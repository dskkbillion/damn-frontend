import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

/// 微信支付配置类
/// 服务端托管模式 - 简化的配置，只包含必要的显示和初始化信息
class WechatConfig {
  final String environment;
  final bool mockPayment;
  final WechatDisplayConfig display;
  final WechatAppConfig appConfig;
  final List<String> paymentScenes;
  final List<String> paymentTypes;

  const WechatConfig({
    required this.environment,
    required this.mockPayment,
    required this.display,
    required this.appConfig,
    required this.paymentScenes,
    required this.paymentTypes,
  });

  /// 从配置文件加载微信支付配置
  static Future<WechatConfig> loadFromAssets({
    String configPath = 'config/wechat_config.yaml',
  }) async {
    try {
      final configContent = await rootBundle.loadString(configPath);
      final yamlMap = loadYaml(configContent) as Map;
      
      return WechatConfig(
        environment: yamlMap['environment'] ?? 'production',
        mockPayment: yamlMap['mock_payment'] ?? false,
        display: WechatDisplayConfig.fromMap(yamlMap['display'] ?? {}),
        appConfig: WechatAppConfig.fromMap(yamlMap['app_config'] ?? {}),
        paymentScenes: List<String>.from(yamlMap['payment_scenes'] ?? ['order']),
        paymentTypes: List<String>.from(yamlMap['payment_types'] ?? ['app']),
      );
    } catch (e) {
      throw Exception('Failed to load wechat config: $e');
    }
  }

  /// 是否为生产环境
  bool get isProduction => environment == 'production';
  
  /// 是否为沙盒环境
  bool get isSandbox => environment == 'sandbox';
  
  /// 显示名称
  String get displayName => display.name;
  
  /// 显示图标
  String get displayIcon => display.icon;
  
  /// 显示颜色
  String get displayColor => display.color;
  
  /// 显示描述
  String get displayDescription => display.description;
  
  /// 微信App ID
  String get appId => appConfig.appId;
  
  /// iOS Universal Link
  String get universalLink => appConfig.universalLink;
  
  /// 是否支持指定支付场景
  bool supportsScene(String scene) => paymentScenes.contains(scene);
  
  /// 是否支持指定支付类型
  bool supportsType(String type) => paymentTypes.contains(type);

  @override
  String toString() {
    return 'WechatConfig{'
        'environment: $environment, '
        'mockPayment: $mockPayment, '
        'appId: ${appConfig.appId}, '
        'scenes: $paymentScenes, '
        'types: $paymentTypes'
        '}';
  }
}

/// 微信支付显示配置
class WechatDisplayConfig {
  final String name;
  final String icon;
  final String color;
  final String description;

  const WechatDisplayConfig({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  factory WechatDisplayConfig.fromMap(Map<dynamic, dynamic> map) {
    return WechatDisplayConfig(
      name: map['name'] ?? '微信支付',
      icon: map['icon'] ?? 'wechat',
      color: map['color'] ?? '#07c160',
      description: map['description'] ?? '安全便捷的移动支付',
    );
  }
}

/// 微信App配置
class WechatAppConfig {
  final String appId;
  final String universalLink;

  const WechatAppConfig({
    required this.appId,
    required this.universalLink,
  });

  factory WechatAppConfig.fromMap(Map<dynamic, dynamic> map) {
    return WechatAppConfig(
      appId: map['app_id'] ?? '',
      universalLink: map['universal_link'] ?? '',
    );
  }
  
  /// 配置是否有效
  bool get isValid => appId.isNotEmpty && universalLink.isNotEmpty;
} 