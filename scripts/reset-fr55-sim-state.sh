#!/bin/zsh

set -euo pipefail

APP_ROOT="$TMPDIR/com.garmin.connectiq/GARMIN/APPS"

rm -rf \
  "$APP_ROOT/SETTINGS/ANTICIPATE.SET" \
  "$APP_ROOT/DATA/MEDIA/OBJSTORE/ANTICIPATE"

echo "Cleared FR55 simulator state for Anticipate Countdowns."
