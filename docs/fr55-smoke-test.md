# FR55 Smoke Test

Use this as the FR55-specific verification flow. For the full supported-device flow, use [multi-device-smoke-test.md](multi-device-smoke-test.md).

## Preferred Launch Path

The preferred runtime path is the VS Code launch configuration in [.vscode/launch.json](../.vscode/launch.json):

- `Run on Forerunner 55`

This is the supported local path for smoke testing. Do not rely on ad-hoc `monkeydo` runs as the primary verification workflow.

## Clean Start

1. Verify the local toolchain:

```sh
./scripts/verify-env.sh
```

2. Build the FR55 simulator artifact with your own local signing key:

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
  -d fr55_sim \
  -r -w -l 2 -w
```

Keep signing keys and certificates outside tracked files. The ignored `private/` directory is one acceptable local-only location.

3. Reset the simulator app state for a truly clean launch:

```sh
./scripts/reset-sim-state.sh
```

The device-neutral reset path is also available:

```sh
./scripts/reset-sim-state.sh
```

4. Open this workspace in VS Code and run:

- `Run on Forerunner 55`

5. Wait for the widget to launch in the FR55 simulator.

If the simulator behaves strangely after SDK changes or repeated runs, quit the simulator, rerun the reset script above, and start again from step 4.

## Manual Test Scenarios

### Settings UI

- Open the app settings editor
- Verify each block starts with a clear title label, such as `COUNTDOWN 1: Title`
- Verify labels inside each block are friendly: `Year`, `Month`, `Day`, `Add a time`, `Hour, if time is on`, and `Minute, if time is on`
- Verify hour and minute remain editable, and their prompts say they are ignored when `Add a time` is off

### 1. Empty State

- Start from a clean reset
- Launch the widget
- Verify the app opens without crashing
- Verify the empty state shows the current multi-line `ANTICIPATE` / `COUNTDOWNS` message cleanly

### 2. All-Day Countdown

- In the simulator, open `File > Edit Persistent Storage > Edit Application.Properties data`
- Set:
  - `event1_name = Summer Trip`
  - `event1_target_year = <future year>`
  - `event1_target_month = <month number>`
  - `event1_target_day = <day number>`
  - `event1_use_specific_time = false`
- Leave hour and minute at `0`
- Save and return to the widget
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
- Save and return to the widget
- Move to the second countdown page
- Verify:
  - the target date line renders as `DD Mon 00:00`

### 4. Rename-Only Stability

- Reopen the properties editor
- Change only `event2_name`
- Do not change date, specific-time, hour, or minute
- Save and return to the widget
- Verify:
  - the title changes
  - the visible target date/time stays the same
  - the countdown does not jump unexpectedly beyond normal elapsed time

### 5. Real Countdown-Input Change

- Reopen the properties editor
- Change one of:
  - `event2_target_year`
  - `event2_target_month`
  - `event2_target_day`
  - `event2_use_specific_time`
  - `event2_target_hour`
  - `event2_target_minute`
- Save and return to the widget
- Verify:
  - the countdown updates to the new target
  - switching `specific_time` changes whether the separate time line is shown

## Optional Raw-State Check

If you want to inspect persistence behavior more closely:

- Application.Storage `eventN_target_epoch` should stay unchanged on a rename-only edit
- Application.Storage `eventN_target_epoch` should change when year, month, day, specific-time, hour, or minute changes

The app also stores an internal target signature in Application.Storage so it can detect real countdown-input changes without repinning epochs on every launch.

## Legacy Migration Check

- Start from a clean reset
- In Application.Properties data, set only legacy fields:
  - `event1_name = Legacy`
  - `event1_target_date = <future date epoch from the date editor>`
  - `event1_all_day = true`
- Launch the widget
- Reopen Application.Properties data
- Verify:
  - `event1_target_year`, `event1_target_month`, and `event1_target_day` were populated
  - the countdown appears and renders the migrated date
