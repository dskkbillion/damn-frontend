# DSKK Flutter 设计系统

## 概述

本文档定义了 DSKK Flutter 应用的核心设计语言，确保整个应用的视觉一致性和用户体验统一。

## 🎨 颜色系统

### 主色调
```dart
// 主品牌色
static const primaryColor = Color(0xFFB66D0E);  // 棕橙色

// 主色调色阶
static const MaterialColor primarySwatch = MaterialColor(0xFFB66D0E, {
  50: Color(0xFFF9ECCF),
  100: Color(0xFFF0D9A0),
  200: Color(0xFFE6C571),
  300: Color(0xFFDCB141),
  400: Color(0xFFCEA128),
  500: Color(0xFFB66D0E), // 主色
  600: Color(0xFFA85F0D),
  700: Color(0xFF9A510B),
  800: Color(0xFF8C430A),
  900: Color(0xFF753506),
});
```

### 功能色
```dart
// 成功色
static const successColor = Color(0xFF4CAF50);
static const successLight = Color(0xFF81C784);
static const successDark = Color(0xFF388E3C);

// 警告色
static const warningColor = Color(0xFFFF9800);
static const warningLight = Color(0xFFFFB74D);
static const warningDark = Color(0xFFF57C00);

// 错误色
static const errorColor = Color(0xFFF44336);
static const errorLight = Color(0xFFE57373);
static const errorDark = Color(0xFFD32F2F);

// 信息色
static const infoColor = Color(0xFF2196F3);
static const infoLight = Color(0xFF64B5F6);
static const infoDark = Color(0xFF1976D2);
```

### 中性色系
```dart
// 灰色系 - 用于文本、边框、背景
static const greyColors = {
  50: Color(0xFFFAFAFA),   // 最浅背景
  100: Color(0xFFF5F5F5),  // 卡片背景
  200: Color(0xFFEEEEEE),  // 分割线
  300: Color(0xFFE0E0E0),  // 禁用边框
  400: Color(0xFFBDBDBD),  // 占位图标
  500: Color(0xFF9E9E9E),  // 次要文本
  600: Color(0xFF757575),  // 说明文本
  700: Color(0xFF616161),  // 正文文本
  800: Color(0xFF424242),  // 主要文本
  900: Color(0xFF212121),  // 标题文本
};
```

### 使用规则
- **主色调**: 用于CTA按钮、链接、重要状态指示
- **功能色**: 根据语义使用，如成功提示、错误信息等
- **灰色系**: 用于文本层级、背景、边框等

## 🔤 字体系统

### 字体层级
```dart
static const textTheme = TextTheme(
  // 页面标题 (24px, Bold)
  displayLarge: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: greyColors[900],
    height: 1.2,
  ),
  
  // 区块标题 (20px, Semi-Bold)
  headlineLarge: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: greyColors[800],
    height: 1.25,
  ),
  
  // 卡片标题 (18px, Semi-Bold)
  titleLarge: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: greyColors[800],
    height: 1.3,
  ),
  
  // 小标题 (16px, Medium)
  titleMedium: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: greyColors[700],
    height: 1.4,
  ),
  
  // 正文文本 (16px, Regular)
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: greyColors[700],
    height: 1.5,
  ),
  
  // 辅助文本 (14px, Regular)
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: greyColors[600],
    height: 1.4,
  ),
  
  // 说明文本 (12px, Regular)
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: greyColors[500],
    height: 1.3,
  ),
  
  // 按钮文字 (16px, Medium)
  labelLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.2,
  ),
  
  // 小按钮文字 (14px, Medium)
  labelMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  ),
  
  // 标签文字 (12px, Medium)
  labelSmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.1,
  ),
);
```

### 字体使用规则
- 标题使用粗体 (Bold) 或半粗体 (Semi-Bold)
- 正文使用常规字重 (Regular)
- 按钮和标签使用中等字重 (Medium)
- 行高设置考虑可读性和视觉层次

## 📐 间距系统

