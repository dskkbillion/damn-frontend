# UI组件设计标准

## 概述

本文档定义了DSKK Flutter应用中各种UI组件的设计标准和使用规范，确保组件在整个应用中的一致性和可复用性。

## 🔘 按钮组件

### 主要按钮 (Primary Button)
```dart
// 标准主要按钮
ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 44),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('确认'),
)
```

**使用场景**:
- 页面中的主要操作 (如提交、确认、保存)
- 每个页面最多只有一个主要按钮
- 需要引起用户注意的重要操作

### 次要按钮 (Secondary Button)
```dart
// 标准次要按钮
OutlinedButton(
  onPressed: onPressed,
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: BorderSide(color: AppColors.primary),
    minimumSize: Size(double.infinity, 44),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('取消'),
)
```

**使用场景**:
- 次要操作 (如取消、返回)
- 与主要按钮配对使用
- 不那么重要但仍需突出的操作

### 文字按钮 (Text Button)
```dart
// 标准文字按钮
TextButton(
  onPressed: onPressed,
  style: TextButton.styleFrom(
    foregroundColor: AppColors.primary,
  ),
  child: Text('跳过'),
)
```

**使用场景**:
- 最不重要的操作
- 链接性质的操作
- 空间受限的场景

### 图标按钮
```dart
// 标准图标按钮
IconButton(
  onPressed: onPressed,
  icon: Icon(Icons.favorite),
  color: AppColors.primary,
  iconSize: 24,
)

// 带背景的图标按钮
Container(
  decoration: BoxDecoration(
    color: AppColors.primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
  ),
  child: IconButton(
    onPressed: onPressed,
    icon: Icon(Icons.add),
    color: AppColors.primary,
  ),
)
```

## 📝 输入组件

### 文本输入框
```dart
// 标准文本输入框
TextFormField(
  decoration: InputDecoration(
    labelText: '用户名',
    hintText: '请输入用户名',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  ),
)

// 带图标的输入框
TextFormField(
  decoration: InputDecoration(
    labelText: '搜索',
    hintText: '请输入关键词',
    prefixIcon: Icon(Icons.search),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: () => controller.clear(),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
)
```

### 搜索框
```dart
// 标准搜索框
Container(
  height: 40,
  decoration: BoxDecoration(
    color: AppColors.grey100,
    borderRadius: BorderRadius.circular(20),
  ),
  child: TextField(
    decoration: InputDecoration(
      hintText: '搜索商品、店铺',
      prefixIcon: Icon(Icons.search, color: AppColors.grey500),
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(vertical: 12),
    ),
  ),
)
```

### 下拉选择器
```dart
// 标准下拉选择器
DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: '选择分类',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  items: items.map((item) => DropdownMenuItem(
    value: item.value,
    child: Text(item.label),
  )).toList(),
  onChanged: onChanged,
)
```

## 🃏 卡片组件

### 基础卡片
```dart
// 标准卡片样式
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('标题', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Text('内容', style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  ),
)
```

### 产品卡片
```dart
// 商品卡片组件
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.grey100,
                    child: Icon(Icons.image, color: AppColors.grey400),
                  ),
                ),
              ),
            ),
            // 商品信息
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '¥${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🏷️ 标签组件

### 状态标签
```dart
// 状态标签组件
class StatusTag extends StatelessWidget {
  final String text;
  final StatusType type;
  final bool large;
  
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(large ? 16 : 12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: large ? 14 : 12,
          fontWeight: FontWeight.w500,
          color: _getTextColor(),
        ),
      ),
    );
  }
  
  Color _getBackgroundColor() {
    switch (type) {
      case StatusType.success:
        return AppColors.success.withOpacity(0.1);
      case StatusType.warning:
        return AppColors.warning.withOpacity(0.1);
      case StatusType.error:
        return AppColors.error.withOpacity(0.1);
      case StatusType.info:
        return AppColors.info.withOpacity(0.1);
      default:
        return AppColors.grey100;
    }
  }
}
```

### 数量标签 (Badge)
```dart
// 数量徽章
class CountBadge extends StatelessWidget {
  final int count;
  final Color? color;
  
