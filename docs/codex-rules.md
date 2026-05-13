# Codex Rules

This document captures permanent Codex/agent release-hardening rules for this repository.

## User Data Safety Rules

This Garmin Connect IQ app stores user data via app properties/settings/persistent storage. Existing user data must be treated as a stable schema.

Hard rules:

1. Never change the app ID
   - Do not modify the `<iq:application id="...">` in `manifest.xml`.
   - This ID is permanent.
   - Changing it can cause existing users to lose their stored countdowns/settings.

2. Never break existing stored property keys
   - Do not rename existing property keys.
   - Do not remove existing property keys.
   - Do not change data types of existing property keys.
   - Do not change stored structure in a non-compatible way.

3. Backward-compatible changes only
   - New fields must be optional.
   - Existing stored data must continue to load.
   - Old formats must remain readable unless a safe migration exists.

4. Migrations are required for schema evolution
   - If stored data structure must change, add explicit versioning.
   - Detect old data.
   - Migrate safely.
   - Preserve user values.
   - Never reset or overwrite existing countdowns silently.

5. Defensive parsing is mandatory
   - Treat missing, null, malformed, or partially corrupted values as expected.
   - Use safe fallbacks.
   - Never crash while loading user data.
   - Never convert a parsing failure into data deletion.

6. No storage clearing
   - Do not clear app properties.
   - Do not reset settings.
   - Do not overwrite stored countdowns with defaults unless the user explicitly requested a reset.

7. Upgrade testing is a release gate
   - Before release, test upgrade from the previous store version:
     - install old version
     - configure at least one all-day countdown
     - configure at least one timed countdown
     - configure multiple countdowns
     - upgrade to the new build
     - verify all countdowns/settings remain present and usable

8. Stop on data-loss risk
   - If any proposed change may cause existing user data loss, stop.
   - Explain the risk.
   - Propose a migration plan.
   - Wait for approval before implementing.

9. Release reports must mention data safety
   - Every release-affecting Codex report must explicitly state:
     - app ID unchanged: yes/no
     - property keys unchanged: yes/no
     - storage schema changed: yes/no
     - migration needed: yes/no
     - upgrade test performed: yes/no
     - known data-loss risks

## Release Checklist

Use this as a hard release gate before Connect IQ Store submission:

- Build all supported devices with `./scripts/build-all-devices.sh /path/to/your/signing-key.der`.
- Run representative simulator smoke tests for each display/input bucket covered by the release.
- Run the upgrade persistence test from the previous store version and confirm all configured countdowns survive the upgrade.
- Audit `manifest.xml`, `resources/properties.xml`, and storage code for app ID and property-schema compatibility before submission.
- Capture fresh screenshots when UI-visible changes are part of the release.
