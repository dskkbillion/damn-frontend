import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/allocated_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AllocatedItemEntity.fromJson (#347)', () {
    test('解析后端实际返回的 camelCase schema', () {
      final entity = AllocatedItemEntity.fromJson({
        'itemId': '42',
        'merchantId': 10373,
        'allocatedAt': 1715843720,
        'status': 'allocated',
      });
      expect(entity.itemId, '42');
      expect(entity.merchantId, 10373);
      expect(entity.allocatedAt, 1715843720);
      expect(entity.status, 'allocated');
    });

    test('容错 snake_case 字段(防御性)', () {
      final entity = AllocatedItemEntity.fromJson({
        'item_id': '42',
        'merchant_id': 10373,
        'allocated_at': 1715843720,
      });
      expect(entity.itemId, '42');
      expect(entity.merchantId, 10373);
      expect(entity.allocatedAt, 1715843720);
      expect(entity.status, 'allocated');
    });

    test('itemId 为整数时转字符串', () {
      final entity = AllocatedItemEntity.fromJson({
        'itemId': 42,
      });
      expect(entity.itemId, '42');
    });

    test('缺失字段不崩,用合理默认', () {
      final entity = AllocatedItemEntity.fromJson({});
      expect(entity.itemId, '');
      expect(entity.merchantId, isNull);
      expect(entity.allocatedAt, isNull);
      expect(entity.status, 'allocated');
    });

    test('Equatable 行为正确', () {
      const a = AllocatedItemEntity(itemId: '1', merchantId: 10);
      const b = AllocatedItemEntity(itemId: '1', merchantId: 10);
      const c = AllocatedItemEntity(itemId: '2', merchantId: 10);
      expect(a, b);
      expect(a == c, isFalse);
    });
  });
}
