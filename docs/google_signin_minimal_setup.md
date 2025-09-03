# Google Sign-In 最简配置（仅获取邮箱）

## 目标
仅使用 Google Sign-In 获取用户邮箱地址，无需后端OAuth集成。

## 最小化配置步骤

### 方案1：Android本地配置（推荐，最简单）

#### 1. 获取调试 SHA-1 指纹
```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# 复制输出的 SHA1 值，例如：
# SHA1: DA:39:A3:EE:5E:6B:4B:0D:32:55:BF:EF:95:60:18:90:AF:D8:07:09
```

#### 2. 创建 Google Cloud 项目
1. 访问 [Google Cloud Console](https://console.cloud.google.com)
2. 创建新项目或选择现有项目
3. 启用 Google Sign-In API

#### 3. 创建 OAuth 2.0 客户端 ID
1. 转到"API和服务" → "凭据"
2. 创建凭据 → OAuth 客户端 ID
3. 应用类型选择"Android"
4. 填写：
   - 名称：DSKK Android
   - 包名：`com.duoshaokk.app`
   - SHA-1 证书指纹：（粘贴步骤1的值）
5. 点击创建

#### 4. 创建 Web 客户端 ID（用于 Android）
1. 再次创建凭据 → OAuth 客户端 ID
2. 应用类型选择"Web应用"
3. 名称：DSKK Web Client
4. 保存后复制客户端 ID（格式：xxx.apps.googleusercontent.com）

#### 5. 更新代码
修改 `lib/features/auth/presentation/pages/unified_login_page.dart`：

```dart
// Google Sign In 实例
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
  // 添加你的 Web 客户端 ID
  serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
);
```

### 方案2：使用 Firebase（如果已有 Firebase 项目）

#### 1. Firebase 配置
1. 访问 [Firebase Console](https://console.firebase.google.com)
2. 添加 Android 应用
3. 下载 `google-services.json`
4. 放置到 `android/app/google-services.json`

#### 2. 修改 Gradle 文件

`android/build.gradle.kts`:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

`android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // 添加这行
}
```

## 测试步骤

1. 清理项目：
```bash
flutter clean
flutter pub get
```

2. 运行应用：
```bash
flutter run
```

3. 点击"Google"登录按钮
4. 选择 Google 账号
5. 邮箱会自动填充到输入框

## 常见问题

### Q: ApiException: 10
A: 配置问题，检查：
- SHA-1 指纹是否正确
- 包名是否匹配
- 是否创建了 Web 客户端 ID

### Q: ApiException: 12500  
A: Google Play Services 版本过旧，更新或使用真机

### Q: 不需要 google-services.json 吗？
A: 如果只是获取邮箱，使用方案1可以不需要。但有 Firebase 项目的话，用方案2更稳定。

## 注意事项

- 这个配置仅适用于获取邮箱地址
- 不包含完整的 OAuth 认证流程
- 用户仍需通过邮箱验证码完成登录
- 生产环境需要添加生产 SHA-1 指纹