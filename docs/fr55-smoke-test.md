# FR55 Smoke Test

Use this as the canonical pre-submit verification flow for the current FR55 release.

## Preferred Launch Path

The preferred runtime path is the VS Code launch configuration in [launch.json](/Users/mwieland/dev/anticipate/.vscode/launch.json):

- `Run on Forerunner 55`

This is the supported local path for smoke testing. Do not rely on ad-hoc `monkeydo` runs as the primary verification workflow.

## Clean Start

1. Verify the local toolchain:

```sh
./scripts/verify-env.sh
```

2. Build the FR55 simulator artifact:

```sh
SDK=$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg") && \
"/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home/bin/java" \
  -Xms1g \
  -Dfile.encoding=UTF-8 \
  -Dapple.awt.UIElement=true \
  -jar "$SDK/bin/monkeybrains.jar" \
  -o "$(pwd)/bin/anticipate.prg" \
  -f "$(pwd)/monkey.jungle" \
  -y "$(pwd)/private/anticipate-dev-key-4096.der" \
  -d fr55_sim \
  -w -l 2 -w
```

3. Reset the simulator app state for a truly clean launch:

```sh
./scripts/reset-fr55-sim-state.sh
```

4. Open this workspace in VS Code and run:

- `Run on Forerunner 55`

5. Wait for the widget to launch in the FR55 simulator.

If the simulator behaves strangely after SDK changes or repeated runs, quit the simulator, rerun the reset script above, and start again from step 4.

## Manual Test Scenarios

### 1. Empty State

- Start from a clean reset
- Launch the widget
- Verify the app opens without crashing
- Verify the empty state shows the current multi-line `ANTICIPATE` / `COUNTDOWNS` message cleanly

### 2. All-Day Countdown

- In the simulator, open `File > Edit Persistent Storage > Edit Application.Properties data`
- Set:
  - `event1_name = Birthday`
  - `event1_target_date = <pick a future date>`
  - `event1_all_day = true`
- Leave hour and minute at `0`
- Save and return to the widget
- Verify:
  - the countdown appears
  - the target date renders as `DD Mon YYYY`
  - no inline time is shown on the date row

### 3. Timed Countdown Including Midnight

- In the same properties editor, set:
  - `event2_name = Midnight`
  - `event2_target_date = <pick a future date>`
  - `event2_all_day = false`
  - `event2_target_hour = 0`
  - `event2_target_minute = 0`
- Save and return to the widget
- Move to the second countdown page
- Verify:
  - the target date line renders as `DD Mon 00:00`

### 4. Rename-Only Stability

- Reopen the properties editor
- Change only `event2_name`
- Do not change date, all-day, hour, or minute
- Save and return to the widget
- Verify:
  - the title changes
  - the visible target date/time stays the same
  - the countdown does not jump unexpectedly beyond normal elapsed time

### 5. Real Countdown-Input Change

- Reopen the properties editor
- Change one of:
  - `event2_target_date`
  - `event2_all_day`
  - `event2_target_hour`
  - `event2_target_minute`
- Save and return to the widget
- Verify:
  - the countdown updates to the new target
  - switching `all_day` changes whether an inline time appears on the date row

## Optional Raw-State Check

If you want to inspect persistence behavior more closely in the properties editor:

- `target_epoch` should stay unchanged on a rename-only edit
- `target_epoch` should change when date, all-day, hour, or minute changes

The app also stores an internal target signature in object storage so it can detect real countdown-input changes without repinning epochs on every launch.
