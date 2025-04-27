# 卖家模块修复计划

## 背景
当前卖家模块存在多个报错，主要包括：
- 类型冲突（如NotificationType从多处导入）
- 实体类属性不匹配（如OrderRefund缺少属性）
- 接口实现缺失（如ISellerRepository方法未实现）
- UI组件参数不匹配
- 枚举成员名称不匹配

## 分而治之策略
通过创建独立预览入口，逐个页面修复问题，而不是一次性解决所有问题。

## 数据策略
采用**两阶段**策略：
1. 第一阶段：**使用模拟数据** - 快速验证UI和基本功能。**利用 `test/features/seller/mocks/` 目录下已有的模拟仓库（如 `MockSellerRepository` 等）提供数据，预览入口位于 `lib/previews/` 目录下。**
2. 第二阶段：**集成真实API** - 在UI稳定后进行网络测试。**此阶段的预览入口建议放在 `lib/previews-realdata/` 目录下，以便区分。**

## 网络图片资源
使用Picsum Photos作为测试图片来源：
```
https://picsum.photos/300      // 商品图片
https://picsum.photos/150      // 头像/小图
```

## 页面修复计划

### 1. 卖家首页 (SellerHomePage)
- [x] 创建独立预览入口：`lib/previews/seller_home_preview.dart`
- [x] 提供模拟数据：卖家基本信息、销售统计 (通过 `MockSellerRepository`)
- [x] 确保首页卡片和统计显示正常 (基于模拟数据，已解决加载问题，基本 UI 显示正常)
- [x] 测试导航到其他页面的功能 (已通过 MockNavigationService 确认导航意图触发)
- [ ] 修复首页 UI 组件 (可选，待进一步检查细节)
- [ ] （第二阶段）集成真实 API

### 2. 商品管理页 (ProductManagementPage)
- [x] 创建独立预览入口：`lib/previews/seller_product_preview.dart`
- [x] 修复SellerManagedProduct实体类（添加缺失属性）
- [x] 创建模拟商品数据 (Mock Repository)
- [x] 修复状态筛选功能
- [x] 修复商品列表展示
- [ ] （第二阶段）集成真实API (入口: `lib/previews-realdata/seller_product_preview.dart`)

### 3. 时间管理页 (TimeManagementPage)
- [x] 创建独立预览入口：`lib/previews/seller_time_preview.dart`
- [x] 修复日期选择器
- [x] 创建模拟时间数据 (Mock Repository)
- [x] 修复时段设置功能
- [ ] （第二阶段）集成真实API (入口: `lib/previews-realdata/seller_time_preview.dart`)

### 4. 通知列表页 (NotificationListPage)
- [x] 创建独立预览入口：`lib/previews/seller_notification_preview.dart`
- [x] 解决NotificationType类型冲突 (已删除旧文件，保留 `seller_notification.dart` 中的定义，相关 BLoC/Event 已部分调整)
- [x] 创建模拟通知数据 (已在 Mock Repository 中添加)
- [x] 修复通知筛选和展示 (基本功能已通过预览验证)
- [ ] （第二阶段）集成真实 API

### 5. 售后管理页 (AfterSalesReviewPage)
- [x] 创建独立预览入口：`lib/previews/seller_after_sales_preview.dart`
- [x] 修复OrderRefund实体 (已统一，DTO映射初步修复)
- [x] 修复RefundType枚举不一致问题 (已在页面和DTO中修复)
- [x] 创建模拟售后数据 (Mock Repository 已提供)
- [x] 修复售后审核功能 (Bloc 列表加载、类型转换已修复)
- [ ] （待测试）审核操作 (同意/拒绝)
- [ ] （待修复）页面中仍存在的属性访问错误 (如 amount, images)
- [ ] （第二阶段）集成真实 API (入口: `lib/previews-realdata/seller_after_sales_preview.dart`)

### 6. 认证管理页 (AuthManagementPage) - 🔴 暂时跳过
- [ ] 创建独立预览入口：`lib/previews/seller_auth_preview.dart` (**已创建，但遇到 ProviderNotFoundException 无法解决**) 
- [x] 实现缺失的ISellerRepository.getAuthenticationStatus方法 (已在 `SellerRepositoryImpl` 和 `MockSellerRepository` 中添加占位/模拟实现，Mock 数据已修正)
- [ ] 创建模拟认证数据 (已在 Mock Repository 中添加)
- [ ] 修复认证状态展示 (**UI 待验证**)
- [ ] 修复认证表单 (**UI 待验证**)
- [ ] （第二阶段）集成真实API (入口: `lib/previews-realdata/seller_auth_preview.dart`)

### 7. 自动回复页 (AutoReplySettingsPage - 待确认页面名称)
- [x] 创建独立预览入口：`lib/previews/seller_auto_reply_preview.dart` (**基本运行成功**)
- [x] 定义自动回复相关实体/模型 (已存在: AutoReplySettings)
- [x] 创建模拟自动回复数据 (已在 Mock Repository 中添加)
- [ ] 修复自动回复设置UI和交互 (**细节待调整**)
- [ ] （第二阶段）集成真实API (入口: `lib/previews-realdata/seller_auto_reply_preview.dart`)

## 最终整合
- [ ] 整合所有修复后的页面
- [ ] 测试完整路由系统
- [ ] 确保所有页面间导航正常
- [ ] 集成真实数据API (参考 `lib/previews-realdata/` 下的实现)
- [ ] 进行端到端测试

## 如何创建预览入口

每个预览入口都应该包含以下内容：

```dart
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/目标页面.dart';
// 导入需要的模拟仓库
import 'package:dskk_flutter_refactor/test/features/seller/mocks/mock_seller_repository.dart'; 
// 其他必要导入

// 可以考虑设置依赖注入来提供模拟仓库，或直接实例化
final mockSellerRepo = MockSellerRepository(); 
// ... 其他模拟仓库实例 ...

void main() {
  // 可选：初始化依赖注入
  // setupMockDependencies(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '页面名称 Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: 页面Widget(/* 传入模拟仓库实例或通过DI获取 */),  
    );
  }
}

// // 提供模拟数据的辅助函数 (现在改为使用模拟仓库)
// class MockData {
//   static get mockData() {
//     return /*模拟数据*/;
//   }
// }

// 可选：设置模拟依赖注入的函数
// void setupMockDependencies() {
//   // 使用 get_it 或其他 DI 库注册模拟仓库
//   GetIt.instance.registerSingleton<ISellerRepository>(mockSellerRepo);
//   // ... 注册其他模拟仓库 ...
// }

```

每个预览入口应独立运行，不依赖其他页面或共享状态。 **优先使用 `test/features/seller/mocks/` 中的模拟仓库获取数据。** 