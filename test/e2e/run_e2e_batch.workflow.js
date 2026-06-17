export const meta = {
  name: 'dskk-e2e-batch',
  description: 'DSKK E2E 冲烟跑批：串行执行所有 automatable=yes 的 DSL case，AUTH-01 先建 session，AUTH-10 最后',
  phases: [
    { title: 'Auth', detail: 'AUTH-01 登录建立 session' },
    { title: 'Cases', detail: '按顺序串行跑剩余 automatable=yes case' },
    { title: 'Teardown', detail: 'AUTH-04 / AUTH-10 破坏登录态的 case' },
    { title: 'Report', detail: '汇总 PASS/FAIL/SKIP 报告' },
  ],
}

// ── 配置 ────────────────────────────────────────────────────────────────────
const DEVICE_ID = args?.deviceId ?? '5EEB52BF-3A70-48A7-A64C-5492FD941CAA'
const E2E_DIR = args?.e2eDir ?? '/Users/paperblue/Projects/DeepStream/damn-frontend/test/e2e'
const RESULTS_DIR = args?.resultsDir ?? '/Users/paperblue/Projects/DeepStream/damn-frontend/test-results/e2e'
const SETTLE_MS_DEFAULT = args?.settleMs ?? 7000  // Zeabur 冷启动慢，默认 7s settle

// settle 时间按脚本类型调整
function estimateSettleMs(caseId) {
  // 登录/登出类（含页面跳转+网络）给更长时间
  if (['AUTH-01', 'AUTH-10', 'HOME-01', 'HOME-04', 'HOME-05'].includes(caseId)) return 10000
  // 含搜索/输入的给 8s
  if (['HOME-13', 'HOME-14', 'HOME-12', 'AI-02', 'ORD-10'].includes(caseId)) return 8000
  // AUTH-04 SnackBar 瞬态，给 4s（tap 后 SnackBar ~2s 消失）
  if (caseId === 'AUTH-04') return 4000
  return SETTLE_MS_DEFAULT
}

// AUTH-05 / AUTH-07 跑完后破坏了登录态（停在登录页），需在下一个 case 前重新登录
const NEED_RELOGIN_AFTER = ['AUTH-05', 'AUTH-07']

// ── 工具函数（传给 agent 的 prompt 中内联）─────────────────────────────────
const RUN_CASE_PROMPT = (caseId, dslFile, settleMs, resultsDir, deviceId) => `
你是 DSKK E2E 跑批器的 case 执行 agent。你的任务是执行一个 DSL 测试脚本并返回结构化结果。

## 要执行的 case
- Case ID: ${caseId}
- DSL 文件: ${dslFile}
- 设备 ID: ${deviceId}
- Settle 等待: ${settleMs}ms（execute_dsl 1s timeout quirk 后等设备执行完成）
- 截图保存目录: ${resultsDir}

## 执行步骤

1. 读取 DSL 文件: ${dslFile}
2. 【重要前置】执行 DSL 前，先用 mcp__mobai__execute_dsl 把 app 导航回首页（除非 DSL 自带 fresh 重启）：
   {"version":"0.2","steps":[{"action":"tap","predicate":{"text_contains":"逛逛"}},{"action":"wait_for","stable":true,"timeout_ms":3000}]}
   - 如果 tap 逛逛失败（不在有 tab bar 的页面），先 open_app fresh 再 tap
3. 用 mcp__mobai__execute_dsl 执行 DSL（device_id="${deviceId}"，commands=文件内容的 JSON 字符串）
   - 会超时 1s 返回 error——这是正常的 1s timeout quirk，脚本仍在设备上异步执行
   - 记录是否超时（timedOut=true）还是真失败
4. 用 Bash sleep ${Math.ceil(settleMs / 1000)} 等待设备执行完成
5. 用 mcp__mobai__get_screenshot 截当前终态图（device_id="${deviceId}"）
6. 用 mcp__mobai__execute_dsl 执行 observe 读取 ui_tree 终态：
   {"version":"0.2","steps":[{"action":"observe","include":["ui_tree"]}]}
7. 基于截图视觉 + ui_tree 文本，判断 PASS 或 FAIL：
   - PASS 条件：终态画面/ui_tree 符合该 case 的预期（参考 DSL 里最后一个 assert_exists 的 predicate）
   - FAIL 条件：崩溃红屏、predicate 未命中、或停在错误页
   - 如果 execute_dsl 返回 success=false 且非 1s timeout quirk，也判 FAIL
8. 用 mcp__mobai__save_screenshot 保存截图到 ${resultsDir}/${caseId}_result.png

## 返回格式（JSON，通过 StructuredOutput 工具返回）

返回以下字段：
- caseId: string
- status: "PASS" | "FAIL" | "ERROR"
- reason: string（PASS 时写终态锚点文本，FAIL/ERROR 时写失败原因）
- screenshotPath: string（保存的截图路径）
- timedOut: boolean（execute_dsl 是否触发了 1s timeout quirk）

## 注意事项
- AUTH-04 是 SnackBar 瞬态 case（约 2s 消失），终态断言靠 execResult.step_results 里的 success 判断，不靠 observe
- AUTH-05/AUTH-07/AUTH-10 自己管理页面状态（会停在登录页），不需要前置「回首页」步骤
- 如果红屏崩溃（ui_tree 只剩 tab bar 或显示 Flutter error text），判 FAIL，reason 写 "崩溃/GlobalKey error 等"
- 不要重试，执行一次截图判定即可
`

