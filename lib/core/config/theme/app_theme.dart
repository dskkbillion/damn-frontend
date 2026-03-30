import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// DeepStream 主题配置
///
/// 支持亮色（Surface Mode）和暗色（Deep Mode���双模式。
/// 默认跟随系统设置 `ThemeMode.system`。
class AppTheme {
  AppTheme._();

  /// 默认主题模式：跟随系统
  static const ThemeMode defaultThemeMode = ThemeMode.system;

  // ==================== 亮色主题（Surface Mode） ====================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundPrimary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.primaryVariant,
      secondaryContainer: AppColors.primaryLight,
      surface: AppColors.backgroundCard,
      error: AppColors.error,
      onPrimary: AppColors.getOnPrimaryColor(),
      onSecondary: AppColors.getOnPrimaryColor(),
      onSurface: AppColors.textPrimary,
      onError: AppColors.getOnErrorColor(),
      outline: AppColors.borderPrimary,
      surfaceContainerHighest: AppColors.backgroundSecondary,
      onSurfaceVariant: AppColors.textSecondary,
    ),
    useMaterial3: true,

    // 页面切换动画
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),

    // 文字主题
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    // 卡片主题 - 白卡浮于暖石灰底
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: const BorderSide(
          color: AppColors.borderPrimary,
          width: AppDimensions.borderStandard,
        ),
      ),
      margin: EdgeInsets.zero,
    ),

    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.getOnPrimaryColor(),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(0, 44),
        textStyle: AppTextStyles.button,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(
          color: AppColors.primary,
          width: AppDimensions.borderStandard,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(0, 44),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.getOnPrimaryColor(),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(0, 44),
        textStyle: AppTextStyles.button,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(0, 44),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    ),

    // AppBar 主题
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundPrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headlineSmall,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppDimensions.iconLg,
      ),
    ),

    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.borderInput,
          width: AppDimensions.borderStandard,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.borderInput,
          width: AppDimensions.borderStandard,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.borderInputFocus,
          width: AppDimensions.borderThick,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppDimensions.borderStandard,
        ),
      ),
      contentPadding: const EdgeInsets.all(AppDimensions.spacingLg),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
      labelStyle: AppTextStyles.labelMedium,
    ),

    // TabBar 主题
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // BottomNavigationBar 主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundCard,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Divider 主题
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: AppDimensions.borderThin,
      space: 0,
    ),

    // Chip 主题
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      selectedColor: AppColors.primaryWithOpacity10,
      labelStyle: AppTextStyles.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      side: BorderSide.none,
    ),

    // Dialog 主题
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      titleTextStyle: AppTextStyles.headlineMedium,
      contentTextStyle: AppTextStyles.bodyMedium,
    ),

    // BottomSheet 主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.borderPrimary,
    ),
  );

  // ==================== 暗色主题（Deep Mode） ====================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.backgroundPrimary,
    colorScheme: const ColorScheme.dark(
      primary: AppColorsDark.accentPrimary,
      primaryContainer: AppColorsDark.accentDark,
      secondary: AppColorsDark.accentLight,
      secondaryContainer: AppColorsDark.accentDark,
      surface: AppColorsDark.backgroundCard,
      error: AppColorsDark.error,
      onPrimary: AppColorsDark.backgroundDeep,
      onSecondary: AppColorsDark.backgroundDeep,
      onSurface: AppColorsDark.textPrimary,
      onError: AppColorsDark.backgroundDeep,
      outline: AppColorsDark.borderPrimary,
      surfaceContainerHighest: AppColorsDark.backgroundElevated,
      onSurfaceVariant: AppColorsDark.textSecondary,
    ),
    useMaterial3: true,

    // 页面切换动画
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),

    // 文字主题（暗色模式覆盖颜色）
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColorsDark.textPrimary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColorsDark.textPrimary),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColorsDark.textPrimary),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColorsDark.textPrimary),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColorsDark.textPrimary),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColorsDark.textPrimary),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColorsDark.textPrimary),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColorsDark.textPrimary),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColorsDark.textPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColorsDark.textPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColorsDark.textPrimary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColorsDark.textSecondary),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColorsDark.textPrimary),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColorsDark.textPrimary),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColorsDark.textSecondary),
    ),

    // 卡片主题 - 深海卡片 + 微妙边框
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColorsDark.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: const BorderSide(
          color: AppColorsDark.borderPrimary,
          width: AppDimensions.borderStandard,
        ),
      ),
      margin: EdgeInsets.zero,
    ),

    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.accentPrimary,
        foregroundColor: AppColorsDark.backgroundDeep,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(0, 44),
        textStyle: AppTextStyles.button.copyWith(color: AppColorsDark.backgroundDeep),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsDark.accentPrimary,
        side: const BorderSide(
          color: AppColorsDark.accentPrimary,
          width: AppDimensions.borderStandard,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(0, 44),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColorsDark.accentPrimary,
        foregroundColor: AppColorsDark.backgroundDeep,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(0, 44),
        textStyle: AppTextStyles.button.copyWith(color: AppColorsDark.backgroundDeep),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsDark.accentPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: const Size(0, 44),
      ),
    ),

    // AppBar 主题
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsDark.backgroundPrimary,
      foregroundColor: AppColorsDark.textPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headlineSmall.copyWith(color: AppColorsDark.textPrimary),
      iconTheme: const IconThemeData(
        color: AppColorsDark.textPrimary,
        size: AppDimensions.iconLg,
      ),
    ),

    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.backgroundElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColorsDark.borderInput,
          width: AppDimensions.borderStandard,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColorsDark.borderInput,
          width: AppDimensions.borderStandard,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColorsDark.borderInputFocus,
          width: AppDimensions.borderThick,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColorsDark.error,
          width: AppDimensions.borderStandard,
        ),
      ),
      contentPadding: const EdgeInsets.all(AppDimensions.spacingLg),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColorsDark.textTertiary),
      labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColorsDark.textSecondary),
    ),

    // TabBar 主题
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      indicatorColor: AppColorsDark.accentPrimary,
      labelColor: AppColorsDark.accentPrimary,
      unselectedLabelColor: AppColorsDark.textSecondary,
      labelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // BottomNavigationBar 主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColorsDark.backgroundCard,
      selectedItemColor: AppColorsDark.accentPrimary,
      unselectedItemColor: AppColorsDark.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Divider 主题
    dividerTheme: const DividerThemeData(
      color: AppColorsDark.divider,
      thickness: AppDimensions.borderThin,
      space: 0,
    ),

    // Chip 主题
    chipTheme: ChipThemeData(
      backgroundColor: AppColorsDark.backgroundElevated,
      selectedColor: AppColorsDark.accentPrimary.withValues(alpha: 0.15),
      labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColorsDark.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      side: BorderSide.none,
    ),

    // Dialog 主题
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorsDark.backgroundElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColorsDark.textPrimary),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColorsDark.textPrimary),
    ),

    // BottomSheet 主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColorsDark.backgroundElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: AppColorsDark.borderSecondary,
    ),
  );
}
