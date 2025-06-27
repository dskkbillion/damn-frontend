# 主题配置标准

## 概述

本文档详细说明如何在 DSKK Flutter 项目中正确配置和使用主题系统，确保所有组件和页面都能使用统一的设计tokens。

## 🏗️ 主题架构

### 当前问题分析

根据代码分析，项目存在以下主题使用问题：

1. **预览文件主题不统一**: 各个预览文件独立定义主题
2. **硬编码颜色**: 部分组件直接使用 `Colors.red`、`Colors.grey` 等
3. **字体样式分散**: 缺乏统一的字体样式规范
4. **主题配置不完整**: `app_theme.dart` 缺少详细配置

### 标准化主题结构

```dart
// lib/core/config/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

class AppTheme {
  // 私有构造函数
  AppTheme._();
  
  /// 亮色主题
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    
    // 颜色系统
    colorScheme: _lightColorScheme,
    primaryColor: AppColors.primary,
    
    // 文字主题
    textTheme: AppTextStyles.textTheme,
    
    // 组件主题
    appBarTheme: _lightAppBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: _cardTheme,
    dividerTheme: _dividerTheme,
    bottomNavigationBarTheme: _bottomNavigationBarTheme,
    
    // Material 3
    useMaterial3: true,
  );
  
  /// 暗色主题
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    textTheme: AppTextStyles.darkTextTheme,
    useMaterial3: true,
    // TODO: 完善暗色主题配置
  );
  
  // ========== 颜色方案 ==========
  
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.secondaryDark,
    
    tertiary: AppColors.accent,
    onTertiary: Colors.white,
    
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.errorDark,
    
    background: Colors.white,
    onBackground: AppColors.textPrimary,
    surface: Colors.white,
    onSurface: AppColors.textPrimary,
    
    surfaceVariant: AppColors.grey100,
    onSurfaceVariant: AppColors.textSecondary,
    
    outline: AppColors.grey300,
    outlineVariant: AppColors.grey200,
    
    inverseSurface: AppColors.grey900,
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.primaryLight,
  );
  
  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    // TODO: 完善暗色颜色方案
  );
  
  // ========== 组件主题 ==========
  
  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  );
  
  static final ElevatedButtonThemeData _elevatedButtonTheme = 
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      minimumSize: const Size(88, 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingSm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  static final OutlinedButtonThemeData _outlinedButtonTheme = 
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      minimumSize: const Size(88, 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingSm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(88, 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
  
  static final InputDecorationTheme _inputDecorationTheme = 
      InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.grey300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.grey300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingMd,
      vertical: AppDimensions.spacingSm,
    ),
    filled: true,
    fillColor: Colors.white,
    hintStyle: TextStyle(color: AppColors.textHint),
  );
  
  static const CardTheme _cardTheme = CardTheme(
    elevation: 2,
    margin: EdgeInsets.zero,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusMd)),
    ),
  );
  
  static const DividerTheme _dividerTheme = DividerTheme(
    color: AppColors.grey200,
    thickness: 1,
    space: 1,
  );
  
  static const BottomNavigationBarTheme _bottomNavigationBarTheme = 
      BottomNavigationBarTheme(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.grey500,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );
}
```

## 🎨 分离配置文件

### app_colors.dart
```dart
// lib/core/config/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // ========== 主色系 ==========
  static const Color primary = Color(0xFFB66D0E);
  static const Color primaryLight = Color(0xFFE6C571);
  static const Color primaryDark = Color(0xFF8C430A);
  
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF64B5F6);
  static const Color secondaryDark = Color(0xFF1976D2);
  
  static const Color accent = Color(0xFF4CAF50);
  
  // ========== 功能色 ==========
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  
  // ========== 灰色系 ==========
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // ========== 语义色 ==========
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey700;
  static const Color textHint = grey500;
  static const Color textDisabled = grey400;
  
  static const Color backgroundPrimary = Colors.white;
  static const Color backgroundSecondary = grey50;
  static const Color backgroundTertiary = grey100;
  
  static const Color borderDefault = grey300;
  static const Color borderFocus = primary;
  static const Color borderError = error;
  
  // ========== 透明度变体 ==========
  static Color primaryWithOpacity(double opacity) => 
      primary.withOpacity(opacity);
  
  static Color blackWithOpacity(double opacity) => 
      Colors.black.withOpacity(opacity);
      
  static Color whiteWithOpacity(double opacity) => 
      Colors.white.withOpacity(opacity);
}
```

