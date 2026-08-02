import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/config/app_feature_flags.dart';

void main() {
  test('seller cash payout routes fail closed during credits MVP', () {
    expect(AppFeatureFlags.sellerCashPayoutsEnabled, isFalse);
    expect(
      AppFeatureFlags.sellerCashRouteRedirect(
        creditsWalletPath: '/seller/wallet',
      ),
      '/seller/wallet',
    );
  });
}
