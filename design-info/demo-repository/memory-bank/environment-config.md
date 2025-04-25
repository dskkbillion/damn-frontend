# React Native项目环境配置指南

## 概述

本文档详细记录了项目的环境依赖配置，包括Kotlin版本、Compose编译器版本、KSP版本、compileSdk版本、Build Tools版本等。这些配置对于项目的构建和运行至关重要，特别是在使用EAS云构建服务时。

## 关键环境变量和配置

### 1. Kotlin版本配置

Kotlin版本是项目中最关键的配置之一，它影响着Compose编译器版本和KSP版本的选择。

| 配置文件 | 配置项 | 值 |
|---------|-------|-----|
| android/build.gradle | kotlinVersion | 1.9.24 |
| gradle.properties | android.kotlinVersion | 1.9.24 |
| eas.json | env.KOTLIN_VERSION | 1.9.24 |
| eas.json | gradleCommand参数 | -Pkotlin.version=1.9.24 |
| ExpoModulesCorePlugin.gradle | 默认kotlinVersion | 1.9.24 |

**注意事项**：
- 所有文件中的Kotlin版本必须保持一致，否则会导致构建失败
- 如果需要升级Kotlin版本，必须同时更新所有相关配置

### 2. Compose编译器版本配置

Compose编译器版本必须与Kotlin版本兼容，否则会导致构建失败。

| 配置文件 | 配置项 | 值 |
|---------|-------|-----|
| android/app/build.gradle | kotlinCompilerExtensionVersion | 1.5.4 |
| gradle.properties | compose.compiler.version | 1.5.4 |
| eas.json | gradleCommand参数 | -Pcompose.compiler.version=1.5.4 |
| expo-modules-core/build.gradle | versionsMap["1.9.24"] | 1.5.4 |

**Kotlin版本与Compose编译器版本对应关系**：
- Kotlin 1.9.24 → Compose编译器 1.5.4
- Kotlin 1.9.25 → Compose编译器 1.5.15

**注意事项**：
- 使用不兼容的Compose编译器版本会导致构建失败，错误信息如下：
  ```
  e: This version (1.5.15) of the Compose Compiler requires Kotlin version 1.9.25 but you appear to be using Kotlin version 1.9.24 which is not known to be compatible.
  ```
- 我们已经修改了expo-modules-core/build.gradle文件，将Kotlin 1.9.24对应的Compose编译器版本从1.5.15降级到1.5.4

### 3. KSP版本配置

KSP（Kotlin Symbol Processing）版本必须与Kotlin版本兼容。

| 配置文件 | 配置项 | 值 |
|---------|-------|-----|
| gradle.properties | kspVersion | 1.9.24-1.0.20 |
| eas.json | gradleCommand参数 | -PkspVersion=1.9.24-1.0.20 |
| ExpoModulesCorePlugin.gradle | kspVersionsMap | 根据kotlinVersion获取 |

**Kotlin版本与KSP版本对应关系**：
- Kotlin 1.9.24 → KSP 1.9.24-1.0.20
- Kotlin 1.9.25 → KSP 1.9.25-1.0.20

### 4. compileSdk版本配置

compileSdk版本决定了项目可以使用的Android API级别。

| 配置文件 | 配置项 | 值 |
|---------|-------|-----|
| android/build.gradle | compileSdkVersion | 35 |
| ExpoModulesCorePlugin.gradle | compileSdkVersion | 34（如果没有指定） |

**注意事项**：
- 项目中的许多依赖项需要compileSdk版本至少为34或35
- 如果compileSdk版本过低，会导致构建失败，错误信息如下：
  ```
  Dependency 'androidx.core:core-splashscreen:1.2.0-alpha02' requires libraries and applications that depend on it to compile against version 35 or later of the Android APIs.
  ```

### 5. Build Tools版本配置

Build Tools版本决定了项目使用的Android构建工具版本。

| 配置文件 | 配置项 | 值 |
|---------|-------|-----|
| android/build.gradle | buildToolsVersion | 29.0.3（如果没有指定） |

**注意事项**：
- 当前项目使用的Android Gradle Plugin 8.6.0需要至少使用Build Tools 34.0.0版本
- 我们已经使用sdkmanager工具安装了Build Tools 34.0.0版本：
  ```bash
  /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager "build-tools;34.0.0"
  ```

### 6. Gradle内存配置

