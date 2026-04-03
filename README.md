# Anticipate Countdowns

Anticipate Countdowns is an open-source Garmin Connect IQ widget for tracking up to five upcoming events with optional event times.

The current validated target is `fr55`. Contributions that adapt and validate the widget for more Garmin watches are especially appreciated.

This project was built with help from OpenAI Codex.

## Features

- Up to 5 countdowns configured in Connect IQ app settings
- Optional specific hour and minute for timed events
- All-day countdowns with date-only display
- Countdown targets pinned to the user's local timezone when saved
- Horizontal paging between configured countdowns

## Current Device Support

- Validated target today: `fr55`
- Current profile: round `208x208`, 8 colors, button navigation
- Additional device support is welcome, but only validated devices should be added to `manifest.xml` or claimed in store metadata

## Prerequisites

- Garmin Connect IQ SDK installed locally
- Java 17 or another compatible JDK available locally
- VS Code with the `garmin.monkey-c` extension is the documented local workflow

The helper scripts in this repo look for the active SDK path in `~/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg`.

## Local Setup

1. Open this folder in VS Code.
2. Run `Monkey C: Verify Installation`.
3. Run the environment check:

```sh
./scripts/verify-env.sh
```

4. Use the `Run on Forerunner 55` launch configuration for the default simulator workflow.

If the simulator behaves strangely after switching SDKs, clear its temporary state:

```sh
rm -rf "$TMPDIR/com.garmin.connectiq"
```

## FR55 Smoke Test

Use [docs/fr55-smoke-test.md](/Users/mwieland/dev/anticipate/docs/fr55-smoke-test.md) for the canonical FR55 verification flow.

At a high level:

1. Verify the toolchain with `./scripts/verify-env.sh`.
2. Build a simulator artifact using your own local signing key.
3. Reset simulator state with `./scripts/reset-fr55-sim-state.sh`.
4. Launch `Run on Forerunner 55` in VS Code.

## Release Build Notes

Release and simulator artifacts must be signed with your own local Connect IQ key material. Do not commit keys, certificates, or other secrets to this repository.

Example local simulator build flow:

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
  -w -l 2 -w
```

Treat that command as an example local flow, not a promise that every machine uses the same Java path or signing-key location.

## Settings Contract

Each countdown slot stores:

- `eventN_name`
- `eventN_target_date`
- `eventN_use_specific_time`
- `eventN_all_day`
- `eventN_target_hour`
- `eventN_target_minute`
- `eventN_target_epoch`

The app also stores an internal `eventN_target_signature` per slot in app storage so it can detect real countdown-input changes without repinning saved epochs on every startup or rename.

`eventN_use_specific_time` is the canonical settings toggle shown in Garmin Connect. The legacy `eventN_all_day` value is still mirrored for compatibility with previously installed data. `eventN_target_epoch` is resolved when the timer is saved so the countdown stays pinned to the user's local timezone at setup time. The raw date and time fields are still kept for settings and display.

Example payload:

```json
{
  "event1_name": "Summer Trip",
  "event1_target_date": 1798761600,
  "event1_use_specific_time": false,
  "event1_all_day": true,
  "event1_target_hour": 0,
  "event1_target_minute": 0,
  "event1_target_epoch": 1798761600
}
```

## Contributing Focus

Contributions are welcome across the project, with extra interest in:

- adapting layouts and navigation for more Garmin watches
- validating simulator behavior on additional devices
- checking text fitting, page indicators, and button behavior on different screen shapes and resolutions
- tightening docs and release workflows for outside contributors

When adding watch support:

- validate the device in the simulator before changing `manifest.xml`
- verify readability, truncation, spacing, and navigation behavior
- document what you tested in the pull request

See [CONTRIBUTING.md](/Users/mwieland/dev/anticipate/CONTRIBUTING.md) for the expected workflow.

## Publishing Notes

- Garmin Connect IQ submission still requires manual work in Garmin's developer portal
- Only claim devices that have actually been validated
- See [docs/publishing.md](/Users/mwieland/dev/anticipate/docs/publishing.md) for the current submission checklist and suggested repo metadata
- Use [docs/store-submission-copy.md](/Users/mwieland/dev/anticipate/docs/store-submission-copy.md) for store copy, privacy wording, and publisher-field reminders

## Support Expectations

This repository is primarily the open-source source code and contributor workflow for the project. Public Garmin store contact and support fields should use the publisher details you choose for release.

## Security

- Never commit signing keys, certificates, or other secrets
- Keep local signing material in ignored paths such as `private/`
- Review screenshots, docs, and examples before publishing to avoid personal data leaks
