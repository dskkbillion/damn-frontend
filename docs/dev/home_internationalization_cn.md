# Home模块国际化实现文档

## 概述

本文档描述了DSKK Flutter项目中对Home模块（主页、搜索页面）进行的国际化处理。我们使用Flutter官方推荐的国际化方案，通过ARB文件定义多语言文本，并在代码中使用`S.of(context)`访问这些文本资源。

## 实现范围

本次国际化实现涵盖以下Home模块的文件：

1. **主页**：
   - `lib/features/home/presentation/pages/home_page.dart`

2. **搜索相关页面**：
   - `lib/features/home/presentation/pages/search_page.dart`
   - `lib/features/home/presentation/pages/search_results_page.dart`

3. **组件**：
   - `lib/features/home/presentation/widgets/product_card.dart`

## 国际化资源

在`lib/l10n/`目录下的ARB文件中，我们添加了以下Home模块相关的国际化文本：

### 主页相关文本

| 键名 | 中文 | 英文 |
|------|------|------|
| `home_title` | 首页 | Home |
| `home_search_hint` | 搜索服务 | Search services |
| `home_loading` | 加载中... | Loading... |
| `home_loading_failed` | 加载失败: {error} | Loading failed: {error} |
| `home_retry` | 重试 | Retry |
| `home_end_of_list` | 已经到底了 | End of list |
| `home_banner_clicked` | 点击了轮播图: {targetType} - {targetValue} | Banner clicked: {targetType} - {targetValue} |
| `home_product_card_clicked` | 点击了服务卡片: {name} | Service card clicked: {name} |
| `home_recommend_clicked` | 点击了"让ta看看"按钮: {name} | Let them see button clicked: {name} |

### 产品卡片相关文本

| 键名 | 中文 | 英文 |
|------|------|------|
| `product_recommend_button` | 让ta看看 | Let them see |
| `product_image_loading_failed` | 图片加载失败 | Image loading failed |
| `product_default_name` | 商品 | Product |

### 搜索相关文本

| 键名 | 中文 | 英文 |
|------|------|------|
| `search_title` | 搜索 | Search |
| `search_button` | 搜索 | Search |
| `search_hot_keywords` | 热搜榜 | Hot Keywords |
| `search_history` | 搜索历史 | Search History |
| `search_no_results` | 没有找到相关的服务 | No relevant services found |
| `search_failed` | 搜索失败: {error} | Search failed: {error} |

## 实现方法

在每个涉及的文件中，我们按照以下步骤进行国际化：

1. 导入国际化资源包：
```dart
import 'package:dskk_flutter_refactor/generated/l10n.dart';
```

2. 在build方法中获取国际化资源：
```dart
final s = S.of(context);
```

3. 使用国际化资源替换硬编码文本：
```dart
// 替换前
Text('搜索服务')

// 替换后
Text(s.home_search_hint)
```

4. 对于带参数的文本，使用如下方式：
```dart
// 替换前
Text('点击了轮播图: ${banner.targetType} - ${banner.targetValue}')

// 替换后
Text(s.home_banner_clicked(banner.targetType, banner.targetValue))
```

## 实现示例

以`home_page.dart`为例，主要修改了以下部分：

1. 顶部导入语句添加国际化资源：
```dart
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源
```

2. 在函数中获取国际化资源：
```dart
Widget build(BuildContext context) {
  // 获取国际化资源
  final s = S.of(context);
  ...
}
```

3. 将硬编码文本替换为国际化资源：
```dart
// 替换前
return const HomeView(title: '首页');

// 替换后
return HomeView(title: s.home_title);
```

## 测试

通过切换App语言设置（在个人中心-设置-语言设置中），可以测试中英文切换的效果。主页和搜索页面的所有文本都会根据语言设置自动切换。

## 注意事项

1. 部分动态生成的文本（如商品名称）不需要国际化，直接使用后端返回的数据。
2. UI布局要考虑不同语言文本长度的差异，留出足够的空间避免溢出。
3. 使用国际化资源类生成工具：

```bash
flutter gen-l10n
```

## 下一步工作

1. 完成其他模块（如商品详情、订单等）的国际化。
2. 添加单元测试验证国际化文本的正确性。
3. 优化UI以适应不同语言文本长度。 