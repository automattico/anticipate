#!/bin/zsh

set -euo pipefail
setopt NULL_GLOB

APP_ROOT="$TMPDIR/com.garmin.connectiq/GARMIN/APPS"
SETTINGS_ROOT="$TMPDIR/com.garmin.connectiq/GARMIN/Settings"

rm -rf \
  "$SETTINGS_ROOT"/ANTICIPATE-settings.* \
  "$APP_ROOT/SETTINGS"/ANTICIPATE*.SET \
  "$APP_ROOT/DATA"/ANTICIPATE*.DAT \
  "$APP_ROOT/DATA"/ANTICIPATE*.IDX \
  "$APP_ROOT/DATA/MEDIA/OBJSTORE"/ANTICIPATE*

echo "Cleared simulator state for Anticipate Countdowns."
