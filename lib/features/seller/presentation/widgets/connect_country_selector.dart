import 'package:flutter/material.dart';

import '../../domain/entities/stripe_connect_country.dart';

class ConnectCountrySelector extends StatelessWidget {
  final StripeConnectCountry? value;
  final ValueChanged<StripeConnectCountry?> onChanged;

  const ConnectCountrySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<StripeConnectCountry>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: '收款账户所在国家或地区',
            border: OutlineInputBorder(),
          ),
          hint: const Text('请选择'),
          items: stripeConnectCountries
              .map(
                (country) => DropdownMenuItem(
                  value: country,
                  child: Text(country.displayName),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        Text(
          value == null
              ? '开户地址创建后无法修改，请按本人或企业银行账户所在地选择。'
              : value!.directChargeEnabled
                  ? '将按 ${value!.name} 的本地要求进入 Stripe 身份验证。'
                  : '${value!.name} 暂未开放当前收款模式，我们会在 Stripe 支持后开放。',
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: value != null && !value!.directChargeEnabled
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
