# Release gate — <Project name> <version (build)>

| Field | Value |
|---|---|
| Release | <version, build number, platforms, tracks> |
| Markets in this release | <list> |
| Gate run on | <YYYY-MM-DD> by <name / Claude + reviewer> |
| Verdict | **Blocked** · **Ready with open items** · **Ready** |

## Blocking criteria

The release is **Blocked** while any of these is true:

- A Critical security issue is unresolved.
- A requirement with status Confirmed and type Legal obligation or mandatory Platform policy is
  unmet or lacks evidence.
- Privacy disclosures contradict actual app, backend, or SDK behaviour.
- The release build uses a non-production configuration, test credentials, or debug bypasses.

## Checks

| Check | Command / method | Result | Evidence |
|---|---|---|---|
| Format | `dart format --output=none --set-exit-if-changed lib test` | <> | <> |
| Static analysis | `flutter analyze` | <> | <> |
| Unit and widget tests | `flutter test` (or per directory) | <> | <> |
| Integration / end-to-end tests | `flutter test integration_test` on device or emulator | <> | <> |
| Consent tests | <test files> | <> | <> |
| Permission tests (granted / denied / revoked) | <test files> | <> | <> |
| Data deletion end-to-end | <test + backend evidence> | <> | <> |
| Authorisation tests | <backend + app tests> | <> | <> |
| Regional behaviour tests | <test files> | <> | <> |
| Disclosures vs behaviour | Data inventory vs network capture vs SDK list | <> | <> |
| Current Apple requirements checked | <URL, date> | <> | <> |
| Current Google Play requirements checked | <URL, date> | <> | <> |
| Release artefacts built from production entrypoint | <build command> | <> | <> |

## Open items carried into this release

| Issue ID | Summary | Blocking? | Owner | Due |
|---|---|---|---|---|

## Sign-off

| Role | Name | Date | Notes |
|---|---|---|---|
| Engineering | <> | <> | <> |
| Product | <> | <> | <> |
| Legal / privacy review (where required) | <> | <> | <> |
