# UI改进待办事项清单

## 📊 当前状况概述

基于代码分析，发现**186个文件**存在设计规范不一致问题，主要集中在以下几个方面：

| 问题类型 | 发现数量 | 严重程度 | 影响范围 |
|---------|----------|----------|----------|
| 预览文件主题不统一 | 12个文件 | 🔥 高 | 开发体验 |
| 硬编码颜色 | 50+ 实例 | 🔥 高 | 视觉一致性 |
| 硬编码字体大小 | 80+ 实例 | 🔥 高 | 字体层级 |
| 硬编码间距 | 100+ 实例 | 🟡 中 | 布局一致性 |
| 硬编码圆角 | 60+ 实例 | 🟡 中 | 组件风格 |

## 🚨 高优先级任务 (1-2周内完成)

### 1. 统一预览文件主题 【P0】
**问题**: 12个预览文件使用不同的主题配置

**受影响文件**:
```
lib/previews/seller_time_preview.dart
lib/previews/seller_product_preview.dart  
lib/previews/seller_notification_preview.dart
lib/previews/seller_home_preview.dart
lib/previews/seller_auto_reply_preview.dart
lib/previews/seller_auth_preview.dart
lib/previews/seller_after_sales_preview.dart
lib/previews/previews-realdata/seller_home_real_preview.dart
lib/previews/previews-realdata/main_wallet_preview.dart
lib/previews/previews-realdata/main_home.dart
lib/previews/previews-realdata/main_favorites_preview.dart
```

**修复方案**:
- [ ] 将所有 `primarySwatch: Colors.blue` 替换为统一主题
- [ ] 移除重复的MaterialColor定义
- [ ] 统一使用 `theme: AppTheme.lightTheme`

**预期收益**: 开发环境视觉统一，预览效果一致

---

### 2. 完善主题配置系统 【P0】
**问题**: 现有`app_theme.dart`配置不完整

**需要创建的文件**:
- [ ] `lib/core/config/theme/app_colors.dart` - 颜色系统
- [ ] `lib/core/config/theme/app_text_styles.dart` - 字体系统  
- [ ] `lib/core/config/theme/app_dimensions.dart` - 尺寸系统
- [ ] `lib/core/config/theme/app_shadows.dart` - 阴影系统

**主要任务**:
- [ ] 完善`AppTheme.lightTheme`配置
- [ ] 添加所有组件主题 (Button, Input, Card等)
- [ ] 定义完整的ColorScheme
- [ ] 建立标准TextTheme

---

### 3. 移除硬编码颜色 【P1】
**问题**: 发现50+个硬编码颜色实例

#### 3.1 功能色替换
**需要替换的颜色**:
```dart
// ❌ 错误用法 → ✅ 正确用法
Colors.red → AppColors.error
Colors.green → AppColors.success  
Colors.orange → AppColors.warning
Colors.blue → AppColors.info
Colors.grey → AppColors.grey[对应级别]
```

#### 3.2 重点修复文件 (按影响范围排序)
**高影响文件** (用户直接可见):
- [ ] `lib/features/seller/presentation/widgets/status_tag.dart`
- [ ] `lib/features/seller/presentation/widgets/product_card.dart`
- [ ] `lib/features/seller/presentation/pages/seller_home_page.dart`
- [ ] `lib/features/seller/presentation/pages/product_management_page.dart`
- [ ] `lib/features/seller/presentation/pages/product_edit_page.dart`

**中等影响文件**:
- [ ] `lib/features/seller/presentation/pages/seller_statistics_page.dart`
- [ ] `lib/features/seller/presentation/pages/seller_profile_page.dart`
- [ ] `lib/features/seller/presentation/pages/time_management_page.dart`

