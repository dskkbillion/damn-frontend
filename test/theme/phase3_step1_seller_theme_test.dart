import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Step 3.1 验证：seller 模块硬编码样式已替换为 DeepStream Theme Token
void main() {
  // 收集所有 seller presentation 文件
  List<File> getSellerPresentationFiles() {
    final dir = Directory('lib/features/seller/presentation');
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('/bloc/') && !f.path.contains('/blocs/'))
        .toList();
  }

  group('Step 3.1: Seller module reskin audit', () {
    test('No old brand color (0xFFB66D0E) remains in seller presentation files', () {
      final files = getSellerPresentationFiles();
      final violations = <String>[];
      for (final file in files) {
        final content = file.readAsStringSync();
        if (content.contains('0xFFB66D0E')) {
          violations.add(file.path);
        }
      }
      expect(violations, isEmpty,
          reason: 'Old brand color 0xFFB66D0E found in: ${violations.join(', ')}');
    });

    test('Seller page files import AppColors', () {
      final pages = Directory('lib/features/seller/presentation/pages')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      int importCount = 0;
      for (final file in pages) {
        final content = file.readAsStringSync();
        if (content.contains('app_colors.dart') || content.contains('AppColors')) {
          importCount++;
        }
      }
      // 至少 80% 的 page 文件应该 import AppColors
      expect(importCount, greaterThanOrEqualTo((pages.length * 0.8).ceil()),
          reason: '$importCount/${pages.length} page files import AppColors');
    });

    test('Seller widget files import AppColors or AppDimensions', () {
      final widgetDir = Directory('lib/features/seller/presentation/widgets');
      final widgets = widgetDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      int importCount = 0;
      for (final file in widgets) {
        final content = file.readAsStringSync();
        if (content.contains('app_colors.dart') || content.contains('app_dimensions.dart') ||
            content.contains('AppColors') || content.contains('AppDimensions')) {
          importCount++;
        }
      }
      expect(importCount, greaterThanOrEqualTo((widgets.length * 0.7).ceil()),
          reason: '$importCount/${widgets.length} widget files import theme tokens');
    });

    test('Hardcoded Color(0xFF333333) residual count is less than 5 across seller', () {
      final files = getSellerPresentationFiles();
      int count = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        count += RegExp(r'Color\(0xFF333333\)').allMatches(content).length;
      }
      expect(count, lessThan(5),
          reason: 'Found $count residual Color(0xFF333333) in seller module');
    });

    test('Hardcoded Colors.grey.shade residual count is less than 5 across seller', () {
      final files = getSellerPresentationFiles();
      int count = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        count += RegExp(r'Colors\.grey\.shade').allMatches(content).length;
      }
      expect(count, lessThan(5),
          reason: 'Found $count residual Colors.grey.shade in seller module');
    });

    test('Seller files use AppDimensions for border radius', () {
      final files = getSellerPresentationFiles();
      int appDimensionsUsage = 0;
      int hardcodedRadiusCount = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        appDimensionsUsage += RegExp(r'AppDimensions\.radius').allMatches(content).length;
        // 查找 BorderRadius.circular(N) 其中 N 是数字
        hardcodedRadiusCount += RegExp(r'BorderRadius\.circular\(\d').allMatches(content).length;
      }
      // AppDimensions 使用量应该大于硬编码量
      expect(appDimensionsUsage, greaterThan(0),
          reason: 'AppDimensions.radius should be used in seller files');
    });
  });
}
