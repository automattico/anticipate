#!/bin/zsh

set -u

SDK_CFG="$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"
SDK_ROOT=""
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE_IDS=("${(@f)$(sed -n 's/.*<iq:product id="\([^"]*\)".*/\1/p' "$PROJECT_ROOT/manifest.xml")}")
JDK_HINT="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
JAVA_BIN="/opt/homebrew/opt/openjdk@17/bin/java"

echo "Checking Garmin Connect IQ workspace..."

if [[ -f "$SDK_CFG" ]]; then
  SDK_ROOT="$(cat "$SDK_CFG")"
fi

if [[ -n "$SDK_ROOT" && -d "$SDK_ROOT" ]]; then
  echo "SDK: OK"
  echo "Active SDK: $SDK_ROOT"
else
  echo "SDK: MISSING"
fi

if [[ ${#DEVICE_IDS[@]} -eq 0 ]]; then
  echo "Manifest devices: MISSING"
  exit 1
fi

for DEVICE_ID in "${DEVICE_IDS[@]}"; do
  if [[ -d "$HOME/Library/Application Support/Garmin/ConnectIQ/Devices/$DEVICE_ID" ]]; then
    echo "Device ($DEVICE_ID): OK"
  else
    echo "Device ($DEVICE_ID): MISSING"
  fi
done

if [[ -x "$JAVA_BIN" ]] && "$JAVA_BIN" -version >/tmp/anticipate-java-version.txt 2>&1; then
  echo "Java: OK"
  head -n 2 /tmp/anticipate-java-version.txt
else
  echo "Java: MISSING"
  echo "Expected JDK root for VS Code setting: $JDK_HINT"
fi

if [[ -n "$SDK_ROOT" && -x "$SDK_ROOT/bin/monkeyc" ]]; then
  echo "Compiler: OK"
else
  echo "Compiler: MISSING"
fi
