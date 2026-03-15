#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_FILE="$ROOT_DIR/.logs/flutter-ios-unified.latest.log"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "missing log file: $LOG_FILE"
  exit 1
fi

tail -n "${TAIL_LINES:-200}" -f "$LOG_FILE"
