# CV 演示入口

此目录包含用于演示展示的入口文件。

## 文件说明

- `main_buyer_preview.dart` - 买家模式展示入口
- `main_seller_preview.dart` - 卖家模式展示入口
- `run_buyer_preview.bat` - 运行买家预览的脚本
- `run_seller_preview.bat` - 运行卖家预览的脚本

## 特点

### 买家预览
- 使用买家账号信息
- 不显示开发tab标签页
- 设置为买家模式，显示买家界面

### 卖家预览
- 使用卖家账号信息
- 设置为卖家模式，自动显示卖家界面

## 依赖注入配置

### 统一的模块化配置
- 所有模块（包括订单模块）都使用统一的依赖注入配置
- 订单模块通过 `OrdersDI.init()` 统一管理所有订单相关依赖
- 买家和卖家预览都使用相同的依赖配置方式

### 订单模块依赖
- 数据源：远程和本地数据源
- 仓库：订单仓库实现
- 用例：买家和卖家订单相关的所有用例
- BLoC：订单列表和详情的状态管理

## 使用方法

### Windows
双击运行 `run_buyer_preview.bat` 或 `run_seller_preview.bat`

### 命令行
```bash
# 运行买家预览
flutter run -t lib/previews/CV-demo/main_buyer_preview.dart

# 运行卖家预览
flutter run -t lib/previews/CV-demo/main_seller_preview.dart
```

## 注意事项

- 这些入口文件使用硬编码的测试账号
- 买家/卖家预览使用不同的身份凭证
- 这些入口只用于演示展示，不用于开发测试
- 订单模块依赖已统一配置，无需手动注册 