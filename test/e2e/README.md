# DSKK E2E 测试脚本资产（mobai DSL v0.2）

## 目录结构

```
test/e2e/
  README.md                # 本文件
  manifest.json            # 全量用例清单（128 条，id/file/module/fixtures/automatable/verified）
  run_batch.workflow.md    # 串行跑批协议（含登录前置顺序约束）
  fixtures/                # 可复用步骤片段（login / ensure_logged_in / ensure_logged_out）
  auth/      (9)   home/    (15)  orders/  (11)  payment/ (6)   favorites/ (8)
  after_sales/(12) chat/    (8)   seller/  (16)  wallet/  (31)  ai_docs/   (9)
```

### 覆盖总览（2026-06-16）

| 模块 | 脚本数 | 真机已验证 | 备注 |
|------|--------|-----------|------|
| auth | 9 | AUTH-01/04/06/10 PASS | AUTH-02/03/11 阻塞（国际号码/邮箱/token） |
| home | 15 | 10 个 PASS | 高价值买家流程全覆盖 |
| payment | 6 | PAY-01 PASS（确认订单页）| 真实支付走 Stripe，PAY-07/08 等 partial/no |
| chat | 8 | CHAT-01 PASS（空态）| 发消息需对端，多数 partial |
| orders/after_sales/favorites | 31 | 脚本就绪，待真机 | **当前测试账号无订单/收藏/会话数据**，需活跃账号或造数据 |
| seller/wallet/connect | 47 | 脚本就绪，待真机 | 需卖家模式 + 卖家数据/Stripe Connect 状态 |

- **128 条 case**：automatable `yes` 34 / `partial` 87 / `no` 7。已真机 PASS **15 条**（auth+home+PAY-01）。
- 其余脚本逻辑已按源码写好、JSON 合法，标 `脚本已生成-待真机校正`——多数 blocked 在 fixture（需活跃账号数据/外部依赖），换有数据的账号即可逐步跑绿。
- ⚠️ **跑批顺序硬约束**：见 `run_batch.workflow.md`——需登录的 case 依赖先跑 AUTH-01 建立 session。
- ⚠️ **关键 fixture 教训**：测试账号 18888888888（common_user 10290 / 买家标识 10378）是干净账号，订单/收藏/会话全空；DB 里 member.id=1 的数据属于别的用户，断言锚点与 fixture 一律以真机实测为准（详见各 case 的 verified）。

## 怎么跑

每个 `.dsl.json` 是一个自包含脚本，交给 mobai 的 `execute_dsl` 工具执行：

```
# 单条
execute_dsl(script=<读取 auth/AUTH-01.dsl.json 的内容>)

# 批量（workflow 串行）
manifest.json 列出了所有 case，workflow 按 cases[] 数组顺序逐条 execute_dsl
```

`fixtures/` 下的 `.fragment.json` **不是**可直接运行的 DSL 脚本（无 `version`/`on_fail` 外壳），仅供人工参考拼接或 workflow 内联使用。

## DSL v0.2 格式速查

```json
{
  "version": "0.2",
  "steps": [ /* actions 数组 */ ],
  "on_fail": { "strategy": "retry", "max_retries": 2 }
}
```

### 常用 actions

| action | 关键字段 | 说明 |
|--------|----------|------|
| `open_app` | `bundle_id`, `fresh` | `fresh:true` 杀进程重启 |
| `tap` | `predicate` | 点击元素 |
| `type` | `text`, `predicate`, `clear_first` | 输入文字，`clear_first:true` 先清空 |
| `if_exists` | `predicate`, `then`, `else` | 条件分支 |
| `wait_for` | `predicate`/`stable`, `timeout_ms` | 等待元素出现或界面稳定 |
| `scroll` | `direction`, `to_element`, `max_scrolls` | 滚动到元素 |
| `assert_exists` | `predicate`, `timeout_ms` | 断言元素存在，失败则脚本失败 |
| `assert_not_exists` | `predicate` | 断言元素不存在 |
| `observe` | `include: ["ui_tree"]` | 每个脚本末尾必加，获取最终 UI 状态 |

### predicate 字段

| 字段 | 说明 |
|------|------|
| `text_contains` | 文本包含（推荐，比 `text` 精确匹配更健壮） |
| `text` | 文本精确匹配（仅用于需要排除子串的场合） |
| `text_regex` | 正则匹配 |
| `type` | 元素类型：`button`/`input`/`switch`/`text`/`image`/`cell` |
| `accessibility_id` | AccessibilityLabel |
| `near` | 相对位置锚点 |
| `index` | 同类型元素的索引（从 0 起） |

### 每个脚本末尾固定收尾

```json
{ "action": "wait_for", "stable": true, "timeout_ms": 3000 },
{ "action": "observe", "include": ["ui_tree"] }
```

## 已核实的选择器（直接用，无需猜）

| 用途 | selector |
|------|---------|
| bundle id | `com.duoshaokankan.weapp` |
| 登录页-手机号 tab | `text_contains: "手机号"` |
| 登录页-获取验证码按钮 | `text_contains: "获取验证码"` |
| 登录页-登录按钮 | `text_contains: "登录"` |
| 登录成功 SnackBar | `text_contains: "登录成功!"` （含感叹号） |
| 首页搜索栏 placeholder | `text_contains: "搜索服务"` |
| 商品详情-已发布状态 | `text_contains: "已发布"` |
| 底部 tab-我的 | `text_contains: "我的"` |
| 账号与安全 | `text_contains: "账号与安全"` |
| 退出登录 | `text_contains: "退出登录"` |
| 确认退出弹窗 | `text_contains: "确认退出"` |

## 跑批器

批量执行所有 `automatable=yes` 用例的协议、串行约束、报告格式和 1s timeout quirk 处理方式，见 [`run_batch.workflow.md`](run_batch.workflow.md)。

## 如何添加新 case

1. 在对应模块目录（`auth/`/`home/` 等）新建 `<CASE-ID>.dsl.json`
2. 脚本必须**自包含**：开头 `open_app fresh:true`，如需登录态则内联登录步骤
3. 脚本必须**幂等**：用 `if_exists` 处理「已登录/未登录」两种初始状态
4. 末尾固定加 `wait_for stable` + `observe ui_tree`
5. 在 `manifest.json` 的 `cases[]` 数组末尾追加一条记录，填写 id/file/module/description/requires_login/fixtures/automatable/assertions
6. 用 `python3 -m json.tool <文件>` 验证 JSON 语法

## 测试账号

- 手机号：`18888888888`
- 万能验证码：`565656`
- bundle id：`com.duoshaokankan.weapp`
