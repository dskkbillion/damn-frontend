# DSKK Flutter 项目分析报告

## 📋 项目概述

**项目名称**: DSKK Flutter Refactor (多少看看)  
**项目类型**: Flutter 电商应用（从 React Native 重构）  
**开发状态**: 活跃开发中  
**当前分支**: `refactor/light-consultation`  
**Flutter SDK**: >=3.4.0 <4.0.0  
**Dart SDK**: 兼容 Flutter 版本

---

## 🏗️ 架构设计

### 核心架构模式
- **Clean Architecture**: 严格的三层架构分离
  - **Domain Layer**: 业务逻辑、实体、用例、仓库接口
  - **Data Layer**: 仓库实现、数据源、模型/DTO
  - **Presentation Layer**: UI页面、组件、状态管理（BLoC/Cubit）

### 模块化设计
采用**模块化增量重构**策略：
- 每个功能模块独立开发，使用 Mock 依赖进行隔离
- 模块完成后集成到主工程
- 支持模块预览入口点进行独立测试

### 技术栈选型

| 类别 | 技术选型 | 版本 | 理由 |
|------|---------|------|------|
| **状态管理** | Bloc (flutter_bloc) | ^8.1.5 | 事件驱动、可测试性强、成熟稳定 |
| **依赖注入** | get_it + injectable | 7.7.0 + 2.4.1 | 自动化配置、类型安全、降低认知负载 |
| **导航** | go_router | ^14.1.0 | 官方推荐、声明式路由、功能强大 |
| **数据库** | Drift (SQLite ORM) | ^2.26.0 | 类型安全、代码生成、支持迁移 |
| **网络请求** | Dio | ^5.8.0+1 | 功能丰富、拦截器支持 |
| **本地化** | flutter_localizations | SDK | 支持中英文 |

---

## 📦 核心模块

### 已实现模块

1. **auth** (认证模块)
   - 用户登录、注册
   - 微信、Google、Apple 登录支持
   - Token 管理

2. **home** (首页模块)
   - 服务发现
   - 服务列表展示
   - 搜索功能

3. **orders** (订单模块) ⭐ **当前开发重点**
   - 订单列表（买家/卖家）
   - 订单详情页
   - 订单状态管理
   - 轻咨询订单特殊处理（当前分支）
   - 订单操作（支付、取消、确认收货等）

4. **chat** (聊天模块)
   - 实时消息
   - WebSocket 连接
   - 消息队列和离线支持
   - 文件传输

5. **profile** (个人中心)
   - 用户信息管理
   - 钱包功能
   - 账户安全设置
   - 语言设置

6. **seller** (卖家模块)
   - 商品管理
   - 订单管理
   - 统计数据
   - 卖家中心

7. **payment** (支付模块)
   - 支付宝（暂时禁用）
   - 微信支付（暂时禁用）
   - Stripe 信用卡支付
   - 支付状态管理

8. **favorites** (收藏模块)
   - 收藏服务
   - 收藏卖家

9. **after_sales** (售后模块)
   - 售后申请
   - 售后处理流程

10. **ai_docs** (AI文档助手)
    - AI 驱动的文档生成
    - 推荐和分发功能

---

## 🗂️ 项目结构

```
lib/
├── app/                    # 应用核心配置
│   ├── app.dart           # 根Widget
│   ├── di/                # 依赖注入配置
│   ├── navigation/        # 路由配置
│   └── app_mode.dart      # 买家/卖家模式
│
├── core/                   # 核心功能
│   ├── analytics/         # 分析统计
│   ├── cache/             # 缓存系统
│   ├── config/            # 配置管理（区域、主题、语言）
│   ├── currency/          # 货币处理
│   ├── database/          # 数据库（Drift）
│   ├── network/           # 网络层（Dio、拦截器）
│   ├── payment/           # 支付服务抽象
│   ├── services/          # 核心服务（文件上传、图片压缩等）
│   └── widgets/           # 全局组件
│
└── features/              # 功能模块（每个模块包含 domain/data/presentation）
    ├── auth/
    ├── home/
    ├── orders/            # ⭐ 当前开发重点
    ├── chat/
    ├── profile/
    ├── seller/
    ├── payment/
    ├── favorites/
    ├── after_sales/
    └── ai_docs/
```

