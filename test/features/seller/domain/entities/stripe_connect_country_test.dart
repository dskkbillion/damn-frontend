import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/stripe_connect_country.dart';

void main() {
  test(
      'covers every Southeast Asian country without enabling unsupported flows',
      () {
    const southeastAsiaCodes = {
      'BN',
      'KH',
      'ID',
      'LA',
      'MY',
      'MM',
      'PH',
      'SG',
      'TH',
      'TL',
      'VN',
    };

    final listedCodes = stripeConnectCountries.map((country) => country.code);
    expect(listedCodes.toSet().containsAll(southeastAsiaCodes), isTrue);
    expect(
      stripeConnectCountries
          .where((country) => country.directChargeEnabled)
          .map((country) => country.code),
      containsAll(<String>['SG', 'US']),
    );
    expect(
      stripeConnectCountries
          .firstWhere((country) => country.code == 'PH')
          .directChargeEnabled,
      isFalse,
    );
    expect(stripeConnectCountryName('sg'), '新加坡');
  });
}
