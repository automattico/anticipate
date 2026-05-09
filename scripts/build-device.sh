#!/bin/zsh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK_CFG="$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"
SDK_ROOT="${CONNECTIQ_SDK_ROOT:-}"
DEVICE_ID="${1:-}"
DEFAULT_PRIVATE_KEY_PATH="$PROJECT_ROOT/private/anticipate-dev-key-4096.der"
if [[ ! -f "$DEFAULT_PRIVATE_KEY_PATH" ]]; then
  DEFAULT_PRIVATE_KEY_PATH="$PROJECT_ROOT/private/anticipate-dev-key.der"
fi
PRIVATE_KEY_PATH="${2:-${PRIVATE_KEY:-$DEFAULT_PRIVATE_KEY_PATH}}"
JAVA_BIN="${JAVA_BIN:-/opt/homebrew/opt/openjdk@17/bin/java}"
OUT_DIR="$PROJECT_ROOT/bin/device-builds"

function stop_running_simulator() {
  pkill -f "monkeybrains.monkeydodeux.MonkeyDoDeux" 2>/dev/null || true
  pkill -f "/bin/monkeydo" 2>/dev/null || true
  pkill -f "/bin/shell --transport=tcp" 2>/dev/null || true
  pkill -f "ConnectIQ.app/Contents/MacOS/simulator" 2>/dev/null || true
}

if [[ -z "$DEVICE_ID" ]]; then
  echo "Usage: $0 <device_id> [/path/to/signing-key.der]" >&2
  echo "Or set PRIVATE_KEY=/path/to/signing-key.der." >&2
  exit 1
fi

if [[ -z "$SDK_ROOT" && -f "$SDK_CFG" ]]; then
  SDK_ROOT="$(cat "$SDK_CFG")"
fi

if [[ -z "$SDK_ROOT" || ! -d "$SDK_ROOT" ]]; then
  echo "Missing Connect IQ SDK. Set CONNECTIQ_SDK_ROOT or configure $SDK_CFG." >&2
  exit 1
fi

if [[ -z "$PRIVATE_KEY_PATH" || ! -f "$PRIVATE_KEY_PATH" ]]; then
  echo "Missing signing key: $PRIVATE_KEY_PATH" >&2
  echo "Pass a key path as the second argument or set PRIVATE_KEY." >&2
  exit 1
fi

if [[ ! -x "$JAVA_BIN" ]]; then
  echo "Missing Java executable: $JAVA_BIN" >&2
  exit 1
fi

if [[ "${KEEP_SIMULATOR_RUNNING:-0}" != "1" ]]; then
  stop_running_simulator
fi

mkdir -p "$OUT_DIR"
LOG_FILE="$OUT_DIR/anticipate-$DEVICE_ID.log"

"$JAVA_BIN" \
    -Xms1g \
    -Dfile.encoding=UTF-8 \
    -Dapple.awt.UIElement=true \
    -jar "$SDK_ROOT/bin/monkeybrains.jar" \
    -o "$OUT_DIR/anticipate-$DEVICE_ID.prg" \
    -f "$PROJECT_ROOT/monkey.jungle" \
    -y "$PRIVATE_KEY_PATH" \
    -d "$DEVICE_ID" \
    -r -w -l 2 -w 2>&1 | tee "$LOG_FILE"

if grep -Eiq '(^|[^[:alpha:]])warning([^[:alpha:]]|$)' "$LOG_FILE"; then
  echo "Compiler warnings found for $DEVICE_ID." >&2
  exit 1
fi

echo "Built $DEVICE_ID with no compiler errors or warnings."
