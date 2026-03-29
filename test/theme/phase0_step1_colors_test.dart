import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

void main() {
  group('AppColors (Light Mode - Surface Mode)', () {
    test('primary is sky-700 brand blue', () {
      expect(AppColors.primary, const Color(0xFF0369A1));
    });

    test('primaryVariant is sky-600', () {
      expect(AppColors.primaryVariant, const Color(0xFF0284C7));
    });

    test('primaryLight is sky-400', () {
      expect(AppColors.primaryLight, const Color(0xFF38BDF8));
    });

    test('primaryDark is sky-800', () {
      expect(AppColors.primaryDark, const Color(0xFF075985));
    });

    test('text colors use slate palette', () {
      expect(AppColors.textPrimary, const Color(0xFF1E293B)); // slate-800
      expect(AppColors.textSecondary, const Color(0xFF64748B)); // slate-500
      expect(AppColors.textTertiary, const Color(0xFF94A3B8)); // slate-400
      expect(AppColors.textDisabled, const Color(0xFFCBD5E1)); // slate-300
    });

    test('background colors use stone palette', () {
      expect(AppColors.backgroundPrimary, const Color(0xFFFAFAF9)); // stone-50
      expect(AppColors.backgroundSecondary, const Color(0xFFF5F5F4)); // stone-100
      expect(AppColors.backgroundCard, const Color(0xFFFFFFFF)); // white
    });

    test('functional colors are correct', () {
      expect(AppColors.error, const Color(0xFFE11D48)); // rose-600
      expect(AppColors.success, const Color(0xFF059669)); // emerald-600
      expect(AppColors.warning, const Color(0xFFF59E0B)); // amber-500
      expect(AppColors.info, const Color(0xFF0EA5E9)); // sky-500
    });

    test('border colors use slate palette', () {
      expect(AppColors.borderPrimary, const Color(0xFFE2E8F0));
      expect(AppColors.borderInputFocus, AppColors.primary);
    });

    test('node colors are defined', () {
      expect(AppColors.nodeHuman, const Color(0xFF7C3AED));
      expect(AppColors.nodeAgent, const Color(0xFF0369A1));
      expect(AppColors.nodeActive, const Color(0xFF15803D));
      expect(AppColors.nodeIdle, const Color(0xFF94A3B8));
    });

    test('accent colors are defined', () {
      expect(AppColors.accentLight, const Color(0xFF38BDF8));
      expect(AppColors.accentDark, const Color(0xFF075985));
      expect(AppColors.accentGlow, const Color(0xFF7DD3FC));
    });

    test('gradient stream has correct start and end colors', () {
      expect(AppColors.gradientStream.colors.first, const Color(0xFF0369A1));
      expect(AppColors.gradientStream.colors.last, const Color(0xFF38BDF8));
    });

    test('grey map has all 10 levels', () {
      expect(AppColors.grey.length, 10);
      expect(AppColors.grey[50], isNotNull);
      expect(AppColors.grey[900], isNotNull);
    });

    test('no old orange brand color remains', () {
      // Old brand orange was 0xFFB66D0E
      const oldOrange = Color(0xFFB66D0E);
      expect(AppColors.primary, isNot(oldOrange));
      expect(AppColors.primaryVariant, isNot(oldOrange));
      expect(AppColors.primaryLight, isNot(oldOrange));
      expect(AppColors.primaryDark, isNot(oldOrange));
    });

    test('all token fields are non-null', () {
      // Exhaustive check that all static consts resolve
      final fields = <Color>[
        AppColors.primary,
        AppColors.primaryVariant,
        AppColors.primaryLight,
        AppColors.primaryDark,
        AppColors.error,
        AppColors.success,
        AppColors.warning,
        AppColors.info,
        AppColors.textPrimary,
        AppColors.textSecondary,
        AppColors.textTertiary,
        AppColors.textDisabled,
        AppColors.textLink,
        AppColors.backgroundPrimary,
        AppColors.backgroundSecondary,
        AppColors.backgroundTertiary,
        AppColors.backgroundCard,
        AppColors.backgroundHover,
        AppColors.borderPrimary,
        AppColors.borderSecondary,
        AppColors.borderInput,
        AppColors.borderInputFocus,
        AppColors.divider,
        AppColors.overlay,
        AppColors.overlayDisabled,
        AppColors.statusOnline,
        AppColors.statusOffline,
        AppColors.statusBusy,
        AppColors.statusDoNotDisturb,
        AppColors.accentLight,
        AppColors.accentDark,
        AppColors.accentGlow,
        AppColors.nodeHuman,
        AppColors.nodeAgent,
        AppColors.nodeActive,
        AppColors.nodeIdle,
      ];
      for (final color in fields) {
        expect(color, isNotNull);
      }
    });
  });

  group('AppColorsDark (Dark Mode - Deep Mode)', () {
    test('accent primary is Stream Blue #58A6FF', () {
      expect(AppColorsDark.accentPrimary, const Color(0xFF58A6FF));
    });

    test('background uses deep sea palette', () {
      expect(AppColorsDark.backgroundDeep, const Color(0xFF0A0E14));
      expect(AppColorsDark.backgroundPrimary, const Color(0xFF0F1419));
      expect(AppColorsDark.backgroundCard, const Color(0xFF151B23));
      expect(AppColorsDark.backgroundElevated, const Color(0xFF1A222C));
      expect(AppColorsDark.backgroundHover, const Color(0xFF1F2937));
    });

    test('text colors are light for dark backgrounds', () {
      expect(AppColorsDark.textPrimary, const Color(0xFFE6EDF3));
      expect(AppColorsDark.textSecondary, const Color(0xFF8B949E));
      expect(AppColorsDark.textTertiary, const Color(0xFF484F58));
    });

    test('functional colors are vivid for dark mode', () {
      expect(AppColorsDark.error, const Color(0xFFF85149));
      expect(AppColorsDark.success, const Color(0xFF3FB950));
      expect(AppColorsDark.warning, const Color(0xFFD29922));
      expect(AppColorsDark.info, const Color(0xFF58A6FF));
    });

    test('borders are subtle for dark mode', () {
      expect(AppColorsDark.borderPrimary, const Color(0xFF21262D));
      expect(AppColorsDark.borderSecondary, const Color(0xFF30363D));
    });

    test('gradient stream has correct colors for dark mode', () {
      expect(AppColorsDark.gradientStream.colors.first, const Color(0xFF1F6FEB));
      expect(AppColorsDark.gradientStream.colors.last, const Color(0xFF58A6FF));
    });

    test('all dark mode token fields are non-null', () {
      final fields = <Color>[
        AppColorsDark.accentPrimary,
        AppColorsDark.accentLight,
        AppColorsDark.accentDark,
        AppColorsDark.backgroundDeep,
        AppColorsDark.backgroundPrimary,
        AppColorsDark.backgroundCard,
        AppColorsDark.backgroundElevated,
        AppColorsDark.backgroundHover,
        AppColorsDark.textPrimary,
        AppColorsDark.textSecondary,
        AppColorsDark.textTertiary,
        AppColorsDark.textDisabled,
        AppColorsDark.borderPrimary,
        AppColorsDark.borderSecondary,
        AppColorsDark.borderInput,
        AppColorsDark.borderInputFocus,
        AppColorsDark.error,
        AppColorsDark.success,
        AppColorsDark.warning,
        AppColorsDark.info,
        AppColorsDark.divider,
        AppColorsDark.overlay,
        AppColorsDark.nodeHuman,
        AppColorsDark.nodeAgent,
        AppColorsDark.nodeActive,
        AppColorsDark.nodeIdle,
      ];
      for (final color in fields) {
        expect(color, isNotNull);
      }
    });
  });
}