const CASE_RESULT_SCHEMA = {
  type: 'object',
  properties: {
    caseId: { type: 'string' },
    status: { type: 'string', enum: ['PASS', 'FAIL', 'ERROR'] },
    reason: { type: 'string' },
    screenshotPath: { type: 'string' },
    timedOut: { type: 'boolean' },
  },
  required: ['caseId', 'status', 'reason', 'screenshotPath', 'timedOut'],
}

// ── 读 manifest，构建有序 case 列表 ──────────────────────────────────────────
const manifestRaw = await agent(
  `读取文件 ${E2E_DIR}/manifest.json，返回所有 automatable=yes 的 case 列表（JSON 数组，每项含 id 和 file 字段）。只返回 JSON 数组，不要其他文字。`,
  {
    label: 'read-manifest',
    phase: 'Auth',
    schema: {
      type: 'object',
      properties: {
        cases: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string' },
              file: { type: 'string' },
            },
            required: ['id', 'file'],
          },
        },
      },
      required: ['cases'],
    },
  }
)

const allCases = manifestRaw.cases

// 排序：AUTH-01 第一，AUTH-04/AUTH-10 最后
const FIRST = ['AUTH-01']
const LAST = ['AUTH-04', 'AUTH-10']
const first = allCases.filter(c => FIRST.includes(c.id))
const last = allCases.filter(c => LAST.includes(c.id))
const middle = allCases.filter(c => !FIRST.includes(c.id) && !LAST.includes(c.id))
const orderedCases = [...first, ...middle, ...last]

log(`共 ${orderedCases.length} 个 automatable=yes case，执行顺序: ${orderedCases.map(c => c.id).join(' → ')}`)

// ── Phase 1: AUTH-01 建 session ──────────────────────────────────────────────
phase('Auth')

const auth01 = orderedCases[0]
log(`[1/${orderedCases.length}] 跑 AUTH-01 建立 session...`)

const auth01Result = await agent(
  RUN_CASE_PROMPT(auth01.id, `${E2E_DIR}/${auth01.file}`, estimateSettleMs(auth01.id), RESULTS_DIR, DEVICE_ID),
  { label: `run:${auth01.id}`, phase: 'Auth', schema: CASE_RESULT_SCHEMA }
)

if (!auth01Result || auth01Result.status === 'FAIL' || auth01Result.status === 'ERROR') {
  log(`⛔ AUTH-01 ${auth01Result?.status ?? 'null'} — session 未建立，无法继续跑批。终止。`)
  const report = {
    summary: { total: orderedCases.length, pass: 0, fail: 1, skip: orderedCases.length - 1, error: 0 },
    results: [{ ...auth01Result, caseId: 'AUTH-01' }],
    blockedReason: 'AUTH-01 失败，session 未建立',
  }
  return report
}

log(`✅ AUTH-01 PASS — session 已建立，继续跑剩余 ${orderedCases.length - 1} 个 case`)

const results = [auth01Result]

// ── Phase 2: 中间 case（复用已登录态）───────────────────────────────────────
phase('Cases')

