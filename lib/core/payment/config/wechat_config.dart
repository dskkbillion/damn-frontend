import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yaml/yaml.dart';

/// 微信支付配置类
/// 服务端托管模式 - 优先从环境变量读取敏感配置，确保安全性
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

  /// 从环境变量和配置文件加载微信支付配置
  /// 优先级：环境变量 > 配置文件 > 默认值
  static Future<WechatConfig> loadFromAssets({
    String configPath = 'config/wechat_config.yaml',
  }) async {
    try {
      // 加载 YAML 配置文件
      final configContent = await rootBundle.loadString(configPath);
      final yamlMap = loadYaml(configContent) as Map;
      
      // 从环境变量读取敏感配置，如果不存在则使用YAML配置
      final envAppId = dotenv.env['WECHAT_APP_ID'];
      final envUniversalLink = dotenv.env['WECHAT_UNIVERSAL_LINK'];
      final envEnvironment = dotenv.env['PAYMENT_ENVIRONMENT'];
      final envMockEnabled = dotenv.env['PAYMENT_MOCK_ENABLED'];
      
      // 构建App配置
      final yamlAppConfig = yamlMap['app_config'] ?? {};
      final appConfig = WechatAppConfig(
        appId: envAppId ?? yamlAppConfig['app_id'] ?? '',
        universalLink: envUniversalLink ?? yamlAppConfig['universal_link'] ?? '',
      );
      
      // 日志记录配置来源
      print('[WechatConfig] App ID source: ${envAppId != null ? 'Environment Variable' : 'YAML File'}');
      print('[WechatConfig] Universal Link source: ${envUniversalLink != null ? 'Environment Variable' : 'YAML File'}');
      
      // 平台特定的配置提示
      if (Platform.isAndroid) {
        print('[WechatConfig] Running on Android - Universal Link is optional');
      } else if (Platform.isIOS) {
        print('[WechatConfig] Running on iOS - Universal Link is required');
      }
      
      return WechatConfig(
        environment: envEnvironment ?? yamlMap['environment'] ?? 'production',
        mockPayment: _parseBool(envMockEnabled) ?? yamlMap['mock_payment'] ?? false,
        display: WechatDisplayConfig.fromMap(yamlMap['display'] ?? {}),
        appConfig: appConfig,
        paymentScenes: List<String>.from(yamlMap['payment_scenes'] ?? ['order']),
        paymentTypes: List<String>.from(yamlMap['payment_types'] ?? ['app']),
      );
    } catch (e) {
      print('[WechatConfig] Failed to load config: $e');
      
      // 尝试仅从环境变量读取
      final envAppId = dotenv.env['WECHAT_APP_ID'];
      final envUniversalLink = dotenv.env['WECHAT_UNIVERSAL_LINK'];
      
      // Android平台只需要App ID，iOS平台需要App ID和Universal Link
      final hasRequiredConfig = Platform.isAndroid 
          ? (envAppId != null)
          : (envAppId != null && envUniversalLink != null);
          
              if (hasRequiredConfig) {
          print('[WechatConfig] Using environment variables only');
          return WechatConfig(
            environment: dotenv.env['PAYMENT_ENVIRONMENT'] ?? 'production',
            mockPayment: _parseBool(dotenv.env['PAYMENT_MOCK_ENABLED']) ?? false,
            display: const WechatDisplayConfig(
              name: '微信支付',
              icon: 'wechat',
              color: '#07c160',
              description: '安全便捷的移动支付',
            ),
            appConfig: WechatAppConfig(
              appId: envAppId!,
              universalLink: envUniversalLink ?? '', // Android平台可以为空
            ),
            paymentScenes: ['order', 'vip', 'wallet'],
            paymentTypes: ['app'],
          );
        }
      
      throw Exception('Failed to load wechat config from both file and environment variables: $e');
    }
  }

  /// 解析布尔值字符串
  static bool? _parseBool(String? value) {
    if (value == null) return null;
    final lowerValue = value.toLowerCase();
    if (lowerValue == 'true' || lowerValue == '1') return true;
    if (lowerValue == 'false' || lowerValue == '0') return false;
    return null;
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

  /// 验证配置是否完整
  bool get isValid => appConfig.isValid;

  @override
  String toString() {
    return 'WechatConfig{'
        'environment: $environment, '
        'mockPayment: $mockPayment, '
        'appId: ${appConfig.appId.replaceRange(3, appConfig.appId.length - 3, '***')}, ' // 隐藏部分App ID用于日志安全
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
  /// iOS平台需要Universal Link，Android平台可选
  bool get isValid {
    if (appId.isEmpty) return false;
    
    // iOS平台必需Universal Link
    if (Platform.isIOS) {
      return universalLink.isNotEmpty;
    }
    
    // Android平台不强制要求Universal Link
    if (Platform.isAndroid) {
      return true; // 只要有App ID就可以
    }
    
    // 其他平台默认需要Universal Link
    return universalLink.isNotEmpty;
  }
} 