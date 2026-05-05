# Multi-Device Smoke Test

Use this as the pre-submit verification flow for supported simulator targets.

## Supported Targets

- `fr55` - Forerunner 55, round `208x208`, MIP 8 colors, API 3.4
- `fr245` - Forerunner 245, round `240x240`, MIP 64 colors, API 3.3
- `fr245m` - Forerunner 245 Music, round `240x240`, MIP 64 colors, API 3.3
- `fr255` - Forerunner 255, round `260x260`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fr255m` - Forerunner 255 Music, round `260x260`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fr255s` - Forerunner 255S, round `218x218`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fr255sm` - Forerunner 255S Music, round `218x218`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fr955` - Forerunner® 955 / Solar, round `260x260`, MIP 64 colors, API 5.2, launcher icon `40x40`
- `fr745` - Forerunner 745, round `240x240`, MIP 8-bit color, API 3.3, widget memory `1048576`, launcher icon `40x40`
- `fr945` - Forerunner 945, round `240x240`, MIP 8-bit color, API 3.3, widget memory `1048576`, launcher icon `40x40`
- `fr945lte` - Forerunner 945 LTE, round `240x240`, MIP 8-bit color, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `fenix7` - fēnix 7 / quatix 7, round `260x260`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7pro` - fēnix 7 Pro, round `260x260`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7s` - fēnix 7S, round `240x240`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7spro` - fēnix 7S Pro, round `240x240`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`

Do not add `fr45` for this widget. The Garmin SDK device profile exposes Forerunner 45 as API 1.4 with only `watchFace` app support, and the compiler rejects this widget target with `Device 'fr45' does not support application type 'widget'`.

Garmin's API 5.2 metadata exposes the newer supported devices as glance-era profiles rather than listing explicit `widget` memory. This project keeps the widget app type and only claims devices that compile and pass simulator validation.

Garmin quatix 7 does not have a separate SDK product ID in the installed metadata. The shared `fenix7` profile is labeled `fēnix® 7 / quatix® 7`, so quatix 7 validation uses the `fenix7` target and simulator profile.

## Preferred Launch Paths

The preferred runtime paths are the VS Code launch configurations in [.vscode/launch.json](../.vscode/launch.json):

- `Run App: Choose Device Each Run`
- `Run App: fēnix 7`
- `Run App: fēnix 7 Pro`
- `Run App: quatix 7 (uses fenix7 profile)`
- `Run Native Pairing: Choose Device Each Run`

Use these as the supported local paths for smoke testing. The picker-based launcher remains useful when switching often, and the device-specific launch configs give a stable path for repeated validation on the same target. Direct `monkeydo` runs are useful for automation and troubleshooting, but VS Code remains the documented contributor workflow.

The Garmin `Build for Device` command and the VS Code run/debug configuration are separate selections. If the simulator opens the wrong watch, change the Run and Debug dropdown to the matching `fr...: Run on ...` configuration; F5 uses that dropdown, not the last device selected for a build task.

The VS Code tasks default to `private/anticipate-dev-key.der`. To use another local key, set `PRIVATE_KEY=/path/to/your/signing-key.der` in the VS Code environment before launching.

## Clean Start

1. Verify the local toolchain:

```sh
./scripts/verify-env.sh
```

2. Verify device metadata for every manifest target:

```sh
./scripts/check-device-metadata.sh
```

3. Regression-build every manifest target with your own local signing key:

```sh
./scripts/build-all-devices.sh /path/to/your/signing-key.der
```

This writes per-device simulator artifacts under ignored `bin/device-builds/` and fails on compiler errors or warnings.

4. Build a single simulator artifact for manual launch, replacing `<device_id>` with any supported target listed above:

```sh
SDK=$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg") && \
JAVA_BIN="${JAVA_HOME:-/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home}/bin/java" && \
"$JAVA_BIN" \
  -Xms1g \
  -Dfile.encoding=UTF-8 \
  -Dapple.awt.UIElement=true \
  -jar "$SDK/bin/monkeybrains.jar" \
  -o "$(pwd)/bin/anticipate.prg" \
  -f "$(pwd)/monkey.jungle" \
  -y "/path/to/your/signing-key.der" \
  -d <device_id> \
  -r -w -l 2 -w
```

