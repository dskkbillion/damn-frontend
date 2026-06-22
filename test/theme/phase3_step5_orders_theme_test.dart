import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Step 3.5 验证：orders 模块硬编码样式已替换为 DeepStream Theme Token
void main() {
  List<File> getOrdersPresentationFiles() {
    final dir = Directory('lib/features/orders/presentation');
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('/bloc/') && !f.path.contains('/cubit/'))
        .where((f) => !f.path.contains('/routes/'))
        .toList();
  }

  group('Step 3.5: Orders module reskin audit', () {
    test('No old brand color (0xFFB66D0E) remains', () {
      final files = getOrdersPresentationFiles();
      final violations = <String>[];
      for (final file in files) {
        if (file.readAsStringSync().contains('0xFFB66D0E')) {
          violations.add(file.path);
        }
      }
      expect(violations, isEmpty,
          reason: 'Old brand color found in: ${violations.join(', ')}');
    });

    test('Majority of page/widget files use theme tokens', () {
      // 主题化既可走 AppColors 静态类，也可走 Flutter 标准 Theme.of(context)/colorScheme。
      // orders 模块实际以 Theme.of/colorScheme 为主，故口径取两者并集。
      final files = getOrdersPresentationFiles()
          .where((f) => f.path.contains('/pages/') || f.path.contains('/widgets/'))
          .toList();
      int count = 0;
      for (final f in files) {
        final c = f.readAsStringSync();
        if (c.contains('AppColors') ||
            c.contains('Theme.of(context)') ||
            c.contains('colorScheme')) {
          count++;
        }
      }
      expect(count, greaterThanOrEqualTo((files.length * 0.6).ceil()),
          reason: '$count/${files.length} files use theme tokens (AppColors/Theme.of/colorScheme)');
    });

    test('Color(0xFF333333) residual < 5', () {
      final files = getOrdersPresentationFiles();
      int count = 0;
      for (final f in files) {
        count += RegExp(r'Color\(0xFF333333\)').allMatches(f.readAsStringSync()).length;
      }
      expect(count, lessThan(5),
          reason: 'Found $count residual Color(0xFF333333)');
    });

    test('Colors.grey.shade residual < 5', () {
      final files = getOrdersPresentationFiles();
      int count = 0;
      for (final f in files) {
        count += RegExp(r'Colors\.grey\.shade').allMatches(f.readAsStringSync()).length;
      }
      expect(count, lessThan(5),
          reason: 'Found $count residual Colors.grey.shade');
    });

    test('AppDimensions.radius is used', () {
      final files = getOrdersPresentationFiles();
      int count = 0;
      for (final f in files) {
        count += RegExp(r'AppDimensions\.radius').allMatches(f.readAsStringSync()).length;
      }
      expect(count, greaterThan(0),
          reason: 'AppDimensions.radius should be used');
    });
  });
}
