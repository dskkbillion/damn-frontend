import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/country_code.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/country_code_selector.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 手机号输入框 Widget，支持国际区号选择
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountryChanged;
  final bool enableCountrySelector;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.enableCountrySelector = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!?.auth_phone_number ?? 'Phone Number',
        border: const OutlineInputBorder(),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CountryCodeSelector(
            selectedCountry: selectedCountry,
            onCountryChanged: onCountryChanged,
            enabled: enableCountrySelector,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!?.auth_phone_validation_empty ?? 'Please enter phone number';
        }
        // 根据不同国家进行验证
        return _validatePhoneNumber(value, selectedCountry.code, context);
      },
    );
  }

  String? _validatePhoneNumber(String value, String countryCode, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 移除所有非数字字符
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    switch (countryCode) {
      case 'CN': // 中国
        if (digitsOnly.length != 11) {
          return l10n?.auth_phone_validation_invalid_cn ?? 'Please enter 11-digit phone number';
        }
        if (!digitsOnly.startsWith('1')) {
          return l10n?.auth_phone_validation_invalid_cn_start ?? 'Phone number must start with 1';
        }
        break;
      case 'US': // 美国
      case 'CA': // 加拿大
        if (digitsOnly.length != 10) {
          return l10n?.auth_phone_validation_invalid_us ?? 'Please enter 10-digit phone number';
        }
        break;
      case 'JP': // 日本
        if (digitsOnly.length != 10 && digitsOnly.length != 11) {
          return l10n?.auth_phone_validation_invalid_jp_kr ?? 'Please enter 10 or 11-digit phone number';
        }
        break;
      case 'KR': // 韩国
        if (digitsOnly.length != 10 && digitsOnly.length != 11) {
          return l10n?.auth_phone_validation_invalid_jp_kr ?? 'Please enter 10 or 11-digit phone number';
        }
        break;
      case 'GB': // 英国
        if (digitsOnly.length != 10 && digitsOnly.length != 11) {
          return l10n?.auth_phone_validation_invalid_jp_kr ?? 'Please enter 10 or 11-digit phone number';
        }
        break;
      default:
        // 其他国家的通用验证：长度在7-15位之间
        if (digitsOnly.length < 7 || digitsOnly.length > 15) {
          return l10n?.auth_phone_validation_invalid_general ?? 'Please enter a valid phone number';
        }
    }
    return null;
  }
}