Keep signing keys and certificates outside tracked files. The ignored `private/` directory is one acceptable local-only location.

5. Reset simulator app state:

```sh
./scripts/reset-sim-state.sh
```

6. Open this workspace in VS Code and launch the matching configuration.

If the simulator behaves strangely after SDK changes or repeated runs, quit the simulator, rerun the reset script above, and start again.

## Manual Test Scenarios

Run these scenarios on each supported target.

### Settings UI

- Open the app settings editor.
- Verify each block starts with a clear title label, such as `COUNTDOWN 1: Title`.
- Verify labels inside each block are friendly: `Year`, `Month`, `Day`, `Add a time`, `Hour, if time is on`, and `Minute, if time is on`.
- Verify hour and minute remain editable, and their prompts say they are ignored when `Add a time` is off.

### 1. Empty State

- Start from a clean reset.
- Launch the widget.
- Verify the app opens without crashing.
- Verify the empty state shows the current multi-line `ANTICIPATE` / `COUNTDOWNS` message cleanly.

### 2. All-Day Countdown

- In the simulator, open `File > Edit Persistent Storage > Edit Application.Properties data`.
- Set:
  - `event1_name = Summer Trip`
  - `event1_target_year = <future year>`
  - `event1_target_month = <month number>`
  - `event1_target_day = <day number>`
  - `event1_use_specific_time = false`
- Leave hour and minute at `0`.
- Save and return to the widget.
- Verify:
  - the countdown appears
  - the target date renders as `DD Mon YYYY`
  - no separate time line is shown
  - hour and minute values are ignored while `event1_use_specific_time = false`

### 3. Timed Countdown Including Midnight

- In the same properties editor, set:
  - `event2_name = Midnight`
  - `event2_target_year = <future year>`
  - `event2_target_month = <month number>`
  - `event2_target_day = <day number>`
  - `event2_use_specific_time = true`
  - `event2_target_hour = 0`
  - `event2_target_minute = 0`
- Save and return to the widget.
- Move to the second countdown page.
- Verify the target date line renders as `DD Mon 00:00`.

### 4. Rename-Only Stability

- Reopen the properties editor.
- Change only `event2_name`.
- Do not change date, specific-time, hour, or minute.
- Save and return to the widget.
- Verify:
  - the title changes
  - the visible target date/time stays the same
  - the countdown does not jump unexpectedly beyond normal elapsed time

### 5. Real Countdown-Input Change

- Reopen the properties editor.
- Change one of:
  - `event2_target_year`
  - `event2_target_month`
  - `event2_target_day`
  - `event2_use_specific_time`
  - `event2_target_hour`
  - `event2_target_minute`
- Save and return to the widget.
- Verify:
  - the countdown updates to the new target
  - switching `specific_time` changes whether the separate time line is shown

## Visual Checks

For each target, inspect:

- title truncation with an 18-character title
- empty-state centering
- all-day and timed countdown spacing
- page-indicator position on round screens
- readability of white and blue text on black

## Optional Raw-State Check

- Application.Storage `eventN_target_epoch` should stay unchanged on a rename-only edit.
- Application.Storage `eventN_target_epoch` should change when year, month, day, specific-time, hour, or minute changes.

The app also stores an internal target signature in Application.Storage so it can detect real countdown-input changes without repinning epochs on every launch.

## Legacy Migration Check

- Start from a clean reset.
- In Application.Properties data, set only legacy fields:
  - `event1_name = Legacy`
  - `event1_target_date = <future date epoch from the date editor>`
  - `event1_all_day = true`
- Launch the widget.
- Reopen Application.Properties data.
- Verify:
  - `event1_target_year`, `event1_target_month`, and `event1_target_day` were populated
  - the countdown appears and renders the migrated date
