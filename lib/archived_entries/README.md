# 存档入口文件说明

此目录包含项目历史上使用过的入口文件，这些文件已被归档但保留以供参考。

## 目录结构

### module_previews/
包含各个模块的独立预览入口文件，用于模块化开发和测试：

- **CV-demo/** - 买家/卖家演示预览
  - `main_buyer_preview.dart` - 买家模式预览
  - `main_seller_preview.dart` - 卖家模式预览
  
- **previews-realdata/** - 使用真实数据的模块预览
  - `main_auth_preview.dart` - 认证模块预览
  - `main_chat_preview.dart` - 聊天模块预览
  - `main_favorites_preview.dart` - 收藏模块预览
  - `main_home.dart` - 主页模块预览
  - `main_orders_preview.dart` - 订单模块预览
  - `main_profile_preview.dart` - 个人资料模块预览
  - `main_seller_preview.dart` - 卖家模块预览
  - `main_wallet_preview.dart` - 钱包模块预览
  - `seller_home_real_preview.dart` - 卖家主页真实数据预览

- **卖家功能预览**
  - `seller_after_sales_preview.dart` - 售后服务预览
  - `seller_auth_preview.dart` - 卖家认证预览
  - `seller_auto_reply_preview.dart` - 自动回复预览
  - `seller_home_preview.dart` - 卖家主页预览
  - `seller_notification_preview.dart` - 通知预览
  - `seller_product_preview.dart` - 产品管理预览
  - `seller_time_preview.dart` - 时间管理预览

- **其他预览**
  - `order_mock_preview.dart` - 订单模拟数据预览

### legacy_entries/
包含旧的应用入口文件，已被新的标准化入口文件替代：

- `main_dev_preview.dart` - 旧的开发预览入口
- `main_dev_VC.dart` - 旧的VC开发入口
- `main_mode_transition_test.dart` - 模式切换测试入口
- `main_beta.dart` - Beta版本入口

## 存档原因

1. **模块预览文件**：在项目重构期间用于独立开发和测试各个模块，现已完成集成到主应用中。

2. **旧入口文件**：被新的标准化入口文件（main_domestic.dart、main_international.dart等）替代，统一了构建和部署流程。

## 使用说明

这些文件仅供历史参考，不应在生产环境中使用。如需要重新启用某个预览模块进行调试，可以：

```bash
# 运行特定的模块预览
flutter run -t lib/archived_entries/module_previews/[specific_preview_file].dart
```

## 当前活跃入口文件

项目当前使用以下标准化入口文件：

- `lib/main.dart` - 默认入口（开发环境）
- `lib/main_domestic.dart` - 国服生产版本
- `lib/main_international.dart` - 外服生产版本
- `lib/main_domestic_dev.dart` - 国服开发版本（含测试账号）
- `lib/main_international_dev.dart` - 外服开发版本（含测试账号）

## 注意事项

- 这些存档文件可能包含过时的代码或配置
- 不建议直接运行这些文件，除非用于历史对比或特定调试需求
- 如需恢复使用某个模块预览，请先更新其依赖和配置