---

## 🔧 核心配置

### 统一入口点
- **生产入口**: `lib/main_unified.dart`
  - 支持所有支付方式和登录方式
  - 使用 USD（美元）作为统一货币
  - 通过 `.env` 文件配置 API 地址

### 区域配置 (RegionConfig)
支持三种区域模式：
- **domestic** (国服): 人民币、支付宝/微信支付
- **international** (国际服): 美元、Stripe
- **unified** (统一服): 美元、Stripe（当前默认）

### 数据库架构
- **版本**: 7
- **表结构**:
  - `orders`: 订单缓存
  - `chat_messages`: 聊天消息
  - `chat_rooms`: 聊天室
  - `message_queue`: 消息队列（离线消息）

### 环境配置
通过 `.env` 文件配置：
- `BACKEND_BASE_URL`: 后端API地址
- `MODEL_BASE_URL`: AI模型服务地址
- `WECHAT_APP_ID`: 微信应用ID
- `WECHAT_UNIVERSAL_LINK`: 微信通用链接

---

## 📊 当前开发状态

### Git 状态
- **当前分支**: `refactor/light-consultation`
- **修改文件**: `lib/features/orders/presentation/widgets/order_action_buttons.dart`

### 最近提交
1. WebSocket 心跳保活机制优化
2. 主题颜色修复（翻转动画、模式切换）
3. 商品管理页面样式统一
4. AI聊天推荐和分发功能修复
5. 商品详情页交付信息显示优化

### 当前开发重点
**轻咨询订单功能优化**:
- 简化订单操作按钮逻辑
- 针对轻咨询订单类型提供简化的UI流程
- 优化订单详情页的操作体验

---

## 🎯 开发工作流

### 模块开发流程
1. **选择模块** - 基于依赖关系、核心功能、问题优先级
2. **定义模块边界** - 明确职责和对外契约
3. **分析参考代码** - 验证边界，提取实现细节
4. **精化 Domain 层** - 定义实体、用例、仓库接口
5. **实现 Data 层** - 仓库实现、数据源、DTO
6. **实现 Domain 逻辑** - Use Cases 实现
7. **实现 Presentation 层** - UI、状态管理
8. **配置 Mock 依赖** - 隔离开发
9. **编写测试** - 单元测试、Widget测试
10. **模块预览验证** - 独立环境测试
11. **集成准备** - 代码评审、合并准备
12. **执行集成** - 替换Mock为真实实现、集成测试

---

## 🔍 代码质量

### 代码规范
- 使用 `flutter_lints` 进行代码检查
- 排除归档入口文件 (`lib/archived_entries/**`)
- 遵循 Dart/Flutter 最佳实践

### 测试策略
- **单元测试**: Domain 层 Use Cases、Data 层 Repository
- **Widget 测试**: Presentation 层重要组件
- **集成测试**: 模块间交互、E2E测试
- **测试工具**: `bloc_test`, `mockito`

### 代码生成
使用 `build_runner` 生成：
- Freezed (不可变类)
- json_serializable (JSON序列化)
- Drift (数据库代码)
- injectable (依赖注入)

---

## 📱 平台支持

- ✅ **Android**: 完整支持
- ✅ **iOS**: 完整支持
- ✅ **Web**: 基础支持（通过 go_router）
- ✅ **macOS**: 配置存在
- ✅ **Linux**: 配置存在
- ✅ **Windows**: 配置存在

---

## 🌐 国际化

- **支持语言**: 中文（zh）、英文（en）
- **本地化文件**: `lib/l10n/`
- **ARB文件**: `intl_zh.arb`, `intl_en.arb`
- **生成工具**: `flutter gen-l10n`

---

## 🔐 安全特性

- **安全存储**: `flutter_secure_storage` 存储敏感信息（Token）
- **认证拦截器**: 自动添加 Authorization Header
- **HTTPS**: 强制使用 HTTPS 连接
- **环境变量**: 敏感配置通过 `.env` 管理

---

## 📈 性能优化