Gradle构建过程需要大量内存，需要适当增加Gradle守护进程的内存限制。

| 配置文件 | 配置项 | 值 |
|---------|-------|-----|
| android/gradle.properties | org.gradle.jvmargs | -Xmx4096m -XX:MaxMetaspaceSize=1024m |

**注意事项**：
- 如果Gradle内存不足，会导致Gradle守护进程崩溃，出现"Gradle build daemon disappeared unexpectedly"错误
- 在内存受限的环境中，可以适当减小内存限制，但可能会影响构建性能

## EAS云构建配置

EAS（Expo Application Services）云构建服务是一个强大的工具，可以帮助我们避免本地构建环境的限制，特别是ARM架构上的AAPT2兼容性问题。

### eas.json配置

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "android": {
        "buildType": "apk",
        "gradleCommand": ":app:assembleDebug -Pkotlin.version=1.9.24 -Pcompose.compiler.version=1.5.4 -PkspVersion=1.9.24-1.0.20",
        "ndk": "26.1.10909125"
      },
      "env": {
        "KOTLIN_VERSION": "1.9.24",
        "NODE_ENV": "development"
      }
    }
  }
}
```

**关键配置项**：
- `gradleCommand`：指定Gradle构建命令和参数，包括Kotlin版本、Compose编译器版本和KSP版本
- `ndk`：指定NDK版本
- `env`：设置环境变量，包括KOTLIN_VERSION和NODE_ENV

### 使用EAS云构建

使用以下命令启动EAS云构建：

```bash
npx eas-cli build --platform android --profile development
```

这个命令会使用eas.json文件中的development配置来构建项目。构建完成后，可以在EAS控制台上查看构建结果，并下载构建好的APK文件。

## 常见问题和解决方案

### 1. Kotlin版本兼容性问题

**问题**：Compose编译器1.5.15需要Kotlin 1.9.25，但项目使用的是Kotlin 1.9.24。

**解决方案**：
- 将Compose编译器版本从1.5.15降级到1.5.4（与Kotlin 1.9.24兼容）
- 或者将Kotlin版本从1.9.24升级到1.9.25（与Compose编译器1.5.15兼容）

### 2. SoftwareComponent容器问题

**问题**：
```
Could not get unknown property 'release' for SoftwareComponent container of type org.gradle.api.internal.component.DefaultSoftwareComponentContainer.
```

**解决方案**：
- 在ExpoModulesCorePlugin.gradle文件中使用try-catch包裹发布配置：
  ```gradle
  try {
    if (project.components.findByName('release') != null) {
      release(MavenPublication) {
        from components.release
      }
    }
  } catch (Exception e) {
    project.logger.warn("Could not create release publication: ${e.message}")
  }
  ```

### 3. ARM架构上的AAPT2问题

**问题**：在ARM架构的机器（如M1/M2 Mac）上构建时，AAPT2工具无法正常工作，出现`rosetta error: failed to open elf at /lib64/ld-linux-x86-64.so.2`错误。

**解决方案**：
- 使用EAS云构建服务，避免本地ARM架构兼容性问题
- 或者使用Docker容器或其他虚拟化技术在x86_64架构环境中构建项目

## 最佳实践

1. **保持版本一致性**：确保所有配置文件中的版本设置保持一致，特别是Kotlin版本、Compose编译器版本和KSP版本。

2. **使用补丁文件**：创建正式的补丁文件，而不是直接修改node_modules中的文件。使用`pnpm patch-apply`命令应用补丁。

3. **定期更新依赖**：定期更新项目的依赖，包括Kotlin、Compose编译器、KSP等，以获取最新的功能和修复。

4. **使用EAS云构建**：对于复杂的构建环境或ARM架构上的兼容性问题，考虑使用EAS云构建服务。

5. **记录配置变更**：每次修改配置时，记录变更的原因和影响，以便团队成员了解配置的历史和背景。

## 参考资料

- [Kotlin官方文档](https://kotlinlang.org/docs/home.html)
- [Jetpack Compose编译器版本兼容性](https://developer.android.com/jetpack/androidx/releases/compose-kotlin)
- [KSP官方文档](https://kotlinlang.org/docs/ksp-overview.html)
- [EAS云构建文档](https://docs.expo.dev/build/introduction/)
- [Android Gradle Plugin文档](https://developer.android.com/studio/build)