# 账号删除功能技术方案

## 一、需求背景

iOS App Store 审核要求 APP 提供账号删除功能。采用**软删除**策略：将用户状态标记为"已注销"（state=3），保留数据一段时间后再清理，同时立即使所有登录 Token 过期。

## 二、接口协议

### 2.1 接口概览

| 项目 | 说明 |
|------|------|
| **接口路径** | `POST /v1/user/delete_account` |
| **HTTP 方法** | `POST` |
| **认证方式** | 必须携带有效 Token，Header: `Authorization: token <uuid>` |
| **Content-Type** | `application/json` |

### 2.2 请求参数

**Request Body**: 空 JSON 对象 `{}`

> 无需传入任何业务参数，用户身份通过 Authorization Token 中间件自动解析获取。

### 2.3 响应参数

**成功响应** (HTTP 200):

```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

**失败响应** (HTTP 400):

```json
{
  "code": <错误码>,
  "msg": "<错误信息>"
}
```

### 2.4 错误场景

| 场景 | HTTP 状态码 | 说明 |
|------|-------------|------|
| Token 无效/过期 | 401 | 鉴权中间件拦截，返回 `ErrUserAuthInvalid` |
| 用户状态非"注册成功" | 400 | 已注销或待验证用户不可重复删除 |
| 请求体为空 | 400 | POST 请求必须携带 body（至少为 `{}`） |
| 服务器内部错误 | 400 | 数据库操作异常等 |

## 三、用户状态机

```
state=1 (待验证) ──注册验证通过──> state=2 (注册成功) ──删除账号──> state=3 (已注销)
```

| 状态值 | 含义 | 常量名 |
|--------|------|--------|
| 1 | 待注册验证（绑定手机号/邮箱验证） | `UserStateWaitVerifyCode` |
| 2 | 注册成功 | `UserStateRegisterSuccess` |
| 3 | 用户已注销 | `UserStateDeactivated` |

> 鉴权中间件 `auth_check.go` 只允许 `state=2` 的用户通过认证，注销后用户自动无法访问任何需鉴权接口。

## 四、服务端实现

### 4.1 架构分层

```
interfaces (路由/控制器)
  └─ application/service (业务逻辑)
       └─ domain/repository (仓储接口)
            └─ infrastructure/persistence (数据库实现)
```

### 4.2 涉及文件

| 文件路径 | 变更类型 | 说明 |
|----------|----------|------|
| `internal/interfaces/ai_record_server.go` | 修改 | 注册路由 |
| `internal/interfaces/service_user.go` | 修改 | 新增 `DeleteAccount` Handler |
| `internal/application/protocol/ai_record_server.go` | 修改 | 新增 `DeleteAccountReq`/`DeleteAccountRsp` |
| `internal/application/service/userservice/user_delete_account.go` | **新增** | 核心业务逻辑 |
| `internal/domain/repository/user_repo.go` | 修改 | 新增 `ExpireUserTokens` 接口方法 |
| `internal/infrastructure/persistence/ai_record_repo/user_repo.go` | 修改 | `ExpireUserTokens` 实现 |

### 4.3 核心业务逻辑（事务操作）

```go
// user_delete_account.go - 在单个数据库事务中完成以下 4 步
func (d *DeleteAccount) DeleteAccount(ctx context.Context) (*protocol.DeleteAccountRsp, error) {
    err := d.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
        // 1. 锁定用户记录（SELECT ... FOR UPDATE）
        userInfo, err := repo.UserRepo().LockUserInfo(ctx, d.userId)

        // 2. 校验用户状态必须为 state=2（注册成功）
        if userInfo.State != entity.UserStateRegisterSuccess {
            return errs.Newf(errorcode.ErrUserAuthInvalid, "user state invalid")
        }

        // 3. 更新用户状态为 state=3（已注销）
        userInfo.State = entity.UserStateDeactivated
        repo.UserRepo().UpdateUserInfo(ctx, userInfo)

        // 4. 使该用户所有 Token 立即过期
        repo.UserRepo().ExpireUserTokens(ctx, d.userId)

        return nil
    })
    return &protocol.DeleteAccountRsp{}, nil
}
```

### 4.4 Token 过期实现

```go
// ExpireUserTokens - 将用户所有未过期 Token 的 expire_time 设为当前时间
func (i *UserRepoImpl) ExpireUserTokens(ctx context.Context, userId int64) error {
    updates := map[string]interface{}{
        "expire_time":      time.Now(),
        "last_update_time": time.Now(),
    }
    return i.db.WithContext(ctx).Table("t_user_token").
        Where("user_id = ? and expire_time > NOW()", userId).
        Updates(updates).Error
}
```

### 4.5 协议定义

```go
// DeleteAccountReq 账号删除请求参数（空结构体，无需业务参数）
type DeleteAccountReq struct{}

// DeleteAccountRsp 账号删除返回参数（空结构体，无需返回业务数据）
type DeleteAccountRsp struct{}
```

### 4.6 路由注册

```go
{"/v1/user/delete_account", i.DeleteAccount, []string{http.MethodPost}, true}
// true = forceAuth，必须携带有效 Token
```

## 五、客户端实现

### 5.1 架构分层

```
page (UI 页面)
  └─ logic (业务逻辑)
       └─ service (API 调用)
            └─ client (HTTP 客户端)
