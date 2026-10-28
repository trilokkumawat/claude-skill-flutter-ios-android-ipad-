# Security checklist — categories 5 to 9

Never print a secret's value in a finding: give the file, line, and kind. Reference standard:
OWASP MASVS (https://mas.owasp.org).

## 5. Input validation and error handling

- Forms validate on the client for usability; the server is assumed to validate independently
  (flag client-only rules that protect data or money).
- JSON parsing: unchecked casts (`as String`, `!`) on decoded maps, `jsonDecode` without error
  handling, DTOs that crash on a missing field. Map parse failures to a typed failure.
- Errors: `catch (_) {}` or `catch (e) {}` that swallows; `e.toString()` or exception text shown
  to users; un-awaited futures without an error path (`unawaited` with no `catchError`).
- Timeouts, cancellation, and retry exist for network calls; loading never gets stuck.

## 6. Authentication and authorisation

- Token storage: tokens in platform secure storage, not `SharedPreferences`, files, or logs
  (`grep -rniE "(token|secret|password).*(SharedPreferences|setString)" lib`).
- Refresh: one in-flight refresh shared by concurrent 401s; refresh failure signs out; offline is
  not treated as expiry.
- Sign-out and account deletion clear tokens and user-scoped local data.
- Authorisation is enforced by the backend. Role checks that exist only in the UI (hidden buttons,
  route guards) are findings when the backend does not also enforce them — mark as Hypothesis
  unless the backend source is available.
- Route guards: authenticated routes redirect when signed out; deep links cannot bypass guards.
- Third-party sign-in uses the provider SDK or OAuth with PKCE; no client secrets in the app.
- Biometrics, if present, unlock a locally stored credential — they are not server authentication.

## 7. Secrets, credentials, tokens, storage, logging

- Secret patterns in tracked files (report location and kind only):
  `grep -rnE "AIza[0-9A-Za-z_-]{35}|sk_live_|-----BEGIN [A-Z ]*PRIVATE KEY|ghp_[0-9A-Za-z]{36}|xox[baprs]-" --exclude-dir=build .`
  and `api[_-]?key|secret|password` assignments in `lib/`.
- `.env` files listed under `flutter: assets:` in `pubspec.yaml` ship inside the app — only
  public values may be in them.
- `--dart-define` and `String.fromEnvironment` values are public; flag anything secret-looking.
- `git ls-files | grep -E "\.(jks|keystore|p12|p8|pem|mobileprovision)$|key\.properties"` —
  tracked signing material is Critical.
- Logging: prints of tokens, headers, request or response bodies, emails, device IDs; verbose
  logging not gated to non-release builds.
- Local database holding sensitive personal data without encryption — Medium to High by data type.

## 8. API and network security

- Cleartext: `http://` URLs outside localhost; Android `android:usesCleartextTraffic="true"` or a
  permissive `network_security_config.xml`; iOS `NSAllowsArbitraryLoads`.
- Certificate validation disabled: `badCertificateCallback` returning `true`, custom
  `HttpOverrides` — Critical in release code.
- Certificate pinning: present only where the threat model requires it, with a rotation plan.
- WebViews: JavaScript enabled only where needed; no untrusted content with JavaScript bridges;
  navigation restricted.
- Deep links: Android App Links with `autoVerify`, iOS Universal Links; parameters validated
  before use; no sensitive actions triggered by a link without confirmation.
- `url_launcher` with untrusted URLs; platform-channel inputs validated on the native side.

## 9. Dependency risks and vulnerable packages

- `flutter pub outdated`: discontinued packages, majors far behind, packages without null safety.
- `dependency_overrides`, git and path dependencies in release builds — explain each.
- Known vulnerabilities: run an already-installed scanner (e.g. `osv-scanner --lockfile
  pubspec.lock`) or check https://osv.dev for key packages; never install a scanner without
  approval — report the check as not run instead.
- Native layers: `ios/Podfile.lock`, Gradle dependencies, and the SDKs plugins bring in
  (advertising, analytics, attribution) — each is also a privacy declaration item.
- Licences compatible with distribution; an open-source notices screen exists
  (`showLicensePage` / `LicensePage`).
