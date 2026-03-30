import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

void main() {
  group('AppDimensions - Border Radius (DeepStream)', () {
    test('radiusSm is 6px', () {
      expect(AppDimensions.radiusSm, 6.0);
    });

    test('radiusMd is 10px', () {
      expect(AppDimensions.radiusMd, 10.0);
    });

    test('radiusLg is 14px', () {
      expect(AppDimensions.radiusLg, 14.0);
    });

    test('radiusXl is 20px', () {
      expect(AppDimensions.radiusXl, 20.0);
    });

    test('radiusPill is 999px', () {
      expect(AppDimensions.radiusPill, 999.0);
    });

    test('radiusNone is 0', () {
      expect(AppDimensions.radiusNone, 0.0);
    });

    test('radiusCircle is 999px', () {
      expect(AppDimensions.radiusCircle, 999.0);
    });
  });

  group('AppDimensions - Animation Durations', () {
    test('animationStandard is 300ms', () {
      expect(AppDimensions.animationStandard, const Duration(milliseconds: 300));
    });

    test('animationFast is 150ms', () {
      expect(AppDimensions.animationFast, const Duration(milliseconds: 150));
    });

    test('animationSlow is 400ms', () {
      expect(AppDimensions.animationSlow, const Duration(milliseconds: 400));
    });
  });

  group('AppDimensions - Spacing (4px base, unchanged)', () {
    test('spacing follows 4px base grid', () {
      expect(AppDimensions.spacingXs, 4.0);
      expect(AppDimensions.spacingSm, 8.0);
      expect(AppDimensions.spacingMd, 12.0);
      expect(AppDimensions.spacingLg, 16.0);
      expect(AppDimensions.spacingXl, 20.0);
      expect(AppDimensions.spacingXxl, 24.0);
      expect(AppDimensions.spacingXxxl, 32.0);
      expect(AppDimensions.spacingXxxxl, 48.0);
    });
  });
}
