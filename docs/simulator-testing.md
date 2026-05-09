# Simulator Testing Playbook

Use this when validating widget UI changes in the Garmin simulator. The goal is to avoid re-learning the same simulator quirks every time.

This document is intentionally practical. It prefers the commands and workflows that actually worked in this repo on macOS with the local Connect IQ SDK.

## What Usually Goes Wrong

- `monkeydo` fails with `Unable to connect to simulator.` when the simulator app is not fully open yet, or when the command is run in a restricted environment.
- In Codex automation, `monkeydo` may also fail with `Unable to connect to simulator.` until it is run outside the sandboxed path, even when the simulator window is already open.
- On newer AMOLED targets, a build signed with the older local test key may launch to a blue error triangle or log `Signature check failed`.
- Resetting simulator state removes the widget configuration, and restoring it is not as simple as copying one obvious file back.
- A stale sideloaded PRG in `GARMIN/APPS/MEDIA` can survive a partial reset and keep the simulator looking for the wrong app-specific settings filename.
- The App Settings Editor stays blank or shows `No settings file found for this app` unless the matching `-settings.json` schema file exists under `GARMIN/Settings/`.
- Screenshot capture is easy once macOS permissions are correct, but brittle if you guess window titles or try to capture too early.
- Paging through countdowns is harder to automate reliably than launching the widget.
- Compiler success does not prove launcher icon compatibility; icon-size warnings must be handled explicitly.

## The Reliable Order of Operations

### 1. Verify tools first

Run:

```sh
./scripts/verify-env.sh
./scripts/check-device-metadata.sh
```

If either fails, fix that first. Do not start simulator work before metadata and SDK paths are confirmed.

### 2. Build before opening the simulator

For all targets:

```sh
./scripts/build-all-devices.sh /path/to/your/signing-key.der
```

For a single target, use the SDK directly or the existing per-device script/task if available.

For this repo, prefer a 4096-bit local signing key for simulator work on newer devices. `scripts/build-device.sh` now prefers `private/anticipate-dev-key-4096.der` when it exists.

Treat compiler warnings as real failures for simulator prep. In this repo, launcher icon size mismatches are the warning most likely to block a clean pass.

### 3. Reset app state when you want empty state

Use:

```sh
./scripts/reset-sim-state.sh
```

This is the reliable way to get a clean empty-state launch.

This script now clears both persisted state and previously sideloaded `ANTICIPATE*.PRG` files from `GARMIN/APPS/MEDIA`. That matters because stale sideloaded app basenames can make the simulator keep looking for the wrong settings schema file.

Do not assume you can trivially restore a previously configured widget state by copying a small set of files back into the simulator cache. That was not reliable in practice.

### 4. Open the simulator explicitly

Use the known SDK app path:

```sh
open "/Users/mwieland/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/ConnectIQ.app"
```

If you want a specific family window immediately, this also worked:

```sh
open -a "/Users/mwieland/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/ConnectIQ.app" --args fenix7
```

Then wait a moment before running `monkeydo`.

### 5. Launch the app with `monkeydo`

Use the direct SDK binary:

```sh
"/Users/mwieland/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/monkeydo" \
  bin/device-builds/<device_id>/anticipate.prg \
  <device_id>
```

If this fails with `Unable to connect to simulator.`:

1. confirm the simulator window is actually open
2. wait 1-2 seconds and retry
3. if running under automation, use the non-sandboxed / approved route that already works for this repo

Do not waste time debugging the widget itself until `monkeydo` can reliably connect.

If the simulator window shows a blue error triangle, inspect `GARMIN/APPS/LOGS/CIQ_LOG.YML`. In this repo, the most important recent clue was `Signature check failed on file: ANTICIPATE-<DEVICE>`, which was fixed by rebuilding with the 4096-bit local key.

## Screenshot Workflow That Actually Works

Use the existing screenshot skill helper on macOS.

### 1. Ensure permissions

```sh
bash /Users/mwieland/.codex/skills/screenshot/scripts/ensure_macos_permissions.sh
```

If permissions are not granted, fix that first in macOS settings.

### 2. List simulator windows when needed

```sh
python3 /Users/mwieland/.codex/skills/screenshot/scripts/take_screenshot.py --list-windows --app "Connect IQ Device Simulator"
```

This is useful when the simulator title changes or when multiple windows exist.

### 3. Capture by app name or window id

Example:

```sh
python3 /Users/mwieland/.codex/skills/screenshot/scripts/take_screenshot.py \
  --app "Connect IQ Device Simulator" \
  --output /tmp/anticipate-shot.png
```

For bulk empty-state captures, this pattern worked well:

1. start `monkeydo` for one device
2. sleep about 2 seconds
3. capture screenshot
4. stop that `monkeydo` process
5. move to the next device

