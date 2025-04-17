# 硬编码值待办事项

本文档记录了在代码中临时硬编码的值，这些值需要在后续开发中替换为动态获取或配置的逻辑。

## 1. 文件上传请求头

**文件路径**: `lib/core/network/dio_http_client.dart`
**方法**: `postMultipart`

**硬编码值**:

*   **`Authorization` Header**:
    *   当前值: `eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjMwZmZjY2YxLWFjNDUtNGM3OS04MjJiLTliNzM0MDZjZjdkYiJ9.g0FkPdnBuvpsirksABX04FrQLTjn-qgbLwRE9QLJOW6Df5syAdTGLn0IhpUYMDRaefbFQ49MWnL5wYUMRtMuiQ`
    *   **待办**: 需要替换为从用户认证状态（例如，登录后保存的 Token）动态获取的逻辑。

*   **`version` Header**:
    *   当前值: `'100'`
    *   **待办**: 需要确认这个值是固定的，还是应该从 `package_info_plus` 获取 `packageInfo.version` 或 `packageInfo.buildNumber`，然后替换硬编码值。

**原因**:
这些值是根据 API 文档或示例请求临时添加的，以使文件上传功能能够通过后端验证。

**负责人**: (请分配给相关开发人员)
**预计完成日期**: (请设置日期)