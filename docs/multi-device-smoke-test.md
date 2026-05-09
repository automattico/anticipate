# Multi-Device Smoke Test

Use this as the pre-submit verification flow for supported simulator targets.

## Supported Targets

- `descentmk2` - Descent Mk2 / Mk2i, round `280x280`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `descentmk2s` - Descent Mk2 S, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `epix2pro42mm` - epix Pro (Gen 2) 42mm, round `390x390`, AMOLED, API 5.2, glance memory `65536`, launcher icon `60x60`
- `fenix6` - fēnix 6 / 6 Solar / 6 Dual Power, round `260x260`, MIP, API 3.4, widget memory `65536`, launcher icon `40x40`
- `fenix6pro` - fēnix 6 Pro / 6 Sapphire / quatix 6, round `260x260`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `fenix6s` - fēnix 6S / 6S Solar / 6S Dual Power, round `240x240`, MIP, API 3.4, widget memory `65536`, launcher icon `40x40`
- `fenix6spro` - fēnix 6S Pro / 6S Sapphire, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `fenix6xpro` - fēnix 6X Pro / 6X Sapphire / tactix Delta Sapphire / quatix 6X, round `280x280`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `fr55` - Forerunner 55, round `208x208`, MIP 8 colors, API 3.4
- `fr165` - Forerunner 165, round `390x390`, AMOLED, API 5.2, launcher icon `54x54`, swipe paging plus button paging
- `fr165m` - Forerunner 165 Music, round `390x390`, AMOLED, API 5.2, launcher icon `54x54`, swipe paging plus button paging
- `fr245` - Forerunner 245, round `240x240`, MIP 64 colors, API 3.3
- `fr245m` - Forerunner 245 Music, round `240x240`, MIP 64 colors, API 3.3
- `fr255` - Forerunner 255, round `260x260`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fr255m` - Forerunner 255 Music, round `260x260`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fr255s` - Forerunner 255S, round `218x218`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fr255sm` - Forerunner 255S Music, round `218x218`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fr645` - Forerunner 645, round `240x240`, MIP, API 3.1, widget memory `65536`, launcher icon `40x40`
- `fr645m` - Forerunner 645 Music, round `240x240`, MIP, API 3.2, widget memory `524288`, launcher icon `40x40`
- `fr935` - Forerunner 935, round `240x240`, MIP, API 3.1, widget memory `65536`, launcher icon `40x40`
- `fr955` - Forerunner® 955 / Solar, round `260x260`, MIP 64 colors, API 5.2, launcher icon `40x40`
- `fr745` - Forerunner 745, round `240x240`, MIP 8-bit color, API 3.3, widget memory `1048576`, launcher icon `40x40`
- `fr945` - Forerunner 945, round `240x240`, MIP 8-bit color, API 3.3, widget memory `1048576`, launcher icon `40x40`
- `fr945lte` - Forerunner 945 LTE, round `240x240`, MIP 8-bit color, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `fenix7` - fēnix 7 / quatix 7, round `260x260`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7pro` - fēnix 7 Pro, round `260x260`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7pronowifi` - fēnix 7 Pro - Solar Edition (no Wi-Fi), round `260x260`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7x` - fēnix 7X / tactix 7 / quatix 7X Solar / Enduro 2, round `280x280`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7xpro` - fēnix 7X Pro, round `280x280`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7xpronowifi` - fēnix 7X Pro - Solar Edition (no Wi-Fi), round `280x280`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7s` - fēnix 7S, round `240x240`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `fenix7spro` - fēnix 7S Pro, round `240x240`, MIP 8-bit color, API 5.2, glance memory `65536`, launcher icon `40x40`
- `marq2` - MARQ (Gen 2) Athlete / Adventurer / Captain / Golfer / Carbon Edition / Commander - Carbon Edition, round `390x390`, AMOLED, API 5.2, glance memory `65536`, launcher icon `60x60`
- `marq2aviator` - MARQ (Gen 2) Aviator, round `390x390`, AMOLED, API 5.2, glance memory `65536`, launcher icon `60x60`
- `marqadventurer` - MARQ Adventurer, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `marqathlete` - MARQ Athlete, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `marqaviator` - MARQ Aviator, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `marqcaptain` - MARQ Captain / American Magic Edition, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `marqcommander` - MARQ Commander, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `marqdriver` - MARQ Driver, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `marqexpedition` - MARQ Expedition, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `marqgolfer` - MARQ Golfer, round `240x240`, MIP, API 3.4, widget memory `1048576`, launcher icon `40x40`
- `venu3` - Venu 3, round `454x454`, AMOLED, API 5.2, glance memory `65536`, launcher icon `70x70`
- `venu441mm` - Venu 4 41mm, round `390x390`, AMOLED, API 6.0, glance memory `65536`, launcher icon `54x54`
- `venu445mm` - Venu 4 45mm / D2 Air X15, round `454x454`, AMOLED, API 6.0, glance memory `65536`, launcher icon `65x65`
- `venu3s` - Venu 3S, round `390x390`, AMOLED, API 5.2, glance memory `65536`, launcher icon `70x70`
- `vivoactive4` - vívoactive 4, round `260x260`, MIP, API 3.3, widget memory `524288`, launcher icon `35x35`
- `vivoactive4s` - vívoactive 4S, round `218x218`, MIP, API 3.3, widget memory `524288`, launcher icon `30x30`
- `vivoactive5` - vívoactive 5, round `390x390`, AMOLED, API 5.2, glance memory `65536`, launcher icon `56x56`
- `vivoactive6` - vívoactive 6, round `390x390`, AMOLED, API 6.0, glance memory `65536`, launcher icon `54x54`

