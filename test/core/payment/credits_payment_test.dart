import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/payment/models/payment_models.dart';
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';

void main() {
  group('credits MVP', () {
    test('uses credits as the payment method code', () {
      expect(PaymentMethod.credits.code, 'credits');
      expect(PaymentMethod.credits.displayName, '积分支付');
    });

    test('renders prices as integer credits', () {
      expect(PriceFormatter.format(12), '12 积分');
      expect(PriceFormatter.format(12.4), '12 积分');
      expect(PriceFormatter.formatRange(10, 20), '10 - 20 积分');
      expect(PriceFormatter.currencyCode, 'credits');
    });
  });
}