### 基础间距单位
```dart
// 基础间距单位 (4px 网格系统)
static const spacing = {
  'xs': 4.0,    // 极小间距
  'sm': 8.0,    // 小间距  
  'md': 16.0,   // 中等间距
  'lg': 24.0,   // 大间距
  'xl': 32.0,   // 超大间距
  'xxl': 48.0,  // 极大间距
};

// 页面边距
static const pageMargin = 16.0;

// 卡片内边距
static const cardPadding = 16.0;

// 列表项间距
static const listItemSpacing = 12.0;
```

### 间距使用规则
- 所有间距都应该是4px的倍数
- 页面边距统一使用16px
- 组件内部间距根据内容重要性调整
- 相关元素间距较小，不相关元素间距较大

## 🎭 圆角与阴影

### 圆角系统
```dart
static const borderRadius = {
  'none': 0.0,
  'sm': 4.0,     // 小圆角 - 按钮、标签
  'md': 8.0,     // 中圆角 - 卡片、输入框
  'lg': 12.0,    // 大圆角 - 对话框、底部弹窗
  'xl': 16.0,    // 超大圆角 - 图片容器
  'pill': 999.0, // 胶囊形状 - 状态标签
};
```

### 阴影系统
```dart
static const elevation = {
  'none': 0.0,
  'sm': 2.0,    // 卡片
  'md': 4.0,    // 按钮
  'lg': 8.0,    // 对话框
  'xl': 16.0,   // 底部弹窗
};

// 自定义阴影
static const cardShadow = [
  BoxShadow(
    color: Color(0x0F000000),  // 6% 透明度黑色
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  ),
];
```

## 🏗️ 布局原则

### 网格系统
- 使用4px基础网格
- 移动端最小触摸目标: 44px
- 内容区域最大宽度: 无限制 (全屏适配)

### 层级结构
```
1. 页面容器 (Scaffold)
├── 2. 应用栏 (AppBar)
├── 3. 主要内容区 (Body)
│   ├── 4. 区块容器 (Container/Card)
│   │   ├── 5. 内容元素
│   │   └── 5. 交互元素
│   └── 4. 浮动操作按钮 (FAB)
└── 3. 底部导航 (BottomNavigationBar)
```

## 🎯 组件规范概览

### 按钮
- 主要按钮: 主色调背景, 白色文字
- 次要按钮: 透明背景, 主色调边框和文字
- 文字按钮: 无背景, 主色调文字

### 卡片
- 背景: 白色
- 圆角: 8px
- 阴影: elevation 2
- 内边距: 16px

### 输入框
- 边框: 1px 灰色 (grey[300])
- 圆角: 8px
- 内边距: 12px 16px
- 聚焦: 主色调边框

## 📱 响应式设计

### 断点
- 手机: < 600px (主要支持)
- 平板: 600px - 1024px (兼容)
- 桌面: > 1024px (未来考虑)

### 适配原则
- 优先考虑移动端体验
- 使用灵活的布局组件 (Flexible, Expanded)
- 图片和图标使用矢量格式或多倍率

## 🚀 实施指南

### 1. 主题配置
所有颜色、字体、间距都应该在 `app_theme.dart` 中定义并通过 Theme 系统使用。

### 2. 组件开发
- 创建可复用的基础组件
- 组件应该使用主题系统中的设计token
- 避免硬编码样式值

### 3. 代码规范
```dart
// ✅ 正确 - 使用主题
Text(
  'Hello',
  style: Theme.of(context).textTheme.titleMedium,
)

// ❌ 错误 - 硬编码样式
Text(
  'Hello',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
)
```

## 📋 检查清单

在开发新功能或组件时，请确保:

- [ ] 使用了正确的颜色 (来自主题)
- [ ] 使用了标准的字体样式
- [ ] 遵循了间距系统
- [ ] 应用了合适的圆角和阴影
- [ ] 考虑了不同屏幕尺寸的适配
- [ ] 组件可复用且一致

---

**注意**: 这个设计系统是活文档，会根据产品需求和用户反馈持续优化。如有疑问或建议，请联系设计团队。 