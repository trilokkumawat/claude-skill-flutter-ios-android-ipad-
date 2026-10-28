# Secrets and configuration

## Never open, print, or copy

`.env` and `.env.*` (except `.env.example`), `*.jks`, `*.keystore`, `key.properties`, `*.p8`,
`*.p12`, `*.pem`, `*.cer`, `*.mobileprovision`, service-account JSON files, CI secret dumps,
and anything under `~/.ssh`, `~/.aws`, `~/.gnupg`.

`google-services.json` and `GoogleService-Info.plist` identify a Firebase project; they are not
secret in the binary, but do not paste their contents into reports, issues, or public repos.

If a project's `.claude/settings.json` denies reading a file, treat that as the intent — never
route around it.

## A mobile binary is public

Every value compiled into the app — `--dart-define`, `--dart-define-from-file`, bundled `.env`
assets, `String.fromEnvironment`, `Info.plist`, `AndroidManifest.xml`, resources — can be
extracted. Obfuscation is not a security control.

- Ship only public identifiers (API base URLs, publishable keys, OAuth client IDs).
- Restrict client keys server-side (application ID / bundle ID / signing-certificate
  fingerprint, API restrictions, quotas).
- Real secrets (private API keys, signing keys, admin tokens, database credentials) live on the
  backend, in CI secret stores, or in a password manager — never in the repository.
- Examples and templates use placeholders: `API_BASE_URL=https://api.example.com`.

## Environments

- Separate development, staging, and production: separate backends, Firebase projects, OAuth
  clients, and application/bundle IDs (for example a `.dev` / `.stg` suffix) so builds install
  side by side and never share data.
- Resolve configuration once, at startup, into an injected environment object. No scattered
  `if (isProd)` checks in features.
- Flutter options: one entrypoint per flavour (`lib/main_dev.dart`, …) and/or
  `--dart-define-from-file=config/<env>.json` (the JSON holds public values only). Android
  `productFlavors`; iOS schemes plus `.xcconfig` per configuration.
- A release build refuses non-production configuration, and a production build carries no
  debug menus, test accounts, bypass flags, or verbose logging.

## Tokens and credentials on device

| Data | Store |
|---|---|
| Access token, refresh token, device secret, encryption keys | Platform secure storage (Keychain / Android Keystore, e.g. `flutter_secure_storage`) |
| Non-sensitive preferences (theme, onboarding seen) | `shared_preferences` |
| User content cache | The local database; encrypt it when it holds sensitive personal data |

Never store passwords. Keep the access token in memory plus secure storage, the refresh token
in secure storage only. Clear all of it — and user-scoped caches — on sign-out and account
deletion.

## Logging and outputs

- Never log tokens, passwords, keys, authorisation headers, full request or response bodies
  with personal data, email addresses, phone numbers, precise location, or device identifiers.
- Gate verbose logging to non-release builds (`kReleaseMode`, the environment object).
- Reports, screenshots, test fixtures, issue text, and graph outputs never contain secrets or
  real personal data. Use `<redacted>` and synthetic fixtures.

## When a secret is found in the repository

Report it as **Critical** with file, line, and the kind of secret — never the value. Recommend
rotating it at the issuer (deleting it from the file or history is not enough), then removing
it, then adding a scan (for example a CI secret scanner) so it cannot return.
