# 卖家钱包 API 对接说明（提现 idempotencyToken + 余额字段对齐）

> 本文基于后端源码 **逐字核实**，非凭记忆。源码位置：
> - `xunman-xunpay/.../controller/payment/SellerWalletApiController.java`
> - `xunman-xunpay/.../controller/payment/SellerWithdrawDTO.java`
> - `xunman-xunpay/.../vo/SellerBalanceVO.java`
>
> 核实环境：本地后端容器 `dskk-admin-dev`（端口 8187），filter 校验 header `clienttype/client/version`，业务接口均需 JWT。

---

## ⚠️ 先纠正一个会坑前端的点：响应是 `AjaxResult` 嵌套，业务体在 `data` 里

后端两个接口都用 `AjaxResult.success(vo)` 返回，统一壳层：

```json
{ "code": 200, "msg": "操作成功", "data": { ...业务字段... } }
```

- **成功码是 `200`，不是 `0`**（与项目 CLAUDE.md「`code == 200` 是唯一成功信号」一致）。
- "余额返回变为 `{bound, available, pending, currency}`" 指的是 **`data` 里**是这四个字段，解析路径是 `body['data']['available']`，**不是顶层** `body['available']`。
- 对比 `/api/fx/rates`（那个是 `AjaxResult.put` 塞顶层、无 data 包裹）——本组接口**有 data 包裹**，两者不同，别套错。

---

## 🔴 必改 1：提现请求体加 `idempotencyToken`

`POST /api/wallet/seller/withdraw`（需 JWT，卖家身份）

### 请求体（`SellerWithdrawDTO`）

```json
{
  "amount": 10.00,
  "idempotencyToken": "前端生成的UUID"
}
```

| 字段 | 类型 | 约束（后端校验） | 说明 |
|---|---|---|---|
| `amount` | BigDecimal（**元**，不是分） | 必填，`>= 10.00`（`@DecimalMin "10.00"`） | 单位是美元/元，**不是 cents** |
| `idempotencyToken` | String | 必填（`@NotBlank`）、**最长 64 字符**（`@Size max=64`） | 一次性 UUID（标准 UUID 36 字符，OK） |

### 核心契约（源码注释钉死，违反会双发打款）

- `idempotencyToken` 必须在**同一次提现意图内稳定复用**——任何重试（请求超时重发、用户重复点击）都必须沿用**同一个 token**。
- 反例后果：超时后换新 token 重试 → 后端 `findByIdempotencyKeyAndOwner` 短路 + Stripe Idempotency-Key 双保险**全部失效 → 重复打款双发**。
- **前端实现约定（本仓库）**：token 在「用户主动点击『确认提现』」时生成一次，随 `SubmitWithdrawal` event 传入，整条调用链复用同一 token。用户主动发起新一笔提现 = 新意图 = 新 token。

### 成功响应（`data` 部分，来自 `buildWithdrawResult`）

```json
{
  "code": 200,
  "msg": "提现申请已提交",
  "data": {
    "cashId": 123,
    "cashSn": "xxxxx",
    "payoutId": "po_xxx",
    "status": "processing"
  }
}
```

- `msg` 可能是 `"提现申请已提交"` 或 `"提现申请已提交（处理中）"`，前端统一按"已提交"展示即可。
- `payoutId` 可能为 `null`（极端落库失败场景），前端不要强依赖。
- `status` 固定字符串 `"processing"`。
- 幂等短路命中（重复提交同一 token）返回**同样的 data 结构**，前端无需区分。

### 失败文案（`code != 200`，`msg` 原文，前端在 UI 层翻译展示）

| 触发条件 | msg 文案 |
|---|---|
| 并发提现（分布式锁未拿到） | `提现处理中，请勿重复提交` |
| 未绑定收款账户 | `请先绑定收款账户` |
| 账户未激活 | `收款账户未激活` |
| 账户不支持提现 | `收款账户暂不支持提现` |
| 低于最低额 | `最低提现金额为 $10.00` |
| 60s 内重复提现 | `操作过于频繁，请稍后再试` |
| 当日超 5 次 | `今日提现次数已达上限` |
| 可提余额不足 | `可提现余额不足，当前可提 $X.XX（部分收入仍在结算中）` |
| 查 Stripe 余额失败 | `查询余额失败，请稍后重试` |
| Stripe Payout 失败 | `提现失败：{原因}` / `提现失败，请稍后重试` |

> 另有框架层 `@RepeatSubmit(interval=10000)`：同一请求体 10s 内重复提交会被直接拦（请求哈希级防抖，与 `idempotencyToken` 业务幂等是两层）。短时间狂点会先撞这层。

---

## 🟡 建议改 2：余额接口对齐 `GET /api/wallet/seller/balance`

需 JWT，无请求参数（鉴权取当前登录卖家）。

### 响应（`data` 部分，`SellerBalanceVO`）

```json
{
  "code": 200,
  "msg": "操作成功",
  "data": { "bound": true, "available": 12345, "pending": 6789, "currency": "usd" }
}
```

| 字段 | 类型 | 说明 |
|---|---|---|
| `bound` | bool | 是否已绑定**并激活** Stripe 账户。`false` → 引导绑定，available/pending 恒为 0 |
| `available` | long | 可提现余额，**单位 cents（分）**，展示 `÷100` |
| `pending` | long | 结算中余额，**单位 cents（分）**，展示 `÷100` |
| `currency` | String | 货币代码，**小写** `"usd"`（注意小写，不是 `"USD"`） |

### 关键提醒

- ⚠️ **单位不一致**：余额是 cents，提现 `amount` 是元。做"全部提现"时记得 `available / 100` 换算成元再填 `amount`。
- `bound=false` → 引导绑定流程，余额区显示 0 或占位。
- 三条路径（未绑定/缓存命中/实时查询）字段集**严格一致**，前端不用分支处理缺字段。
- 余额有 ~5s Redis 缓存；提现校验后端另走实时查询（不吃缓存）——"余额刚好够但提现报不足"是可能的（结算中变动），文案已覆盖。
- 失败时 `code != 200`，`msg = "查询余额失败，请稍后重试"`。

---

## ⚪ 本期前端不用动的

- **退款**：后端未接线，前端不动。
- **绑定流程**：本次未变。
- **提现记录 / 流水**：`POST /api/wallet/seller/withdraw/records`（分页）、`GET /api/wallet/seller/ledger?limit=20` 接口存在但契约未变，按需接。

---

## 验证说明（诚实标注）

- 路径 / method / 鉴权要求 / DTO 字段名 / 类型 / 约束 / `AjaxResult` 嵌套形态：**源码 100% 核实**。
- filter 行为已 curl 实测：带 `clienttype:1 / client:ios / version:100` 可过版本墙；无 JWT 时两接口均返回 `401`（证明都需登录）。
- `data` 业务体的真实 200 响应**未跑出**：需一个「已绑定且 active Stripe 账户」的卖家 JWT，本地 DB 暂无此数据前提。字段结构由 `@Data`/`buildWithdrawResult` 源码推导，字段名无歧义。
