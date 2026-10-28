# Platform and compliance checklist — categories 13 to 15

Classify each item as **Mandatory** (required by a store policy or platform rule as checked),
**Recommended** (best practice), **Project risk** (specific to this app), or **Manual check**
(needs a device, a console, or a reviewer's judgement).

Values that change over time — the Google Play target API level, Apple's minimum Xcode and SDK
for uploads, Android memory page-size requirements, the privacy-manifest required-reason API
list — are fetched from the official pages at review time and cited with the date checked. Never
rely on a remembered value. Starting URLs: the `global-compliance` skill's `official-sources.md`.

## 13. Android, iOS, and iPad behaviour

Android:

- Permissions: each `<uses-permission>` maps to a feature; requested in context with a
  rationale; denied, permanently denied, and revoked states handled; library-merged permissions
  the app does not need removed (`tools:node="remove"`).
- Notifications: `POST_NOTIFICATIONS` requested when a notifying feature is first enabled.
- Background work and foreground services: service type declared and justified; no service
  used to dodge background limits; exact alarms only with a feature that needs them.
- Edge-to-edge and insets; predictive back (`PopScope`); back closes sheets and dialogs first.
- Process death: state restored or safely reset; deep links on cold start.
- Large screens and foldables: resizable activity, no forced portrait without reason.

iOS:

- `Info.plist` purpose strings specific and accurate for every protected resource used.
- Background modes match real features; no mode kept only to stay alive.
- Entitlements match capabilities used (push, associated domains, Sign in with Apple, App Groups).
- Scene and lifecycle handling; state preserved across background and termination.

iPad:

- Supports the multitasking sizes the deployment target allows (Split View, Slide Over, Stage
  Manager), or full-screen is justified; all orientations unless justified.
- Layouts usable at narrow split widths and at full width; no stretched phone layout.
- Hardware keyboard (shortcuts, focus), pointer hover, and drag where natural.
- Popovers and sheets sized for large screens.

## 14. Privacy, permissions, data collection

- If `docs/compliance/` exists: compare it with the code — every collected data element, SDK, and
  permission in the app appears in `privacy-data-inventory.md`, and nothing is declared that the
  app does not do. Run the `global-compliance` skill's `--release-gate` for a release audit.
- If it does not exist: report the gap and recommend `/global-compliance`.
- Code evidence to gather: network endpoints and payloads (`lib/data`), analytics and crash
  SDKs in `pubspec.yaml`, iOS `PrivacyInfo.xcprivacy` presence and contents, Android manifest
  permissions after merge (`android/app/build/intermediates/merged_manifests/` only if a build
  exists — do not build just to check unless authorised).
- Account deletion: discoverable in the app, confirmed, deletes backend data and local data.
- Tracking: no advertising identifiers or cross-app tracking without the required consent and
  declarations.
- Children: if minors can use the app, the applicable restrictions are designed in.

## 15. Build, signing, release, store policies

- Versioning: `version:` in `pubspec.yaml` maps to `versionName`/`versionCode` and
  `CFBundleShortVersionString`/`CFBundleVersion`; build numbers increase and are never reused.
- Release configuration: production entrypoint and environment; no debug banners, bypass flags,
  test accounts, verbose logging, or seeded demo data.
- Signing: release keys and profiles outside the repository; Play App Signing; iOS signing
  through the team's managed process.
- Build: `flutter build appbundle --release` and `flutter build ipa --release` (with the
  production entrypoint) succeed — report as not run unless they ran.
- Obfuscation and symbols: if `--obfuscate` is used, `--split-debug-info` symbols are kept for
  crash symbolication (obfuscation is not a security control).
- Store metadata, screenshots (including iPad when supported), content rating, export
  compliance, privacy policy URL, reviewer notes and demo account.
- Never state that the app will be approved; state what was checked.