```

### 5.2 涉及文件

| 文件路径 | 变更类型 | 说明 |
|----------|----------|------|
| `lib/config/RoutesConfig.dart` | 修改 | 新增 `DELETE_ACCOUNT` 常量 |
| `lib/service/response/DeleteAccountResponse.dart` | **新增** | 响应模型 |
| `lib/service/DioService.dart` | 修改 | 新增 `deleteAccount()` 方法 |
| `lib/logic/ProfileLogic.dart` | 修改 | 新增 `deleteAccount()` 方法 |
| `lib/page/center/AccountSecurityPage.dart` | **新增** | 账号与安全页面 |
| `lib/page/center/ProfilePage.dart` | 修改 | 新增菜单入口 |
| `lib/main.dart` | 修改 | 注册 `/accountSecurity` 路由 |
| `lib/l10n/arb/intl_*.arb` (5个) | 修改 | 国际化文案 |
| `lib/l10n/generated/l10n.dart` | 修改 | 生成的 i18n getter |
| `lib/l10n/generated/intl/messages_*.dart` (5个) | 修改 | 生成的消息映射 |

### 5.3 API 调用链路

```dart
// 1. 路由常量
static const String DELETE_ACCOUNT = 'v1/user/delete_account';

// 2. 网络请求（DioService）- 使用带 Auth 的 _dioClient
static Future<DeleteAccountResponse> deleteAccount() async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.DELETE_ACCOUNT) as Map<String, dynamic>;
    return DeleteAccountResponse.fromJson(apiResponse);
}

// 3. 业务逻辑（ProfileLogic）- 调用 API + 清缓存
Future<DeleteAccountResponse> deleteAccount() async {
    final resp = await DioService.deleteAccount();
    if (resp.code == ErrConstants.SUCCESS_CODE) {
        await Cache.removeAll();  // 清除 token、userId、userInfo
    }
    return resp;
}
```

### 5.4 UI 交互流程

```
个人中心 (ProfilePage)
  └─ 点击「账号与安全」菜单 → 进入 AccountSecurityPage
       └─ 点击红色「删除账号」按钮
            └─ 弹出确认对话框（含警告文案）
                 ├─ 点击「取消」→ 关闭对话框
                 └─ 点击「确认删除」
                      ├─ 显示 Loading 状态
                      ├─ 调用 deleteAccount() API
                      ├─ 成功 → 清缓存 → 跳转登录页（清空路由栈）
                      └─ 失败 → 显示红色 SnackBar 错误提示
```

### 5.5 国际化 (i18n)

支持 5 种语言：中文简体、英文、日语、韩语、中文繁体。

| Key | 中文 | English |
|-----|------|---------|
| `ProfilePage_k21` | 账号与安全 | Account & Security |
| `AccountSecurityPage_k1` | 账号与安全 | Account & Security |
| `AccountSecurityPage_k2` | 删除账号 | Delete Account |
| `AccountSecurityPage_k3` | 确认删除账号 | Confirm Account Deletion |
| `AccountSecurityPage_k4` | 删除账号后，您的所有数据将被清除且无法恢复。确定要继续吗？ | After deleting your account, all your data will be erased and cannot be recovered. Are you sure you want to continue? |
| `AccountSecurityPage_k5` | 取消 | Cancel |
| `AccountSecurityPage_k6` | 确认删除 | Confirm Delete |
| `AccountSecurityPage_k7` | 删除账号失败，请稍后重试 | Failed to delete account, please try again later |

## 六、前后端交互时序图

```
┌──────────┐                    ┌──────────┐                    ┌──────────┐
│  Client  │                    │  Server  │                    │    DB    │
└────┬─────┘                    └────┬─────┘                    └────┬─────┘
     │                               │                               │
     │  POST /v1/user/delete_account │                               │
     │  Authorization: token <uuid>  │                               │
     │  Body: {}                     │                               │
     │──────────────────────────────>│                               │
     │                               │                               │
     │                               │  auth_check: 验证 Token       │
     │                               │  获取 userId                  │
     │                               │                               │
     │                               │  BEGIN TRANSACTION            │
     │                               │──────────────────────────────>│
     │                               │                               │
     │                               │  SELECT ... FOR UPDATE        │
     │                               │  (锁定用户记录)                │
     │                               │──────────────────────────────>│
     │                               │                               │
     │                               │  校验 state == 2              │
     │                               │                               │
     │                               │  UPDATE t_user_info           │
     │                               │  SET state = 3                │
     │                               │──────────────────────────────>│
     │                               │                               │
     │                               │  UPDATE t_user_token          │
     │                               │  SET expire_time = NOW()      │
     │                               │  WHERE user_id=? AND          │
     │                               │  expire_time > NOW()          │
     │                               │──────────────────────────────>│
     │                               │                               │
     │                               │  COMMIT                       │
     │                               │──────────────────────────────>│
     │                               │                               │
     │  Response: {code:0, msg:""}   │                               │
     │<──────────────────────────────│                               │
     │                               │                               │
     │  Cache.removeAll()            │                               │
     │  (清除本地缓存)               │                               │
     │                               │                               │
     │  跳转登录页                    │                               │
     │  (清空路由栈)                  │                               │
     │                               │                               │
```

## 七、安全考虑

1. **鉴权保护**：接口设置 `forceAuth=true`，必须携带有效 Token
2. **行锁保护**：使用 `SELECT ... FOR UPDATE` 防止并发删除
3. **事务原子性**：状态变更和 Token 过期在同一事务内完成
4. **状态校验**：只允许 `state=2` 的用户执行删除，防止重复操作
5. **后续隔离**：注销后 `auth_check` 中间件自动拦截所有请求（要求 state=2）
6. **客户端清理**：成功后清除本地全部缓存，跳转登录页并清空路由栈
