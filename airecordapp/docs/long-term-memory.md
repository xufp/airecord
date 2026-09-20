# 长期记忆备份

> 导出时间：2026-04-05
> 记忆 ID：45400447

---

## 项目信息

- **项目名**: airecordapp (YiGuo Voice)
- **Bundle ID**: `com.uniai.recordpen`
- **Team ID**: `FJWNBF222Q`
- **Flutter 版本**: `~/flutter_3.27.4` (Flutter 3.27.4, Dart 3.6.2)

## 完整构建流程

### 1. 清理旧进程

```bash
pkill -f "flutter.*run"
```

### 2. 清理并获取依赖

```bash
cd /Users/faberxu/Documents/workspace/airecordapp
~/flutter_3.27.4/bin/flutter clean
~/flutter_3.27.4/bin/flutter pub get
```

### 3. 创建 ExportOptions.plist

路径：`ios/ExportOptions.plist`

- method: `app-store-connect`
- destination: `export`（先导出到本地，不直接上传）
- signingStyle: `automatic`
- teamID: `FJWNBF222Q`
- uploadSymbols: `false`

### 4. 构建 IPA

```bash
~/flutter_3.27.4/bin/flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

构建耗时较长（约 15-20 分钟），先 archive 再 export。

### 5. 关键 Bug 修复（Flutter 3.27.4 已知问题）

`App.framework` 缺少 `MinimumOSVersion` 字段，导致 Apple 验证失败。

**修复命令：**

```bash
plutil -insert MinimumOSVersion -string "13.0" \
  build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks/App.framework/Info.plist
```

修复后需重新用 xcodebuild 导出：

```bash
xcodebuild -exportArchive \
  -allowProvisioningDeviceRegistration \
  -allowProvisioningUpdates \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist ios/ExportOptions.plist
```

### 6. 上传到 TestFlight

创建 upload 专用 plist（`/tmp/UploadOptions.plist`），将 `destination` 改为 `upload`：

```bash
xcodebuild -exportArchive \
  -allowProvisioningDeviceRegistration \
  -allowProvisioningUpdates \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportPath build/ios/upload \
  -exportOptionsPlist /tmp/UploadOptions.plist
```

Xcode 利用 keychain 中已登录的 Apple Developer 账号会话自动认证上传，无需额外提供 API Key 或密码。

## 签名信息

- **证书**: Apple Distribution: Feipeng xu (FJWNBF222Q)
- **签名模式**: 自动签名
- 本机只显示 Development 证书，但 Xcode 自动管理时能找到 Distribution 证书

## 注意事项

- export 阶段可能耗时较长（签名所有 framework），需耐心等待
- 构建日志位于 `/var/folders/.../Runner_*.xcdistributionlogs/`
- 上传成功后 Apple 需要 5-30 分钟处理，之后才出现在 TestFlight
- IPA 输出路径: `build/ios/ipa/YiGuo Voice.ipa`（约 32MB）
