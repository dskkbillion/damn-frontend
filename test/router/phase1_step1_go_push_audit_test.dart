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
  // 合法 go() 场景（参考）：登出清栈 /login；Tab 切换 /home /chat /profile
  // /ai-docs /ai_chat /dev /dev_menu；canPop 兜底 /seller /orders；
  // 支付清栈 /profile/orders?status=...；跨 Shell /chat/refactored（#349）。

  group('Step 1.1: go() → push() audit', () {
    test('profile_page.dart has no go() calls except logout', () {
      final file = File('lib/features/profile/presentation/pages/profile_page.dart');
      final content = file.readAsStringSync();
      final goMatches = RegExp(r'context\.go\(').allMatches(content);

      // 只允许 1 处 go: 登出到已注册的 AuthRoutes.loginPath
      for (final match in goMatches) {
        final lineStart = content.lastIndexOf('\n', match.start) + 1;
        final lineEnd = content.indexOf('\n', match.end);
        final line = content.substring(lineStart, lineEnd).trim();
        // Skip commented-out lines
        if (line.startsWith('//')) continue;
        expect(
          line.contains('AuthRoutes.loginPath'),
          isTrue,
          reason: 'profile_page.dart has go() not for logout: $line',
        );
      }
    });

    test('logout redirects use the registered login route', () {
      for (final path in [
        'lib/features/profile/presentation/pages/profile_page.dart',
        'lib/features/profile/presentation/pages/account_security_page.dart',
      ]) {
        final content = File(path).readAsStringSync();
        expect(
          content.contains("context.go('/auth/login')"),
          isFalse,
          reason: '$path uses an unregistered /auth/login route',
        );
        expect(
          content.contains('AuthRoutes.loginPath'),
          isTrue,
          reason: '$path should redirect through AuthRoutes.loginPath',
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
      // 路径已去 /home 前缀（reviews 走 /product/$id/reviews），仍是 push（子页面递进）
      expect(content.contains("context.push('/product/\$productId/reviews')"), isTrue);
      expect(content.contains("context.go('/product/\$productId/reviews')"), isFalse);
    });

    test('product_detail_page.dart uses push() for reviews', () {
      final file = File('lib/features/home/presentation/pages/product_detail_page.dart');
      final content = file.readAsStringSync();
      expect(content.contains("context.push('/product/\$productId/reviews')"), isTrue);
      expect(content.contains("context.go('/product/\$productId/reviews')"), isFalse);
    });

    test('seller_public_profile_page.dart uses push() for product detail', () {
      final file = File('lib/features/home/presentation/pages/seller_public_profile_page.dart');
      final content = file.readAsStringSync();
      expect(content.contains("context.push('/product/\${product.id}')"), isTrue);
      expect(content.contains("context.go('/product/\${product.id}')"), isFalse);
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

    test('seller order widgets use go() for cross-Shell chat navigation', () {
      // #349: /chat/refactored 是跨 Shell 路由，从 seller Shell 跳 chat 必须用 go()
      // （push 跨 Shell 会出问题）。买家侧 notification/global_message 同样用 go()。
      final file1 = File('lib/features/orders/presentation/seller/widgets/seller_order_item_card_action_buttons.dart');
      final file2 = File('lib/features/orders/presentation/seller/widgets/seller_order_detail_actions.dart');
      final content1 = file1.readAsStringSync();
      final content2 = file2.readAsStringSync();

      expect(content1.contains("context.go('/chat/refactored/\${room.id}')"), isTrue);
      expect(content2.contains("context.go('/chat/refactored/\${room.id}')"), isTrue);
    });

    test('payment_navigation_service.dart uses push() for orderDetail', () {
      final file = File('lib/core/payment/services/payment_navigation_service.dart');
      final content = file.readAsStringSync();

      // orderDetail should be push (user may want to go back)
      final orderDetailGoPattern = RegExp(r"context\.go\('/orderDetail/");
      expect(orderDetailGoPattern.hasMatch(content), isFalse,
          reason: 'orderDetail navigation should use push(), not go()');

      // orders list go is OK (payment clear-stack)；路径现为 /profile/orders
      final ordersGoPattern = RegExp(r"context\.go\('/profile/orders");
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
