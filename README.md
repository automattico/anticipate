# Anticipate Countdown

Connect IQ widget workspace for a Garmin Forerunner 55 countdown widget.

The current product is a single-event MVP focused on being stable and easy to configure:

- one countdown only
- configured through Garmin app settings
- no on-watch editing
- no glance support yet
- FR55-first round-screen layout

## Current setup

- Target device: `fr55`
- Device profile: `round-208x208`, `8 colors`, non-touch, button navigation
- App type: `widget`
- SDK path: active SDK from `~/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg`
- VS Code extension: `garmin.monkey-c`
- Java 17 JDK installed via Homebrew: `/opt/homebrew/opt/openjdk@17`

## First run checklist

1. Open this folder in VS Code.
2. Run `Monkey C: Verify Installation`.
3. Run the `Run on Forerunner 55` debug configuration.
4. If the simulator behaves strangely after switching SDKs, clear the temp simulator cache:

```sh
rm -rf "$TMPDIR/com.garmin.connectiq"
```

## Settings contract

The MVP reads two flat app properties:

- `event1_name`
- `event1_target_date`

Example payload:

```json
{
  "event1_name": "Brasil",
  "event1_target_date": 1780531200
}
```

`event1_target_date` comes from Garmin's `date` setting and is stored as a numeric value. If the name or date is missing or invalid, the widget falls back to the empty-state screen instead of failing.

## UI notes

- Main widget: event name, large countdown value, and target date.
- Empty state: prompts the user to open app settings and add one date.
- Formatting: `TODAY` for the first 24 hours after the target, `DONE` after that, and no seconds.
- Buttons: `BACK` exits; other buttons currently do nothing in the MVP.

## Shell Java setup

VS Code can use the configured JDK path directly. If you also want `java` available in every terminal session, add this to your shell profile:

```sh
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
```

## Local checks

Run:

```sh
./scripts/verify-env.sh
```

That script checks for the active SDK, the FR55 device pack, and Java availability.
