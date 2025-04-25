# 项目配置管理

## 概述

本文档旨在统一讨论项目的配置问题，包括环境配置、依赖管理、构建配置等方面。通过集中管理这些配置信息，我们可以更好地理解项目的结构，避免配置冲突，提高开发和构建效率。

## 当前配置状态

### 1. 环境配置

| 配置项 | 当前值 | 文件位置 | 说明 |
|-------|-------|---------|------|
| Node.js | 18.x+ | package.json engines | 项目需要Node.js 18或更高版本 |
| React Native | 0.76.6 | package.json | 使用最新的React Native版本 |
| Expo SDK | 52.0.27 | package.json | 使用最新的Expo SDK |
| Kotlin | 1.9.24 | android/build.gradle | 需要与Compose编译器版本兼容 |
| Compose编译器 | 1.5.4 | gradle.properties | 与Kotlin 1.9.24兼容的版本 |
| KSP | 1.9.24-1.0.20 | gradle.properties | 与Kotlin 1.9.24兼容的版本 |
| compileSdk | 35 | android/build.gradle | 满足依赖项的要求 |
| Build Tools | 34.0.0 | android/build.gradle | 满足Android Gradle Plugin 8.6.0的要求 |
| NDK | 26.1.10909125 | eas.json | 用于EAS云构建 |

### 2. 依赖管理

项目使用pnpm作为包管理工具，这带来了一些特殊的配置需求：

1. **依赖解析问题**：
   - 在EAS云构建环境中，pnpm的严格依赖解析可能导致某些包无法正确找到
   - 解决方案：在package.json中添加`"expo-modules-autolinking": "*"`依赖

2. **补丁管理**：
   - 使用patch-package为第三方库应用补丁
   - 当前补丁：expo-modules-core（修复Kotlin版本兼容性问题和SoftwareComponent容器问题）

3. **版本覆盖**：
   - 在package.json的resolutions和overrides部分指定特定依赖的版本
   - 主要用于解决依赖冲突和确保使用特定版本的包

### 3. 构建配置

#### Android构建配置

1. **Gradle配置**：
   - 内存设置：`org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m`
   - 并行构建：`org.gradle.parallel=true`
   - 构建缓存：`org.gradle.caching=true`

2. **EAS云构建配置**：
   - 开发版本：使用development配置，构建APK
   - 生产版本：使用production配置，构建App Bundle
   - 构建参数：`-Pkotlin.version=1.9.24 -Pcompose.compiler.version=1.5.4 -PkspVersion=1.9.24-1.0.20`

#### iOS构建配置

1. **Podfile配置**：
   - 使用最新的CocoaPods版本
   - 配置特定的iOS部署目标版本

2. **EAS云构建配置**：
   - 开发版本：支持模拟器
   - 生产版本：针对App Store发布

## 配置问题分类

### 1. 版本兼容性问题

1. **Kotlin与Compose编译器版本兼容性**：
   - 问题：Compose编译器1.5.15需要Kotlin 1.9.25，但项目使用的是Kotlin 1.9.24
   - 解决方案：降级Compose编译器版本到1.5.4
   - 长期解决方案：考虑升级Kotlin版本到1.9.25

2. **KSP版本兼容性**：
   - 问题：KSP版本需要与Kotlin版本匹配
   - 解决方案：设置kspVersion=1.9.24-1.0.20
   - 配置位置：gradle.properties

3. **React Native与Expo兼容性**：
   - 确保React Native版本与Expo SDK版本兼容
   - 当前状态：React Native 0.76.6与Expo SDK 52.0.27兼容

### 2. 构建环境问题

1. **ARM架构兼容性问题**：
   - 问题：在ARM架构的机器上构建时，AAPT2工具无法正常工作
   - 临时解决方案：使用EAS云构建服务
   - 长期解决方案：等待Android Gradle Plugin和AAPT2工具更新，提供对ARM架构的原生支持

2. **Gradle内存问题**：
   - 问题：Gradle构建过程需要大量内存，导致Gradle守护进程崩溃
   - 解决方案：增加Gradle守护进程的内存限制
   - 配置位置：android/gradle.properties

