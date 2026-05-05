# Publishing Checklist

This repo can prepare the app binary and most of the product copy, but Garmin Connect IQ submission still requires manual work in the Garmin developer portal.

## Suggested GitHub Metadata

Use this as the starting point for the GitHub repository details UI:

- Description: `Open-source Garmin Connect IQ countdown widget with up to 5 events and optional event times.`
- Topics: `garmin connect-iq monkey-c countdown widget forerunner55`
- Website: leave blank until the public Garmin store page exists, then link the app listing

## Repo-Side Status

Already updated in this repo:

- App name reflects multi-countdown support
- Empty-state copy reflects Connect IQ naming
- Settings support up to 5 countdowns
- Countdowns use an `Add a time` toggle with date-only behavior when off
- Countdowns now stay set after setup
- Demo timer seeding has been removed for release builds
- README matches the current feature set

## Suggested Store Copy

Use the full copy pack in [store-submission-copy.md](store-submission-copy.md).

## Supported-Device Smoke Test

Use the documented supported-device verification flow in [multi-device-smoke-test.md](multi-device-smoke-test.md).

Preferred local launch path:

- build the simulator artifact with the command in [multi-device-smoke-test.md](multi-device-smoke-test.md)
- reset state with `./scripts/reset-sim-state.sh`
- launch from the matching VS Code configuration

Treat direct `monkeydo` runs as optional troubleshooting, not the canonical pre-submit workflow.

Release builds must be signed with your own local key material. Do not publish or commit signing keys, certificates, or other secrets.

## Release Package Build

Build the Garmin upload artifact as a release package, using the real device id rather than the simulator id:

```sh
SDK=$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg") && \
JAVA_BIN="${JAVA_HOME:-/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home}/bin/java" && \
"$JAVA_BIN" \
  -Xms1g \
  -Dfile.encoding=UTF-8 \
  -Dapple.awt.UIElement=true \
  -jar "$SDK/bin/monkeybrains.jar" \
  -e \
  -o "$(pwd)/bin/anticipate.iq" \
  -f "$(pwd)/monkey.jungle" \
  -y "/path/to/your/signing-key.der" \
  -d fr55 \
  -r -w -l 2 -w
```

## Pre-Submit Security Check

Before committing, pushing, or uploading to Garmin:

- Run `git status --short --ignored` and verify only intentional source/docs changes are staged or unstaged
- Confirm `private/`, `bin/`, `diagnostics/`, signing keys, `.prg`, `.iq`, and debug XML files are ignored or absent
- Build release or pre-submit artifacts with `-r` so compiler debug paths are stripped
- Search staged changes for real countdown names, birthdates, emails, phone numbers, addresses, credentials, tokens, and local filesystem paths
- Use only synthetic event names and dates in screenshots, docs, examples, and store assets
- Upload only the intended release `.iq` package to Garmin, never debug XML, simulator state, signing keys, or local generated artifacts
- Replace placeholder support/contact fields with public release details you are comfortable publishing

## Manual Garmin Submission Tasks

These still must be done by hand in Garmin's submission flow:

- Upload the exported `.iq` package
- Set or verify the store description
- Choose categories and tags
- Upload screenshots
- Upload hero/store art if required
- Select supported products
- Submit the app for review

Official Garmin submission guide:

- [Submit an App](https://developer.garmin.com/connect-iq/submit-an-app/)
- [App Review Guidelines](https://developer.garmin.com/connect-iq/app-review-guidelines/)
- [Connect IQ Brand Guidelines](https://developer.garmin.com/brand-guidelines/connect-iq/)

## Adding More Watches

Garmin requires you to list supported products in `manifest.xml`, and your exported `.iq` package must include binaries for every product you claim to support.

Community help adapting and validating the widget on more Garmin watches is very welcome. Keep claimed support conservative until each device has actually been tested.

Recommended approach:

1. Start with devices close to the currently supported targets:
   - round watch displays
   - similar resolution families
   - API level 3.1 or higher
2. Add one small cluster at a time in `manifest.xml`
3. Build and run the simulator for each added device
4. Check text fitting, button navigation, page indicator spacing, and title truncation
5. Only then include those devices in the store submission

Forerunner 45 (`fr45`) is not a valid target for this widget because Garmin's SDK profile exposes it as a watch-face-only Connect IQ device.

Enduro 2 and tactix 7 are covered by Garmin's shared `fenix7x` SDK profile, labeled `fēnix® 7X / tactix® 7 / quatix® 7X Solar / Enduro™ 2`. Do not add the separate `enduro` profile for Enduro 2; that profile is the older Enduro device.

Useful official references:

- [Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [Device Reference](https://developer.garmin.com/connect-iq/device-reference/venu2plus/)

## Practical Expansion Strategy

Likely easier candidates are other round, button-driven watches in nearby resolution families. Add AMOLED, touch-heavy, square, or much higher-resolution products only after layout is validated in the simulator.
