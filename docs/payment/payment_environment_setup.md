# 支付环境变量配置指南

## 概述

为了提高安全性，本项目已将支付相关的敏感信息（如微信App ID、Universal Link等）从代码中移除，改为使用环境变量进行配置。

## 环境变量配置

### 1. 创建 .env 文件

在项目根目录创建 `.env` 文件（与 `pubspec.yaml` 同级），内容如下：

```bash
# =====================================================
# 支付配置（必需）
# =====================================================
# 微信支付App ID（从微信开放平台获取）
WECHAT_APP_ID=wx8647007008f7b74d

# iOS Universal Link（必需，用于微信支付回调）
WECHAT_UNIVERSAL_LINK=https://app.duoshaokankan.com/wechat/

# =====================================================
# 后端服务配置（必需）
# =====================================================
# 后端API基础URL
BACKEND_BASE_URL=https://app.duoshaokankan.com/prod-api

# AI模型服务URL
MODEL_BASE_URL=http://47.113.230.11:5102

# =====================================================
# 可选配置
# =====================================================
# 支付环境：production（生产）| sandbox（沙盒）| development（开发）
PAYMENT_ENVIRONMENT=production

# 是否启用Mock支付（开发调试用）：true | false
PAYMENT_MOCK_ENABLED=false

# 是否为开发环境：true | false
DEBUG_MODE=false

# 日志级别：debug | info | warning | error
LOG_LEVEL=info
```

### 2. 环境变量说明

#### 必需配置

| 变量名 | 说明 | 示例值 | 获取方式 |
|--------|------|--------|----------|
| `WECHAT_APP_ID` | 微信开放平台App ID | `wx8647007008f7b74d` | [微信开放平台](https://open.weixin.qq.com/) |
| `WECHAT_UNIVERSAL_LINK` | iOS Universal Link（**仅iOS必需**） | `https://app.duoshaokankan.com/wechat/` | 配置域名和路径 |
| `BACKEND_BASE_URL` | 后端API地址 | `https://app.duoshaokankan.com/prod-api` | 后端服务器地址 |

#### 可选配置

| 变量名 | 说明 | 默认值 | 可选值 |
|--------|------|--------|--------|
| `PAYMENT_ENVIRONMENT` | 支付环境 | `production` | `production`, `sandbox`, `development` |
| `PAYMENT_MOCK_ENABLED` | Mock支付模式 | `false` | `true`, `false` |
| `DEBUG_MODE` | 调试模式 | `false` | `true`, `false` |
| `LOG_LEVEL` | 日志级别 | `info` | `debug`, `info`, `warning`, `error` |

### 3. 平台特定说明

#### 📱 iOS平台
- **必需配置**：`WECHAT_APP_ID` + `WECHAT_UNIVERSAL_LINK`
- **支付回调**：通过Universal Link处理
- **配置要求**：Universal Link必须在微信开放平台中正确配置

#### 🤖 Android平台
- **必需配置**：仅需 `WECHAT_APP_ID`
- **支付回调**：通过AndroidManifest.xml中的Intent Filter和WXPayEntryActivity处理
- **Universal Link**：可选配置，不影响支付功能

#### 🌐 Web/其他平台
- **配置同iOS**：建议配置Universal Link以确保兼容性

### 4. 安全注意事项

#### ⚠️ 重要提醒

1. **不要提交 .env 文件到版本控制系统**
   - `.env` 文件已在 `.gitignore` 中被忽略
   - 如果意外提交，需要立即撤销并更换敏感信息

2. **保护敏感信息**
   - 微信App ID、Universal Link等应妥善保管
   - 不要在代码、日志、截图中暴露这些信息
   - 团队成员需要单独获取和配置

3. **环境区分**
   - 开发环境可使用Mock模式（`PAYMENT_MOCK_ENABLED=true`）
   - 生产环境必须使用真实配置和`production`环境

## 配置验证

### 自动验证

应用启动时会自动验证配置，并在控制台输出验证报告：

```
=== 支付配置验证报告 ===
✅ 所有配置检查通过！

=== 配置说明 ===
请在项目根目录创建 .env 文件，包含以下内容：
...
```

### 手动验证

如果遇到问题，可以手动检查：

1. **检查 .env 文件是否存在**
   ```bash
   ls -la .env
   ```

2. **检查文件内容**
   ```bash
   cat .env
   ```

3. **验证格式**
   - 每行格式：`KEY=VALUE`
   - 不要有空格：`WECHAT_APP_ID=wx123` ✅  `WECHAT_APP_ID = wx123` ❌
   - 不要有引号：`WECHAT_APP_ID=wx123` ✅  `WECHAT_APP_ID="wx123"` ❌

## 常见问题解决

### 问题 1：配置验证失败

**症状**：应用启动时显示配置问题
```
❌ 发现配置问题：
  1. WECHAT_APP_ID 环境变量未设置或为空
```

**解决方案**：
1. 确认 `.env` 文件存在于项目根目录
2. 检查文件中是否包含所需的环境变量
3. 确认格式正确（无空格、无引号）

### 问题 2：微信支付初始化失败

**症状**：微信支付不可用
```
[WechatPaymentService] Configuration validation failed
[WechatPaymentService] App ID: MISSING
```

**解决方案**：
1. 检查 `WECHAT_APP_ID` 是否正确设置
2. 确认App ID格式（应以`wx`开头）
3. 验证Universal Link是否可访问

### 问题 3：支付回调不工作

**症状**：支付完成后应用无响应

**解决方案**：
1. 检查 `WECHAT_UNIVERSAL_LINK` 配置
2. 确认URL使用HTTPS协议
3. 验证域名配置和证书有效性

## 开发调试

### Mock支付模式

开发阶段可以启用Mock支付，避免真实支付：

```bash
# 在 .env 文件中设置
PAYMENT_MOCK_ENABLED=true
PAYMENT_ENVIRONMENT=development
DEBUG_MODE=true
```

Mock模式特点：
- 跳过微信SDK初始化
- 模拟支付成功结果
- 2秒延迟模拟网络请求
- 不产生真实交易

### 日志调试

设置详细日志查看配置加载过程：

```bash
LOG_LEVEL=debug
DEBUG_MODE=true
```

## 部署配置

### 开发环境
```bash
PAYMENT_ENVIRONMENT=development
PAYMENT_MOCK_ENABLED=true
DEBUG_MODE=true
LOG_LEVEL=debug
```

### 测试环境
```bash
PAYMENT_ENVIRONMENT=sandbox
PAYMENT_MOCK_ENABLED=false
DEBUG_MODE=false
LOG_LEVEL=info
```

### 生产环境
```bash
PAYMENT_ENVIRONMENT=production
PAYMENT_MOCK_ENABLED=false
DEBUG_MODE=false
LOG_LEVEL=warning
```

## 团队协作

### 配置分享

由于 `.env` 文件不能提交到版本控制，团队协作时需要：

1. **技术负责人**：
   - 创建 `.env.example` 模板文件（已创建）
   - 提供真实配置值给团队成员
   - 定期更新配置文档

2. **开发人员**：
   - 复制 `.env.example` 为 `.env`
   - 填入从负责人获取的真实配置
   - 不要分享或截图包含敏感信息的配置

### 配置管理

建议使用配置管理工具：
- 开发环境：本地 `.env` 文件
- 测试环境：CI/CD 环境变量
- 生产环境：服务器环境变量或密钥管理服务

---

**需要帮助？**

如果在配置过程中遇到问题，请：
1. 查看应用启动时的配置验证报告
2. 检查本文档的常见问题部分
3. 联系技术负责人获取正确的配置值 