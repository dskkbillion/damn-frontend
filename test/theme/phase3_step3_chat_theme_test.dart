import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Step 3.3 验证：chat 模块硬编码样式已替换为 DeepStream Theme Token
void main() {
  // 收集所有 chat presentation 文件（排除 bloc/cubit）
  List<File> getChatPresentationFiles() {
    final dir = Directory('lib/features/chat/presentation');
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) =>
            !f.path.contains('/bloc/') &&
            !f.path.contains('/blocs/') &&
            !f.path.contains('/cubit/'))
        .toList();
  }

  group('Step 3.3: Chat module reskin audit', () {
    test('No old brand color (0xFFB66D0E) remains in chat presentation files', () {
      final files = getChatPresentationFiles();
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

    test('Chat page files import AppColors', () {
      final pages = Directory('lib/features/chat/presentation/pages')
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

    test('Chat widget files import AppColors or AppDimensions', () {
      final widgetDir = Directory('lib/features/chat/presentation/widgets');
      final widgets = widgetDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      int importCount = 0;
      for (final file in widgets) {
        final content = file.readAsStringSync();
        if (content.contains('app_colors.dart') ||
            content.contains('app_dimensions.dart') ||
            content.contains('AppColors') ||
            content.contains('AppDimensions')) {
          importCount++;
        }
      }
      expect(importCount, greaterThanOrEqualTo((widgets.length * 0.7).ceil()),
          reason: '$importCount/${widgets.length} widget files import theme tokens');
    });

    test('Hardcoded Colors.grey.shade residual count is less than 5 across chat', () {
      final files = getChatPresentationFiles();
      int count = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        count += RegExp(r'Colors\.grey\.shade').allMatches(content).length;
      }
      expect(count, lessThan(5),
          reason: 'Found $count residual Colors.grey.shade in chat module');
    });

    test('Chat files use AppDimensions for border radius', () {
      final files = getChatPresentationFiles();
      int appDimensionsUsage = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        appDimensionsUsage += RegExp(r'AppDimensions\.radius').allMatches(content).length;
      }
      expect(appDimensionsUsage, greaterThan(0),
          reason: 'AppDimensions.radius should be used in chat files');
    });

    test('Hardcoded Colors.red residual count is less than 5 across chat', () {
      final files = getChatPresentationFiles();
      int count = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        // Allow Colors.red in comments, but not as actual color values
        count += RegExp(r'(?<!\/\/.*)Colors\.red[^_]').allMatches(content).length;
      }
      expect(count, lessThan(5),
          reason: 'Found $count residual Colors.red in chat module');
    });

    test('Hardcoded Colors.blue residual count is less than 5 across chat', () {
      final files = getChatPresentationFiles();
      int count = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        count += RegExp(r'(?<!\/\/.*)Colors\.blue[^_]').allMatches(content).length;
      }
      expect(count, lessThan(5),
          reason: 'Found $count residual Colors.blue in chat module');
    });

    test('Hardcoded Colors.green residual count is less than 5 across chat', () {
      final files = getChatPresentationFiles();
      int count = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        count += RegExp(r'(?<!\/\/.*)Colors\.green[^_]').allMatches(content).length;
      }
      expect(count, lessThan(5),
          reason: 'Found $count residual Colors.green in chat module');
    });
  });
}
