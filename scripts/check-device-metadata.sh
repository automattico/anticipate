#!/bin/zsh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK_CFG="$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"
SDK_ROOT="${CONNECTIQ_SDK_ROOT:-}"
DEVICES_ROOT="$HOME/Library/Application Support/Garmin/ConnectIQ/Devices"

if [[ -z "$SDK_ROOT" && -f "$SDK_CFG" ]]; then
  SDK_ROOT="$(cat "$SDK_CFG")"
fi

if [[ -z "$SDK_ROOT" || ! -d "$SDK_ROOT" ]]; then
  echo "SDK: MISSING"
else
  echo "SDK: OK ($SDK_ROOT)"
fi

DEVICE_IDS=("${(@f)$(sed -n 's/.*<iq:product id="\([^"]*\)".*/\1/p' "$PROJECT_ROOT/manifest.xml")}")
if [[ ${#DEVICE_IDS[@]} -eq 0 ]]; then
  echo "No devices found in manifest.xml." >&2
  exit 1
fi

for DEVICE_ID in "${DEVICE_IDS[@]}"; do
  COMPILER_JSON="$DEVICES_ROOT/$DEVICE_ID/compiler.json"
  if [[ ! -f "$COMPILER_JSON" ]]; then
    echo "$DEVICE_ID: MISSING metadata"
    exit 1
  fi

  jq -r '
    . as $d |
    ([$d.appTypes[]? | select(.type == "widget") | .memoryLimit][0]) as $widgetMemory |
    ([$d.appTypes[]? | select(.type == "glance") | .memoryLimit][0]) as $glanceMemory |
    [
      $d.deviceId,
      $d.displayName,
      (($d.resolution.width|tostring) + "x" + ($d.resolution.height|tostring)),
      $d.displayType,
      $d.deviceGroup,
      (($d.launcherIcon.width|tostring) + "x" + ($d.launcherIcon.height|tostring)),
      ("widgetMemory=" + (($widgetMemory // "none")|tostring)),
      ("glanceMemory=" + (($glanceMemory // "none")|tostring))
    ] | @tsv
  ' "$COMPILER_JSON"
done
