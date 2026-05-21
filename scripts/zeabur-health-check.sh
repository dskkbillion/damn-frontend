#!/usr/bin/env bash
# #359 Zeabur staging 服务健康检查脚本
#
# 用法: ./scripts/zeabur-health-check.sh [TOKEN]
#   - 若不传 TOKEN, 仅检查服务部署状态(不做 curl 探测)
#   - 若传 TOKEN, 同时跑 4 个 curl 探测验证后端功能
#
# 部署在 Zeabur 腾讯云新加坡, 项目 deepstream-staging。
# 输出格式化 ✅/❌ 每服务一行 + 末尾汇总。
# 详细信息见 ~/.claude/skills/开发-Deepstream全栈/references/zeabur-staging.md

set -uo pipefail

# --- Service IDs ---
DSKK_BACKEND_ID="69ef07eb6d2b0f8eeeda3709"
DSKK_MODEL_ID="69ef07f8e66a6b143b48a6ab"
MYSQL_ID="69ef07d0e66a6b143b48a68b"
REDIS_ID="69ef07dce66a6b143b48a69a"
MILVUS_ID="69eef525e66a6b143b489df2"
MINIO_ID="69eef525e66a6b143b489df1"
ETCD_ID="69eef525e66a6b143b489dfd"

BACKEND_URL="https://dskk-api-staging.zeabur.app"
MODEL_URL="https://dskk-model-staging.zeabur.app"

TOKEN="${1:-}"

# --- 颜色 ---
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
CYAN=$'\e[36m'
RESET=$'\e[0m'

# --- 计数器 ---
PASS=0
FAIL=0

check_deploy() {
  local name="$1"
  local sid="$2"
  local status
  status=$(npx -y zeabur@latest deployment list --service-id "$sid" -i=false 2>&1 \
    | head -3 | tail -1 | grep -oE "(BUILDING|RUNNING|FAILED|CRASHED|REMOVED)" | head -1)
  if [[ "$status" == "RUNNING" ]]; then
    echo "${GREEN}✅${RESET} ${name} (${sid:0:12}...) → RUNNING"
    PASS=$((PASS+1))
  elif [[ -z "$status" ]]; then
    echo "${YELLOW}⚠️${RESET}  ${name} (${sid:0:12}...) → 无活跃部署"
    FAIL=$((FAIL+1))
  else
    echo "${RED}❌${RESET} ${name} (${sid:0:12}...) → ${status}"
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
  headers=$(curl -sS -I --max-time 10 \
    -H "Authorization: ${TOKEN}" -H "packageName: com.duoshaokankan.weapp" \
    -H "version: 100" -H "client: ios" -H "clienttype: 1" \
    -X POST "${MODEL_URL}/model/chat/audio" 2>&1 || echo "")

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
echo "${CYAN}1. 应用服务部署状态 (zeabur cli)${RESET}"
# Note: 只查 Docker 应用服务的 deployment, prebuilt marketplace 服务(mysql/redis/milvus/...)
# 没有 deployment 概念, 通过应用服务的成功调用间接验证(见步骤 2 curl 探测)
check_deploy "dskk-backend     " "$DSKK_BACKEND_ID"
check_deploy "dskk-model-cols  " "$DSKK_MODEL_ID"
echo ""

echo "${CYAN}1.5 基础设施服务 (prebuilt — 间接验证)${RESET}"
echo "  通过 dskk-backend 的 mysql/redis 查询验证(见步骤 2)"
echo "  通过 dskk-model-cols 的 milvus 查询验证(见步骤 2)"
echo "  minio/etcd 通过 milvus 依赖关系间接验证"
echo ""

if [[ -n "$TOKEN" ]]; then
  echo "${CYAN}2. API 功能探测 (curl + token)${RESET}"
  curl_check "GET  /api/member/info       " "$BACKEND_URL/api/member/info" "200"
  curl_check "GET  /api/project/details   " "$BACKEND_URL/api/project/details?memberId=10318" "200"
  curl_check "POST /model/chat/list       " "$MODEL_URL/model/chat/list" "200|405"  # POST endpoint, GET 通常 405
  echo ""

  echo "${CYAN}3. ASR sunset 监控 (#368 下线追踪)${RESET}"
  asr_sunset_check
  echo ""
else
  echo "${YELLOW}⚠️${RESET}  未传 TOKEN, 跳过 API 探测和 ASR sunset 检查"
  echo "用法: ./scripts/zeabur-health-check.sh <MEMBER_TOKEN>"
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
