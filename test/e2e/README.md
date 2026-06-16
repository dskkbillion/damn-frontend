# DSKK E2E 测试脚本资产（mobai DSL v0.2）

## 目录结构

```
test/e2e/
  README.md                          # 本文件
  manifest.json                      # 所有用例清单（id/file/module/fixtures/automatable/verified 等）
  run_batch.workflow.md              # 串行跑批协议（含登录前置顺序约束）
  fixtures/
    login.fragment.json              # 「登录」步骤片段（参考用，不可直接 execute_dsl）
    ensure_logged_out.fragment.json  # 「确保登出」步骤片段（参考用）
    ensure_logged_in.fragment.json   # 「确保已登录」轻量前置（HOME 系列用，依赖跑批器先建 session）
  auth/
    AUTH-01.dsl.json                 # 手机号登录（幂等，自包含）
    AUTH-04.dsl.json                 # 无效手机号格式提示
    AUTH-06.dsl.json                 # 发送验证码（partial，倒计时不可测）
    AUTH-10.dsl.json                 # 退出登录
  home/
    HOME-01.dsl.json                 # 首页加载断言
    HOME-04.dsl.json                 # 进入商品详情
    HOME-10.dsl.json                 # 查看卖家主页
    HOME-12.dsl.json                 # 搜索入口跳转
    HOME-13.dsl.json                 # 搜索显示结果
    HOME-14.dsl.json                 # 搜索无结果空态
```

> 全部 10 条 case 已于 2026-06-16 真机实跑校正（manifest.verified 字段记录结果，9 PASS + 1 partial）。
> ⚠️ 跑批顺序有硬约束：见 `run_batch.workflow.md`——需登录的 HOME case 依赖先跑 AUTH-01 建立 session。

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
