# Security Policy

## 支持的版本 / Supported Versions

我们对最新的 `main` 分支提供安全维护。发现漏洞请优先在此分支验证。

## 报告漏洞 / Reporting a Vulnerability

如果你发现了安全漏洞，请**不要**直接提交公开 Issue。请通过以下方式私下联系维护者：

- 提交私密的 Security Advisory（GitHub → Security → Report a vulnerability）
- 或发送邮件至维护者邮箱（见仓库主页）

我们会在收到报告后尽快响应，并在修复后进行致谢。

If you discover a security vulnerability, please **do not** open a public issue.
Instead, report it privately via GitHub Security Advisory or the maintainer's email.

## 密钥与凭证 / Secrets & Credentials

本仓库**不包含**任何真实的第三方密钥。所有配置文件均以占位符提供：

- 后端配置：`airecodeserver/conf/ai_record_server.example.yaml`、`trpc_go.example.yaml`
- Web 端：`airecodeshop/.env.example`
- Android 签名：通过环境变量或 `key.properties` 注入，切勿提交 keystore

请务必：

1. 从 `*.example` 文件复制生成真实配置，且**不要提交**真实配置（已在 `.gitignore` 中排除）。
2. 使用最小权限的 API 密钥，并定期轮换。
3. 生产环境启用 HTTPS/TLS，并妥善保管 keystore 与证书私钥。

> ⚠️ 如果你在历史提交中不慎泄露了密钥，请**立即在对应云平台吊销并重新生成**，仅从代码中删除是不够的。
