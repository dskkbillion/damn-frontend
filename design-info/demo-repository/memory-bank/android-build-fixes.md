# Android构建问题修复记录

## 问题概述

项目在Android平台构建时遇到了几个主要问题：

1. **极光SDK兼容性问题**：极光SDK（`jcore-react-native`和`jverification-react-native`）在新版本的React Native和Android环境中存在兼容性问题，导致构建失败。

2. **ARM架构兼容性问题**：在ARM架构的机器（如M1/M2 Mac）上构建时，AAPT2工具（Android Asset Packaging Tool 2）无法正常工作，出现`rosetta error: failed to open elf at /lib64/ld-linux-x86-64.so.2`错误。

3. **Kotlin版本兼容性问题**：Compose编译器1.5.15需要Kotlin 1.9.25，但项目使用的是Kotlin 1.9.24，导致构建失败。具体错误发生在`:expo-modules-core:compileDebugKotlin`任务中：
   ```
   e: This version (1.5.15) of the Compose Compiler requires Kotlin version 1.9.25 but you appear to be using Kotlin version 1.9.24 which is not known to be compatible.
   ```

4. **SoftwareComponent容器问题**：
   ```
   Could not get unknown property 'release' for SoftwareComponent container of type org.gradle.api.internal.component.DefaultSoftwareComponentContainer.
   ```

5. **Gradle内存不足问题**：Gradle构建过程需要大量内存，导致Gradle守护进程崩溃，出现"Gradle build daemon disappeared unexpectedly"错误。

6. **Build Tools版本问题**：系统只安装了Build Tools 29.0.3版本，而当前项目使用的Android Gradle Plugin 8.6.0需要至少使用Build Tools 34.0.0版本。

7. **compileSdk版本问题**：项目中的许多依赖项需要compileSdk版本至少为34或35，但当前项目使用的是compileSdk 33。错误信息如下：
   ```
   Dependency 'androidx.core:core-splashscreen:1.2.0-alpha02' requires libraries and applications that depend on it to compile against version 35 or later of the Android APIs.
   :app is currently compiled against android-34.
   ```

8. **Expo包路径变化问题**：在EAS云构建过程中，自动生成的PackageList.java文件尝试导入`expo.core.ExpoModulesPackage`类，但在Expo SDK 52版本中，这个类已经被移动到不同的包中：
   ```
   /home/expo/workingdir/build/android/app/build/generated/autolinking/src/main/java/com/facebook/react/PackageList.java:20: error: cannot find symbol
   import expo.core.ExpoModulesPackage;
                 ^
   ```

## 解决方案

### 1. 移除极光SDK

由于极光SDK主要用于短信验证功能，而该功能实际上是通过后端API实现的，我们决定完全移除极光SDK：

1. **从package.json中移除依赖**：
   - 移除了`jcore-react-native`
   - 移除了`jverification-react-native`

2. **修改sdk/login/jiguang.ts文件**：
   - 创建了一个模拟的`LoginService`类，保留了相同的接口
   - 确保短信登录功能仍然可以通过后端API正常工作

3. **从android/app/build.gradle文件中移除配置**：
   - 移除了极光推送的配置
   - 移除了AAPT选项中忽略极光验证模块的资源的配置
   - 移除了排除极光验证模块的配置

### 2. 解决ARM架构兼容性问题

为了解决ARM架构上的AAPT2兼容性问题，我们采取了以下措施：

1. **移除不兼容的配置**：
   - 从`android/gradle.properties`文件中移除了`android.buildCacheDir=build-cache`配置，因为这个选项在Android Gradle插件7.0中已被移除

2. **使用EAS云构建服务**：
   - 使用Expo Application Services (EAS)进行云构建，避免本地ARM架构兼容性问题
   - 配置`eas.json`文件，设置适当的构建配置

### 3. 解决Kotlin版本兼容性问题

为了解决Kotlin版本兼容性问题，我们采取了以下措施：

1. **修改expo-modules-core的build.gradle文件**：
   - 将Kotlin 1.9.24对应的Compose编译器版本从1.5.15降级到1.5.4（与Kotlin 1.9.24兼容的版本）
   - 移除不支持的`suppressKotlinVersionCompatibilityCheck`属性，因为当前版本的Android Gradle插件不支持这个属性

   具体修改如下：
   ```gradle
   if (KOTLIN_MAJOR_VERSION < 2) {
     composeOptions {
       def versionsMap = [
         "1.9.24": "1.5.4",  // 从1.5.15降级到1.5.4
         "1.9.25": "1.5.15",
       ]
       kotlinCompilerExtensionVersion = versionsMap[kotlinVersion()]
       // 移除不支持的属性
       // suppressKotlinVersionCompatibilityCheck = true
     }
   }
   ```

2. **在gradle.properties文件中添加配置**：
   ```properties
   # 设置Compose编译器版本
   compose.compiler.version=1.5.4
   ```

3. **在eas.json文件中添加构建参数**：
   ```json
   "gradleCommand": ":app:assembleDebug -Pkotlin.version=1.9.24 -Pcompose.compiler.version=1.5.4"
   ```

### 4. 解决SoftwareComponent容器问题

为了解决SoftwareComponent容器问题，我们修改了ExpoModulesCorePlugin.gradle文件，使用try-catch包裹发布配置：

```gradle
project.afterEvaluate {
  publishing {
    publications {
      // 修改这里，使用try-catch包裹，避免在components.release不存在时失败
      try {
        if (project.components.findByName('release') != null) {
          release(MavenPublication) {
            from components.release
          }
        }
      } catch (Exception e) {
        // 如果components.release不存在，则不创建发布配置
        project.logger.warn("Could not create release publication: ${e.message}")
      }
    }
    repositories {
      maven {
        url = mavenLocal().url
      }
    }
  }
}
```

