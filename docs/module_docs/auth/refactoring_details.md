# Auth 模块实现详情

## 模块状态

**状态**: **完成** - 模块核心功能已实现并测试，包括登录、注销、验证码发送等功能，并完成了Token验证逻辑的实现。

**实现周期**: 2024-04 至 2024-05-06

本文档详细说明 `Auth` 模块按照 Flutter Clean Architecture 进行实现的过程和关键决策。实现过程中优先遵循 API 文档设计，并根据实际情况进行了适当调整。

## 实现详情

### 模块边界定义

**核心业务能力:**
- 短信登录 (`/api/auth/login`)
- 验证码发送 (`/api/common/send-code/register`)
- 会话管理 (Token)
- 用户信息获取 (`/api/member/info`)

**核心组件:**
- **Use Cases**:
  - `LoginWithVerificationCodeUseCase`
  - `LogoutUseCase`
  - `SendVerificationCodeUseCase`
  - `GetAuthStatusStreamUseCase`
  - `GetLoggedInUserUseCase`
  - `FetchUserInfoUseCase`

- **Entities**:
  - `AuthenticatedUser` (包含 `token` 和 `id`)
  - `VerificationCodeCredentials`
  - `AuthStatus`
  - `VerificationPurpose`
  - `UserInfo` (基于API响应定义)

- **Repository Interfaces**:
  - `IAuthRepository`
  - `ISecureStorageRepository`
  - `IUserInfoRepository`

### API实现差异

**登录 API (`/api/auth/login`):**
- API文档描述与实际不符: 文档未明确说明响应会包含token
- 实际实现: 响应中包含token，使用token作为认证凭证

**用户信息 API (`/api/member/info`):**
- API文档不完整: 文档缺失`data`对象结构
- 实际实现: 响应包含完整用户信息，包括ID、昵称、手机号等

**登出处理:**
- 无后端Logout API
- 实现方式: 仅在客户端清除token和用户数据

**Token校验:**
- 实现方式: 通过`/api/member/info`接口验证token有效性

### 关键实现决策

1. **用户标识选择**:
   - 使用`/api/member/info`响应中的`id`(int)作为用户唯一标识符
   - 将`token`(String)作为API认证凭证
   - 同时存储commonUserId用于特定业务场景

2. **UserInfo组件临时实现**:
   - 理论上`UserInfoRemoteDataSource`和`UserInfoModel`应在Core/Profile模块
   - 为解除Auth模块依赖阻塞，临时在Auth模块中实现
   - 后续计划迁移至Core/Profile模块

3. **UI设计决策**:
   - 移除Logo显示
   - 调整主题色为`#b66d0e`，按钮颜色为`#c58c4a`
   - 添加底部"隐私政策"和"用户协议"链接
   - 移除AppBar

### API响应示例

**`/api/member/info` 响应结构:**
```json
{
    "msg": "获取成功",
    "code": 200,
    "data": {
        "id": 10302,
        "mobile": "17895868541",
        "nickName": "178****1",
        "gender": "NONE",
        "status": "ENABLE",
        "commonUserId": 10297,
        "onlineFlag": true,
        // 其他字段略
    }
}
```

### 已解决的开发问题

1. **验证码发送问题**:
   - 问题: 验证码无法发送，业务状态码为400，错误信息为"缺少参数包名/版本号"
   - 解决方案: 在请求头中添加`clienttype: '1'`、`client: 'android'`和`version: '100'`参数
   - 改进: 修改验证码和登录方法的错误处理，同时检查HTTP状态码和业务状态码

2. **用户信息获取问题**:
   - 问题: 登录后获取用户信息时出现`TypeError: null: type 'Null' is not a subtype of type 'num'`错误
   - 原因: `UserInfoModel`中`id`字段定义为`required int`，但API返回可能为null
   - 解决方案: 修改字段定义，处理null值情况

3. **验证码按钮状态问题**:
   - 问题: 倒计时结束后按钮未恢复可点击状态
   - 解决方案: 修复了状态管理逻辑

### Token验证实现

Token验证逻辑已实现并测试:
1. 创建了`TokenValidator`接口和实现类，验证Token有效性
2. 创建了`ValidateTokenUseCase`用例，封装验证业务逻辑
3. 更新了初始化认证状态的方法使用Token验证器
4. 添加了完整单元测试，覆盖了各种场景
5. 使所有API请求都包含必要的请求头信息

### 模块预览环境

为方便测试，实现了独立的模块预览环境:
- 创建了`lib/main_auth_preview.dart`作为预览入口点
- 包含独立的依赖注入和模拟实现
- 可通过`flutter run -t lib/main_auth_preview.dart`命令运行

### 待解决问题

1. 更新API文档，反映实际API行为
2. 将`UserInfo`相关实现迁移到Core/Profile模块
3. 完善单元测试，覆盖更多边缘情况
