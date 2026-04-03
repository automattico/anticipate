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
- Countdowns now use an explicit `All day` toggle
- Countdowns now stay set after setup
- Demo timer seeding has been removed for release builds
- README matches the current feature set

## Suggested Store Copy

Use the full copy pack in [store-submission-copy.md](/Users/mwieland/dev/anticipate/docs/store-submission-copy.md).

## FR55 Smoke Test

Use the documented FR55 verification flow in [fr55-smoke-test.md](/Users/mwieland/dev/anticipate/docs/fr55-smoke-test.md).

Preferred local launch path:

- build the FR55 simulator artifact with the command in [fr55-smoke-test.md](/Users/mwieland/dev/anticipate/docs/fr55-smoke-test.md)
- reset state with `./scripts/reset-fr55-sim-state.sh`
- launch from the VS Code `Run on Forerunner 55` configuration

Treat direct `monkeydo` runs as optional troubleshooting, not the canonical pre-submit workflow.

Release builds must be signed with your own local key material. Do not publish or commit signing keys, certificates, or other secrets.

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

1. Start with devices close to FR55:
   - round MIP watches
   - similar resolution
   - API level 3.1 or higher
2. Add one small cluster at a time in `manifest.xml`
3. Build and run the simulator for each added device
4. Check text fitting, button navigation, page indicator spacing, and title truncation
5. Only then include those devices in the store submission

Useful official references:

- [Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [Device Reference](https://developer.garmin.com/connect-iq/device-reference/venu2plus/)

## Practical Expansion Strategy

Likely easier first candidates after FR55 are other round, button-driven, MIP watches in the same rough size class. Avoid adding AMOLED, touch-heavy, square, or much higher-resolution products until layout is validated there.
