# 贡献指南 / Contributing Guide

感谢你对 **AiRecord** 的关注！我们欢迎任何形式的贡献：代码、文档、Bug 报告、功能建议，或只是分享你的使用场景。

Thanks for your interest in **AiRecord**! Contributions of all kinds are welcome.

---

## 🧭 项目结构 / Project Structure

| 目录 | 说明 | 技术栈 |
| --- | --- | --- |
| `airecordapp/` | 移动端 App | Flutter / Dart |
| `airecodeserver/` | 后端服务 + Admin 后台 | Go (tRPC-Go) + Vue |
| `airecodeshop/` | 用户购买 Web 端 | Vue 3 + Vite |

各子模块的详细说明见其目录下的 `README.md`。

---

## 🚀 快速开始 / Getting Started

1. Fork 本仓库并 clone 到本地。
2. 阅读根目录 `README.md` 与对应子模块的 `README.md`，完成环境搭建。
3. 从 `*.example` 复制配置文件并填入你自己的密钥（切勿提交真实密钥）。
4. 创建特性分支：`git checkout -b feat/your-feature`。

---

## 📝 提交规范 / Commit Convention

建议使用 [Conventional Commits](https://www.conventionalcommits.org/)：

```
feat: 新增语音实时转写进度提示
fix: 修复蓝牙断连后无法重连的问题
docs: 完善后端部署文档
refactor: 抽取音频上传逻辑到独立 service
```

常用类型：`feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore`。

---

## ✅ 提交 PR 前请确认 / Before Submitting a PR

- [ ] 代码可编译、可运行，未破坏现有功能。
- [ ] 未包含任何真实密钥、令牌、证书或个人隐私信息。
- [ ] 遵循对应语言的格式规范：
  - Go：`gofmt` / `go vet`
  - Dart：`dart format` / `flutter analyze`
  - Vue/JS：项目 ESLint 规则
- [ ] 关联了相关 Issue（如有），并在 PR 描述中说明改动动机与验证方式。

---

## 🐛 报告 Bug / Reporting Bugs

提交 Issue 时请尽量包含：

- 复现步骤、期望行为与实际行为
- 运行环境（OS、Flutter/Go/Node 版本、设备型号）
- 相关日志或截图

---

## 🔐 安全问题 / Security Issues

安全漏洞请勿公开提交，参见 [SECURITY.md](./SECURITY.md)。

---

## 📄 许可 / License

提交贡献即表示你同意你的贡献将以本项目的 [MIT License](./LICENSE) 授权发布。
