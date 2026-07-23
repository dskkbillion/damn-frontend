class StripeConnectCountry {
  final String code;
  final String name;
  final bool directChargeEnabled;

  const StripeConnectCountry({
    required this.code,
    required this.name,
    required this.directChargeEnabled,
  });

  String get displayName => directChargeEnabled ? name : '$name（暂未开放）';
}

/// 首版展示完整东南亚范围，但只允许后端已验证的 Direct Charge 国家开户。
const stripeConnectCountries = <StripeConnectCountry>[
  StripeConnectCountry(code: 'SG', name: '新加坡', directChargeEnabled: true),
  StripeConnectCountry(code: 'BN', name: '文莱', directChargeEnabled: false),
  StripeConnectCountry(code: 'KH', name: '柬埔寨', directChargeEnabled: false),
  StripeConnectCountry(code: 'ID', name: '印度尼西亚', directChargeEnabled: false),
  StripeConnectCountry(code: 'LA', name: '老挝', directChargeEnabled: false),
  StripeConnectCountry(code: 'MY', name: '马来西亚', directChargeEnabled: false),
  StripeConnectCountry(code: 'MM', name: '缅甸', directChargeEnabled: false),
  StripeConnectCountry(code: 'PH', name: '菲律宾', directChargeEnabled: false),
  StripeConnectCountry(code: 'TH', name: '泰国', directChargeEnabled: false),
  StripeConnectCountry(code: 'TL', name: '东帝汶', directChargeEnabled: false),
  StripeConnectCountry(code: 'VN', name: '越南', directChargeEnabled: false),
  StripeConnectCountry(code: 'US', name: '美国', directChargeEnabled: true),
];

String stripeConnectCountryName(String? code) {
  if (code == null) return '';
  for (final country in stripeConnectCountries) {
    if (country.code == code.toUpperCase()) return country.name;
  }
  return code.toUpperCase();
}
