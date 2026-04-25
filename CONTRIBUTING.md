# Contributing

Thanks for helping with Anticipate Countdowns.

## What Contributions Are Most Helpful

Especially appreciated:

- adapting the widget to more Garmin watches
- validating simulator behavior on additional devices
- improving text fitting, layout, and button-navigation behavior
- fixing bugs or tightening the local build and test workflow

## Local Setup

1. Install the Garmin Connect IQ SDK locally.
2. Install Java 17 or another compatible JDK locally.
3. Open the repo in VS Code with the `garmin.monkey-c` extension.
4. Run:

```sh
./scripts/verify-env.sh
```

5. Use the `Run on Forerunner 55` launch configuration as the default local simulator flow.

## Smoke Testing

Use [docs/fr55-smoke-test.md](docs/fr55-smoke-test.md) for the canonical FR55 smoke test.

Before opening a PR for behavior changes, run the documented FR55 flow and note anything you could not verify.

## Adding Support For More Watches

If your contribution adds or improves support for another Garmin watch:

- validate the layout in the simulator before editing `manifest.xml`
- check text fitting, page-indicator spacing, empty state layout, and button navigation
- confirm the app still behaves correctly with all-day and timed countdowns
- document which device(s) you tested and what changed

Do not claim support for a device in `manifest.xml` or store metadata until it has actually been validated.

## Pull Requests

Good PRs are:

- focused and scoped
- clear about user-visible behavior changes
- explicit about device coverage and what was tested

If you change UI behavior, include a short note about the watch profile or simulator target you checked.

## Issues And Feature Requests

Bug reports and feature requests are welcome through the repository. If you are requesting support for a Garmin device, include the device name, screen shape, and any simulator or real-device observations you already have.

## Security And Privacy

- Never commit signing keys, certificates, or secrets
- Keep local key material in ignored paths such as `private/`
- Do not commit simulator state dumps or personal countdown data
- Review screenshots and docs before publishing them publicly