### app_text_styles.dart
```dart
// lib/core/config/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();
  
  // ========== 基础字体样式 ==========
  static const String _fontFamily = null; // 使用系统默认字体
  
  static const TextTheme textTheme = TextTheme(
    // 显示类文字 - 用于大标题
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.2,
      fontFamily: _fontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.2,
      fontFamily: _fontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.2,
      fontFamily: _fontFamily,
    ),
    
    // 标题类文字
    headlineLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.25,
      fontFamily: _fontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
      fontFamily: _fontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
      fontFamily: _fontFamily,
    ),
    
    // 标题文字
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
      fontFamily: _fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.4,
      fontFamily: _fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.4,
      fontFamily: _fontFamily,
    ),
    
    // 正文文字
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
      height: 1.5,
      fontFamily: _fontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
      height: 1.4,
      fontFamily: _fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textHint,
      height: 1.3,
      fontFamily: _fontFamily,
    ),
    
    // 标签文字
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.2,
      fontFamily: _fontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.2,
      fontFamily: _fontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.1,
      fontFamily: _fontFamily,
    ),
  );
  
  // 暗色主题文字样式
  static TextTheme get darkTextTheme => textTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );
  
  // ========== 自定义文字样式 ==========
  
  /// 按钮文字样式
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.2,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.2,
    fontFamily: _fontFamily,
  );
  
  /// 价格文字样式
  static const TextStyle priceMain = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.2,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.2,
    fontFamily: _fontFamily,
  );
  
  /// 状态文字样式
  static const TextStyle statusSuccess = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
    height: 1.2,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle statusWarning = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.warning,
    height: 1.2,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle statusError = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    height: 1.2,
    fontFamily: _fontFamily,
  );
}
```

### app_dimensions.dart
```dart
// lib/core/config/theme/app_dimensions.dart

class AppDimensions {
  AppDimensions._();
  
  // ========== 间距系统 ==========
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  
  // ========== 圆角系统 ==========
  static const double radiusNone = 0.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusPill = 999.0;
  
  // ========== 阴影系统 ==========
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
  
  // ========== 组件尺寸 ==========
  static const double buttonHeight = 44.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 52.0;
  
  static const double inputHeight = 44.0;
  static const double inputHeightLarge = 52.0;
  
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 32.0;
  
  static const double avatarSize = 40.0;
  static const double avatarSizeSmall = 24.0;
  static const double avatarSizeLarge = 80.0;
  
  // ========== 页面布局 ==========
  static const double pageMargin = 16.0;
  static const double cardPadding = 16.0;
  static const double listItemSpacing = 12.0;
  
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;
  
  // ========== 最小触摸目标 ==========
  static const double minTouchTarget = 44.0;
}
```

## 🔧 主题使用指南

### 1. 应用配置

在 `lib/app/app.dart` 中使用统一主题：

```dart
MaterialApp.router(
  // 使用统一主题
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  // ...
)
```

### 2. 组件中使用主题

```dart
// ✅ 正确使用方式
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        children: [
          Text(
            'Title',
            style: textTheme.titleLarge,
          ),
          Text(
            'Body',
            style: textTheme.bodyMedium,
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Button'),
          ),
        ],
      ),
    );
  }
}
```

### 3. 自定义样式

```dart
// 基于主题扩展
Text(
  'Custom Text',
  style: theme.textTheme.bodyMedium?.copyWith(
    color: theme.colorScheme.primary,
    fontWeight: FontWeight.bold,
  ),
)

// 使用预定义样式
Text(
  '¥99.00',
  style: AppTextStyles.priceMain,
)
```

## 🚫 常见错误

### 1. 硬编码样式
```dart
// ❌ 错误
Text(
  'Hello',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF616161),
  ),
)

// ✅ 正确
Text(
  'Hello',
  style: Theme.of(context).textTheme.titleMedium,
)
```

### 2. 直接使用 Colors
```dart
// ❌ 错误
Container(color: Colors.grey[300])

// ✅ 正确
Container(color: Theme.of(context).colorScheme.outline)
// 或
Container(color: AppColors.grey300)
```

### 3. 预览文件重复定义主题
```dart
// ❌ 错误 - 在预览文件中
MaterialApp(
  theme: ThemeData(primarySwatch: Colors.blue),
  // ...
)

// ✅ 正确 - 在预览文件中
MaterialApp(
  theme: AppTheme.lightTheme,
  // ...
)
```

## 🔄 迁移步骤

### 1. 更新 app_theme.dart
按照上述结构重构现有的 `app_theme.dart` 文件。

### 2. 创建分离的配置文件
创建 `app_colors.dart`、`app_text_styles.dart`、`app_dimensions.dart`。

### 3. 更新预览文件
统一所有预览文件使用 `AppTheme.lightTheme`。

### 4. 重构组件
逐步替换硬编码样式为主题系统。

### 5. 添加 Lint 规则
配置 lint 规则防止硬编码样式的引入。

## 📋 检查清单

- [ ] `app_theme.dart` 包含完整的主题配置
- [ ] 颜色、文字、尺寸配置分离到独立文件
- [ ] 所有预览文件使用统一主题
- [ ] 组件使用 `Theme.of(context)` 获取样式
- [ ] 避免硬编码颜色和尺寸
- [ ] 自定义样式基于主题扩展

---

遵循这些配置标准，可以确保整个应用的视觉一致性和主题系统的可维护性。 