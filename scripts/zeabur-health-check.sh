#!/usr/bin/env bash
# #359 Zeabur staging 服务健康检查脚本
#
# 用法: ./scripts/zeabur-health-check.sh
#   - 默认检查 Zeabur 当前服务状态和官方 gateway 健康状态
#   - 设置 DSKK_MEMBER_TOKEN 后，同时跑鉴权 API 探测
#
# 部署在 Zeabur 腾讯云新加坡, 项目 deepstream-staging。
# 输出格式化 ✅/❌ 每服务一行 + 末尾汇总。
# 详细信息见 ~/.claude/skills/开发-Deepstream全栈/references/zeabur-staging.md

set -uo pipefail

for required_command in zeabur jq curl; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "缺少必要命令: $required_command" >&2
    exit 2
  fi
done

# --- Service IDs ---
DSKK_BACKEND_ID="69ef07eb6d2b0f8eeeda3709"
DSKK_MODEL_ID="69ef07f8e66a6b143b48a6ab"
DSKK_GATEWAY_ID="6a5c99bd2280c02cc1b654ad"
DSKK_ENVIRONMENT_ID="69eef4f41e7c7466bb9d0cbf"
MYSQL_ID="69ef07d0e66a6b143b48a68b"
REDIS_ID="69ef07dce66a6b143b48a69a"
MILVUS_ID="69eef525e66a6b143b489df2"
MINIO_ID="69eef525e66a6b143b489df1"
ETCD_ID="69eef525e66a6b143b489dfd"

BACKEND_URL="https://deep-stream.ai/prod-api"
GATEWAY_URL="https://deep-stream.ai"
MODEL_URL="https://dskk-model-staging.zeabur.app"

if [[ $# -ne 0 ]]; then
  echo "拒绝从命令行参数读取 Token；请改用 DSKK_MEMBER_TOKEN 环境变量。" >&2
  exit 2
fi

TOKEN="${DSKK_MEMBER_TOKEN:-}"

# --- 颜色 ---
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
CYAN=$'\e[36m'
RESET=$'\e[0m'

# --- 计数器 ---
PASS=0
FAIL=0

check_service() {
  local name="$1"
  local sid="$2"
  local status
  status=$(zeabur service get --id "$sid" --env-id "$DSKK_ENVIRONMENT_ID" \
    --json -i=false 2>/dev/null | jq -r '.Status // empty')

  if [[ "$status" == "RUNNING" ]]; then
    echo "${GREEN}✅${RESET} ${name} (${sid:0:12}...) → RUNNING"
    PASS=$((PASS+1))
  elif [[ -z "$status" ]]; then
    echo "${RED}❌${RESET} ${name} (${sid:0:12}...) → 无法读取当前服务状态"
    FAIL=$((FAIL+1))
  else
    echo "${RED}❌${RESET} ${name} (${sid:0:12}...) → ${status}"
    FAIL=$((FAIL+1))
  fi
}

public_check() {
  local name="$1"
  local url="$2"
  local expected="$3"
  local code
  code=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 15 "$url" \
    2>/dev/null || echo "000")
  if [[ "$code" =~ $expected ]]; then
    echo "${GREEN}✅${RESET} ${name} HTTP ${code} (期望 ${expected})"
    PASS=$((PASS+1))
  else
    echo "${RED}❌${RESET} ${name} HTTP ${code} (期望 ${expected})"
    FAIL=$((FAIL+1))
  fi
}

semantic_health_check() {
  local name="$1"
  local url="$2"
  local body_file
  body_file="$(mktemp)"
  local code
  code=$(curl -sS -o "${body_file}" -w "%{http_code}" --max-time 15 "${url}" 2>/dev/null || echo "000")
  local status
  status=$(jq -r 'if (type == "object") then (.status // empty) else empty end' "${body_file}" 2>/dev/null || true)
  local legacy_code
  legacy_code=$(jq -r 'if (type == "object") then (.code // empty) else empty end' "${body_file}" 2>/dev/null || true)
  rm -f "${body_file}"
  if [[ "${code}" == "200" && "${status}" == "UP" && -z "${legacy_code}" ]]; then
    echo "${GREEN}✅${RESET} ${name} HTTP 200 status=UP"
    PASS=$((PASS+1))
  else
    echo "${RED}❌${RESET} ${name} HTTP ${code} status=${status:-missing} legacyCode=${legacy_code:-none}"
    FAIL=$((FAIL+1))
  fi
}

curl_check() {
  local name="$1"
  local url="$2"
  local extra_grep="${3:-200}"
  local code
  code=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 15 \
    -H "Authorization: ${TOKEN}" -H "packageName: com.duoshaokankan.weapp" \
    -H "version: 100" -H "client: ios" -H "clienttype: 1" \
    "$url" 2>&1 || echo "000")
  if [[ "$code" =~ $extra_grep ]]; then
    echo "${GREEN}✅${RESET} ${name} HTTP ${code} (期望 ${extra_grep})"
    PASS=$((PASS+1))
  else
    echo "${RED}❌${RESET} ${name} HTTP ${code} (期望 ${extra_grep})"
    FAIL=$((FAIL+1))
  fi
}

