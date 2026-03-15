#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="$ROOT_DIR/.logs/flutter-ios-unified.pid"
SESSION_FILE="$ROOT_DIR/.logs/flutter-ios-unified.tmux-session"

if [[ -f "$SESSION_FILE" ]]; then
  SESSION_NAME="$(cat "$SESSION_FILE")"
  if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux kill-session -t "$SESSION_NAME"
    echo "stopped flutter-ios-unified session $SESSION_NAME"
  else
    echo "stale tmux session file found for $SESSION_NAME"
  fi
  rm -f "$SESSION_FILE" "$PID_FILE"
  exit 0
fi

if [[ ! -f "$PID_FILE" ]]; then
  echo "flutter-ios-unified is not running"
  exit 0
fi

PID="$(cat "$PID_FILE")"
if kill -0 "$PID" 2>/dev/null; then
  kill "$PID"
  echo "stopped flutter-ios-unified pid $PID"
else
  echo "stale pid file found for pid $PID"
fi

rm -f "$PID_FILE"
