import 'dart:convert';

import 'package:dskk_flutter_refactor/features/chat/domain/entities/payment_prompt_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentPromptPayload.tryParse', () {
    test('valid prod-shaped payload returns full PaymentPromptPayload', () {
      final json = jsonEncode({
        'type': 'payment_prompt',
        'source': 'seller',
        'content': '继续付费咨询',
        'productId': '42',
        'sellerId': 7,
        'roundCount': 5,
        'variants': [
          {'id': 1, 'price': 30, 'name': '基础咨询'},
          {'id': 2, 'price': 50, 'name': '标准咨询'},
        ],
      });

      final payload = PaymentPromptPayload.tryParse(json);

      expect(payload, isNotNull);
      expect(payload!.type, kPaymentPromptType);
      expect(payload.source, 'seller');
      expect(payload.content, '继续付费咨询');
      expect(payload.productId, '42');
      expect(payload.sellerId, 7);
      expect(payload.roundCount, 5);
      expect(payload.variants, hasLength(2));
      expect(payload.variants[0].id, 1);
      expect(payload.variants[0].price, 30);
      expect(payload.variants[0].name, '基础咨询');
    });

    test('malformed JSON returns null', () {
      expect(PaymentPromptPayload.tryParse('{not json'), isNull);
      expect(PaymentPromptPayload.tryParse('{"type":"payment_prompt"'), isNull);
    });

    test('non-JSON plain text returns null via startsWith guard', () {
      expect(PaymentPromptPayload.tryParse('hello world'), isNull);
      expect(PaymentPromptPayload.tryParse('普通聊天消息'), isNull);
    });

    test('empty / null context returns null', () {
      expect(PaymentPromptPayload.tryParse(''), isNull);
      expect(PaymentPromptPayload.tryParse(null), isNull);
    });

    test('JSON without "payment_prompt" substring short-circuits to null', () {
      final json = jsonEncode({'type': 'text', 'content': 'hi'});
      expect(PaymentPromptPayload.tryParse(json), isNull);
    });

    test('type field with a different value returns null', () {
      // Contains the literal "payment_prompt" so the substring guard passes,
      // but the actual type field is something else — must reject.
      final json = '{"type":"image","note":"payment_prompt is just text here"}';
      expect(PaymentPromptPayload.tryParse(json), isNull);
    });

    test('extra/unknown top-level fields are ignored', () {
      final json = jsonEncode({
        'type': 'payment_prompt',
        'content': 'x',
        'roundCount': 1,
        'variants': <dynamic>[],
        'unexpectedField': 'whatever',
      });

      expect(PaymentPromptPayload.tryParse(json), isNotNull);
    });

    test('historical payload with showPopup is parsed and showPopup is dropped',
        () {
      // Wedge-legacy: production chat history contains payloads with showPopup.
      // Must parse cleanly and silently ignore the field.
      final json = jsonEncode({
        'type': 'payment_prompt',
        'source': 'seller',
        'content': '历史消息',
        'productId': '1',
        'sellerId': 2,
        'roundCount': 3,
        'variants': [
          {'id': 10, 'price': 99, 'name': '会员'},
        ],
        'showPopup': true,
      });

      final payload = PaymentPromptPayload.tryParse(json);

      expect(payload, isNotNull);
      expect(payload!.content, '历史消息');
      expect(payload.variants, hasLength(1));
      // No surface for showPopup on the typed model — confirm by serializing
      // back out and asserting the key is gone.
      expect(payload.toJson().containsKey('showPopup'), isFalse);
    });

    test('empty variants list produces payload with empty list', () {
      final json = jsonEncode({
        'type': 'payment_prompt',
        'content': 'x',
        'variants': <dynamic>[],
      });

      final payload = PaymentPromptPayload.tryParse(json);

      expect(payload, isNotNull);
      expect(payload!.variants, isEmpty);
    });

    test('missing optional sellerId / productId yields nulls', () {
      final json = jsonEncode({
        'type': 'payment_prompt',
        'content': 'x',
        'roundCount': 0,
        'variants': <dynamic>[],
      });

      final payload = PaymentPromptPayload.tryParse(json);

      expect(payload, isNotNull);
      expect(payload!.sellerId, isNull);
      expect(payload.productId, isNull);
    });

    test('variant id as integer JSON number parses successfully', () {
      final json = jsonEncode({
        'type': 'payment_prompt',
        'content': 'x',
        'variants': [
          {'id': 42, 'price': 100},
        ],
      });

      final payload = PaymentPromptPayload.tryParse(json);

      expect(payload, isNotNull);
      expect(payload!.variants.single.id, 42);
      expect(payload.variants.single.id, isA<num>());
    });

    test('variant id as double JSON number parses successfully', () {
      // jsonDecode treats numeric literals with fractional part as double.
      const raw =
          '{"type":"payment_prompt","content":"x","variants":[{"id":1.5,"price":2.5}]}';

      final payload = PaymentPromptPayload.tryParse(raw);

      expect(payload, isNotNull);
      expect(payload!.variants.single.id, 1.5);
      expect(payload.variants.single.price, 2.5);
    });
  });
}
