# 应用入口文件说明文档

本文档详细说明了项目中各种入口文件的用途、特点和使用场景。

## 📋 目录

- [主入口文件](#主入口文件)
- [开发测试入口](#开发测试入口)
- [模块预览入口](#模块预览入口)
- [演示入口](#演示入口)
- [使用指南](#使用指南)

## 🏠 主入口文件

### 1. `main.dart` - 生产环境主入口
**用途**: 生产环境正式发布版本的主入口文件

**特点**:
- ✅ 使用真实的认证服务和API调用
- ✅ 包含完整的依赖注入配置
- ✅ 集成分析和监控功能
- ✅ 支持环境变量配置
- ⚠️ 包含临时的测试用户注入（待移除）

**使用场景**: 应用商店发布、生产环境部署

---

### 2. `main_beta.dart` - 公测入口 🆕
**用途**: 用于公开测试的入口文件，让用户体验完整的注册登录流程

**特点**:
- ✅ **无硬编码登录信息** - 用户需要真实注册/登录
- ✅ 使用真实认证服务
- ✅ 启动时清理历史会话数据
- ✅ 隐藏开发者功能Tab
- ✅ 完整的功能模块支持

**使用场景**: 
- 公测版本发布
- 测试注册登录流程
- 收集用户反馈

**启动命令**:
```bash
flutter run lib/main_beta.dart
flutter build apk --target=lib/main_beta.dart
```

---

## 🔧 开发测试入口

### 3. `main_dev_VC.dart` - 上线前测试入口
**用途**: 用于Production-ready测试，包含完整功能和测试用户账号

**特点**:
- ✅ **硬编码测试用户账号** - 自动登录
- ✅ 使用Mock认证服务（便于测试）
- ✅ 完整的功能模块配置
- ✅ 隐藏开发者Tab
- ✅ 支持所有业务流程测试

**测试账号信息**:
- UserID: `13819198810`
- CommonUserID: `10319`
- ReferID: `10319`

**使用场景**: 
- 上线前的完整功能测试
- 业务流程验证
- 性能测试

---

### 4. `main_dev_preview.dart` - 开发预览入口
**用途**: 开发阶段的预览入口，包含开发菜单Tab

**特点**:
- ✅ **包含开发菜单Tab** - 方便测试不同模块
- ✅ Mock认证服务
- ✅ 注入测试用户账号
- ✅ 适合开发阶段调试

**使用场景**:
- 开发阶段调试
- 模块功能测试
- 快速原型验证

---

## 📱 模块预览入口

### 卖家模块预览文件

#### 5. `seller_home_preview.dart` - 卖家首页预览
**用途**: 独立预览卖家首页功能

**特点**:
- 🔧 Mock数据和服务
- 🎨 统一应用主题
- 📊 包含仪表板数据和店铺信息

**已知问题**: 
- ❌ BLoC构造参数数量错误（期望2个，实际3个）

---

#### 6. `seller_product_preview.dart` - 商品管理预览
**用途**: 独立预览商品管理功能

**特点**:
- 📦 商品列表管理
- 📝 草稿功能
- 🔄 状态更新和删除功能

**已知问题**:
- ❌ BLoC构造参数数量错误（期望4个，实际5个）

---

#### 7. `seller_after_sales_preview.dart` - 售后审核预览
**用途**: 独立预览售后审核功能

**特点**:
- 📋 售后订单列表
- ✅ 审核和退款操作
- 🔍 租户审核功能

---

#### 8. `seller_auth_preview.dart` - 认证管理预览
**用途**: 独立预览卖家认证状态管理

**特点**:
- 🔐 认证状态查看
- 📄 认证材料管理
- 🔄 使用BlocProvider.value模式

---

#### 9. `seller_auto_reply_preview.dart` - 自动回复预览
**用途**: 独立预览自动回复设置功能

**特点**:
- 💬 自动回复配置
- ⚙️ 回复规则设置
- 🔄 使用BlocProvider.value模式

---

#### 10. `seller_notification_preview.dart` - 通知管理预览
**用途**: 独立预览通知列表和管理功能

**特点**:
- 📬 通知列表显示
- ✅ 标记已读功能
- 🔢 未读计数管理

---

#### 11. `seller_time_preview.dart` - 时间管理预览
**用途**: 独立预览时间设置功能

**特点**:
- ⏰ 营业时间配置
- 📅 时间规则设置
- 🔄 时间设置更新

---

## 🎭 演示入口

### `/previews` 目录
包含各种功能模块的独立预览文件

### `/CV-demo` 目录
**用途**: 简历演示相关的入口文件

**包含文件**:
- `main_seller_preview.dart` - 卖家模式演示
- `main_buyer_preview.dart` - 买家模式演示
- `run_seller_preview.bat` - 卖家演示启动脚本
- `run_buyer_preview.bat` - 买家演示启动脚本
- `README.md` - 演示说明文档

### `/previews-realdata` 目录
**用途**: 使用真实数据的预览文件

**包含文件**:
- `main_orders_preview.dart` - 订单模块预览
- `main_home.dart` - 首页预览
- `main_seller_preview.dart` - 卖家模块预览
- `main_favorites_preview.dart` - 收藏模块预览
- `main_profile_preview.dart` - 个人资料预览
- `main_wallet_preview.dart` - 钱包模块预览
- `main_chat_preview.dart` - 聊天模块预览
- `main_auth_preview.dart` - 认证模块预览
- `seller_home_real_preview.dart` - 卖家首页真实数据预览

---

## 🔧 使用指南

### 环境变量配置
所有入口文件都支持通过 `.env` 文件配置后端地址：

```env
BACKEND_BASE_URL=https://app.duoshaokankan.com/prod-api
```

### 启动不同入口的命令

```bash
# 生产环境
flutter run lib/main.dart

# 公测环境
flutter run lib/main_beta.dart

# 上线前测试
flutter run lib/main_dev_VC.dart

# 开发预览
flutter run lib/main_dev_preview.dart

# 卖家首页预览
flutter run lib/previews/seller_home_preview.dart

# 其他模块预览
flutter run lib/previews/[模块名]_preview.dart
```

### 构建发布版本

```bash
# 公测版本
flutter build apk --target=lib/main_beta.dart

# 生产版本
flutter build apk --target=lib/main.dart
```

---

## ⚠️ 已知问题

1. **BLoC构造参数问题**:
   - `seller_home_preview.dart`: 参数数量不匹配
   - `seller_product_preview.dart`: 参数数量不匹配

2. **待优化项**:
   - 移除 `main.dart` 中的临时测试用户注入
   - 统一预览文件的Mock数据管理
   - 完善错误处理和日志记录

---

## 📊 入口文件对比

| 入口文件 | 认证服务 | 硬编码登录 | 开发Tab | 使用场景 |
|---------|---------|-----------|---------|----------|
| `main.dart` | 真实 | ⚠️ 临时有 | ❌ | 生产环境 |
| `main_beta.dart` | 真实 | ❌ | ❌ | 公测 |
| `main_dev_VC.dart` | Mock | ✅ | ❌ | 上线前测试 |
| `main_dev_preview.dart` | Mock | ✅ | ✅ | 开发调试 |
| 预览文件 | Mock | N/A | N/A | 模块测试 |

---

## 🚀 推荐使用流程

1. **开发阶段**: 使用 `main_dev_preview.dart` 进行功能开发
2. **模块测试**: 使用对应的预览文件进行独立测试
3. **集成测试**: 使用 `main_dev_VC.dart` 进行完整流程测试
4. **公测发布**: 使用 `main_beta.dart` 进行公开测试
5. **生产发布**: 使用 `main.dart` 进行正式发布

---

*最后更新: 2024年*
*文档版本: 1.0* 