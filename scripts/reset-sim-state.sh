#!/bin/zsh

set -euo pipefail
setopt NULL_GLOB

APP_ROOT="$TMPDIR/com.garmin.connectiq/GARMIN/APPS"
SETTINGS_ROOT="$TMPDIR/com.garmin.connectiq/GARMIN/Settings"

pkill -f "monkeybrains.monkeydodeux.MonkeyDoDeux" 2>/dev/null || true
pkill -f "/bin/monkeydo" 2>/dev/null || true
pkill -f "/bin/shell --transport=tcp" 2>/dev/null || true
pkill -f "ConnectIQ.app/Contents/MacOS/simulator" 2>/dev/null || true

rm -rf \
  "$APP_ROOT/MEDIA"/ANTICIPATE* \
  "$SETTINGS_ROOT"/ANTICIPATE-settings.* \
  "$SETTINGS_ROOT"/ANTICIPATE-*-settings.* \
  "$APP_ROOT/SETTINGS"/ANTICIPATE*.SET \
  "$APP_ROOT/DATA"/ANTICIPATE*.DAT \
  "$APP_ROOT/DATA"/ANTICIPATE*.IDX \
  "$APP_ROOT/DATA/MEDIA/OBJSTORE"/ANTICIPATE*

echo "Cleared simulator state for Anticipate Countdowns."
