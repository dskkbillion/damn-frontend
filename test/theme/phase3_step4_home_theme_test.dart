import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Step 3.4 验证：home 模块硬编码样式已替换为 DeepStream Theme Token
void main() {
  List<File> getHomePresentationFiles() {
    final dir = Directory('lib/features/home/presentation');
    return dir.listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('/bloc/') && !f.path.contains('/cubit/'))
        .where((f) => !f.path.contains('/navigation/') && !f.path.contains('/routes/'))
        .toList();
  }

  group('Step 3.4: Home module reskin audit', () {
    test('No old brand color (0xFFB66D0E) remains', () {
      final files = getHomePresentationFiles();
      final violations = <String>[];
      for (final file in files) {
        if (file.readAsStringSync().contains('0xFFB66D0E')) violations.add(file.path);
      }
      expect(violations, isEmpty, reason: 'Old brand color found in: ${violations.join(', ')}');
    });

    test('Page files import AppColors', () {
      final pages = Directory('lib/features/home/presentation/pages').listSync()
          .whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
      int count = 0;
      for (final f in pages) {
        if (f.readAsStringSync().contains('AppColors')) count++;
      }
      expect(count, greaterThanOrEqualTo((pages.length * 0.7).ceil()));
    });

    test('Widget files import theme tokens', () {
      final widgets = Directory('lib/features/home/presentation/widgets').listSync(recursive: true)
          .whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
      int count = 0;
      for (final f in widgets) {
        final c = f.readAsStringSync();
        if (c.contains('AppColors') || c.contains('AppDimensions')) count++;
      }
      expect(count, greaterThanOrEqualTo((widgets.length * 0.7).ceil()));
    });

    test('Color(0xFF333333) residual < 5', () {
      final files = getHomePresentationFiles();
      int count = 0;
      for (final f in files) count += RegExp(r'Color\(0xFF333333\)').allMatches(f.readAsStringSync()).length;
      expect(count, lessThan(5));
    });

    test('Colors.grey.shade residual < 5', () {
      final files = getHomePresentationFiles();
      int count = 0;
      for (final f in files) count += RegExp(r'Colors\.grey\.shade').allMatches(f.readAsStringSync()).length;
      expect(count, lessThan(5));
    });

    test('AppDimensions.radius is used', () {
      final files = getHomePresentationFiles();
      int count = 0;
      for (final f in files) count += RegExp(r'AppDimensions\.radius').allMatches(f.readAsStringSync()).length;
      expect(count, greaterThan(0));
    });
  });
}
