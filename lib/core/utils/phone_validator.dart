import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 手机号验证工具
///
/// 支持的国家/地区及其验证规则：
/// - CN (中国): 11位，必须以1开头
/// - US (美国): 10位
/// - CA (加拿大): 10位
/// - JP (日本): 10位
/// - KR (韩国): 10位
/// - GB (英国): 10位
/// - DE (德国): 10位
/// - AU (澳大利亚): 10位
/// - FR (法国): 9位
/// - TH (泰国): 9位
/// - SG (新加坡): 8位
/// - MY (马来西亚): 9-10位
/// - 其他国家: 7-15位（符合E.164国际标准）
///
/// 注意：验证的是本地号码（不含国际区号），
/// 调用方需要自行处理国际区号的添加。

/// 手机号验证结果
class PhoneValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PhoneValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  /// 创建验证成功的结果
  const PhoneValidationResult.success()
      : isValid = true,
        errorMessage = null;

  /// 创建验证失败的结果
  const PhoneValidationResult.failure(this.errorMessage) : isValid = false;
}

/// 手机号验证工具类
///
/// 提供统一的手机号验证逻辑，支持多国家/地区的验证规则
class PhoneValidator {
  PhoneValidator._(); // 私有构造函数，防止实例化

  /// 验证手机号是否符合指定国家/地区的格式
  ///
  /// [phoneNumber] 要验证的手机号（纯数字或包含格式字符）
  /// [countryCode] 国家/地区代码（如 'CN', 'US', 'JP'）
  /// [context] BuildContext，用于获取国际化错误消息（可选）
  ///
  /// 返回 [PhoneValidationResult] 包含验证结果和错误消息
  static PhoneValidationResult validate(
    String phoneNumber,
    String countryCode, {
    BuildContext? context,
  }) {
    // 获取国际化实例
    final l10n = context != null ? AppLocalizations.of(context) : null;

    // 检查是否为空
    if (phoneNumber.isEmpty) {
      return PhoneValidationResult.failure(
        l10n?.auth_phone_validation_empty ?? 'Please enter phone number',
      );
    }

    // 移除所有非数字字符
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // 根据不同国家进行验证
    switch (countryCode) {
      case 'CN': // 中国 - 11位手机号，以1开头
        if (digitsOnly.length != 11) {
          return PhoneValidationResult.failure(
            l10n?.auth_phone_validation_invalid_cn ??
                'Please enter 11-digit phone number',
          );
        }
        if (!digitsOnly.startsWith('1')) {
          return PhoneValidationResult.failure(
            l10n?.auth_phone_validation_invalid_cn_start ??
                'Phone number must start with 1',
          );
        }
        break;

      case 'US': // 美国 - 10位
      case 'CA': // 加拿大 - 10位
        if (digitsOnly.length != 10) {
          return PhoneValidationResult.failure(
            l10n?.auth_phone_validation_invalid_us ??
                'Please enter 10-digit phone number',
          );
        }
        break;

      case 'JP': // 日本 - 10位（手机号含区号）
      case 'KR': // 韩国 - 10位
      case 'GB': // 英国 - 10位
      case 'DE': // 德国 - 10位
      case 'AU': // 澳大利亚 - 10位（手机号格式 04XX XXX XXX）
        if (digitsOnly.length != 10) {
          return PhoneValidationResult.failure(
            l10n?.auth_phone_validation_invalid_general ??
                'Please enter 10-digit phone number',
          );
        }
        break;

      case 'FR': // 法国 - 9位（不含国际区号）
      case 'TH': // 泰国 - 9位（手机号 0X XXXX XXXX）
        if (digitsOnly.length != 9) {
          return PhoneValidationResult.failure(
            l10n?.auth_phone_validation_invalid_general ??
                'Please enter 9-digit phone number',
          );
        }
        break;

      case 'SG': // 新加坡 - 8位（手机号以8或9开头）
        if (digitsOnly.length != 8) {
          return PhoneValidationResult.failure(
            l10n?.auth_phone_validation_invalid_general ??
                'Please enter 8-digit phone number',
          );
        }
        break;

      case 'MY': // 马来西亚 - 9-10位（手机号 01X-XXX XXXX）
        if (digitsOnly.length < 9 || digitsOnly.length > 10) {
          return PhoneValidationResult.failure(
            l10n?.auth_phone_validation_invalid_general ??
                'Please enter 9 or 10-digit phone number',
          );
        }
        break;

      default:
        // 其他国家的通用验证：长度在7-15位之间（符合E.164标准）
        if (digitsOnly.length < 7 || digitsOnly.length > 15) {
          return PhoneValidationResult.failure(
            l10n?.auth_phone_validation_invalid_general ??
                'Please enter a valid phone number (7-15 digits)',
          );
        }
    }

    return const PhoneValidationResult.success();
  }

  /// 验证手机号（不带国际化消息）
  ///
  /// 适用于不需要显示用户友好错误消息的场景
  /// 返回简单的布尔值
  static bool isValid(String phoneNumber, String countryCode) {
    final result = validate(phoneNumber, countryCode);
    return result.isValid;
  }
}