const middleCases = orderedCases.slice(1, orderedCases.length - 2)

let needRelogin = false

for (let i = 0; i < middleCases.length; i++) {
  const c = middleCases[i]
  const idx = i + 2  // 整体序号（AUTH-01=1）

  // 上一个 case 破坏了登录态，先用 AUTH-01 脚本恢复 session
  // AUTH-01 自带 if_exists 逻辑：已登录跳过，未登录则执行完整登录流程
  if (needRelogin) {
    log(`  ↻ 恢复 session（用 AUTH-01 脚本重新登录）...`)
    const reloginResult = await agent(
      RUN_CASE_PROMPT('AUTH-01-relogin', `${E2E_DIR}/auth/AUTH-01.dsl.json`, 12000, RESULTS_DIR, DEVICE_ID),
      { label: `relogin-before:${c.id}`, phase: 'Cases', schema: CASE_RESULT_SCHEMA }
    )
    if (!reloginResult || reloginResult.status !== 'PASS') {
      log(`  ⛔ session 恢复失败（${reloginResult?.reason ?? 'null'}），后续 case 跳过`)
      for (let j = i; j < middleCases.length; j++) {
        results.push({ caseId: middleCases[j].id, status: 'ERROR', reason: 'session 恢复失败，跳过', screenshotPath: '', timedOut: false })
      }
      break
    }
    needRelogin = false
    log(`  ✅ session 已恢复`)
  }

  log(`[${idx}/${orderedCases.length}] 跑 ${c.id}...`)

  const result = await agent(
    RUN_CASE_PROMPT(c.id, `${E2E_DIR}/${c.file}`, estimateSettleMs(c.id), RESULTS_DIR, DEVICE_ID),
    { label: `run:${c.id}`, phase: 'Cases', schema: CASE_RESULT_SCHEMA }
  )

  if (result) {
    results.push(result)
    log(`  → ${result.status}: ${result.reason.slice(0, 80)}`)
  } else {
    results.push({ caseId: c.id, status: 'ERROR', reason: 'agent 返回 null', screenshotPath: '', timedOut: false })
    log(`  → ERROR: agent 返回 null`)
  }

  // 标记下一 case 需要 relogin
  if (NEED_RELOGIN_AFTER.includes(c.id)) needRelogin = true
}

// ── Phase 3: 破坏登录态的 case（AUTH-04、AUTH-10）───────────────────────────
phase('Teardown')

const teardownCases = orderedCases.slice(-2)

for (let i = 0; i < teardownCases.length; i++) {
  const c = teardownCases[i]
  const idx = orderedCases.length - 1 + i
  log(`[${idx}/${orderedCases.length}] 跑 ${c.id}（破坏登录态）...`)

  const result = await agent(
    RUN_CASE_PROMPT(c.id, `${E2E_DIR}/${c.file}`, estimateSettleMs(c.id), RESULTS_DIR, DEVICE_ID),
    { label: `run:${c.id}`, phase: 'Teardown', schema: CASE_RESULT_SCHEMA }
  )

  if (result) {
    results.push(result)
    log(`  → ${result.status}: ${result.reason.slice(0, 80)}`)
  } else {
    results.push({ caseId: c.id, status: 'ERROR', reason: 'agent 返回 null', screenshotPath: '', timedOut: false })
  }
}

// ── Phase 4: 汇总报告 ────────────────────────────────────────────────────────
phase('Report')

const pass = results.filter(r => r.status === 'PASS').length
const fail = results.filter(r => r.status === 'FAIL').length
const error = results.filter(r => r.status === 'ERROR').length

const reportLines = [
  '=== DSKK E2E 跑批报告 ===',
  `设备: ${DEVICE_ID}`,
  `总计: ${results.length} / PASS: ${pass} / FAIL: ${fail} / ERROR: ${error}`,
  '',
  '| Case     | Status | 原因/锚点                           |',
  '|----------|--------|-------------------------------------|',
  ...results.map(r =>
    `| ${r.caseId.padEnd(8)} | ${r.status.padEnd(6)} | ${(r.reason ?? '').slice(0, 50).padEnd(51)} |`
  ),
]

log(reportLines.join('\n'))

return {
  summary: { total: results.length, pass, fail, error, skip: orderedCases.length - results.length },
  results,
  reportText: reportLines.join('\n'),
}
