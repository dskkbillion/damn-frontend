# ID Schema 跨端梳理

> 关联 issue: #358 (epic)、#355、#346
> 最后核对: 2026-05-17 (基于 staging 数据库 schema + chat #266 数据复盘)

## 为什么有这份文档

DSKK 跨端有多套用户 ID,职责边界不清晰,**隔三差五撞 bug**(#172、#355、#346)。
本文档先把事实 freeze 下来,再决定是否做简化。

---

## 1. 表层模型(基于 staging dskk 库实测)

### 1.1 业务表(身份各自管)

| 表 | 主键 | 角色 |
|---|---|---|
| `member` | `id` (auto_increment, 纯主键) | 买家(C端用户) |
| 卖家表(类似 tenant 表) | `id` | 卖家 |
| 管理员表 | `id` | 后台管理员 |

每张业务表自己生 id,**互相不重叠也不映射**。

### 1.2 统一身份层 `xun_common_user`

**复合主键**: `(id, refer_id, type)` — 三列复合 PK!

| 字段 | 类型 | 含义 |
|---|---|---|
| `id` | int unsigned, auto_increment | 统一身份 ID — 跨身份场景(chat/AI/推荐)的唯一 key |
| `refer_id` | int | 指向原始业务表的 PK(member.id / 卖家.id / 管理员.id) |
| `type` | enum(`MEMBER`/`TENANT`/`ADMIN`) | 标明 refer_id 指向哪张表 |
| nick_name, avatar, mobile, online_flag... | | 业务表字段的 **冗余拷贝**,用于跨身份显示 |

**核心语义**: `xun_common_user` 是 **member / tenant / admin 三张表的统一身份代理层**。
- 用户在 chat 里、AI 推荐里、Milvus user_collection 里 — 都用 `xun_common_user.id` 作 key
- 想从 `xun_common_user` 回到具体业务实体,看 `(refer_id, type)` 组合

### 1.3 实例(本周复盘)

```
member.id = 10319     纸蓝测试  (买家)
member.id = 10520     Phương Thảo  (越南卖家,作为买家身份注册)

xun_common_user(id=10594, refer_id=10319, type=MEMBER) — 纸蓝测试的统一身份
xun_common_user(id=10737, refer_id=10520, type=MEMBER) — Phương Thảo 的统一身份

商品 511.tenant_id = 10737            ← 这里存的是 xun_common_user.id
chat.id=266.doctor_id = 10737         ← 也是 xun_common_user.id
chat.id=266.member_id = 10594         ← 也是 xun_common_user.id
订单 768.buyerId = 10377              ← (待核实,可能是 member.id 而非 common_user.id — 见 §3)
```

⚠️ 同一份「ID 值 10737」在不同表语义不同:
- 在 `member.id` 表里 → **不存在**(member 没这个 id)
- 在 `xun_common_user.id` 表里 → Phương Thảo 的统一身份
- 在 `chat.doctor_id` / 商品 `tenant_id` 里 → xun_common_user.id (10737)

**所以 "tenant_id" / "doctor_id" / "buyer_id" 这种字段名不带前缀指明属于哪个表,极易引发误解。**

---

## 2. 跨端契约 — 哪些 endpoint 传哪种 ID

### 2.1 Java 后端 API

| Endpoint | 入参字段 | 实际期望的语义 | 注意 |
|---|---|---|---|
| `POST /api/chat/addChat` | `doctorId` | **member.id**(= xun_common_user.refer_id 当 type=MEMBER) | 后端 lookup 转 xun_common_user.id 存表 |
| `POST /api/stripe-connect/create-account` | (隐式 from JWT) | (待核实) **member.id 还是 xun_common_user.id** | #346 "用户信息不存在" 即此处对不上 |
| `POST /api/shop/order/create` | `tenantId` | (待核实) | 订单的 buyerId/tenantId 看起来又是 member.id |

### 2.2 Model 后端(model-backend Python)

| Endpoint | 入参字段 | 期望语义 |
|---|---|---|
| `POST /model/chat/allocate` | `user_id`, `merchant_id` | **xun_common_user.id**(前端 currentUserId/service.tenantId 都是这个) |
| 推荐 API 输出 `items[].tenantId` | | **xun_common_user.id**(商品表里的 tenant_id) |

### 2.3 前端 ChatUserRepository.getCurrentUser

返回 `{ userId, commonUserId }`:
- 实测日志 `userId: 10377, commonUserId: 10594` — `userId` 是 **member.id**,`commonUserId` 是 **xun_common_user.id**

### 2.4 WebSocket 消息字段

`MessageDto.memberId` / `MessageDto.doctorId` — 按 `chat_web_socket_data_source.impl.dart:269` 注释,都是 **xun_common_user.id**(与 chat 表存的值一致)。

---

## 3. 已知的 "ID 对不上" bug

| Issue | 现象 | 根因 | 备注 |
|---|---|---|---|
| #355 | OptimizedAllocation `addChat` 报 "用户不存在" | 前端传 `service.tenantId`(=xun_common_user.id=10737)给 doctorId,后端期望 member.id(=10520) | 详根因见 #355 评论 |
| #346 | Stripe Connect 「开始绑定」失败 "用户信息不存在" | 后端从 JWT 拿到的 user id 类型与查询时用的表不一致 | 待后端日志确认到底是哪种 ID |
| #172 (历史) | 推荐系统拿错 ID | member.id vs common_user.id 混淆 | 已修复 |

---

## 4. 跨端代码注释的矛盾点(需要清理)

- `chat_web_socket_data_source.impl.dart:269`: `doctorId = 接收者的 CommonUser.id` ✅ (与 chat 表实际存储一致)
- `chat_remote_data_source.impl.dart:252-254`: `participantId is the referId of the target user` ✅ (与 addChat **入参**语义一致,但用了 "referId" 这个表字段名作为参数名,**易误解**)
- CLAUDE.md: `chat.doctor_id/member_id are CommonUser.id NOT Member.id` ✅ (描述存储,**不描述接口入参**,容易让读者把入参也理解成 CommonUser.id)

注释每一条单独看都对,**合起来读容易让人撞 bug**(我今晚就撞了)。

---

## 5. 简化方向(讨论,不立刻动手)

### 5.1 短期(临时止血)— 不破坏现有调用约定

- [ ] **Java addChat 加 fallback**: 如果 `doctorId` 当 member.id 查不到,再 try 当 xun_common_user.id 查,二者都失败才报错。一次性给 #355/#346/#336/#343 一类 bug 兜底
- [ ] **CLAUDE.md 改写**: 把"接口入参语义"和"表存储语义"分开写,贴 §2 的清单
- [ ] **前端 `chat_remote_data_source.impl.dart` 注释更新**: `participantId` 改名提示更清楚,或者改 wrapper 函数把语义封死

### 5.2 中期(降低撞 bug 概率)

- [ ] 前端 `IdResolver` 服务: `IdResolver.toMemberIdFor(commonUserId)`、`toCommonUserId(memberId)` — 把每个调用点的语义选择集中收口
- [ ] 给关键 endpoint 加契约测试(给定 member.id 走通整链路 / 给定 common_user.id 走通另一链路),CI 防回归
- [ ] 重命名字段:`tenant_id` 在不同表语义不同,长期建议改为 `tenant_member_id` / `tenant_common_user_id` 二选一

### 5.3 长期(架构)

- [ ] 评估能否合并 `xun_common_user` 与 `member` 等业务表 — 让 ID 维度从 N 套降到 1 套
- [ ] 或者强制所有跨端 endpoint **只接 xun_common_user.id**,业务表只在内部用 — 对外接口归一化

---

## 6. 工作流补丁(立刻可做)

> 加到 CLAUDE.md 的「Hard rules for editing this codebase」

```
**ID 使用规则(参考 docs/dev/id_schema_cn.md)**

- 写跨端 API 调用前,先在 [§2 跨端契约清单](docs/dev/id_schema_cn.md#2-跨端契约--哪些-endpoint-传哪种-id) 查这个 endpoint 期望传 member.id 还是 xun_common_user.id
- 没查到的新 endpoint,**先 staging curl 抽样确认**,然后补到 §2 表里
- 不要按变量名猜语义 — `tenantId` / `doctorId` / `memberId` / `userId` 在不同上下文语义不同
```
