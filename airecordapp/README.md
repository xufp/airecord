# 📱 airecordapp · 移动端 App（Flutter）

AiRecord 平台的 iOS / Android 移动端 App，负责与蓝牙录音笔硬件通信、录音采集、上传转写、AI 总结与用户交互。

> 本模块是 [AiRecord 开源平台](../README.md) 的一部分。

## ✨ 功能

- **蓝牙录音笔接入**：基于 `flutter_blue_plus` 与硬件通信（自定义 BLE 协议，见 [`../docs/`](../docs)）。
- **录音与音频处理**：Opus 编解码（`opus_dart` / `opus_flutter`）、实时波形（`audio_waveforms`）、音频会话管理。
- **云端语音转写**：音频通过腾讯云 COS 直传后，由后端触发 ASR，展示带时间轴的文字稿。
- **AI 智能总结**：调用大模型对转写内容做摘要、要点、问答。
- **多语言**：内置 17 种语言（`lib/l10n/arb`），基于 `intl` / `intl_utils` 自动生成。
- **用户体系**：邮箱/验证码登录注册、套餐余额、订单、个人中心。

## 🧱 技术栈

Flutter 3.24+ / Dart 3 · GetX · Riverpod · Dio · Floor(SQLite) · flutter_blue_plus · WebSocket · 腾讯云 COS SDK

## 📂 目录结构（`lib/`）

| 目录 | 说明 |
| --- | --- |
| `service/` | 基础服务封装：蓝牙、录音、网络(Dio)、WebSocket、数据库 |
| `logic/` | 业务逻辑层，调用 service |
| `controller/` | 页面交互控制（GetX） |
| `page/` | 页面 UI（录音、蓝牙、AI 对话、登录、个人中心等） |
| `command/` | 蓝牙命令封装 |
| `config/` | 路由、蓝牙等基础配置 |
| `client/` | 基于 Dio 的网络基础封装 |
| `db/` | 本地数据库与缓存 |
| `constant/` `enum/` | 常量与枚举定义 |
| `l10n/` | 多语言 ARB 与生成代码 |
| `util/` | 公共工具 |

## ⚙️ 配置

运行前请替换为你自己的后端与 AI 配置：

- 后端 API 域名：见网络请求配置（`lib/config` / `lib/client`）。
- App 内直连的大模型密钥：`lib/page/chatgpt/chatgpt_service.dart`（示例为占位，**建议改为由后端代理调用，避免在客户端暴露密钥**）。
- Firebase（如使用）：自行放置 `android/app/google-services.json` 与 `ios/Runner/GoogleService-Info.plist`（已在 `.gitignore` 中排除）。

## 🚀 运行与出包

```bash
flutter pub get

# 若使用了多语言/数据库代码生成
flutter pub run build_runner build --delete-conflicting-outputs

flutter run                    # 调试

# Android 出包：先自行生成 keystore，并用环境变量注入密码
#   keytool -genkey -v -keystore android/release.keystore -alias your_alias \
#     -keyalg RSA -keysize 2048 -validity 10000 -storetype JKS
#   export ANDROID_KEYSTORE_PASSWORD=... ANDROID_KEY_ALIAS=... ANDROID_KEY_PASSWORD=...
flutter build apk --release

flutter build ipa --release    # iOS 出包（需自行配置签名）
```

## 🔐 安全提示

- 不要把 keystore、`key.properties`、Firebase 配置、真实密钥提交到仓库。
- 客户端应尽量避免硬编码第三方 AI 密钥，推荐通过后端代理。
