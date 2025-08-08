# Flutter应用入口文件说明

## 概述
本项目支持多环境、多地区的部署，通过不同的入口文件来管理不同的运行配置。

## 活跃入口文件

### 生产环境入口

| 入口文件 | 用途 | API服务器 | 特点 |
|---------|------|----------|------|
| `main_domestic.dart` | 国服生产版本 | https://app.duoshaokankan.com/prod-api | 正式发布到国内应用市场 |
| `main_international.dart` | 外服生产版本 | https://api-global.duoshaokankan.com | 正式发布到国际应用市场 |

### 开发环境入口

| 入口文件 | 用途 | API服务器 | 特点 |
|---------|------|----------|------|
| `main.dart` | 默认开发入口 | 从.env文件读取 | 包含测试账号，用于日常开发 |
| `main_domestic_dev.dart` | 国服开发版本 | https://app.duoshaokankan.com/prod-api | 自动注入测试账号，便于开发调试 |
| `main_international_dev.dart` | 外服开发版本 | https://api-global.duoshaokankan.com | 自动注入测试账号，便于国际版调试 |

## 使用说明

### 运行应用

```bash
# 运行默认开发版本
flutter run

# 运行国服生产版本
flutter run -t lib/main_domestic.dart

# 运行外服生产版本
flutter run -t lib/main_international.dart

# 运行国服开发版本（带测试账号）
flutter run -t lib/main_domestic_dev.dart

# 运行外服开发版本（带测试账号）
flutter run -t lib/main_international_dev.dart
```

### 构建APK

```bash
# 构建国服生产版APK
flutter build apk -t lib/main_domestic.dart --release

# 构建外服生产版APK
flutter build apk -t lib/main_international.dart --release

# 构建开发版APK（用于测试）
flutter build apk -t lib/main_domestic_dev.dart --debug
```

### 构建iOS

```bash
# 构建国服生产版iOS
flutter build ios -t lib/main_domestic.dart --release

# 构建外服生产版iOS
flutter build ios -t lib/main_international.dart --release
```

## 配置差异

### API服务器配置
- **国服**: 使用 `https://app.duoshaokankan.com/prod-api`
- **外服**: 使用 `https://api-global.duoshaokankan.com`

### 测试账号配置（仅开发版本）
开发版本会自动注入测试账号，方便开发调试：
- 买家测试账号：13333333333
- Token自动注入，无需手动登录

### 环境变量支持
所有入口文件都支持通过`.env`文件覆盖默认配置：
- `BACKEND_BASE_URL`: 自定义API服务器地址
- `WECHAT_APP_ID`: 微信应用ID
- `WECHAT_UNIVERSAL_LINK`: 微信通用链接

## 注意事项

1. **生产版本不包含测试账号**：`main_domestic.dart` 和 `main_international.dart` 不会自动注入测试凭证
2. **开发版本包含调试日志**：开发版本会输出更多日志信息，便于调试
3. **API地址硬编码**：为确保安全性，生产版本的API地址是硬编码的，不依赖环境变量
4. **支付配置验证**：所有版本都会在启动时验证支付相关配置

## 存档文件

历史入口文件已移至 `lib/archived_entries/` 目录：
- `module_previews/`: 模块独立预览入口
- `legacy_entries/`: 旧版入口文件

详见 [存档文件说明](archived_entries/README.md)

## 版本发布指南

### 国内发布
1. 使用 `main_domestic.dart` 构建
2. 确保API指向国内服务器
3. 测试微信、支付宝支付功能

### 国际发布
1. 使用 `main_international.dart` 构建
2. 确保API指向国际服务器
3. 测试Stripe等国际支付方式

### 开发测试
1. 使用 `main_domestic_dev.dart` 或 `main_international_dev.dart`
2. 自动登录测试账号
3. 可查看详细调试日志