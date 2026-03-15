#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT_DIR/.logs"
PID_FILE="$LOG_DIR/flutter-ios-unified.pid"
SESSION_FILE="$LOG_DIR/flutter-ios-unified.tmux-session"
LOG_FILE="$LOG_DIR/flutter-ios-unified.latest.log"
PREVIOUS_LOG="$LOG_DIR/flutter-ios-unified.previous.log"
DEVICE_ID="${DEVICE_ID:-EEEC9C9C-AD80-443E-A3A6-E4920DDE3916}"
ENV_FILE="${ENV_FILE:-.env.local-debug}"
ENTRYPOINT="${ENTRYPOINT:-lib/main_unified.dart}"
SESSION_NAME="${SESSION_NAME:-flutter-ios-unified}"

mkdir -p "$LOG_DIR"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required for stable frontend background logging"
  exit 1
fi

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "flutter-ios-unified is already running in tmux session $SESSION_NAME"
  echo "log: $LOG_FILE"
  exit 1
fi

rm -f "$PID_FILE" "$SESSION_FILE"

if [[ -f "$LOG_FILE" ]]; then
  mv "$LOG_FILE" "$PREVIOUS_LOG"
fi

cd "$ROOT_DIR"
COMMAND="cd \"$ROOT_DIR\" && flutter run --machine -d \"$DEVICE_ID\" -t \"$ENTRYPOINT\" --dart-define=ENV_FILE=\"$ENV_FILE\""
tmux new-session -d -s "$SESSION_NAME" "$COMMAND"
tmux pipe-pane -o -t "$SESSION_NAME" "cat >> \"$LOG_FILE\""

PANE_PID="$(tmux list-panes -t "$SESSION_NAME" -F '#{pane_pid}')"
echo "$PANE_PID" >"$PID_FILE"
echo "$SESSION_NAME" >"$SESSION_FILE"

echo "flutter-ios-unified started"
echo "pid: $PANE_PID"
echo "tmux session: $SESSION_NAME"
echo "log: $LOG_FILE"
echo "device: $DEVICE_ID"
echo "entrypoint: $ENTRYPOINT"
echo "env: $ENV_FILE"
