# URL硬编码移除报告

## 执行日期
2025-08-08

## 概述
已成功移除Flutter项目中所有硬编码的URL回退逻辑，改为严格从环境变量获取配置。应用程序现在在缺少必需的环境变量时会明确失败，而不是使用可能不安全的默认值。

## 主要改动

### 1. 新增配置验证器
**文件**: `lib/core/config/config_validator.dart`
- 创建了专门的配置验证器类
- 定义了必需的环境变量列表（BACKEND_BASE_URL, MODEL_BASE_URL）
- 提供了验证和获取环境变量的方法
- 在环境变量缺失时抛出明确的异常

### 2. 移除的硬编码URL

#### 核心配置文件
- **lib/core/config/region_config.dart**
  - 移除: `'https://app.duoshaokankan.com/prod-api'`
  - 移除: `'http://47.113.230.11:5107'`
  
- **lib/core/config/app_config.dart**
  - 移除: `'ws://47.113.230.11:5102'`
  - 改为动态从BACKEND_BASE_URL派生WebSocket URL

- **lib/core/network/dio_http_client.dart**
  - 移除: `'http://47.113.230.11:5107'`

#### 主入口文件
- **lib/main.dart**
- **lib/main_domestic.dart**
- **lib/main_domestic_dev.dart**
- **lib/main_international.dart**
- **lib/main_international_dev.dart**
  - 全部移除硬编码回退，改用ConfigValidator验证

#### 功能模块
- **lib/features/home/di/home_di.dart**
  - 移除: `'https://app.duoshaokankan.com/prod-api'`

- **lib/features/home/presentation/pages/search_page.dart**
  - 移除硬编码回退

- **lib/features/ai_docs/data/datasources/**
  - file_upload_data_source_impl.dart
  - ai_docs_file_upload_data_source_impl.dart
  - 移除: `'http://fallback-backend-url'`

- **lib/features/chat/data/datasources/**
  - chat_remote_data_source.impl.dart
  - file_remote_data_source.impl.dart
  - chat_web_socket_data_source.impl.dart
  - 移除: `'http://app.duoshaokankan.com/prod-api'`
  - 移除: `'ws://app.duoshaokankan.com/prod-api'`

- **lib/core/network/core_web_socket_service_impl.dart**
  - 移除WebSocket硬编码URL

- **lib/features/payment/di/payment_di.dart**
  - 移除: `'https://app.duoshaokankan.com/prod-api'`

- **lib/features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart**
  - 移除: `"http://app.duoshaokankan.com/prod-api"`

#### 模型文件
- **lib/features/home/data/models/banner_model.dart**
- **lib/features/home/data/models/home_feed_item_model.dart**
  - 改为从环境变量动态获取基础URL

### 3. 环境变量文档更新
**文件**: `.env.example`
- 添加了详细的配置说明
- 明确标注了必需和可选的环境变量
- 提供了配置示例和注意事项

## 必需的环境变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| BACKEND_BASE_URL | 后端API基础URL | https://app.duoshaokankan.com/prod-api |
| MODEL_BASE_URL | AI模型服务URL | http://your-model-server.com:5107 |

## 可选的环境变量

| 变量名 | 说明 | 默认行为 |
|--------|------|----------|
| WECHAT_APP_ID | 微信App ID | 微信功能不可用 |
| WECHAT_UNIVERSAL_LINK | 微信通用链接 | iOS微信功能不可用 |
| INTERNATIONAL_API_URL | 国际服API URL | 使用BACKEND_BASE_URL |
| INTERNATIONAL_MODEL_URL | 国际服模型URL | 使用MODEL_BASE_URL |
| WEBSOCKET_BASE_URL | WebSocket URL | 从BACKEND_BASE_URL派生 |

## 迁移指南

### 对于开发者
1. 确保`.env`文件包含所有必需的环境变量
2. 不要提交实际的`.env`文件到版本控制
3. 使用`.env.example`作为模板

### 对于部署
1. 在生产环境中设置所有必需的环境变量
2. 使用HTTPS/WSS协议确保安全
3. 不要在URL末尾添加斜杠

## 错误处理
当必需的环境变量缺失时，应用将：
1. 抛出`ConfigurationException`异常
2. 显示明确的错误信息
3. 打印配置帮助信息
4. 阻止应用启动

## 未修改的文件
以下文件包含硬编码URL但未修改（因为是mock或测试文件）：
- `lib/features/profile/data/datasources/mock_profile_remote_data_source.dart` - Mock数据源，硬编码可接受
- `lib/archived_entries/**` - 存档文件，不在主要代码路径中

## 验证步骤
1. 删除`.env`文件中的BACKEND_BASE_URL，应用应该无法启动
2. 删除`.env`文件中的MODEL_BASE_URL，应用应该无法启动
3. 提供正确的环境变量，应用应该正常工作
4. WebSocket连接应该自动使用正确的协议（ws/wss）

## 建议
1. 在CI/CD流程中添加环境变量检查
2. 考虑使用密钥管理服务存储敏感配置
3. 定期审计代码以防止新的硬编码URL
4. 为不同环境（开发、测试、生产）维护不同的配置文件

## 结论
项目现在更加安全和可配置。所有关键的URL配置都通过环境变量管理，消除了意外连接到错误服务器的风险。这种改变使得应用更适合生产环境部署。