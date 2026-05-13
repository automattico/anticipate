#!/bin/zsh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK_CFG="$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"
SDK_ROOT="${CONNECTIQ_SDK_ROOT:-}"
PRIVATE_KEY_PATH="${1:-${PRIVATE_KEY:-}}"
OUT_DIR="$PROJECT_ROOT/bin/device-builds"

if [[ -z "$SDK_ROOT" && -f "$SDK_CFG" ]]; then
  SDK_ROOT="$(cat "$SDK_CFG")"
fi

if [[ -z "$SDK_ROOT" || ! -d "$SDK_ROOT" ]]; then
  echo "Missing Connect IQ SDK. Set CONNECTIQ_SDK_ROOT or configure $SDK_CFG." >&2
  exit 1
fi

if [[ -z "$PRIVATE_KEY_PATH" || ! -f "$PRIVATE_KEY_PATH" ]]; then
  echo "Usage: $0 /path/to/signing-key.der" >&2
  echo "Or set PRIVATE_KEY=/path/to/signing-key.der." >&2
  exit 1
fi

MONKEYC_BIN="$SDK_ROOT/bin/monkeyc"
if [[ ! -x "$MONKEYC_BIN" ]]; then
  echo "Missing Connect IQ compiler: $MONKEYC_BIN" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

DEVICE_IDS=("${(@f)$(sed -n 's/.*<iq:product id="\([^"]*\)".*/\1/p' "$PROJECT_ROOT/manifest.xml")}")
if [[ ${#DEVICE_IDS[@]} -eq 0 ]]; then
  echo "No devices found in manifest.xml." >&2
  exit 1
fi

for DEVICE_ID in "${DEVICE_IDS[@]}"; do
  echo "Building $DEVICE_ID..."
  LOG_FILE="$OUT_DIR/anticipate-$DEVICE_ID.log"
  "$MONKEYC_BIN" \
      -o "$OUT_DIR/anticipate-$DEVICE_ID.prg" \
      -f "$PROJECT_ROOT/monkey.jungle" \
      -y "$PRIVATE_KEY_PATH" \
      -d "$DEVICE_ID" \
      -r -w -l 2 2>&1 | tee "$LOG_FILE"

  if grep -Eiq '(^|[^[:alpha:]])warning([^[:alpha:]]|$)' "$LOG_FILE"; then
    echo "Compiler warnings found for $DEVICE_ID." >&2
    exit 1
  fi
done

echo "Built ${#DEVICE_IDS[@]} device targets with no compiler errors or warnings."
