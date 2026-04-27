#!/bin/zsh

set -u

SDK_CFG="$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"
SDK_ROOT=""
DEVICE_IDS=("fr55" "fr245" "fr245m" "fr255" "fr255m" "fr255s" "fr255sm" "fr955")
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
