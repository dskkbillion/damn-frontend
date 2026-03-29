import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/animations/deepstream_page_transition.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// Step 1.3 验证：DeepStream 统一转场动画组件
///
/// 验证：
/// - DeepStreamPageTransition 的 transitionDuration 为 300ms
/// - DeepStreamPageTransition 的 transitionsBuilder 不为 null
/// - DeepStreamNoTransitionPage 可正常实例化
/// - DeepStreamPageTransition 的 child 参数可以正常传递
void main() {
  group('Step 1.3: DeepStream page transition components', () {
    test('DeepStreamPageTransition transitionDuration equals animationStandard (300ms)', () {
      final page = DeepStreamPageTransition(
        child: const SizedBox(),
      );

      expect(page.transitionDuration, equals(AppDimensions.animationStandard));
      expect(page.transitionDuration, equals(const Duration(milliseconds: 300)));
    });

    test('DeepStreamPageTransition reverseTransitionDuration equals animationStandard (300ms)', () {
      final page = DeepStreamPageTransition(
        child: const SizedBox(),
      );

      expect(page.reverseTransitionDuration, equals(AppDimensions.animationStandard));
      expect(page.reverseTransitionDuration, equals(const Duration(milliseconds: 300)));
    });

    test('DeepStreamPageTransition transitionsBuilder is not null', () {
      final page = DeepStreamPageTransition(
        child: const SizedBox(),
      );

      expect(page.transitionsBuilder, isNotNull);
    });

    test('DeepStreamPageTransition child is passed correctly', () {
      const childWidget = Text('test child');
      final page = DeepStreamPageTransition(
        child: childWidget,
      );

      expect(page.child, equals(childWidget));
    });

    test('DeepStreamNoTransitionPage can be instantiated', () {
      const page = DeepStreamNoTransitionPage(
        child: SizedBox(),
      );

      expect(page, isNotNull);
    });

    test('DeepStreamNoTransitionPage child is passed correctly', () {
      const childWidget = Text('no transition child');
      const page = DeepStreamNoTransitionPage(
        child: childWidget,
      );

      expect(page.child, equals(childWidget));
    });
  });
}
