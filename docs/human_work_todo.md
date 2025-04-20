# 手动操作待办事项

本文档记录在 AI 辅助开发过程中，需要开发者手动完成的操作。

1.  **配置 `image_picker` 平台权限**

    - **原因**: 添加 `image_picker` 包后，需要在 iOS 和 Android 项目中声明使用相册和相机的权限，否则应用在尝试访问时会崩溃或无法正常工作。
    - **操作**:
      - **iOS**: 编辑 `ios/Runner/Info.plist` 文件，添加 `NSPhotoLibraryUsageDescription` (相册) 和 `NSCameraUsageDescription` (相机) 键，并提供用户将看到的权限请求说明文字。
      - **Android**: 编辑 `android/app/src/main/AndroidManifest.xml` 文件，根据需要添加 `<uses-permission android:name="android.permission.CAMERA" />` 和/或处理存储权限 (对于较新 Android 版本，可能不需要显式文件权限，但相机权限通常需要)。
    - **参考**: 详细的键名和配置方法请参考 `image_picker` 包在 pub.dev 上的官方文档。

2.  **配置 `record` 和 `permission_handler` 平台权限 (麦克风)**
    - **原因**: 添加 `record` 和 `permission_handler` 包后，需要声明使用麦克风的权限。
    - **操作**:
      - **iOS**: 编辑 `ios/Runner/Info.plist` 文件，添加 `NSMicrophoneUsageDescription` 键，并提供用户将看到的权限请求说明文字。
      - **Android**: 编辑 `android/app/src/main/AndroidManifest.xml` 文件，添加 `<uses-permission android:name="android.permission.RECORD_AUDIO" />` 权限。对于 Android 12 及以上，如果需要蓝牙麦克风，可能还需要 `BLUETOOTH_CONNECT` 权限。
    - **参考**: 参考 `record` 和 `permission_handler` 包的官方文档。
