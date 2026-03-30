import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Step 1.1 验证：所有子页面导航使用 push() 而非 go()
///
/// 规则：
/// - go() 仅用于：Tab 根切换、登出清栈、支付完成清栈、canPop 失败兜底
/// - push() 用于：所有层级递进的子页面导航
///
/// 此测试通过静态分析源码确保 go() 没有在子页面导航场景被误用。
void main() {
  /// 已审计的合法 go() 使用列表
  /// 每项格式：文件相对路径 + 行内容片段
  final allowedGoUsages = <String>[
    // 登出清栈
    "context.go('/auth/login')",
    // 底部 Tab 切换 (favorites_page)
    "context.go('/ai-docs')",
    "context.go('/home')",
    "context.go('/chat')",
    "context.go('/profile')",
    "context.go('/dev')",
    // 底部 Tab 切换 (seller_public_profile_page)
    "context.go('/ai_chat')",
    "context.go('/dev_menu')",
    // canPop 失败兜底
    "context.go('/seller')",
    "context.go('/orders')",
    // 支付结果清栈 (payment_navigation_service)
    "context.go('/orders?status=awaitingPayment')",
    "context.go('/orders?status=\$statusString')",
  ];

  group('Step 1.1: go() → push() audit', () {
    test('profile_page.dart has no go() calls except logout', () {
      final file = File('lib/features/profile/presentation/pages/profile_page.dart');
      final content = file.readAsStringSync();
      final goMatches = RegExp(r'context\.go\(').allMatches(content);

      // 只允许 1 处 go: 登出到 /auth/login
      for (final match in goMatches) {
        final lineStart = content.lastIndexOf('\n', match.start) + 1;
        final lineEnd = content.indexOf('\n', match.end);
        final line = content.substring(lineStart, lineEnd).trim();
        // Skip commented-out lines
        if (line.startsWith('//')) continue;
        expect(
          line.contains('/auth/login'),
          isTrue,
          reason: 'profile_page.dart has go() not for logout: $line',
        );
      }
    });

    test('profile_header.dart uses push() for account security', () {
      final file = File('lib/features/profile/presentation/widgets/profile_header.dart');
      final content = file.readAsStringSync();
      expect(content.contains('context.push(ProfileRoutes.accountSecurityPath)'), isTrue);
      expect(content.contains('context.go(ProfileRoutes.accountSecurityPath)'), isFalse);
    });

    test('order_status_section.dart uses push() for order navigation', () {
      final file = File('lib/features/profile/presentation/widgets/order_status_section.dart');
      final content = file.readAsStringSync();
      // Should have push, not go, for /profile/orders paths
      expect(content.contains('context.push(pathWithQuery)'), isTrue);
      expect(content.contains('context.push(basePath)'), isTrue);
      expect(content.contains('context.go(pathWithQuery)'), isFalse);
      expect(content.contains('context.go(basePath)'), isFalse);
    });

    test('product_detail_content.dart uses push() for reviews', () {
      final file = File('lib/features/home/presentation/widgets/product_detail_content.dart');
      final content = file.readAsStringSync();
      expect(content.contains("context.push('/home/product/\$productId/reviews')"), isTrue);
      expect(content.contains("context.go('/home/product/\$productId/reviews')"), isFalse);
    });

    test('product_detail_page.dart uses push() for reviews', () {
      final file = File('lib/features/home/presentation/pages/product_detail_page.dart');
      final content = file.readAsStringSync();
      expect(content.contains("context.push('/home/product/\$productId/reviews')"), isTrue);
      expect(content.contains("context.go('/home/product/\$productId/reviews')"), isFalse);
    });

    test('seller_public_profile_page.dart uses push() for product detail', () {
      final file = File('lib/features/home/presentation/pages/seller_public_profile_page.dart');
      final content = file.readAsStringSync();
      expect(content.contains("context.push('/home/product/\${product.id}')"), isTrue);
      expect(content.contains("context.go('/home/product/\${product.id}')"), isFalse);
    });

    test('seller_home_page.dart uses push() for sub-pages', () {
      final file = File('lib/features/seller/presentation/pages/seller_home_page.dart');
      final content = file.readAsStringSync();
      expect(content.contains("context.push('/seller-profile/\${profile.storeId}')"), isTrue);
      expect(content.contains("context.push('/seller/dashboard')"), isTrue);
      expect(content.contains("context.go('/seller-profile/"), isFalse);
      expect(content.contains("context.go('/seller/dashboard')"), isFalse);
    });

    test('seller_profile_page.dart uses push() for navigation', () {
      final file = File('lib/features/seller/presentation/pages/seller_profile_page.dart');
      final content = file.readAsStringSync();
      expect(content.contains('context.push(route)'), isTrue);
      expect(content.contains('context.go(route)'), isFalse);
    });

    test('seller order widgets use push() for chat navigation', () {
      final file1 = File('lib/features/orders/presentation/seller/widgets/seller_order_item_card_action_buttons.dart');
      final file2 = File('lib/features/orders/presentation/seller/widgets/seller_order_detail_actions.dart');
      final content1 = file1.readAsStringSync();
      final content2 = file2.readAsStringSync();

      expect(content1.contains("context.push('/chat/refactored/\${room.id}')"), isTrue);
      expect(content1.contains("context.go('/chat/refactored/"), isFalse);
      expect(content2.contains("context.push('/chat/refactored/\${room.id}')"), isTrue);
      expect(content2.contains("context.go('/chat/refactored/"), isFalse);
    });

    test('payment_navigation_service.dart uses push() for orderDetail', () {
      final file = File('lib/core/payment/services/payment_navigation_service.dart');
      final content = file.readAsStringSync();

      // orderDetail should be push (user may want to go back)
      final orderDetailGoPattern = RegExp(r"context\.go\('/orderDetail/");
      expect(orderDetailGoPattern.hasMatch(content), isFalse,
          reason: 'orderDetail navigation should use push(), not go()');

      // orders list go is OK (payment clear-stack)
      final ordersGoPattern = RegExp(r"context\.go\('/orders");
      expect(ordersGoPattern.hasMatch(content), isTrue,
          reason: 'orders list navigation should use go() (clear-stack after payment)');
    });

    test('simple_profile_page.dart uses push() for favorites', () {
      final file = File('lib/features/profile/presentation/pages/simple_profile_page.dart');
      final content = file.readAsStringSync();
      expect(content.contains("context.push('/favorites')"), isTrue);
      expect(content.contains("context.go('/favorites')"), isFalse);
    });
  });
}
