# Google Sign-In 配置指南

## 问题诊断
错误代码 `ApiException: 10` 表示 Google Sign-In 配置缺失或不正确。

## 配置步骤

### 1. Firebase 项目设置

1. 访问 [Firebase Console](https://console.firebase.google.com)
2. 创建新项目或选择现有项目
3. 点击"添加应用" → 选择 Android
4. 填写以下信息：
   - Android 包名：`com.duoshaokk.app`
   - 应用昵称：多少看看
   - SHA-1 证书指纹（调试版）：运行以下命令获取
   
   ```bash
   # Windows
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   
   # Mac/Linux
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

5. 下载 `google-services.json` 文件

### 2. 添加配置文件

将 `google-services.json` 文件放置到：
```
android/app/google-services.json
```

### 3. 修改 Gradle 配置

#### 修改 `android/build.gradle.kts`：

```kotlin
buildscript {
    dependencies {
        // 添加 Google Services 插件
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
// ... 其他配置保持不变
```

#### 修改 `android/app/build.gradle.kts`：

在文件顶部的 plugins 块中添加：
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // 添加 Google Services 插件
    id("com.google.gms.google-services")
}
```

### 4. 启用 Google Sign-In API

1. 在 [Google Cloud Console](https://console.cloud.google.com) 中
2. 选择你的项目
3. 转到"API和服务" → "启用的API"
4. 搜索并启用 "Google Sign-In API"

### 5. 配置 OAuth 2.0 客户端

1. 在 Firebase Console 中，进入"身份验证" → "登录方法"
2. 启用 "Google" 登录提供方
3. 记录 Web 客户端 ID（格式：xxx.apps.googleusercontent.com）
4. 在代码中更新客户端 ID：

修改 `lib/features/auth/presentation/pages/unified_login_page.dart`：

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
  // 添加你的 Web 客户端 ID
  serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
);
```

### 6. 测试配置

1. 清理并重新构建项目：
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. 测试 Google 登录功能

## 常见问题

### Q: 仍然收到 ApiException: 10
A: 检查以下几点：
- 确保 SHA-1 指纹已添加到 Firebase
- 确保包名完全匹配
- 确保 google-services.json 是最新的
- 清理项目并重新构建

### Q: 收到 ApiException: 12500
A: 表示需要更新 Google Play Services，在模拟器上更新或使用真机测试

### Q: 登录后没有返回用户信息
A: 检查是否正确配置了 serverClientId

## 生产环境配置

发布应用前，需要：
1. 添加生产环境的 SHA-1 指纹到 Firebase
2. 在 Google Play Console 中配置 OAuth 同意屏幕
3. 更新隐私政策和服务条款链接