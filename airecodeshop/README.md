# airecodeshop

YiGuo Voice（AI 录音笔）**用户端 Web 平台**：用户登录后购买套餐包、查看套餐余额与历史订单。

> 由于 iOS 应用商店政策限制，App 内无法集成第三方支付，故新增本 Web 端用于完成购买流程。
> 后端 API 完全复用 `airecodeserver`（详见《AI 录音笔服务端接口文档.pdf》），接口前缀 `/v1`。

## 技术栈

- Vue 3 + `<script setup>`
- Vite 7
- Vue Router 4（History 模式，部署在 `/shop/` 子路径）
- Element Plus（中文 locale）
- Axios（带请求/响应拦截器）

## 目录结构

```
airecodeshop/
├── index.html
├── package.json
├── vite.config.js          # base=/shop/，dev 代理 /v1 -> your-api-domain.com
├── .env.example            # VITE_API_BASE 配置示例
└── src/
    ├── main.js             # ElementPlus 注入、全局样式
    ├── App.vue             # 顶部导航 + 路由出口
    ├── router/index.js     # 路由（含登录守卫）
    ├── stores/user.js      # 简易全局用户状态（reactive）
    ├── api/                # 后端接口封装
    │   ├── request.js      # axios 实例 + 拦截器（注入 token、401 跳登录）
    │   ├── auth.js         # /v1/auth/*
    │   ├── user.js         # /v1/user_info, /v1/user/package
    │   ├── package.js      # /v1/packages/available, /v1/user/package_give
    │   └── order.js        # /v1/order/*
    ├── components/
    │   ├── AppHeader.vue   # 顶栏 + 用户菜单
    │   └── PackageCard.vue # 套餐卡片
    └── views/
        ├── Login.vue          # 邮箱密码登录 + 注册（含邮箱验证码）
        ├── ResetPassword.vue  # 邮箱验证码两步重置密码
        ├── Packages.vue       # 套餐列表 + 下单
        ├── Orders.vue         # 订单列表 + 详情
        ├── Profile.vue        # 个人中心 + 套餐余额 + 修改密码
        ├── PaySuccess.vue     # PayPal 支付返回页
        └── PayCancel.vue      # PayPal 支付取消页
```

## 开发启动

```bash
cd airecodeshop
npm install
npm run dev
```

默认开发服务器：<http://localhost:5174/shop/>

> 开发模式下，`/v1/*` 通过 Vite 代理转发到 `https://your-api-domain.com`（与 `airecordapp` 移动端保持一致）。
> 如需指向其他后端域名，复制 `.env.example` 为 `.env.local` 并修改 `VITE_API_BASE`。

## 生产构建

```bash
npm run build
```

产物在 `dist/`，所有静态资源默认前缀为 `/shop/`。

## 部署建议

由于站点路径为 `/shop/`，与现有 admin（`/admin/`）平级，推荐两种部署方案：

### 方案 A：与后端同源（推荐）

将 `dist/` 输出托管在与 `your-api-domain.com` 同域名下的 `/shop/` 路径，例如在 Nginx 中：

```nginx
server {
    server_name your-api-domain.com;

    # admin 后台
    location /admin/ {
        alias /var/www/admin/;
        try_files $uri $uri/ /admin/index.html;
    }

    # 用户购买端（本工程）
    location /shop/ {
        alias /var/www/shop/;
        try_files $uri $uri/ /shop/index.html;
    }

    # 后端 API
    location /v1/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

同源部署后无需 CORS 配置；前端 axios 直接以相对路径请求 `/v1/*`。

### 方案 B：独立域名

如部署到独立域名（如 `shop.your-domain.com`），将 `vite.config.js` 中 `base` 改为 `'/'`，
并把 `.env.production` 中 `VITE_API_BASE` 设置为后端域名（同时后端要允许该域名跨域）。

## PayPal 回调地址配置

订单创建（`POST /v1/order/create`）后，后端返回 PayPal 支付链接，
PayPal 完成支付后会跳转回后端的 `/v1/order/paypal/return`、`/v1/order/paypal/cancel`。
后端处理完毕后建议 302 重定向到本 Web 端的：

- 支付成功：`/shop/pay/success?order_id=xxx`
- 用户取消：`/shop/pay/cancel?order_id=xxx`

如已经按此约定实现，前端会自动展示结果并轮询订单详情；
如暂未对接，前端在 `localStorage.last_order_id` 中保留了本次下单的订单 ID 作为兜底。

## 已对接接口一览

| 模块 | 方法 | 路径 |
| ---- | ---- | ---- |
| 登录/注册 | POST | `/v1/auth/login` |
| 验证码（注册/重置密码） | POST | `/v1/auth/get_code` |
| 验证码校验 | POST | `/v1/auth/verify_code` |
| 修改密码 | POST | `/v1/auth/change_password` |
| 重置密码 | POST | `/v1/auth/reset_password` |
| 用户信息 | GET | `/v1/user_info` |
| 套餐余额 | GET | `/v1/user/package` |
| 可购买套餐 | GET | `/v1/packages/available?package_type=1\|2\|3` |
| 免费套餐领取 | POST | `/v1/user/package_give` |
| 创建订单 | POST | `/v1/order/create` |
| 订单详情 | GET | `/v1/order/detail` |
| 订单列表 | GET | `/v1/order/list` |

所有需鉴权接口在 axios 拦截器中自动注入：

```
Authorization: token ${access_token}
```

401 时自动清理本地态并跳转 `/shop/login`。
