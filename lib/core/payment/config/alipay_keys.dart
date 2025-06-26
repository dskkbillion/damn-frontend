import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

/// 支付宝密钥管理类（服务端托管模式）
/// 服务端托管模式下，客户端不需要管理任何密钥
class AlipayKeys {
  static AlipayKeys? _instance;
  
  final String mode;
  final String note;
  
  AlipayKeys._({
    required this.mode,
    required this.note,
  });
  
  /// 获取密钥实例（单例模式）
  static Future<AlipayKeys> getInstance() async {
    _instance ??= await _loadKeys();
    return _instance!;
  }
  
  /// 从配置文件加载密钥配置
  static Future<AlipayKeys> _loadKeys() async {
    try {
      // 从配置文件加载
      final keysString = await rootBundle.loadString('config/alipay_keys.yaml');
      final keys = loadYaml(keysString);
      
      final alipayKeys = keys['alipay_keys'];
      
      return AlipayKeys._(
        mode: alipayKeys['mode'] ?? 'server_hosted',
        note: alipayKeys['note'] ?? '服务端托管模式，客户端无需配置密钥',
      );
    } catch (e) {
      print('加载支付宝密钥配置失败: $e');
      // 返回默认配置
      return AlipayKeys._(
        mode: 'server_hosted',
        note: '服务端托管模式，客户端无需配置密钥',
      );
    }
  }
  
  /// 验证配置是否有效（服务端托管模式始终有效）
  bool get isValid {
    // 服务端托管模式：客户端不需要验证密钥
    return mode == 'server_hosted';
  }
  
  /// 是否为服务端托管模式
  bool get isServerHosted => mode == 'server_hosted';
  
  /// 重置实例（用于测试）
  static void resetInstance() {
    _instance = null;
  }
  
  @override
  String toString() {
    return 'AlipayKeys{mode: $mode, serverHosted: $isServerHosted}';
  }
} 