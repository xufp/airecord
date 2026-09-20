# ⚙️ airecodeserver · 后端服务（Go / tRPC-Go）

AiRecord 平台的后端服务，提供 HTTP API、WebSocket 实时通道、内置 Admin 管理后台与定时任务，聚合语音转写、大模型、对象存储与支付等云能力。

> 本模块是 [AiRecord 开源平台](../README.md) 的一部分。

## ✨ 功能

- **RESTful API（`/v1`）**：认证、用户、媒体（录音）、订单、套餐等。
- **WebSocket**：实时消息推送。
- **Admin 后台**：内置 Vue 管理端（`web/`），用户/订单/套餐管理。
- **定时任务**：转写状态轮询等（`robfig/cron`）。
- **可插拔 AI 能力**：腾讯云 ASR、腾讯混元、Azure OpenAI / OpenAI。
- **对象存储**：腾讯云 COS，临时密钥直传。
- **支付**：PayPal 订单与订阅（沙箱/生产可切换）。
- **通知**：短信（腾讯云 SMS）与邮件（SMTP）。

## 🧱 技术栈

Go 1.23 · [tRPC-Go](https://github.com/trpc-group/trpc-go) · GORM(MySQL) · Gin/Gorilla · Vue(admin)

## 📂 架构（DDD 分层，`internal/`）

| 分层 | 目录 | 职责 |
| --- | --- | --- |
| 接口层 | `interfaces/` | HTTP/WSS 路由与入参出参（auth/user/media/order/wss…） |
| 应用层 | `application/` | 用例编排、领域服务、事件、端口(ports) |
| 领域层 | `domain/` | 实体、领域逻辑、调度 |
| 基础设施 | `infrastructure/` | 配置、启动、各云厂商适配器(adapters)、工具 |
| 管理后台 | `admin/` | Admin 路由与逻辑 |

```
cmd/main.go            # 程序入口
conf/                  # 配置（*.example.yaml 为模板）
internal/              # 业务代码（DDD 分层）
web/                   # Admin 前端源码（构建产物 dist/ 不入库）
script/                # 部署脚本
case_test/             # 集成测试用例
```

## ⚙️ 配置

真实配置**不入库**，请从模板复制并填入你自己的凭证：

```bash
cp conf/ai_record_server.example.yaml conf/ai_record_server.yaml
cp conf/trpc_go.example.yaml conf/trpc_go.yaml
```

- `ai_record_server.yaml`：业务配置（腾讯云 SecretId/Key、COS、ASR、混元、OpenAI、PayPal、SMTP、短信等）。
- `trpc_go.yaml`：框架配置（监听端口、MySQL DSN、日志、TLS 证书路径）。

需要 TLS 时，将证书放到 `conf/ssl/`（`server.crt` / `server.key`），或在 `trpc_go.yaml` 中注释掉 TLS 配置。自签示例：

```bash
openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
  -keyout conf/ssl/server.key -out conf/ssl/server.crt
```

## 🗄️ 依赖

- **MySQL**：创建数据库 `ai_record_db`，并在 `trpc_go.yaml` 的 DSN 中配置账号密码。
- 各云厂商账号：腾讯云（COS/ASR/混元/SMS）、Azure OpenAI 或 OpenAI、PayPal、SMTP 邮箱。

## 🚀 编译与运行

```bash
# 编译（产物在 ./bin）
sh build.sh            # 或 sh build.sh all 清理后重编

# 运行
cd bin
./ai_record_server -conf ../conf/trpc_go.yaml
```

默认监听：API `:8081`，Admin `:8082`（见 `trpc_go.yaml`）。

## 🧪 测试

`internal/**/adapters/**/*_test.go` 与 `case_test/` 为集成测试，运行前需在测试中填入你自己的凭证（当前为占位符）。

```bash
go test ./...
```

## 🔐 安全提示

- 所有密钥使用最小权限，定期轮换。
- 生产环境务必启用 TLS，妥善保管证书私钥。
- 真实的 `ai_record_server.yaml` / `trpc_go.yaml` / `conf/ssl/*` 已在 `.gitignore` 中排除，切勿提交。
