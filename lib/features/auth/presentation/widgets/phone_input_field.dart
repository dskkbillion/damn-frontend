import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/country_code.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/country_code_selector.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/utils/phone_validator.dart';

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
        labelText: AppLocalizations.of(context).auth_phone_number ?? 'Phone Number',
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
          return AppLocalizations.of(context).auth_phone_validation_empty ?? 'Please enter phone number';
        }
        // 使用统一的验证工具类
        final result = PhoneValidator.validate(
          value,
          selectedCountry.code,
          context: context,
        );
        return result.isValid ? null : result.errorMessage;
      },
    );
  }
}