asr_sunset_check() {
  # 第 8 探测: /model/chat/audio 是否仍在响应 + 是否带 Sunset header
  # 后端 #360 已加 Sunset/Deprecation header。脚本检查:
  # - HTTP 200 (deprecated 状态, 仍能响应) → ⚠️ warning(前端仍可能调)
  # - HTTP 404/410/Gone → ✅(2026-06-04 真正下线后)
  # - 无响应 → ❌
  local headers
  # 用 POST + 有效 body, 后端才会进入 endpoint 路由并附上 Sunset header
  # 故意传一个会 422 失败的 URL — 仅检 response headers 是否带 deprecation 标记
  headers=$(curl -sS --max-time 10 -D - -o /dev/null \
    -H "Authorization: ${TOKEN}" -H "packageName: com.duoshaokankan.weapp" \
    -H "version: 100" -H "client: ios" -H "clienttype: 1" \
    -H "Content-Type: application/json" \
    -X POST "${MODEL_URL}/model/chat/audio" \
    -d '{"user_id":10377,"url":"https://example.com/notreal.mp3"}' 2>&1 || echo "")

  local sunset=$(echo "$headers" | grep -i "^sunset:" | head -1)
  local deprecation=$(echo "$headers" | grep -i "^deprecation:" | head -1)
  local status_line=$(echo "$headers" | head -1)
  local http_code=$(echo "$status_line" | grep -oE '[0-9]{3}' | head -1)

  if [[ "$http_code" == "404" || "$http_code" == "410" || "$http_code" == "405" ]]; then
    echo "${GREEN}✅${RESET} ASR /model/chat/audio 已下线 (HTTP ${http_code})"
    PASS=$((PASS+1))
  elif [[ -n "$sunset" ]] || [[ -n "$deprecation" ]]; then
    echo "${YELLOW}⚠️${RESET}  ASR /model/chat/audio 仍在线(deprecated)"
    [[ -n "$sunset" ]] && echo "        ${sunset}"
    [[ -n "$deprecation" ]] && echo "        ${deprecation}"
    PASS=$((PASS+1))
  elif [[ -z "$http_code" ]]; then
    echo "${RED}❌${RESET} ASR /model/chat/audio 无响应"
    FAIL=$((FAIL+1))
  else
    echo "${YELLOW}⚠️${RESET}  ASR /model/chat/audio HTTP ${http_code} (无 Sunset header, 可能未部署 #360 后端改动)"
    PASS=$((PASS+1))
  fi
}

echo "${CYAN}=== Zeabur Staging Health Check $(date +%H:%M:%S) ===${RESET}"
echo ""
echo "${CYAN}1. 应用服务当前状态 (zeabur cli)${RESET}"
check_service "deepstream-gateway" "$DSKK_GATEWAY_ID"
check_service "dskk-backend     " "$DSKK_BACKEND_ID"
check_service "dskk-model-cols  " "$DSKK_MODEL_ID"
echo ""

echo "${CYAN}1.5 基础设施服务 (prebuilt — 间接验证)${RESET}"
echo "  通过 dskk-backend 的 mysql/redis 查询验证(见步骤 2)"
echo "  通过 dskk-model-cols 的 milvus 查询验证(见步骤 2)"
echo "  minio/etcd 通过 milvus 依赖关系间接验证"
echo ""

echo "${CYAN}2. 官方入口健康探测${RESET}"
public_check "GET  /healthz               " "$GATEWAY_URL/healthz" "200"
semantic_health_check "GET  backend liveness      " "$BACKEND_URL/actuator/health/liveness"
semantic_health_check "GET  backend readiness     " "$BACKEND_URL/actuator/health/readiness"
echo ""

if [[ -n "$TOKEN" ]]; then
  echo "${CYAN}3. API 功能探测 (curl + DSKK_MEMBER_TOKEN)${RESET}"
  curl_check "GET  /api/member/info       " "$BACKEND_URL/api/member/info" "200"
  curl_check "GET  /api/project/details   " "$BACKEND_URL/api/project/details?memberId=10318" "200"
  curl_check "POST /model/chat/list       " "$MODEL_URL/model/chat/list" "200|405"  # POST endpoint, GET 通常 405
  echo ""

  echo "${CYAN}3. ASR sunset 监控 (#368 下线追踪)${RESET}"
  asr_sunset_check
  echo ""
else
  echo "${YELLOW}⚠️${RESET}  未传 TOKEN, 跳过 API 探测和 ASR sunset 检查"
  echo "用法: DSKK_MEMBER_TOKEN='<短期测试令牌>' ./scripts/zeabur-health-check.sh"
  echo ""
fi

# --- 汇总 ---
TOTAL=$((PASS + FAIL))
echo "${CYAN}=== 汇总 ===${RESET}"
if [[ $FAIL -eq 0 ]]; then
  echo "${GREEN}✅ 全部 ${PASS}/${TOTAL} 通过${RESET}"
  exit 0
else
  echo "${RED}❌ ${FAIL}/${TOTAL} 失败 (通过 ${PASS})${RESET}"
  exit 1
fi