### 已实施的优化
- **图片缓存**: 限制缓存数量（100张）和内存（50MB）
- **数据库索引**: 聊天消息、订单查询优化索引
- **HTTP缓存**: Dio 缓存拦截器
- **预加载服务**: ProfilePreloaderService 预加载数据
- **批量操作**: 数据库批量插入/更新

### 缓存策略
- **订单列表缓存**: 本地数据库缓存
- **聊天消息缓存**: 本地数据库 + 内存缓存
- **HTTP响应缓存**: Dio 缓存拦截器

---

## 🚀 部署配置

### 构建命令
```bash
# 开发运行
flutter run -t lib/main_unified.dart

# 生产构建 Android
flutter build apk -t lib/main_unified.dart --release

# 生产构建 iOS
flutter build ios -t lib/main_unified.dart --release
```

### 代码生成
```bash
# 生成代码
dart run build_runner build --delete-conflicting-outputs

# 监听模式
dart run build_runner watch --delete-conflicting-outputs
```

---

## 📚 文档资源

### 核心文档
- `CLAUDE.md`: 项目开发指南
- `docs/dev/模块开发核心工作流.md`: 模块开发流程
- `docs/dev/tech_stack.md`: 技术栈说明
- `docs/BD/`: 模块边界定义文档

### API文档
- `design-info/api/`: 后端API文档
- `design-info/HTML原型/`: UI原型参考

---

## ⚠️ 已知问题与限制

1. **支付SDK**: 支付宝（tobias）和微信支付（fluwx）暂时禁用
2. **归档入口**: 多个旧入口文件已归档到 `lib/archived_entries/`
3. **轻咨询订单**: 正在优化中，当前分支专门处理此功能

---

## 🎨 UI/UX 特性

- **主题系统**: 统一的主题配置（`AppTheme.lightTheme`）
- **模式切换**: 买家/卖家模式切换（带翻转动画）
- **响应式设计**: 适配不同屏幕尺寸
- **全局消息通知**: `GlobalMessageNotification` 组件
- **国际化UI**: 支持中英文切换

---

## 🔄 数据流

### 典型数据流
```
UI Event → BLoC Event → Use Case → Repository → DataSource → API/DB
                ↓
         State Update → UI Rebuild
```

### 状态管理流程
1. UI 触发事件
2. BLoC 接收事件
3. 调用 Use Case
4. Use Case 调用 Repository
5. Repository 调用 DataSource
6. 返回结果，更新状态
7. UI 响应状态变化

---

## 📝 开发建议

### 新功能开发
1. 遵循 Clean Architecture 三层分离
2. 先定义 Domain 层接口
3. 使用 Mock 进行隔离开发
4. 编写单元测试
5. 在模块预览环境验证
6. 最后集成到主工程

### 代码提交
- 每个模块在独立分支开发
- 通过 PR/MR 进行代码评审
- 确保测试通过
- 运行 `flutter analyze` 检查

### 问题排查
- 查看 `docs/` 目录下的相关文档
- 检查 `.cursor/rules/` 下的开发规则
- 参考 React Native 原代码和 HTML 原型

---

## 🎯 项目亮点

1. **架构清晰**: Clean Architecture + 模块化设计
2. **开发规范**: 完善的工作流和文档
3. **技术选型**: 成熟稳定的技术栈
4. **国际化支持**: 多语言、多区域配置
5. **性能优化**: 多层次的缓存策略
6. **可测试性**: 良好的测试基础设施

---

## 📞 关键文件索引

| 文件路径 | 说明 |
|---------|------|
| `lib/main_unified.dart` | 统一生产入口 |
| `lib/app/di/injection_container.dart` | 依赖注入配置 |
| `lib/app/navigation/app_router_config.dart` | 路由配置 |
| `lib/core/database/app_database.dart` | 数据库配置 |
| `lib/core/config/region_config.dart` | 区域配置 |
| `pubspec.yaml` | 项目依赖配置 |
| `CLAUDE.md` | 开发指南 |

---

**报告生成时间**: 2024年  
**项目状态**: 活跃开发中  
**建议**: 继续遵循模块化开发流程，保持代码质量和文档更新
