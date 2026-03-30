import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Step 1.5 验证：路由遗留代码清理
///
/// 验证：
/// - app_router.dart.new 临时文件已被删除
/// - /seller/orders 路径在 app_router.dart 中只有一个 GoRoute 定义（无重复）
/// - OrderRoutes 中的 /seller/orders 从未被注册到主路由（只拉取 :orderId 子路由）
void main() {
  group('Step 1.5: Route cleanup verification', () {
    test('app_router.dart.new temporary file does not exist', () {
      final file = File(
        '${Directory.current.path}/lib/app/navigation/app_router.dart.new',
      );
      expect(
        file.existsSync(),
        isFalse,
        reason: 'app_router.dart.new is a temporary file and should have been deleted',
      );
    });

    test('/seller/orders GoRoute defined exactly once in app_router.dart', () {
      final file = File(
        '${Directory.current.path}/lib/app/navigation/app_router.dart',
      );
      expect(file.existsSync(), isTrue, reason: 'app_router.dart must exist');

      final content = file.readAsStringSync();

      // Count GoRoute definitions with path: '/seller/orders'
      // Match lines like: path: '/seller/orders',
      final pattern = RegExp(r"path:\s*'/seller/orders'");
      final matches = pattern.allMatches(content).toList();

      expect(
        matches.length,
        equals(1),
        reason:
            'Expected exactly 1 GoRoute definition for /seller/orders in app_router.dart, '
            'found ${matches.length}. Duplicate definitions cause runtime conflicts.',
      );
    });

    test('app_router.dart does not pull /seller/orders list route from OrderRoutes', () {
      final file = File(
        '${Directory.current.path}/lib/app/navigation/app_router.dart',
      );
      final content = file.readAsStringSync();

      // The only OrderRoutes.routes.firstWhere for seller orders should be the detail route
      final sellerOrdersListPull = RegExp(
        r"OrderRoutes\.routes\.firstWhere.*path.*==.*'/seller/orders'[^/]",
      );
      expect(
        sellerOrdersListPull.hasMatch(content),
        isFalse,
        reason:
            'app_router.dart should not pull the /seller/orders list route from OrderRoutes '
            '(it defines its own). Only the :orderId detail route should be pulled.',
      );
    });

    test('app_router.dart pulls /seller/orders/:orderId detail route from OrderRoutes', () {
      final file = File(
        '${Directory.current.path}/lib/app/navigation/app_router.dart',
      );
      final content = file.readAsStringSync();

      // Verify the detail route IS pulled from OrderRoutes (correct pattern)
      final sellerOrderDetailPull = RegExp(
        r"OrderRoutes\.routes\.firstWhere.*path.*==.*'/seller/orders/:orderId'",
      );
      expect(
        sellerOrderDetailPull.hasMatch(content),
        isTrue,
        reason:
            'app_router.dart should pull the /seller/orders/:orderId detail route from OrderRoutes',
      );
    });
  });
}
