import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';
import 'app_shadows.dart';

/// Centralized application theme configuration.
class AppTheme {
  /// Defines the light theme for the application.
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.primaryVariant,
      secondaryContainer: AppColors.primaryLight,
      surface: AppColors.backgroundPrimary,
      background: AppColors.backgroundPrimary,
      error: AppColors.error,
      onPrimary: AppColors.getOnPrimaryColor(),
      onSecondary: AppColors.getOnPrimaryColor(),
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: AppColors.getOnErrorColor(),
      outline: AppColors.borderPrimary,
      surfaceVariant: AppColors.backgroundSecondary,
      onSurfaceVariant: AppColors.textSecondary,
    ),
    useMaterial3: true,
    
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
    
    // 卡片主题 - 使用淡主题色背景
    cardTheme: CardTheme(
      // 添加轻微阴影提升立体感
      elevation: 1,
      shadowColor: AppColors.grey[300]!.withOpacity(0.3),
      // 使用很淡的主题色作为卡片背景，增强品牌感
      color: AppColors.backgroundCardTinted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: BorderSide(
          // 使用更明显的边框色和厚度
          color: AppColors.borderPrimary,
          width: AppDimensions.borderStandard,
        ),
      ),
      // 移除强制margin，让各个页面自主控制间距，保持原有的紧密模块式布局
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
        minimumSize: Size(0, AppDimensions.buttonHeightMd),
        textStyle: AppTextStyles.button,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: AppColors.primary,
          width: AppDimensions.borderStandard,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: Size(0, AppDimensions.buttonHeightMd),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: Size(0, AppDimensions.buttonHeightMd),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    ),
    
    // AppBar主题
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundPrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headlineSmall,
      iconTheme: IconThemeData(
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
        borderSide: BorderSide(
          color: AppColors.borderInput,
          width: AppDimensions.borderStandard,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(
          color: AppColors.borderInput,
          width: AppDimensions.borderStandard,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(
          color: AppColors.borderInputFocus,
          width: AppDimensions.borderThick,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(
          color: AppColors.error,
          width: AppDimensions.borderStandard,
        ),
      ),
      contentPadding: EdgeInsets.all(AppDimensions.spacingLg),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
      labelStyle: AppTextStyles.labelMedium,
    ),
    
    // TabBar主题 - 去除Material 3默认的分隔线
    tabBarTheme: TabBarTheme(
      dividerColor: Colors.transparent, // 隐藏TabBar下方的分隔线
      dividerHeight: 0, // 设置分隔线高度为0
      indicatorColor: AppColors.primary, // 选中指示器颜色
      labelColor: AppColors.primary, // 选中标签颜色
      unselectedLabelColor: AppColors.textSecondary, // 未选中标签颜色
      labelStyle: AppTextStyles.labelLarge, // 选中标签样式
      unselectedLabelStyle: AppTextStyles.labelMedium, // 未选中标签样式
      indicatorSize: TabBarIndicatorSize.label, // 指示器尺寸跟随标签
    ),
    
    // BottomNavigationBar主题 - 去除顶部分隔线
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundPrimary,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0, // 去除阴影，避免产生视觉分隔线
    ),
  );

  /// Defines the dark theme for the application (placeholder).
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFb66d0e), // Use the same seed for consistency
      brightness: Brightness.dark, // Important hint for fromSeed in dark mode
    ),
    useMaterial3: true,
    // TODO: Define dark theme specific overrides if needed
  );

  // Private constructor to prevent instantiation
  AppTheme._();
}