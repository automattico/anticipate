# Local-time target verification

Run the Monkey C regression suite with the simulator available:

```sh
./scripts/test-timezones.sh venu445mm
./scripts/test-timezones.sh fr55
```

The script uses the current SDK and the preferred local signing key (or pass a key path as argument two). It does not reset simulator state. Unit tests use an in-memory storage adapter; they never clear or rewrite real countdown settings. Build and test logs are ignored under `bin/timezone-tests/<device>/`. SDK 9.1 returns exit code 1 for successful unit tests, so the runner requires the explicit zero-failure results footer.

## Automated coverage

Nine Monkey C tests cover UTC, positive/negative offsets, UTC+5:30 and UTC+5:45, New Year rollover, nonzero seconds, all five slots, saved-instant stability across offset changes, target edits, exact UTC repair, backup preservation, interrupted repairs, interrupted first saves, custom/mismatched signatures, legacy epochs (including the default zero), malformed caches/backups/versions, overflow, and zero-padded settings.

String signatures must be compared by content with `equals()`, including after storage deserialization or recomputation. Identity comparisons can silently repin an otherwise unchanged target. Date-only events normalize their time to midnight; the existing 24-hour TODAY/DONE window is unchanged.

## Upgrade and simulator checks

Before any store release:

1. Install the previous store binary without resetting its storage.
2. Configure synthetic all-day and timed events, including multiple slots.
3. Record names, input fields, UTC epochs, and signatures.
4. Install the new build with the same app ID and simulator app basename.
5. Verify every input remains unchanged. Matching UTC epochs move by the effective local offset exactly once; each original epoch/signature/offset is backed up and version becomes `1`.
6. Verify widget and glance agree, including opening the glance first, restarting, renaming, and changing the watch's offset. Saved epochs and backups must remain stable until target inputs change.
7. Verify invalid/partial dates and malformed time/mode fields do not clear cached targets. Keep custom or ambiguous caches unchanged; later valid date/time edits should create new targets.
8. Compile all manifest targets with `./scripts/build-all-devices.sh <local-key>`, then load and capture the latest Venu 4 45mm and FR55 screens. Inspect both all-day/timed widget screens and populated glance screens.

The simulator's persistent-data editor may require a Garmin Connect login. A guarded, generated baseline fixture can seed synthetic data only after verifying that no countdown is present: use the unchanged application ID and never reset storage. Simulator data can be shared across app basenames; a renamed binary is not an isolated data store. Any later synthetic input edits must require the fixture marker and exact expected synthetic values. Fixture/probe code belongs only in ignored build artifacts and must not enter production builds. Run cross-device unit tests before seeding: switching the simulator device can remove incompatible sideloads and their synthetic data. If switching leaves a blue triangle without a new app error log, retry the launch after the device switch finishes.

## Verification record — 10 November 2026

- Environment and device metadata checks passed. Venu simulator profile: API 6.0.0 / firmware 16.28; FR55: API 3.4.2. Garreth's physical Venu firmware 18.32 was not available for testing.
- Venu 4 45mm and FR55: all nine regression tests passed on each device with no compiler warnings.
- All 46 manifest targets compiled with no errors or warnings.
- Venu and FR55 production widgets (all-day and timed) and populated glances captured and visually checked. FR55 synthetic date/time editing produced the expected new local target while retaining the original backup. Screenshots are retained under ignored `private/timezone-verification-2026-11-10/`. Glance-first upgrade persisted slot 1 before the widget ran; later widget opening migrated the remaining slots. Reloading preserved the corrected target and original backup.
- In-place upgrade exercised the previous export dated 16 June 2026 (now retained at ignored `private/releases/anticipate-previous-2026-06-16.iq`), using its Venu 4 binary and three guarded synthetic countdowns (all-day, timed, multiple slots). The unchanged simulator basename preserved data across builds. Original epochs were retained in backups; corrected epochs differed by exactly 3,600 seconds at the simulator's UTC+1 offset. All names, dates, time modes, hours, and minutes remained unchanged.
- Published-baseline provenance confirmed on 10 November 2026: Garmin lists version 1.3.1 (internal 5), released 16 June 2026, and the publisher confirmed that the retained June export is the published 1.3.1 package used for the upgrade test. The upgrade release gate is satisfied.