#### 3.3 十六进制硬编码清理
**需要移除的硬编码颜色**:
```dart
// 主色调相关
Color(0xFFB66D0E) → AppColors.primary
Color(0xFFBF7D2A) → AppColors.primaryVariant  
Color(0xFFD0903D) → AppColors.primaryLight

// 文字颜色相关  
Color(0xFF333333) → AppColors.textPrimary
Color(0xFF666666) → AppColors.textSecondary
Color(0xFF212121) → AppColors.textPrimary

// 背景色相关
Color(0xFFEDEDED) → AppColors.backgroundSecondary
Color(0xFFF6F6F6) → AppColors.backgroundTertiary
```

---

### 4. 标准化字体样式 【P1】
**问题**: 发现80+个硬编码字体大小实例

#### 4.1 字体大小映射表
```dart
// ❌ 硬编码 → ✅ 标准化
fontSize: 24 → Theme.of(context).textTheme.displaySmall
fontSize: 20 → Theme.of(context).textTheme.headlineLarge  
fontSize: 18 → Theme.of(context).textTheme.titleLarge
fontSize: 16 → Theme.of(context).textTheme.titleMedium
fontSize: 14 → Theme.of(context).textTheme.bodyMedium
fontSize: 12 → Theme.of(context).textTheme.bodySmall
fontSize: 10 → Theme.of(context).textTheme.labelSmall
```

#### 4.2 重点修复文件
**高频使用文件**:
- [ ] `lib/features/seller/presentation/pages/product_edit_page.dart` (20+实例)
- [ ] `lib/features/seller/presentation/pages/seller_statistics_page.dart` (15+实例)
- [ ] `lib/features/seller/presentation/pages/seller_home_page.dart` (12+实例)
- [ ] `lib/features/seller/presentation/pages/seller_profile_page.dart` (10+实例)

## 🟡 中等优先级任务 (2-4周内完成)

### 5. 标准化间距系统 【P2】

#### 5.1 间距值映射
**需要替换的EdgeInsets**:
```dart
// ❌ 硬编码 → ✅ 标准化
EdgeInsets.all(4) → EdgeInsets.all(AppDimensions.spacingXs)
EdgeInsets.all(8) → EdgeInsets.all(AppDimensions.spacingSm)  
EdgeInsets.all(12) → EdgeInsets.all(AppDimensions.spacingMd)
EdgeInsets.all(16) → EdgeInsets.all(AppDimensions.spacingLg)
EdgeInsets.all(20) → EdgeInsets.all(AppDimensions.spacingXl)
EdgeInsets.all(24) → EdgeInsets.all(AppDimensions.spacingXxl)
```

#### 5.2 重点修复文件
- [ ] `lib/features/seller/presentation/pages/product_edit_page.dart` (30+实例)
- [ ] `lib/features/seller/presentation/pages/seller_home_page.dart` (15+实例)
- [ ] `lib/features/seller/presentation/pages/seller_profile_page.dart` (10+实例)

---

### 6. 统一圆角系统 【P2】

#### 6.1 圆角值标准化
```dart  
// ❌ 硬编码 → ✅ 标准化
BorderRadius.circular(4) → BorderRadius.circular(AppDimensions.radiusSm)
BorderRadius.circular(8) → BorderRadius.circular(AppDimensions.radiusMd)
BorderRadius.circular(12) → BorderRadius.circular(AppDimensions.radiusLg)
BorderRadius.circular(16) → BorderRadius.circular(AppDimensions.radiusXl)
BorderRadius.circular(20) → BorderRadius.circular(AppDimensions.radiusPill)
```

#### 6.2 重点修复文件
- [ ] `lib/features/seller/presentation/pages/product_edit_page.dart` (20+实例)
- [ ] `lib/features/orders/presentation/widgets/` (多个文件)
- [ ] `lib/features/chat/presentation/widgets/` (多个文件)

---

### 7. 组件标准化 【P2】

#### 7.1 创建标准组件库
- [ ] `lib/core/widgets/buttons/` 
  - [ ] `primary_button.dart`
  - [ ] `secondary_button.dart`  
  - [ ] `text_button.dart`
  - [ ] `icon_button.dart`

