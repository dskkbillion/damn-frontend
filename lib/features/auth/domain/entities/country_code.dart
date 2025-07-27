import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_code.freezed.dart';
part 'country_code.g.dart';

@freezed
class CountryCode with _$CountryCode {
  const factory CountryCode({
    required String name,
    required String nameEn,
    required String code,
    required String dialCode,
    required String flag,
  }) = _CountryCode;

  factory CountryCode.fromJson(Map<String, dynamic> json) =>
      _$CountryCodeFromJson(json);
}

class CountryCodes {
  static const List<CountryCode> commonCountries = [
    CountryCode(
      name: '中国',
      nameEn: 'China',
      code: 'CN',
      dialCode: '+86',
      flag: '🇨🇳',
    ),
    CountryCode(
      name: '美国',
      nameEn: 'United States',
      code: 'US',
      dialCode: '+1',
      flag: '🇺🇸',
    ),
    CountryCode(
      name: '日本',
      nameEn: 'Japan',
      code: 'JP',
      dialCode: '+81',
      flag: '🇯🇵',
    ),
    CountryCode(
      name: '韩国',
      nameEn: 'South Korea',
      code: 'KR',
      dialCode: '+82',
      flag: '🇰🇷',
    ),
    CountryCode(
      name: '英国',
      nameEn: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      flag: '🇬🇧',
    ),
    CountryCode(
      name: '法国',
      nameEn: 'France',
      code: 'FR',
      dialCode: '+33',
      flag: '🇫🇷',
    ),
    CountryCode(
      name: '德国',
      nameEn: 'Germany',
      code: 'DE',
      dialCode: '+49',
      flag: '🇩🇪',
    ),
    CountryCode(
      name: '加拿大',
      nameEn: 'Canada',
      code: 'CA',
      dialCode: '+1',
      flag: '🇨🇦',
    ),
    CountryCode(
      name: '澳大利亚',
      nameEn: 'Australia',
      code: 'AU',
      dialCode: '+61',
      flag: '🇦🇺',
    ),
    CountryCode(
      name: '新加坡',
      nameEn: 'Singapore',
      code: 'SG',
      dialCode: '+65',
      flag: '🇸🇬',
    ),
    CountryCode(
      name: '马来西亚',
      nameEn: 'Malaysia',
      code: 'MY',
      dialCode: '+60',
      flag: '🇲🇾',
    ),
    CountryCode(
      name: '泰国',
      nameEn: 'Thailand',
      code: 'TH',
      dialCode: '+66',
      flag: '🇹🇭',
    ),
  ];

  static CountryCode getDefaultCountryCode(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return commonCountries[0]; // China
      case 'en':
        return commonCountries[1]; // United States
      case 'ja':
        return commonCountries[2]; // Japan
      case 'ko':
        return commonCountries[3]; // South Korea
      case 'fr':
        return commonCountries[5]; // France
      case 'de':
        return commonCountries[6]; // Germany
      default:
        return commonCountries[1]; // Default to United States
    }
  }
}