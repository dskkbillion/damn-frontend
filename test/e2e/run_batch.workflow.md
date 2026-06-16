# E2E 跑批器设计说明（run_batch.workflow.md）

## 目的

本文档描述如何用 mobai `execute_dsl` 把 `manifest.json` 里的所有 `automatable=yes` 用例串行跑完，汇总 PASS/FAIL 表。供人工操作或未来 Claude 会话照着执行。

---

## 约束：必须串行，绝不并行

mobai 控制的是单台物理/模拟器设备。同一时间只能有一个 DSL 脚本占用设备交互。并行执行会互相打断手势和输入，导致所有 case 全部 FAIL。

**结论：按 `cases[]` 数组顺序逐条跑，前一条完成后再跑下一条。**

---

## Case 分类

从 `manifest.json` 读取 `automatable` 字段分三类：

| automatable | 处理方式 |
|-------------|----------|
| `yes` | 纳入跑批，自动执行 |
| `partial` | 跳过自动执行，报告中标注「需人工辅助 / fixtures 未就绪」 |
| `no` | 跳过，报告中标注「不可自动化」并说明原因 |

当前 manifest 的 automatable 分布（6 条，均已 2026-06-16 真机实跑校正，verified 字段见 manifest）：

| Case | automatable | verified | 备注 |
|------|-------------|----------|------|
| AUTH-01 | yes | PASS | 自动跑（自动登出→登录→首页断言）|
| AUTH-04 | yes | PASS | 自动跑（瞬态 SnackBar 断言，tap 后不可插 wait_for stable）|
| AUTH-06 | partial | 环境受限 | 万能码不触发倒计时，跳过或只跑确定性弱断言 |
| HOME-01 | yes | PASS | 自动跑 |
| HOME-04 | yes | PASS | 自动跑 |
| HOME-12 | yes | PASS | 自动跑 |

---

## 执行协议（伪代码，供 Claude 会话照着执行）

```javascript
// run_batch.workflow — 供 Claude 会话逐步执行，不是可直接运行的代码
// 调用方：在 Claude Code 会话中，逐步用 mcp__mobai__execute_dsl 执行

const manifest = JSON.parse(readFile("test/e2e/manifest.json"));
const results = [];

for (const c of manifest.cases) {
  // 1. 跳过不可自动化的 case
  if (c.automatable !== "yes") {
    results.push({
      id: c.id,
      status: "SKIP",
      reason: c.automatable === "partial"
        ? "partial — 需人工辅助或 fixtures 未就绪"
        : "no — 不可自动化（" + c.description + "）",
      screenshot: null,
    });
    continue;
  }

  // 2. 读取 DSL 脚本
  const script = JSON.parse(readFile("test/e2e/" + c.file));

  // 3. 执行 DSL。⚠️ 长脚本（含 type / 页面跳转）几乎必触发 MCP 1s timeout——
  //    execute_dsl 抛 timeout error，但设备端仍在异步执行整段脚本。
  let execResult = null;
  try {
    execResult = await mcp__mobai__execute_dsl({ script: JSON.stringify(script) });
  } catch (e) {
    execResult = { timedOut: true };  // timeout 不代表失败，操作仍在跑
  }

  // 4. 等待整段脚本在设备上真正执行完（按脚本步数估，登出+登录类给 20-25s，单页类给 5-8s）
  await sleep(estimateRuntime(script));

  // 5. ⚠️ 关键：PASS/FAIL 不能看 execResult.error（1s timeout 会污染它）。
  //    必须用 observe 重新读终态 ui_tree，对脚本最后一个 assert_exists 的目标做独立复核。
  const finalTree = await mcp__mobai__execute_dsl({
    script: JSON.stringify({ version: "0.2", steps: [{ action: "observe", include: ["ui_tree"] }] })
  });
  const screenshotPath = "test-results/e2e/" + c.id + "_" + timestamp() + ".png";
  await mcp__mobai__save_screenshot({ path: screenshotPath });

  // 6. 判定：终态 ui_tree 里是否包含该 case 期望的终态锚点文本（取自 manifest.assertions 末项）
  //    例：AUTH-01→「搜索服务」, HOME-04→「已发布」, HOME-12→「热搜榜」
  const passed = finalTree.includes(c.expectedFinalAnchor);
  results.push({
    id: c.id,
    status: passed ? "PASS" : "FAIL",
    reason: passed ? null : "终态 ui_tree 未命中期望锚点：" + c.expectedFinalAnchor,
    screenshot: screenshotPath,
  });

  // 7. 瞬态断言 case（如 AUTH-04 的 SnackBar）特殊处理：SnackBar ~2s 即消失，
  //    无法靠"事后 observe"复核。这类 case 在脚本内 tap 紧跟 assert_exists 完成断言，
  //    且 tap+assert 短脚本通常 <1s 返回——直接读 execResult.step_results 末项 success 即可。

  // 8. 间隔 1s，让设备回到稳定态
  await sleep(1000);
}

// 8. 汇总报告
printReport(results);
```

---

## 报告格式

跑批结束后打印/输出以下格式：

```
=== DSKK E2E 跑批报告 ===
运行时间: 2026-06-16 HH:MM:SS
设备: com.duoshaokankan.weapp

| Case    | Status | 截图                         | 备注 |
|---------|--------|------------------------------|------|
| AUTH-01 | PASS   | test-results/e2e/AUTH-01_*.png | —  |
| AUTH-04 | PASS   | test-results/e2e/AUTH-04_*.png | SnackBar「请输入11位手机号」命中 |
| AUTH-06 | SKIP   | —                              | partial：万能码环境倒计时不触发，需真实短信环境 |
| HOME-01 | PASS   | test-results/e2e/HOME-01_*.png | —  |
| HOME-04 | PASS   | test-results/e2e/HOME-04_*.png | —  |
| HOME-12 | PASS   | test-results/e2e/HOME-12_*.png | —  |

自动跑: 5 / PASS: 5 / FAIL: 0 / SKIP: 1（AUTH-06 partial）
```

---

## AUTH-06 特别说明

AUTH-06 的核心验证目标是「验证码倒计时」，但 **2026-06-16 真机实测：万能码 565656 环境下点「获取验证码」14s 后按钮仍是「获取验证码」，根本不进入 60s 倒计时**——服务端直接返回码，绕过了真实短信倒计时逻辑。因此倒计时这一行为在本测试环境**不可复现**，AUTH-06 标 `partial`，跑批时 SKIP。脚本本身改成确定性弱断言（点击后验证码 input 仍在 + 无「异常」报错），只验证「点击未崩溃」，不验证倒计时。倒计时需真实短信环境才能测。

---

## 执行前检查清单

- [ ] 设备已连接（`mcp__mobai__list_devices` 有设备输出）
- [ ] App 已安装（bundle_id `com.duoshaokankan.weapp` 可见）
- [ ] 本地后端/staging 已启动，账号 18888888888 + 565656 万能码有效
- [ ] `test-results/e2e/` 目录已建（`mkdir -p test-results/e2e`）
- [ ] 每条跑完后确认设备回到稳定态再跑下一条

---

## 关于 1s timeout quirk

mobai `execute_dsl` 在某些版本下会在约 1s 后返回（即使 DSL 还在执行）。应对方式：
1. 执行后 `sleep(2000)` 等待动作完成
2. 再调用 `mcp__mobai__save_screenshot` 拿终态截图
3. 用截图 + `observe ui_tree` 双重确认终态断言

这不是 bug，是单设备串行驱动的正常节奏。
