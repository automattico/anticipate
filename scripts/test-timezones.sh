#!/bin/zsh
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK_ROOT="${CONNECTIQ_SDK_ROOT:-$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")}"
DEVICE_ID="${1:-venu445mm}"
PRIVATE_KEY_PATH="${2:-${PRIVATE_KEY:-$PROJECT_ROOT/private/anticipate-dev-key-4096.der}}"
OUT_DIR="$PROJECT_ROOT/bin/timezone-tests/$DEVICE_ID"
mkdir -p "$OUT_DIR"

"$SDK_ROOT/bin/monkeyc" \
  -o "$OUT_DIR/anticipate-timezone-tests.prg" \
  -f "$PROJECT_ROOT/monkey.jungle;$PROJECT_ROOT/tests.jungle" \
  -y "$PRIVATE_KEY_PATH" -d "$DEVICE_ID" --unit-test -w -l 2 \
  > "$OUT_DIR/build.log" 2>&1
cat "$OUT_DIR/build.log"
if grep -Eiq '(^|[^[:alpha:]])warning([^[:alpha:]]|$)' "$OUT_DIR/build.log"; then
  exit 1
fi

open "$SDK_ROOT/bin/ConnectIQ.app"
RUN_STATUS=0
"$SDK_ROOT/bin/monkeydo" "$OUT_DIR/anticipate-timezone-tests.prg" "$DEVICE_ID" -t \
  > "$OUT_DIR/tests.log" 2>&1 || RUN_STATUS=$?
cat "$OUT_DIR/tests.log"
# SDK 9.1 monkeydo returns 1 even when all tests pass. Require the explicit
# results footer, and reject other failures rather than trusting that exit code.
[[ "$RUN_STATUS" -le 1 ]] && \
  grep -Eq '^PASSED \(passed=[1-9][0-9]*, failed=0, errors=0\)$' "$OUT_DIR/tests.log" && \
  ! grep -Eq '^FAILED|^ERROR|^FAIL$' "$OUT_DIR/tests.log"