3. **Build Tools版本问题**：
   - 问题：Android Gradle Plugin 8.6.0需要至少使用Build Tools 34.0.0版本
   - 解决方案：安装Build Tools 34.0.0版本
   - 命令：`sdkmanager "build-tools;34.0.0"`

### 3. 依赖解析问题

1. **pnpm依赖解析问题**：
   - 问题：在EAS云构建环境中，pnpm的严格依赖解析可能导致某些包无法正确找到
   - 解决方案：在package.json中添加`"expo-modules-autolinking": "*"`依赖
   - 替代方案：在.npmrc中添加`node-linker=hoisted`配置（不适用于monorepo）

2. **Expo包路径变化问题**：
   - 问题：在Expo SDK 52版本中，`ExpoModulesPackage`类的路径发生了变化
   - 解决方案：创建桥接类和添加expo-modules-autolinking依赖
   - 文件位置：android/app/src/main/java/expo/core/ExpoModulesPackage.java

## 配置最佳实践

### 1. 版本管理

1. **保持版本一致性**：
   - 确保所有配置文件中的版本设置保持一致，特别是Kotlin版本、Compose编译器版本和KSP版本
   - 使用gradle.properties和eas.json中的环境变量统一管理版本

2. **定期更新依赖**：
   - 定期更新项目的依赖，包括Kotlin、Compose编译器、KSP等
   - 更新前先测试兼容性，避免引入新的问题

3. **版本锁定**：
   - 使用pnpm-lock.yaml锁定依赖版本
   - 对于关键依赖，在package.json的resolutions和overrides部分指定版本

### 2. 补丁管理

1. **创建正式的补丁文件**：
   - 使用`pnpm patch-create`创建正式的补丁文件
   - 使用`pnpm patch-apply`应用补丁，而不是直接修改node_modules中的文件

2. **记录补丁信息**：
   - 在文档中记录每个补丁的目的、修改内容和影响
   - 定期检查补丁是否仍然需要，是否可以通过升级依赖来解决

### 3. 构建配置

1. **使用EAS云构建服务**：
   - 对于复杂的构建环境或ARM架构上的兼容性问题，使用EAS云构建服务
   - 配置多个构建配置，满足不同的需求（开发、测试、生产）

2. **优化构建性能**：
   - 启用Gradle并行构建和构建缓存
   - 增加Gradle守护进程的内存限制
   - 使用增量构建，减少构建时间

3. **环境变量管理**：
   - 使用eas.json中的env部分管理环境变量
   - 对于敏感信息，使用EAS的密钥管理功能

## 未来优化方向

### 1. 技术栈升级

1. **升级Kotlin版本**：
   - 考虑将项目的Kotlin版本升级到1.9.25，以避免未来可能出现的兼容性问题
   - 升级后可以使用最新的Compose编译器版本1.5.15

2. **升级React Native和Expo**：
   - 跟踪React Native和Expo的最新版本
   - 评估升级的收益和风险，制定升级计划

### 2. 构建系统优化

1. **优化EAS构建配置**：
   - 进一步优化EAS构建配置，提高构建效率和稳定性
   - 探索EAS的高级功能，如自动化构建和发布

2. **解决ARM架构上的AAPT2问题**：
   - 跟踪Android Gradle Plugin和AAPT2工具的更新
   - 探索其他解决方案，如使用Docker容器或其他虚拟化技术

### 3. 依赖管理优化

1. **依赖审计**：
   - 定期审计项目依赖，移除不必要的依赖
   - 使用工具检测依赖冲突和安全漏洞

2. **monorepo优化**：
   - 如果项目是monorepo，优化pnpm的配置
   - 考虑使用工作区功能，提高依赖管理效率

## 结论

项目配置管理是一个持续的过程，需要团队成员的共同参与和维护。通过本文档，我们希望能够统一项目的配置管理，提高开发和构建效率，减少配置问题带来的困扰。

我们将定期更新本文档，反映项目配置的最新状态和最佳实践。如有任何建议或问题，请与团队成员讨论。