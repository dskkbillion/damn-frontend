import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Step 2.5 验证：高频页面 loading state 使用骨架屏替代 CircularProgressIndicator
void main() {
  group('Step 2.5: Skeleton replacement audit', () {
    test('home_page.dart imports skeleton components', () {
      final content = File('lib/features/home/presentation/pages/home_page.dart').readAsStringSync();
      expect(content.contains('skeleton'), isTrue,
          reason: 'home_page.dart should import skeleton components');
    });

    test('chat_list_page.dart imports skeleton components', () {
      final content = File('lib/features/chat/presentation/pages/chat_list_page.dart').readAsStringSync();
      expect(content.contains('skeleton'), isTrue,
          reason: 'chat_list_page.dart should import skeleton components');
    });

    test('order_list_page.dart imports skeleton components', () {
      final content = File('lib/features/orders/presentation/pages/order_list_page.dart').readAsStringSync();
      expect(content.contains('skeleton'), isTrue,
          reason: 'order_list_page.dart should import skeleton components');
    });

    test('seller_profile_page.dart imports skeleton components', () {
      final content = File('lib/features/seller/presentation/pages/seller_profile_page.dart').readAsStringSync();
      expect(content.contains('skeleton'), isTrue,
          reason: 'seller_profile_page.dart should import skeleton components');
    });

    test('home_page.dart uses SkeletonCard or SkeletonPage in loading state', () {
      final content = File('lib/features/home/presentation/pages/home_page.dart').readAsStringSync();
      expect(
        content.contains('SkeletonCard') || content.contains('SkeletonPage'),
        isTrue,
        reason: 'home_page.dart should use skeleton components for loading state',
      );
    });

    test('chat_list_page.dart uses SkeletonChatItem or SkeletonPage in loading state', () {
      final content = File('lib/features/chat/presentation/pages/chat_list_page.dart').readAsStringSync();
      expect(
        content.contains('SkeletonChatItem') || content.contains('SkeletonPage'),
        isTrue,
        reason: 'chat_list_page.dart should use skeleton components for loading state',
      );
    });
  });
}