Do not add `fr45` for this widget. The Garmin SDK device profile exposes Forerunner 45 as API 1.4 with only `watchFace` app support, and the compiler rejects this widget target with `Device 'fr45' does not support application type 'widget'`.

Garmin's newer metadata exposes several supported devices as glance-era profiles rather than listing explicit `widget` memory. This project keeps the widget app type and only claims devices that compile and pass simulator validation. That includes `fr165`, `fr165m`, `venu3`, `venu441mm`, `venu445mm`, and `vivoactive6` on the current SDK.

The `390x390`, `416x416`, and `454x454` AMOLED additions share the current large-screen layout family, but they require matching launcher-icon resource buckets so the compiler does not fall back to scaled `35x35` icons. `venu3` specifically needs its own `70x70` launcher icon override.

Requested Venu 4 names map to Garmin SDK product IDs `venu441mm` and `venu445mm`. Do not use `venu4-41mm` or `venu4-45mm` in the manifest or build tooling.

Garmin quatix 7 does not have a separate SDK product ID in the installed metadata. The shared `fenix7` profile is labeled `fēnix® 7 / quatix® 7`, so quatix 7 validation uses the `fenix7` target and simulator profile.

Garmin Enduro 2 and tactix 7 do not have separate SDK product IDs in the installed metadata. The shared `fenix7x` profile is labeled `fēnix® 7X / tactix® 7 / quatix® 7X Solar / Enduro™ 2`, so Enduro 2 and tactix 7 validation use the `fenix7x` target and simulator profile. Do not add `enduro` for Enduro 2; the `enduro` profile is the older Enduro device.

## Preferred Launch Paths

The preferred runtime paths are the VS Code launch configurations in [.vscode/launch.json](../.vscode/launch.json):

- `Run App: Choose Device Each Run`
- `Run App: fēnix 7`
- `Run App: fēnix 7 Pro (no Wi-Fi)`
- `Run App: fēnix 7 Pro`
- `Run App: fēnix 7X / tactix 7 / Enduro 2`
- `Run App: fēnix 7X Pro`
- `Run App: fēnix 7X Pro (no Wi-Fi)`
- `Run App: quatix 7 (uses fenix7 profile)`
- `Run App: Forerunner 165`
- `Run App: Forerunner 165 Music`
- `Run App: Forerunner 645`
- `Run App: Forerunner 645 Music`
- `Run App: Forerunner 935`
- `Run App: Descent Mk2 / Mk2i`
- `Run App: Descent Mk2 S`
- `Run App: epix Pro (Gen 2) 42mm`
- `Run App: fēnix 6 / 6 Solar`
- `Run App: fēnix 6 Pro`
- `Run App: fēnix 6S`
- `Run App: fēnix 6S Pro`
- `Run App: fēnix 6X Pro`
- `Run App: MARQ (Gen 2)`
- `Run App: MARQ (Gen 2) Aviator`
- `Run App: MARQ Adventurer`
- `Run App: MARQ Athlete`
- `Run App: MARQ Aviator`
- `Run App: MARQ Captain`
- `Run App: MARQ Commander`
- `Run App: MARQ Driver`
- `Run App: MARQ Expedition`
- `Run App: MARQ Golfer`
- `Run App: Venu 3`
- `Run App: Venu 4 41mm`
- `Run App: Venu 4 45mm`
- `Run App: Venu 3S`
- `Run App: vívoactive 4`
- `Run App: vívoactive 4S`
- `Run App: vívoactive 5`
- `Run App: vívoactive 6`
- `Run Native Pairing: Choose Device Each Run`

Use these as the supported local paths for smoke testing. The picker-based launcher remains useful when switching often, and the device-specific launch configs give a stable path for repeated validation on the same target. Direct `monkeydo` runs are useful for automation and troubleshooting, but VS Code remains the documented contributor workflow.

The Garmin `Build for Device` command and the VS Code run/debug configuration are separate selections. If the simulator opens the wrong watch, change the Run and Debug dropdown to the matching `fr...: Run on ...` configuration; F5 uses that dropdown, not the last device selected for a build task.

The VS Code tasks and `scripts/build-device.sh` prefer `private/anticipate-dev-key-4096.der` when it exists, then fall back to `private/anticipate-dev-key.der`. To use another local key, set `PRIVATE_KEY=/path/to/your/signing-key.der` in the VS Code environment before launching.

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

### 6. FR165 Touch Parity

- On `fr165` and `fr165m`, verify swipe up/down changes pages the same way button paging does.
- Verify tap does not open a new workflow or otherwise change behavior beyond the current widget interaction model.
- Verify button paging still works exactly as before.

## Visual Checks

For each target, inspect:

- title truncation with an 18-character title
- empty-state centering
- all-day and timed countdown spacing
- page-indicator position on round screens
- readability of white and blue text on black
- no clipping near the `390x390` AMOLED round edge

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
