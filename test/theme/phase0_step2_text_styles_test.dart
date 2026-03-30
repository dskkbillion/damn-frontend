import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_text_styles.dart';

void main() {
  group('AppTextStyles - Font families', () {
    test('heading font is HarmonyOS Sans SC', () {
      expect(AppTextStyles.headingFont, 'HarmonyOS Sans SC');
    });

    test('body font is PingFang SC', () {
      expect(AppTextStyles.bodyFont, 'PingFang SC');
    });

    test('mono font is JetBrains Mono', () {
      expect(AppTextStyles.monoFont, 'JetBrains Mono');
    });

    test('display styles use heading font', () {
      expect(AppTextStyles.displayLarge.fontFamily, AppTextStyles.headingFont);
      expect(AppTextStyles.displayMedium.fontFamily, AppTextStyles.headingFont);
      expect(AppTextStyles.displaySmall.fontFamily, AppTextStyles.headingFont);
    });

    test('headline styles use heading font', () {
      expect(AppTextStyles.headlineLarge.fontFamily, AppTextStyles.headingFont);
      expect(AppTextStyles.headlineMedium.fontFamily, AppTextStyles.headingFont);
      expect(AppTextStyles.headlineSmall.fontFamily, AppTextStyles.headingFont);
    });

    test('body styles use body font', () {
      expect(AppTextStyles.bodyLarge.fontFamily, AppTextStyles.bodyFont);
      expect(AppTextStyles.bodyMedium.fontFamily, AppTextStyles.bodyFont);
      expect(AppTextStyles.bodySmall.fontFamily, AppTextStyles.bodyFont);
    });

    test('price styles use mono font', () {
      expect(AppTextStyles.priceLarge.fontFamily, AppTextStyles.monoFont);
      expect(AppTextStyles.priceMedium.fontFamily, AppTextStyles.monoFont);
      expect(AppTextStyles.priceSmall.fontFamily, AppTextStyles.monoFont);
    });
  });

  group('AppTextStyles - Font sizes', () {
    test('displayLarge is 28px Bold', () {
      expect(AppTextStyles.displayLarge.fontSize, 28.0);
      expect(AppTextStyles.displayLarge.fontWeight, FontWeight.bold);
    });

    test('displayMedium is 24px Bold', () {
      expect(AppTextStyles.displayMedium.fontSize, 24.0);
      expect(AppTextStyles.displayMedium.fontWeight, FontWeight.bold);
    });

    test('displaySmall is 20px Bold', () {
      expect(AppTextStyles.displaySmall.fontSize, 20.0);
      expect(AppTextStyles.displaySmall.fontWeight, FontWeight.bold);
    });

    test('bodyMedium is 14px Regular', () {
      expect(AppTextStyles.bodyMedium.fontSize, 14.0);
      expect(AppTextStyles.bodyMedium.fontWeight, FontWeight.w400);
    });

    test('labelSmall is 10px Medium', () {
      expect(AppTextStyles.labelSmall.fontSize, 10.0);
      expect(AppTextStyles.labelSmall.fontWeight, FontWeight.w500);
    });

    test('priceLarge is 24px Bold mono', () {
      expect(AppTextStyles.priceLarge.fontSize, 24.0);
      expect(AppTextStyles.priceLarge.fontWeight, FontWeight.bold);
      expect(AppTextStyles.priceLarge.fontFamily, AppTextStyles.monoFont);
    });

    test('priceMedium is 16px SemiBold mono', () {
      expect(AppTextStyles.priceMedium.fontSize, 16.0);
      expect(AppTextStyles.priceMedium.fontWeight, FontWeight.w600);
      expect(AppTextStyles.priceMedium.fontFamily, AppTextStyles.monoFont);
    });
  });

  group('AppTextStyles - All fields non-null', () {
    test('all style getters return non-null TextStyle', () {
      final styles = [
        AppTextStyles.displayLarge,
        AppTextStyles.displayMedium,
        AppTextStyles.displaySmall,
        AppTextStyles.headlineLarge,
        AppTextStyles.headlineMedium,
        AppTextStyles.headlineSmall,
        AppTextStyles.titleLarge,
        AppTextStyles.titleMedium,
        AppTextStyles.titleSmall,
        AppTextStyles.bodyLarge,
        AppTextStyles.bodyMedium,
        AppTextStyles.bodySmall,
        AppTextStyles.labelLarge,
        AppTextStyles.labelMedium,
        AppTextStyles.labelSmall,
        AppTextStyles.priceLarge,
        AppTextStyles.priceMedium,
        AppTextStyles.priceSmall,
        AppTextStyles.button,
        AppTextStyles.link,
        AppTextStyles.emphasis,
        AppTextStyles.disabled,
      ];
      for (final style in styles) {
        expect(style, isNotNull);
        expect(style.fontSize, isNotNull);
        expect(style.fontWeight, isNotNull);
        expect(style.fontFamily, isNotNull);
      }
    });
  });
}
