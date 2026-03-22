# Anticipate Countdowns

Connect IQ widget workspace for a Garmin countdown widget with up to five timers.

## Current Product

- Up to 5 countdowns, configured in Connect IQ app settings
- Optional hour and minute per countdown when `All day` is off
- All-day countdowns supported with an explicit `All day` toggle
- Timer targets are frozen to the user's local timezone when saved
- Horizontal paging between configured countdowns
- FR55 is the only validated target today

## Current Setup

- Target device in `manifest.xml`: `fr55`
- Device profile: `round-208x208`, 8 colors, non-touch, button navigation
- App type: `widget`
- SDK path: active SDK from `~/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg`
- VS Code extension: `garmin.monkey-c`
- Java 17 JDK installed via Homebrew: `/opt/homebrew/opt/openjdk@17`

## First Run Checklist

1. Open this folder in VS Code.
2. Run `Monkey C: Verify Installation`.
3. Run the `Run on Forerunner 55` debug configuration.
4. If the simulator behaves strangely after switching SDKs, clear the temp simulator cache:

```sh
rm -rf "$TMPDIR/com.garmin.connectiq"
```

## Settings Contract

Each countdown slot stores:

- `eventN_name`
- `eventN_target_date`
- `eventN_all_day`
- `eventN_target_hour`
- `eventN_target_minute`
- `eventN_target_epoch`

The app also stores an internal `eventN_target_signature` per slot in app storage so it can detect real countdown-input changes without repinning saved epochs on every startup or rename.

`eventN_target_epoch` is resolved when the timer is saved so the countdown stays pinned to the user's local timezone at setup time. `eventN_all_day` controls whether the saved timer is treated as an all-day countdown or a specific time such as `00:00`. The raw date and time fields are still kept for settings and display.

Example payload:

```json
{
  "event1_name": "Summer Trip",
  "event1_target_date": 1798761600,
  "event1_all_day": true,
  "event1_target_hour": 0,
  "event1_target_minute": 0,
  "event1_target_epoch": 1798761600
}
```

## UI Notes

- Main widget: event name, primary countdown value, and target date
- Longer titles fall back from `FONT_SMALL` to `FONT_TINY` before clipping
- Empty state prompts the user to open Connect IQ settings and add countdowns
- Sub-day timers show hours, minutes, and seconds
- Buttons: `BACK` exits; horizontal navigation moves between countdowns on supported devices

## Publishing Notes

- The app name and in-app copy now describe multiple countdowns
- `manifest.xml` is still intentionally limited to `fr55` until more devices are validated
- Store descriptions, screenshots, hero images, categories, and supported products in the Garmin submission UI still need manual review
- See [docs/publishing.md](/Users/mwieland/dev/anticipate/docs/publishing.md) for a submission checklist and suggested store copy
- Use [docs/fr55-smoke-test.md](/Users/mwieland/dev/anticipate/docs/fr55-smoke-test.md) for the canonical FR55 pre-submit verification flow

## Local Checks

Run:

```sh
./scripts/verify-env.sh
```

Build a release artifact:

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

Reset simulator state for a clean smoke test:

```sh
./scripts/reset-fr55-sim-state.sh
```