  Widget build(BuildContext context) {
    if (count <= 0) return SizedBox.shrink();
    
    return Container(
      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
      padding: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color ?? AppColors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
```

## 📋 列表组件

### 基础列表项
```dart
// 标准列表项
ListTile(
  leading: CircleAvatar(
    backgroundColor: AppColors.primary,
    child: Icon(Icons.person, color: Colors.white),
  ),
  title: Text('标题'),
  subtitle: Text('副标题'),
  trailing: Icon(Icons.chevron_right),
  onTap: onTap,
)

// 自定义列表项
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    border: Border(
      bottom: BorderSide(color: AppColors.grey200, width: 1),
    ),
  ),
  child: Row(
    children: [
      // 图标或头像
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.notifications, color: AppColors.primary),
      ),
      SizedBox(width: 12),
      // 内容区域
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('通知标题', style: Theme.of(context).textTheme.titleSmall),
            Text('通知内容', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      // 右侧内容
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('刚刚', style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 4),
          CountBadge(count: 2),
        ],
      ),
    ],
  ),
)
```

## 🖼️ 图片组件

### 头像组件
```dart
// 标准头像
CircleAvatar(
  radius: 20,
  backgroundColor: AppColors.grey300,
  backgroundImage: NetworkImage(user.avatarUrl),
  child: user.avatarUrl.isEmpty 
    ? Icon(Icons.person, color: AppColors.grey600)
    : null,
)

// 可点击头像
GestureDetector(
  onTap: onTap,
  child: Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.primary, width: 2),
    ),
    child: CircleAvatar(
      radius: 38,
      backgroundImage: NetworkImage(user.avatarUrl),
    ),
  ),
)
```

### 图片查看器
```dart
// 图片网格查看器
class ImageGridViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int maxCount;
  
  Widget build(BuildContext context) {
    final displayCount = imageUrls.length > maxCount ? maxCount : imageUrls.length;
    final hasMore = imageUrls.length > maxCount;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        final isLastItem = index == displayCount - 1 && hasMore;
        
        return GestureDetector(
          onTap: () => _showImagePreview(context, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrls[index],
                  fit: BoxFit.cover,
                ),
                if (isLastItem)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        '+${imageUrls.length - maxCount + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

## 📢 反馈组件

### 加载指示器
```dart
// 标准加载指示器
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primary,
          ),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

// 页面级加载遮罩
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LoadingIndicator(message: message),
              ),
            ),
          ),
      ],
    );
  }
}
```

### 空状态组件
```dart
// 空状态展示
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## 🎭 弹窗组件

### 确认对话框
```dart
// 标准确认对话框
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmText = '确认',
  String cancelText = '取消',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
```

### 底部弹出菜单
```dart
// 底部操作菜单
Future<T?> showBottomActionSheet<T>(
  BuildContext context, {
  required String title,
  required List<ActionSheetItem<T>> items,
}) {
  return showModalBottomSheet<T>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Divider(height: 1),
          // 选项列表
          ...items.map((item) => ListTile(
            leading: item.icon != null ? Icon(item.icon) : null,
            title: Text(item.title),
            onTap: () => Navigator.of(context).pop(item.value),
          )),
          // 取消按钮
          ListTile(
            title: Text('取消', textAlign: TextAlign.center),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}
```

## 📏 组件尺寸规范

### 标准尺寸
```dart
class ComponentSizes {
  // 按钮高度
  static const double buttonHeight = 44.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 52.0;
  
  // 列表项高度
  static const double listItemHeight = 56.0;
  static const double listItemHeightLarge = 72.0;
  
  // 头像尺寸
  static const double avatarSmall = 24.0;
  static const double avatarMedium = 40.0;
  static const double avatarLarge = 80.0;
  
  // 图标尺寸
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
}
```

## 📋 使用规范

### 1. 组件选择原则
- 优先使用标准组件
- 需要自定义时基于标准组件扩展
- 保持组件API的一致性

### 2. 交互反馈
- 所有可点击元素必须有反馈效果
- 加载状态要给用户明确提示
- 错误状态要提供解决方案

### 3. 无障碍访问
- 确保最小触摸目标44px
- 提供语义化的组件描述
- 支持屏幕阅读器

### 4. 性能优化
- 图片组件使用缓存
- 长列表使用懒加载
- 避免不必要的重建

---

遵循这些组件标准，可以确保整个应用的UI组件一致性和用户体验的连贯性。 