# Repo Instructions

These instructions apply to all work in this repository.

## Verification Workflow

- For any watchface, widget, layout, or visual UI change, always compile the app before finishing.
- After compiling, always launch the Garmin simulator for the target device and load the latest build.
- Always capture a screenshot of the updated screen and visually verify the result yourself.
- If the layout, spacing, alignment, clipping, or styling is off, keep iterating and re-testing until it is corrected.
- Do not stop at code changes alone for UI work unless the required simulator or screenshot tooling is unavailable. If blocked, say exactly what could not be run.

## Codex Automation Preferences

- This repo is trusted for Codex automation work.
- Prefer direct Garmin SDK commands over `zsh -lc` wrappers when possible so existing approval rules can match consistently.
- Prefer these paths and commands for verification flows:
  - `./scripts/reset-sim-state.sh`
  - `./scripts/reset-fr55-sim-state.sh`
  - `open "$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/ConnectIQ.app"`
  - `"$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/monkeyc" ...`
  - `"$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/monkeydo" ...`
- For screenshots, prefer the built-in screenshot skill or the existing approved screenshot helper.