## What To Trust and What Not To Trust

### Trust

- `./scripts/verify-env.sh`
- `./scripts/check-device-metadata.sh`
- `./scripts/build-all-devices.sh`
- `./scripts/reset-sim-state.sh`
- direct SDK `monkeydo`
- screenshot capture after the simulator is visibly open

### Do Not Trust Without Extra Verification

- guessed simulator state restore by copying app storage files back
- keypress automation for paging across different device families
- click-coordinate automation for hardware buttons
- extra-file injection into `monkeydo` as a substitute for real settings control
- a screenshot captured immediately after launch with no delay

## Empty-State Validation Recipe

This is the easiest fully repeatable check and should be the default first pass for every new device.

1. Run `./scripts/reset-sim-state.sh`
2. Launch simulator
3. Run `monkeydo` for target device
4. Wait about 2 seconds
5. Capture screenshot
6. Verify:
   - no crash
   - centered title and body
   - no clipping on round edges
   - expected black background and foreground contrast

## Configured-State Validation Recipe

This is the part that needs more care.

### Best manual path

Use the simulator UI:

1. `File > Edit Persistent Storage`
2. edit `Application.Properties` for the widget
3. set one all-day countdown
4. set one timed countdown
5. save
6. relaunch or return to the widget

Use this to verify:

- all-day countdown layout
- timed countdown layout
- long-title truncation
- page indicator placement
- no runtime crash while paging

### Proven seeded-device workflow

For this repo, the most reliable way to reproduce configured countdown screenshots across multiple devices was:

1. build a simulator PRG whose defaults already contain the seeded countdown data
2. keep the installed simulator app basename stable as `ANTICIPATE.PRG`
3. do not run `./scripts/reset-sim-state.sh` between device switches
4. rebuild the same `ANTICIPATE.PRG` for the next device target and launch it again

That preserved the seeded `Application.Properties` data across device switches in the simulator and allowed configured-state screenshots on multiple models from one seeded setup pass.

### Settings editor prerequisites

The App Settings Editor only became reliable again when all three of these were true:

1. the stale sideloaded PRG had been removed from `GARMIN/APPS/MEDIA`
2. the running build used a simulator-accepted signature
3. the matching settings schema file existed at `GARMIN/Settings/<APP_BASENAME>-settings.json`

For this repo's per-device builds, the basename is derived from the PRG filename. Example:

- PRG: `bin/device-builds/anticipate-venu3.prg`
- simulator app files: `ANTICIPATE-VENU3.PRG`, `ANTICIPATE-VENU3.SET`
- required schema sidecar for the editor: `GARMIN/Settings/ANTICIPATE-VENU3-settings.json`

If the editor is blank or shows `No settings file found for this app`, verify that basename match first.

### Important warning

Do not assume reset-plus-restore automation will preserve configured test scenarios. In prior runs, copying candidate state files back into the simulator cache did not reliably restore the countdown configuration.

Also, direct accessibility `set value` automation against the editor controls was not sufficient to prove that settings had been persisted back into the running widget. Treat manual entry in the editor as the trusted path unless a repo-owned fixture workflow is added and re-verified.

If you need repeatable configured-state validation, prefer either:

- a documented manual persistent-storage edit flow
- or a repo-owned simulator fixture workflow that is proven to restore correctly

Until such a fixture workflow exists, be explicit in reports about what was manually verified versus what was only compile-checked or empty-state checked.

## Launcher Icon Rules

When adding devices, always inspect launcher icon requirements from device metadata before simulator work.

In this repo, some devices need device-specific icon sizes even when the display bucket matches a broader family. Examples from prior validation:

- `vivoactive4`: `35x35`
- `vivoactive4s`: `30x30`
- `epix2pro42mm`: `60x60`
- `marq2`: `60x60`
- `marq2aviator`: `60x60`
- `venu3`: `70x70`
- `venu441mm`: `54x54`
- `venu445mm`: `65x65`
- `venu3s`: `70x70`
- `vivoactive5`: `56x56`
- `vivoactive6`: `54x54`

If compiler warnings mention launcher icon size, fix resource overrides before spending more time in the simulator.

The Garmin SDK product IDs for Venu 4 are `venu441mm` and `venu445mm`. If a request uses `venu4-41mm` or `venu4-45mm`, translate those to the actual SDK IDs before editing the manifest or build tooling.

## Good Reporting Hygiene

When writing up simulator results, separate these clearly:

- compile-clean verification
- metadata verification
- empty-state simulator verification
- configured-state simulator verification
- launcher icon compile compliance
- launcher icon visual verification in launcher context

Do not say "fully verified" unless all of those were actually covered.

## Suggested Next Improvement

The next thing worth building is a reproducible configured-state fixture flow for the simulator. That would remove the biggest source of repeated friction in this repo.
