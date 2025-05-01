# Auth 模块说明文档

## 1. 模块概述 (Brief Overview)

**一句话描述:** 处理用户认证流程，包括短信验证码登录、Token管理、用户信息获取和会话管理。

**主要功能点:**
- 手机号+验证码登录
- 发送短信验证码
- 会话状态管理（Token处理）
- 自动登录/登出处理
- 用户信息获取

## 2. 路由入口与参数 (Routing Entry Points & Parameters)

**如何进入本模块:**
- **路径:** `/login`
- **名称:** 无特定名称，通过go_router直接导航

**必需参数:**
- 无需参数，通过点击"我的"页面中的登录按钮或需要登录权限的功能时，将自动跳转到登录页面。

## 3. 外部依赖说明 (External Dependencies)

**核心服务依赖:**
- `ISecureStorageRepository` (存储和检索用户认证信息，如token和userId)
- `NetworkInfo` (检查网络连接状态)
- `TokenValidator` (验证token有效性)
- `DioClient` (通过Repository间接依赖，用于网络请求)
- `INavigationService` (在登录/登出后导航)

**跨模块依赖:**
- 暂无直接依赖其他feature模块

## 4. 调用的主要 API (APIs Consumed)

**接口列表:**
- `POST /api/auth/login` (短信验证码登录API)
- `POST /api/common/send-code/register` (发送验证码API)
- `GET /api/member/info` (获取用户信息API，同时用于验证Token有效性)

**注意事项:**
- 登录API(`/api/auth/login`)响应会包含token
- 用户信息API(`/api/member/info`)响应包含用户ID及各种用户详情
- 发送验证码API需要在header中添加设备信息(`clienttype`, `client`, `version`)

## 5. 对外暴露的服务/接口 (Exposed Services/Interfaces)

本模块对外暴露以下接口供其他模块使用:

- **IAuthRepository:**
  - `Stream<AuthStatus> get authStatus` - 获取认证状态流，可观察登录状态变化
  - `Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(...)` - 使用验证码登录
  - `Future<Either<Failure, void>> logout()` - 登出当前用户
  - `Future<Either<Failure, void>> sendVerificationCode(...)` - 发送验证码
  - `Either<Failure, AuthenticatedUser?> getLoggedInUserSync()` - 同步获取当前登录用户

- **IUserInfoRepository:**
  - `Future<Either<Failure, UserInfo>> fetchUserInfo(String token)` - 获取用户信息

## 6. 注意事项/配置要求

- 需要在`.env`文件中配置`BACKEND_BASE_URL`环境变量
- 当前实现中，`UserInfoRemoteDataSourceImpl`和`UserInfoRepositoryImpl`暂时在Auth模块中实现，后续可能会迁移到Core/Profile模块
- 本模块存储了三个关键信息:
  - `user_id` - 用户主ID
  - `auth_token` - 认证令牌
  - `common_user_id` - 用户CommonID（用于某些业务场景）

## 7. 依赖包使用说明 (Package Dependencies)

- `flutter_bloc: ^8.1.5` - 用于状态管理，在所有Cubit/Bloc文件中使用
- `dartz: ^0.10.1` - 用于函数式编程和Either类型，在所有Repository和UseCase中使用
- `injectable: ^2.4.1` - 用于依赖注入，在所有需要注入的类中使用
- `get_it: ^7.7.0` - 服务定位器，用于获取依赖实例
- `flutter_secure_storage: ^9.2.2` - 用于安全存储认证信息，在SecureStorageRepositoryImpl中使用
- `connectivity_plus: ^6.0.3` - 用于检查网络连接状态，在NetworkInfoImpl中使用
- `dio: ^5.8.0+1` - 用于网络请求，在所有RemoteDataSource实现中使用
- `equatable: ^2.0.5` - 简化相等性比较，在所有实体和状态类中使用
- `freezed_annotation: ^2.4.1` - 用于数据类生成，在所有model类中使用

## 8. 资源管理说明 (Resource Management)

**模块资源列表:**
- 本模块不使用特定的图片或图标资源

**资源命名规范:**
- 无特定资源命名规范

**资源存放位置:**
- 无特定资源存放位置

## 9. 已知问题与解决方案 (Known Issues & Solutions)

**已知限制:**
- 验证码发送后只会在控制台打印，实际短信可能无法接收
- 目前仅实现了短信验证码登录，未实现密码登录
- 用户信息字段针对可能为null的情况处理可能不完整

**已解决问题:**
- 验证码无法发送问题: 已通过在请求头中添加设备信息解决
- 用户信息字段空值问题: 已通过修改模型类适配null值解决
- 验证码按钮倒计时结束后不自动恢复问题: 已修复

**开发者注意事项:**
- 注意在使用UserInfo模型时处理可能为null的字段
- 修改Token验证逻辑时需同时更新相关测试

## 10. 跨模块通信机制 (Cross-Module Communication)

**输出事件/通知:**
- 登录状态变化 (`AuthStatus` 流) - 其他需要根据登录状态执行操作的模块可以监听此流

**输入事件/通知:**
- 无特定输入事件

**通信方式:**
- 主要通过依赖注入和流(Stream)实现跨模块通信
- 使用go_router的redirects机制自动根据登录状态重定向页面

**直接依赖:**
- 无直接依赖其他模块，采用依赖注入解耦