Historical save-time timezone information was never stored. Repairs use the current watch offset. Events originally saved in another timezone or manually adjusted to compensate for the UTC bug may require a date/time edit. Future daylight-saving transitions are not predicted; saved targets remain fixed instants.

## Data safety and delivery

- App ID unchanged: yes.
- Existing property keys and types unchanged: yes.
- Storage schema changed: yes, optional version/backup fields only; old formats remain readable.
- Migration needed: yes, implemented with backup-before-repair and retry protection.
- Upgrade test performed: yes, from published 1.3.1; baseline identity confirmed by the publisher.
- Known data-loss risks: no intentional deletion/reset paths in this fix. Automatic repair cannot reconstruct historical timezone information or detect manual compensation of entered settings; original cached targets are retained in backups.

Captured screenshots (ignored local artifacts):

- `private/timezone-verification-2026-11-10/venu445mm-all-day.png`
- `private/timezone-verification-2026-11-10/venu445mm-timed.png`
- `private/timezone-verification-2026-11-10/venu445mm-glance.png`
- `private/timezone-verification-2026-11-10/fr55-all-day.png`
- `private/timezone-verification-2026-11-10/fr55-timed.png`
- `private/timezone-verification-2026-11-10/fr55-glance.png`

## Store package — version 1.3.2

- Signed release export: `bin/anticipate.iq`, built 10 November 2026 for all 86 firmware/region variants across the 46 supported device profiles; no compiler errors or warnings.
- SHA-256: `1da7e1a76614089893229fdc1c5f4911bd11a77dcf8d97fd2dfd311f8d860ef5`.
- Size: 2,260,464 bytes.
- Application ID, signing public key, and device-variant set match the published 1.3.1 export.
- Exported Venu 4 45mm and FR55 PRGs exactly match the previously validated device-build PRGs.
- Previous 1.3.1 package retained privately; SHA-256 `730b90ee51a2e476a55a57dd0910d645bf6c7e109619266f085cdfdce7ee57d6`.

## Garmin submission — 10 November 2026

- Submitted the signed package as version **1.3.2** to the existing Anticipate Countdowns listing, retaining the store app identifier.
- Garmin verified the manifest AppID and signature before accepting the submission.
- Saved the timezone-fix release notes; existing description, images, category, contact details, and other listing settings were retained.
- After submission, Garmin's update form reports **Latest app version: 1.3.2**. Developer Dashboard status is **Approved**.
- The independently loaded public listing still displayed version **1.3.1** at the final check, although the new release notes were present. Public live availability of 1.3.2 is not yet confirmed.

## Post-release source cleanup — 10 November 2026

- Removed 14 unreferenced helper methods from the app/event loader and an unused storage import; retained all active migration and parsing paths.
- Removed temporary simulator fixture sources and test binaries/caches, including orphaned test artifacts. Original release logs, screenshots, package verification evidence, the submitted 1.3.2 IQ, and the previous 1.3.1 IQ are retained privately.
- Rebuilt all 46 device targets with no compiler errors or warnings; all nine existing regression tests passed again on FR55.
- Loaded the rebuilt FR55 app in the simulator and visually verified its empty-state screen without resetting settings. Screenshot: `private/timezone-verification-2026-11-10/cleanup-fr55-empty.png`.
- Cleanup verification logs are retained under ignored `private/timezone-verification-2026-11-10/logs/cleanup-*`.
- The submitted 1.3.2 package and previous 1.3.1 package retain the hashes recorded above; this cleanup does not create a new store release.
- Cleanup data safety: app ID unchanged **yes**; property keys/types unchanged **yes**; storage schema changed **no**; migration needed **no**; a new upgrade test performed **no** (the published 1.3.1-to-1.3.2 upgrade test above remains applicable); known additional data-loss risks **none identified**.
