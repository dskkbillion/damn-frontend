plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.duoshaokk.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.duoshaokk.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // 添加支付宝SDK配置
    packagingOptions {
        pickFirst("lib/armeabi-v7a/libentryexpro.so")
        pickFirst("lib/arm64-v8a/libentryexpro.so")
        pickFirst("lib/x86/libentryexpro.so")
        pickFirst("lib/x86_64/libentryexpro.so")
        exclude("META-INF/LICENSE")
        exclude("META-INF/NOTICE")
    }
}

flutter {
    source = "../.."
}

// 添加支持库依赖，避免版本冲突
dependencies {
    // 避免版本冲突
    implementation("com.android.support:support-v4:28.0.0")
    implementation("com.android.support:design:28.0.0")
}
