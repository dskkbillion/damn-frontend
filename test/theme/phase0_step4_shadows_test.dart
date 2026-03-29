import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_shadows.dart';

void main() {
  group('AppShadows (Light Mode)', () {
    test('sm/md/lg shadow alpha increases with depth', () {
      final smAlpha = AppShadows.sm.first.color.a;
      final mdAlpha = AppShadows.md.first.color.a;
      final lgAlpha = AppShadows.lg.first.color.a;
      expect(mdAlpha, greaterThan(smAlpha));
      expect(lgAlpha, greaterThanOrEqualTo(mdAlpha));
    });

    test('focus shadow uses brand blue (0x0369A1), not old orange', () {
      final focusColor = AppShadows.focus.first.color;
      // Should NOT contain old orange 0xB66D0E
      expect(focusColor, isNot(const Color(0x33B66D0E)));
      // Should use brand blue base
      expect(focusColor, const Color(0x330369A1));
    });

    test('glow shadow uses brand blue', () {
      expect(AppShadows.glow.isNotEmpty, isTrue);
      final glowColor = AppShadows.glow.first.color;
      expect(glowColor, const Color(0x400369A1));
    });

    test('no old brand orange color (0xB66D0E) in any shadow', () {
      final allShadows = [
        ...AppShadows.sm,
        ...AppShadows.md,
        ...AppShadows.lg,
        ...AppShadows.xl,
        ...AppShadows.focus,
        ...AppShadows.glow,
        ...AppShadows.error,
        ...AppShadows.success,
        ...AppShadows.warning,
      ];
      for (final shadow in allShadows) {
        // Extract RGB (ignore alpha) and check it's not old orange
        final rgb = shadow.color.value & 0x00FFFFFF;
        expect(rgb, isNot(0xB66D0E),
            reason: 'Found old brand orange in shadow');
      }
    });

    test('error shadow uses rose-600 base', () {
      final errorColor = AppShadows.error.first.color;
      expect(errorColor, const Color(0x1AE11D48));
    });

    test('success shadow uses emerald-600 base', () {
      final successColor = AppShadows.success.first.color;
      expect(successColor, const Color(0x1A059669));
    });
  });

  group('AppShadowsDark (Dark Mode)', () {
    test('glow shadow uses accentPrimary #58A6FF', () {
      expect(AppShadowsDark.glow.isNotEmpty, isTrue);
      final glowColor = AppShadowsDark.glow.first.color;
      expect(glowColor, const Color(0x4058A6FF));
    });

    test('focus shadow uses accentPrimary', () {
      final focusColor = AppShadowsDark.focus.first.color;
      expect(focusColor, const Color(0x4058A6FF));
    });

    test('sm/md/lg are defined', () {
      expect(AppShadowsDark.sm.isNotEmpty, isTrue);
      expect(AppShadowsDark.md.isNotEmpty, isTrue);
      expect(AppShadowsDark.lg.isNotEmpty, isTrue);
    });

    test('none is empty', () {
      expect(AppShadowsDark.none, isEmpty);
    });
  });
}
