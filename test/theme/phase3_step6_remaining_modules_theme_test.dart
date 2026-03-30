import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Step 3.6 验证：剩余模块硬编码样式已替换为 DeepStream Theme Token
void main() {
  List<File> getPresentationFiles(String module) {
    final dir = Directory('lib/features/$module/presentation');
    if (!dir.existsSync()) return [];
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('/bloc/') && !f.path.contains('/cubit/'))
        .where((f) => !f.path.contains('/routes/'))
        .toList();
  }

  final modules = ['ai_docs', 'payment', 'auth', 'favorites', 'after_sales'];

  group('Step 3.6: Remaining modules reskin audit', () {
    test('No old brand color (0xFFB66D0E) remains across all modules', () {
      final violations = <String>[];
      for (final mod in modules) {
        for (final file in getPresentationFiles(mod)) {
          if (file.readAsStringSync().contains('0xFFB66D0E')) {
            violations.add(file.path);
          }
        }
      }
      expect(violations, isEmpty,
          reason: 'Old brand color found in: ${violations.join(', ')}');
    });

    test('Majority of files import AppColors or AppDimensions', () {
      int total = 0;
      int withTokens = 0;
      for (final mod in modules) {
        for (final file in getPresentationFiles(mod)) {
          total++;
          final c = file.readAsStringSync();
          if (c.contains('AppColors') || c.contains('AppDimensions')) {
            withTokens++;
          }
        }
      }
      expect(withTokens, greaterThanOrEqualTo((total * 0.5).ceil()),
          reason: '$withTokens/$total files import theme tokens');
    });

    test('Color(0xFF333333) residual < 10 across all modules', () {
      int count = 0;
      for (final mod in modules) {
        for (final file in getPresentationFiles(mod)) {
          count += RegExp(r'Color\(0xFF333333\)').allMatches(file.readAsStringSync()).length;
        }
      }
      expect(count, lessThan(10),
          reason: 'Found $count residual Color(0xFF333333)');
    });

    test('Colors.grey.shade residual < 10 across all modules', () {
      int count = 0;
      for (final mod in modules) {
        for (final file in getPresentationFiles(mod)) {
          count += RegExp(r'Colors\.grey\.shade').allMatches(file.readAsStringSync()).length;
        }
      }
      expect(count, lessThan(10),
          reason: 'Found $count residual Colors.grey.shade');
    });
  });
}
