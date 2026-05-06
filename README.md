# Anticipate Countdowns

Anticipate Countdowns is an open-source Garmin Connect IQ widget for tracking up to five upcoming events with optional event times.

The current validated targets are `descentmk2`, `descentmk2s`, `epix2pro42mm`, `fenix6`, `fenix6pro`, `fenix6s`, `fenix6spro`, `fenix6xpro`, `fr55`, `fr165`, `fr165m`, `fr245`, `fr245m`, `fr255`, `fr255m`, `fr255s`, `fr255sm`, `fr645`, `fr645m`, `fr745`, `fr935`, `fr945`, `fr945lte`, `fr955`, `fenix7`, `fenix7pro`, `fenix7pronowifi`, `fenix7x`, `fenix7xpro`, `fenix7xpronowifi`, `fenix7s`, `fenix7spro`, `marq2`, `marq2aviator`, `marqadventurer`, `marqathlete`, `marqaviator`, `marqcaptain`, `marqcommander`, `marqdriver`, `marqexpedition`, `marqgolfer`, `venu3s`, `vivoactive4`, `vivoactive4s`, and `vivoactive5`. Garmin quatix 7 uses the shared `fenix7` SDK profile. Contributions that adapt and validate the widget for more Garmin watches are especially appreciated.

This project was built with help from OpenAI Codex.

## Features

- Up to 5 countdowns configured in Connect IQ app settings
- Optional specific hour and minute for timed events
- All-day countdowns with date-only display
- Countdown targets pinned to the user's local timezone when saved
- Horizontal paging between configured countdowns

## Current Device Support

- Validated targets today: `descentmk2`, `descentmk2s`, `epix2pro42mm`, `fenix6`, `fenix6pro`, `fenix6s`, `fenix6spro`, `fenix6xpro`, `fr55`, `fr165`, `fr165m`, `fr245`, `fr245m`, `fr255`, `fr255m`, `fr255s`, `fr255sm`, `fr645`, `fr645m`, `fr745`, `fr935`, `fr945`, `fr945lte`, `fr955`, `fenix7`, `fenix7pro`, `fenix7pronowifi`, `fenix7x`, `fenix7xpro`, `fenix7xpronowifi`, `fenix7s`, `fenix7spro`, `marq2`, `marq2aviator`, `marqadventurer`, `marqathlete`, `marqaviator`, `marqcaptain`, `marqcommander`, `marqdriver`, `marqexpedition`, `marqgolfer`, `venu3s`, `vivoactive4`, `vivoactive4s`, and `vivoactive5`
- Current profiles: round `208x208`, `218x218`, `240x240`, `260x260`, `280x280`, and `390x390`
- Display/input mix: MIP button-first layouts across `208-280` buckets plus a shared `390x390` AMOLED bucket for `fr165`, `fr165m`, `epix2pro42mm`, `venu3s`, `vivoactive5`, `marq2`, and `marq2aviator`, with swipe paging parity and no new touch-only workflows
- `fr165` maps to `Forerunner® 165`: round `390x390`, AMOLED, API 5.2, launcher icon `54x54`
- `fr165m` maps to `Forerunner® 165 Music`: round `390x390`, AMOLED, API 5.2, launcher icon `54x54`
- `fr955` maps to `Forerunner® 955 / Solar`: round `260x260`, MIP 64 colors, API 5.2, launcher icon `40x40`
- `fenix7` maps to `fēnix® 7 / quatix® 7`: round `260x260`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fenix7pro` maps to `fēnix® 7 Pro`: round `260x260`, MIP 8-bit color, API 5.2, launcher icon `40x40`
- `fenix7s`, `fenix7spro`, `fenix7pronowifi`, `fenix7xpronowifi`, `fr165`, `fr165m`, `epix2pro42mm`, `venu3s`, `vivoactive5`, `marq2`, and `marq2aviator` are API 5.2 glance-era profiles; the SDK compiler accepts this widget target, matching the existing API 5.2 support pattern
- Forerunner 45 (`fr45`) is not supported by this widget because Garmin's device profile does not support Connect IQ widgets on that target
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

4. Use either `Run App: Choose Device Each Run` or a matching device-specific launch configuration for simulator workflow.

If the simulator behaves strangely after switching SDKs, clear its temporary state:

```sh
rm -rf "$TMPDIR/com.garmin.connectiq"
```

## Smoke Tests

Use [docs/multi-device-smoke-test.md](docs/multi-device-smoke-test.md) for the canonical supported-device verification flow. The older [docs/fr55-smoke-test.md](docs/fr55-smoke-test.md) remains available for FR55-specific checks.

At a high level:

1. Verify the toolchain with `./scripts/verify-env.sh`.
2. Check local device metadata with `./scripts/check-device-metadata.sh`.
3. Build every supported device with `./scripts/build-all-devices.sh /path/to/your/signing-key.der`.
4. Reset simulator state with `./scripts/reset-sim-state.sh`.
5. Launch the matching VS Code run configuration.

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
  -r -w -l 2 -w
```

Treat that command as an example local flow, not a promise that every machine uses the same Java path or signing-key location. Keep `-r` on release or pre-submit builds so debug source paths are stripped from generated artifacts.

To regression-build every manifest target and fail on compiler warnings, run:

```sh
./scripts/build-all-devices.sh /path/to/your/signing-key.der
```

For VS Code launch configurations, the default local key path is `private/anticipate-dev-key.der`. You can override it by setting `PRIVATE_KEY=/path/to/your/signing-key.der`.

## Settings Contract

Each countdown slot stores:

- `eventN_name`
- `eventN_target_year`
- `eventN_target_month`
- `eventN_target_day`
- `eventN_use_specific_time`
- `eventN_target_hour`
- `eventN_target_minute`

Legacy installs may also have `eventN_target_date`, `eventN_all_day`, and `eventN_target_epoch` in Application.Properties. These are kept as hidden compatibility inputs only.

The app stores internal `eventN_target_epoch` and `eventN_target_signature` values in Application.Storage so it can detect real countdown-input changes without repinning saved epochs on every startup or rename.

`eventN_use_specific_time` is shown to users as `Add a time`. Hour and minute remain editable in settings, but the app ignores them when `Add a time` is off. On first launch after upgrading from an older release, the app migrates legacy `eventN_target_date` values into numeric year/month/day settings and migrates legacy `eventN_all_day` into `eventN_use_specific_time` when needed.

Example payload:

```json
{
  "event1_name": "Summer Trip",
  "event1_target_year": "2027",
  "event1_target_month": "1",
  "event1_target_day": "1",
  "event1_use_specific_time": false,
  "event1_target_hour": 0,
  "event1_target_minute": 0
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

See [CONTRIBUTING.md](CONTRIBUTING.md) for the expected workflow.

## Publishing Notes

- Garmin Connect IQ submission still requires manual work in Garmin's developer portal
- Only claim devices that have actually been validated
- See [docs/publishing.md](docs/publishing.md) for the current submission checklist and suggested repo metadata
- Use [docs/store-submission-copy.md](docs/store-submission-copy.md) for store copy, privacy wording, and publisher-field reminders

## Support Expectations

This repository is primarily the open-source source code and contributor workflow for the project. Public Garmin store contact and support fields should use the publisher details you choose for release.

## Security

- Never commit signing keys, certificates, or other secrets
- Keep local signing material in ignored paths such as `private/`
- Review screenshots, docs, and examples before publishing to avoid personal data leaks