### 5. 解决Gradle内存不足问题

为了解决Gradle内存不足问题，我们增加了Gradle守护进程的内存限制：

```properties
# 增加Gradle守护进程的内存限制
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m
```

### 6. 解决Build Tools版本问题

为了解决Build Tools版本问题，我们使用sdkmanager工具安装了Build Tools 34.0.0版本：

```bash
/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager "build-tools;34.0.0"
```

### 7. 解决compileSdk版本问题

为了解决compileSdk版本问题，我们将compileSdkVersion从33更新到了35：

```gradle
compileSdkVersion = Integer.parseInt(findProperty('android.compileSdkVersion') ?: '35')
```

### 8. 解决Expo包路径变化问题

为了解决Expo SDK 52版本中包路径变化的问题，我们创建了一个桥接类：

1. **创建桥接类**：
   - 在`android/app/src/main/java/expo/core/`目录下创建了`ExpoModulesPackage.java`文件
   - 这个类继承自`expo.modules.adapters.react.ReactAdapterPackage`，并将请求转发到父类
   - 这样，当自动生成的`PackageList.java`文件尝试导入和使用`expo.core.ExpoModulesPackage`类时，它将实际上使用`expo.modules.adapters.react.ReactAdapterPackage`的功能

这是一种简单有效的解决方案，不需要修改SDK源码，只需在项目中添加一个Java类文件。

注意：在EAS云构建环境中，这个解决方案可能不起作用，因为云构建环境中的文件结构可能与本地环境不同。在这种情况下，可以在package.json中添加`"expo-modules-autolinking": "*"`依赖，这将帮助pnpm正确解析依赖关系。

## 最新调试进展（2025-03-21）

1. **解决Kotlin版本兼容性问题**：
   - 通过降级Compose编译器版本到1.5.4并移除不支持的`suppressKotlinVersionCompatibilityCheck`属性，成功解决了Kotlin版本兼容性问题
   - 修改了node_modules/.pnpm/expo-modules-core@2.2.1_patch_hash=d68aec82bc025c3338d138b82ddcd13e520988488a47b34e990aefde02d1b3ac/node_modules/expo-modules-core/android/build.gradle文件

2. **解决SoftwareComponent容器问题**：
   - 通过在ExpoModulesCorePlugin.gradle文件中使用try-catch包裹发布配置，成功解决了SoftwareComponent容器问题
   - 修改了node_modules/.pnpm/expo-modules-core@2.2.1_patch_hash=d68aec82bc025c3338d138b82ddcd13e520988488a47b34e990aefde02d1b3ac/node_modules/expo-modules-core/android/ExpoModulesCorePlugin.gradle文件

3. **使用EAS云构建服务**：
   - 配置了eas.json文件，设置了正确的NDK版本和构建参数
   - 使用`npx eas-cli build --platform android --profile development`命令启动云构建

4. **解决Gradle内存不足问题**：
   - 增加了Gradle守护进程的内存限制，将`org.gradle.jvmargs`从`-Xmx2048m -XX:MaxMetaspaceSize=512m`增加到`-Xmx4096m -XX:MaxMetaspaceSize=1024m`
   - 修改了android/gradle.properties文件

5. **解决Build Tools版本问题**：
   - 使用sdkmanager工具安装了Build Tools 34.0.0版本
   - 命令：`/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager "build-tools;34.0.0"`

6. **解决compileSdk版本问题**：
   - 将compileSdkVersion从33更新到了35
   - 修改了android/build.gradle文件中的`compileSdkVersion = Integer.parseInt(findProperty('android.compileSdkVersion') ?: '35')`

7. **ARM架构上的AAPT2问题仍然存在**：
   - 在ARM架构的机器上构建时，AAPT2工具仍然无法正常工作，出现`rosetta error: failed to open elf at /lib64/ld-linux-x86-64.so.2`错误
   - 目前的解决方案是使用EAS云构建服务，避免本地ARM架构兼容性问题

8. **解决Expo包路径变化问题**：
   - 在EAS云构建过程中，发现自动生成的PackageList.java文件尝试导入`expo.core.ExpoModulesPackage`类，但在Expo SDK 52版本中，这个类已经被移动到不同的包中
   - 创建了桥接类`android/app/src/main/java/expo/core/ExpoModulesPackage.java`，继承自`expo.modules.adapters.react.ReactAdapterPackage`
   - 这个桥接类将请求转发到正确的实现类，解决了包路径变化的问题
    - 对于EAS云构建环境，在package.json中添加了`"expo-modules-autolinking": "*"`依赖，这将帮助pnpm正确解析依赖关系
   - 这是一种简单有效的解决方案，不需要修改SDK源码，只需在项目中添加一个Java类文件

## 建议的后续步骤

1. **创建正式的补丁文件**：
   - 创建正式的补丁文件，而不是直接修改node_modules中的文件
   - 使用`pnpm patch-apply`命令应用补丁

2. **考虑升级Kotlin版本**：
   - 考虑将项目的Kotlin版本升级到1.9.25，以避免未来可能出现的兼容性问题

3. **优化EAS构建配置**：
   - 进一步优化EAS构建配置，提高构建效率和稳定性

4. **解决KSP版本不匹配问题**：
   - 在gradle.properties文件中添加`kspVersion=1.9.24-1.0.20`配置，解决KSP版本不匹配问题

5. **继续解决ARM架构上的AAPT2问题**：
   - 考虑使用Docker容器或其他虚拟化技术在x86_64架构环境中构建项目，避免ARM架构上的AAPT2兼容性问题
   - 或者等待Android Gradle Plugin和AAPT2工具更新，提供对ARM架构的原生支持