- [ ] `lib/core/widgets/cards/`
  - [ ] `standard_card.dart`
  - [ ] `product_card.dart`
  - [ ] `info_card.dart`

- [ ] `lib/core/widgets/forms/`
  - [ ] `standard_text_field.dart`
  - [ ] `search_field.dart`
  - [ ] `dropdown_field.dart`

#### 7.2 替换现有组件
**状态标签组件**:
- [ ] 重构 `lib/features/seller/presentation/widgets/status_tag.dart`
- [ ] 使用设计规范中定义的StatusTag组件

**卡片组件**:
- [ ] 重构 `lib/features/seller/presentation/widgets/product_card.dart`
- [ ] 统一卡片阴影和圆角

## 🔵 低优先级任务 (1-2个月内完成)

### 8. 建立代码质量检查 【P3】

#### 8.1 添加Lint规则
- [ ] 配置 `analysis_options.yaml` 禁止硬编码样式
- [ ] 添加自定义lint规则检查Theme使用

#### 8.2 建立审查流程
- [ ] 创建PR检查模板
- [ ] 建立设计一致性审查清单
- [ ] 定期进行设计债务评估

---

### 9. 性能和体验优化 【P3】

#### 9.1 响应式设计完善
- [ ] 添加断点系统
- [ ] 优化平板和大屏适配
- [ ] 建立响应式组件库

#### 9.2 无障碍访问优化
- [ ] 确保最小触摸目标44px
- [ ] 添加语义化标签
- [ ] 支持屏幕阅读器

---

### 10. 文档和培训 【P3】

#### 10.1 完善设计文档
- [ ] 录制设计系统使用视频
- [ ] 创建组件使用示例
- [ ] 建立设计token查询工具

#### 10.2 团队培训
- [ ] 组织设计系统培训
- [ ] 建立新人入职指南
- [ ] 定期设计规范回顾

## 📈 进度追踪

### 完成度指标
| 阶段 | 目标完成度 | 关键指标 |
|------|------------|----------|
| Phase 1 | 70% | 预览文件统一，主要颜色规范化 |
| Phase 2 | 85% | 字体和间距标准化 |  
| Phase 3 | 95% | 组件库建立，自动化检查 |

### 每周检查项
- [ ] 新增硬编码样式数量
- [ ] 设计规范使用率
- [ ] 组件复用率
- [ ] 代码审查通过率

## 🛠️ 实施建议

### 1. 人员分工
- **前端主程**: 负责核心组件库建设
- **功能开发者**: 负责各自模块的样式重构
- **设计师**: 负责设计token验证和视觉审查

### 2. 时间安排
```
Week 1-2: 完成P0任务 (预览统一 + 主题完善)
Week 3-4: 完成P1任务 (颜色 + 字体规范化)  
Week 5-8: 完成P2任务 (间距 + 圆角 + 组件标准化)
Week 9+:  完成P3任务 (质量检查 + 优化完善)
```

### 3. 风险控制
- **回归测试**: 每次重构后进行视觉回归测试
- **逐步迁移**: 优先重构用户高频使用的页面
- **向后兼容**: 保留旧API一段时间，逐步废弃

---

## ✅ 验收标准

### 最终目标 (3个月后)
- [ ] **95%** 的颜色使用来自主题系统
- [ ] **90%** 的文字样式使用TextTheme
- [ ] **100%** 的预览文件使用统一主题  
- [ ] **80%** 的界面使用标准组件
- [ ] **零** 新增硬编码样式值

### 用户体验改善
- [ ] 视觉风格完全一致
- [ ] 交互行为可预测
- [ ] 界面响应更流畅
- [ ] 品牌感知更强烈

通过完成这个todolist，我们将显著提升应用的视觉一致性和用户体验质量！

---

**创建时间**: 2024年12月  
**预计完成**: 2025年3月  
**责任人**: DSKK前端团队 