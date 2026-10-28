# Testing checklist — category 10

## Inventory

- Count test files per directory (`find test integration_test -name "*_test.dart" | sed 's|/[^/]*$||' | sort | uniq -c`).
- Shared helpers: `test/support/`, harnesses, fakes, fixtures — reuse them; flag duplicated fakes.
- CI runs the same gate as local (format, analyze, tests, coverage floor, builds)?

## Coverage of critical flows

Map each critical flow to the tests that prove it. A flow with no test is a finding (High for
auth, payments, data deletion; Medium otherwise).

| Flow | Unit | Widget | Integration |
|---|---|---|---|
| Sign up, sign in, sign out, session expiry | | | |
| Account deletion | | | |
| Core feature create / update / delete | | | |
| Offline use and recovery | | | |
| Purchases and restore (if any) | | | |
| Permission granted / denied / revoked | | | |
| Consent and regional behaviour (if any) | | | |

## Scenarios per level

- **Unit** — repositories, use cases, state owners, validators, mappers, date and time logic;
  success and failure paths; boundaries; 400 / 401 / 403 / 404 / 409 / 422 / 500 / timeout /
  offline mapped to typed failures; serialized token refresh.
- **Widget** — loading, success, empty, error, offline states; callbacks fire; form validation;
  dialogs and sheets open and close; light and dark themes; 200% text scale on a small phone and
  on a tablet without overflow; accessibility guideline matchers.
- **Integration** (`integration_test/`) — whole flows across screens and platform features;
  fresh install, restart, and offline paths.
- **Regression** — every fixed defect has a test that failed before the fix.

## Test quality

- Deterministic: no real network, no wall-clock dependence (inject a clock), no `sleep`-based
  waits; `pumpAndSettle` not used to hide infinite animations.
- Independent: no shared mutable state, any order.
- Names state behaviour (`shows error when sign-in fails`), never `test1`.
- The behaviour under test is not mocked; fakes sit at the boundaries.
- Platform channels faked in widget tests so teardown does not hang.

## Coverage numbers

Report a coverage percentage only if `flutter test --coverage` ran in this session; otherwise
say it was not measured. Coverage is a floor, not a goal — untested critical flows matter more
than the percentage.

## Running

- Narrow to wide: the changed file's tests (`--impact` from the import graph), then the feature,
  then the suite.
- Large suites can be killed for memory and exit silently: run per directory or with
  `--concurrency=2`, and report each chunk.
- Record exact commands and pass / fail / skip counts.
