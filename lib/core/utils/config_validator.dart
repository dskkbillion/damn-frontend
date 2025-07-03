import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 配置验证工具类
/// 用于检查支付相关的环境变量配置是否完整
class ConfigValidator {
  /// 验证微信支付配置
  static ConfigValidationResult validateWechatConfig() {
    final issues = <String>[];
    final warnings = <String>[];
    
    // 检查必需的环境变量
    final wechatAppId = dotenv.env['WECHAT_APP_ID'];
    final wechatUniversalLink = dotenv.env['WECHAT_UNIVERSAL_LINK'];
    
    if (wechatAppId == null || wechatAppId.isEmpty) {
      issues.add('WECHAT_APP_ID 环境变量未设置或为空');
    } else if (wechatAppId.contains('placeholder') || wechatAppId.contains('wx_placeholder')) {
      issues.add('WECHAT_APP_ID 仍使用占位符值，请设置真实的微信App ID');
    } else if (!wechatAppId.startsWith('wx')) {
      warnings.add('WECHAT_APP_ID 格式可能不正确，微信App ID通常以"wx"开头');
    }
    
    // Universal Link主要用于iOS，Android可选
    if (Platform.isIOS) {
      if (wechatUniversalLink == null || wechatUniversalLink.isEmpty) {
        issues.add('WECHAT_UNIVERSAL_LINK 环境变量未设置或为空（iOS必需）');
      } else if (wechatUniversalLink.contains('placeholder')) {
        issues.add('WECHAT_UNIVERSAL_LINK 仍使用占位符值，请设置真实的Universal Link（iOS必需）');
      } else if (!wechatUniversalLink.startsWith('https://')) {
        warnings.add('WECHAT_UNIVERSAL_LINK 应该使用HTTPS协议');
      }
    } else if (Platform.isAndroid) {
      if (wechatUniversalLink != null && wechatUniversalLink.isNotEmpty) {
        if (wechatUniversalLink.contains('placeholder')) {
          warnings.add('WECHAT_UNIVERSAL_LINK 在Android上是可选的，但如果设置请使用真实值');
        } else if (!wechatUniversalLink.startsWith('https://')) {
          warnings.add('WECHAT_UNIVERSAL_LINK 应该使用HTTPS协议');
        }
      }
      // Android上不需要Universal Link，所以不报错
    } else {
      // 其他平台或Web，给出提示
      if (wechatUniversalLink == null || wechatUniversalLink.isEmpty) {
        warnings.add('WECHAT_UNIVERSAL_LINK 未设置，可能影响支付回调（仅iOS必需）');
      }
    }
    
    // 检查可选的环境变量
    final paymentEnv = dotenv.env['PAYMENT_ENVIRONMENT'];
    if (paymentEnv != null && paymentEnv.isNotEmpty) {
      if (!['production', 'sandbox', 'development'].contains(paymentEnv)) {
        warnings.add('PAYMENT_ENVIRONMENT 值不在推荐范围内 (production, sandbox, development)');
      }
    }
    
    final mockEnabled = dotenv.env['PAYMENT_MOCK_ENABLED'];
    if (mockEnabled != null && mockEnabled.isNotEmpty) {
      if (!['true', 'false', '1', '0'].contains(mockEnabled.toLowerCase())) {
        warnings.add('PAYMENT_MOCK_ENABLED 应该设置为 true/false 或 1/0');
      }
    }
    
    return ConfigValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      warnings: warnings,
    );
  }
  
  /// 验证后端API配置
  static ConfigValidationResult validateBackendConfig() {
    final issues = <String>[];
    final warnings = <String>[];
    
    final backendUrl = dotenv.env['BACKEND_BASE_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      issues.add('BACKEND_BASE_URL 环境变量未设置');
    } else if (!backendUrl.startsWith('http')) {
      warnings.add('BACKEND_BASE_URL 格式可能不正确，应该包含协议 (http/https)');
    }
    
    return ConfigValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      warnings: warnings,
    );
  }
  
  /// 验证所有支付配置
  static OverallValidationResult validateAllPaymentConfig() {
    final wechatResult = validateWechatConfig();
    final backendResult = validateBackendConfig();
    
    final allIssues = <String>[]
      ..addAll(wechatResult.issues)
      ..addAll(backendResult.issues);
    
    final allWarnings = <String>[]
      ..addAll(wechatResult.warnings)
      ..addAll(backendResult.warnings);
    
    return OverallValidationResult(
      isValid: allIssues.isEmpty,
      wechatConfig: wechatResult,
      backendConfig: backendResult,
      allIssues: allIssues,
      allWarnings: allWarnings,
    );
  }
  
  /// 打印配置检查报告
  static void printValidationReport() {
    print('\n=== 支付配置验证报告 ===');
    
    final result = validateAllPaymentConfig();
    
    if (result.isValid) {
      print('✅ 所有配置检查通过！');
    } else {
      print('❌ 发现配置问题：');
      for (int i = 0; i < result.allIssues.length; i++) {
        print('  ${i + 1}. ${result.allIssues[i]}');
      }
    }
    
    if (result.allWarnings.isNotEmpty) {
      print('\n⚠️ 配置警告：');
      for (int i = 0; i < result.allWarnings.length; i++) {
        print('  ${i + 1}. ${result.allWarnings[i]}');
      }
    }
    
    print('\n=== 配置说明 ===');
    print('请在项目根目录创建 .env 文件，包含以下内容：');
    print('');
    print('# 微信支付配置（必需）');
    print('WECHAT_APP_ID=wx8647007008f7b74d');
    
    if (Platform.isIOS) {
      print('WECHAT_UNIVERSAL_LINK=https://app.duoshaokankan.com/wechat/  # iOS必需');
    } else if (Platform.isAndroid) {
      print('# WECHAT_UNIVERSAL_LINK=https://app.duoshaokankan.com/wechat/  # Android可选');
    } else {
      print('WECHAT_UNIVERSAL_LINK=https://app.duoshaokankan.com/wechat/  # iOS必需，其他平台可选');
    }
    
    print('');
    print('# 后端API配置');
    print('BACKEND_BASE_URL=https://app.duoshaokankan.com/prod-api');
    print('');
    print('# 可选配置');
    print('PAYMENT_ENVIRONMENT=production');
    print('PAYMENT_MOCK_ENABLED=false');
    
    if (Platform.isAndroid) {
      print('');
      print('# Android支付回调说明：');
      print('# Android使用AndroidManifest.xml中的Intent Filter');
      print('# 和WXPayEntryActivity处理支付回调，无需Universal Link');
    } else if (Platform.isIOS) {
      print('');
      print('# iOS支付回调说明：');
      print('# iOS必需配置Universal Link用于支付回调');
      print('# 确保Universal Link在微信开放平台中正确配置');
    }
    
    print('\n========================\n');
  }
}

/// 配置验证结果
class ConfigValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> warnings;
  
  const ConfigValidationResult({
    required this.isValid,
    required this.issues,
    required this.warnings,
  });
}

/// 总体验证结果
class OverallValidationResult {
  final bool isValid;
  final ConfigValidationResult wechatConfig;
  final ConfigValidationResult backendConfig;
  final List<String> allIssues;
  final List<String> allWarnings;
  
  const OverallValidationResult({
    required this.isValid,
    required this.wechatConfig,
    required this.backendConfig,
    required this.allIssues,
    required this.allWarnings,
  });
} 