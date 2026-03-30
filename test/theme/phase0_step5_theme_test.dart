import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

void main() {
  group('AppTheme.lightTheme (Surface Mode)', () {
    test('brightness is light', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
    });

    test('scaffold background is stone-50', () {
      expect(AppTheme.lightTheme.scaffoldBackgroundColor, AppColors.backgroundPrimary);
    });

    test('colorScheme primary is brand blue', () {
      expect(AppTheme.lightTheme.colorScheme.primary, AppColors.primary);
    });

    test('card theme uses white background', () {
      expect(AppTheme.lightTheme.cardTheme.color, AppColors.backgroundCard);
    });

    test('appBar background is stone-50', () {
      expect(AppTheme.lightTheme.appBarTheme.backgroundColor, AppColors.backgroundPrimary);
    });

    test('bottomNavigationBar uses brand blue for selected', () {
      expect(
        AppTheme.lightTheme.bottomNavigationBarTheme.selectedItemColor,
        AppColors.primary,
      );
    });

    test('tabBar indicator uses brand blue', () {
      expect(AppTheme.lightTheme.tabBarTheme.indicatorColor, AppColors.primary);
    });

    test('useMaterial3 is true', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
    });

    test('textTheme has all levels defined', () {
      final textTheme = AppTheme.lightTheme.textTheme;
      expect(textTheme.displayLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.labelSmall, isNotNull);
    });

    test('dialog/bottomSheet themes are configured', () {
      expect(AppTheme.lightTheme.dialogTheme.backgroundColor, AppColors.backgroundCard);
      expect(AppTheme.lightTheme.bottomSheetTheme.backgroundColor, AppColors.backgroundCard);
    });
  });

  group('AppTheme.darkTheme (Deep Mode)', () {
    test('brightness is dark', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('scaffold background is deep sea', () {
      expect(
        AppTheme.darkTheme.scaffoldBackgroundColor,
        AppColorsDark.backgroundPrimary,
      );
    });

    test('colorScheme primary is Stream Blue #58A6FF', () {
      expect(
        AppTheme.darkTheme.colorScheme.primary,
        AppColorsDark.accentPrimary,
      );
    });

    test('card uses dark background with border', () {
      expect(AppTheme.darkTheme.cardTheme.color, AppColorsDark.backgroundCard);
    });

    test('appBar uses dark background', () {
      expect(
        AppTheme.darkTheme.appBarTheme.backgroundColor,
        AppColorsDark.backgroundPrimary,
      );
    });

    test('bottomNavigationBar uses accent blue for selected', () {
      expect(
        AppTheme.darkTheme.bottomNavigationBarTheme.selectedItemColor,
        AppColorsDark.accentPrimary,
      );
    });

    test('input fill color uses elevated background', () {
      expect(
        AppTheme.darkTheme.inputDecorationTheme.fillColor,
        AppColorsDark.backgroundElevated,
      );
    });

    test('textTheme has dark mode colors', () {
      final textTheme = AppTheme.darkTheme.textTheme;
      expect(textTheme.displayLarge?.color, AppColorsDark.textPrimary);
      expect(textTheme.bodySmall?.color, AppColorsDark.textSecondary);
    });

    test('useMaterial3 is true', () {
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });
  });

  group('AppTheme - Default mode', () {
    test('defaultThemeMode is system', () {
      expect(AppTheme.defaultThemeMode, ThemeMode.system);
    });
  });
}
