# TestFlight 发布交接清单

## 当前已准备完成

- 分支：`dev`
- Bundle ID：`com.duoshaokankan.weapp`
- Team ID：`WXR72K6438`
- 版本：`1.0.0 (202607121)`
- Release 环境：`.env.staging`
- staging API：`https://deep-stream.ai/prod-api`
- App Icon：使用 `assets/icons/nav/dskk_logo.svg` 生成白底冰蓝标记；图形视觉宽度约为画布 66%，避免主屏图标显得过满
- 部署后 E2E 证据：`test-results/testflight-e2e/`

## 本机当前阻塞

执行 `security find-identity -v -p codesigning` 返回 `0 valid identities found`，且本机没有 Provisioning Profile。因此当前只能生成已验证的无签名 archive，不能导出可上传的 IPA。

## 在具备 Apple 签名环境的机器上执行

1. 安装 Apple Distribution certificate，并登录具有该 App 权限的 Apple Developer 账号。
2. 为 `com.duoshaokankan.weapp` 安装对应的 App Store provisioning profile，或在 Xcode 中开启 Automatic Signing。
3. 确认签名环境：

   ```bash
   security find-identity -v -p codesigning
   ls "$HOME/Library/MobileDevice/Provisioning Profiles"
   ```

4. 在 `damn-frontend` 执行：

   ```bash
   flutter pub get
   flutter build ipa --release -t lib/main_unified.dart
   ```

   Release 配置已经固定读取 `.env.staging`，不要额外传入 `.env.local-debug`。

5. 用 Xcode Organizer 或 Transporter 上传 `build/ios/ipa/*.ipa`，再在 TestFlight 内部测试组分发。
6. 安装 TestFlight build 后，按 `test-results/testflight-e2e/README.md` 重新跑一遍登录、买家/卖家模式、消息、统计、会话和商品详情链路。

## 已验证的无签名 Archive

`build/ios/archive/Runner.xcarchive` 已验证版本、Bundle ID、App Icon、Launch Image，以及归档内的 `.env.staging` 和 staging API 地址。
