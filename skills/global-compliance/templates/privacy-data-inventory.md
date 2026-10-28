# Privacy and data inventory — <Project name>

Source of truth for privacy disclosures. The privacy policy, Apple privacy labels and privacy
manifest, and Google Play Data safety answers must match this inventory and the app's actual
behaviour.

## Personal data elements

| Data element | Category | Collected from | Purpose | Basis / consent (per market) | Required or optional | Stored where | Encrypted (transit / rest) | Retention | Deletion path | Shared with | Cross-border transfer | Apple label category | Google Data safety category | Matrix rows | Evidence |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| <email address> | <contact info> | <sign-up form> | <account, sign-in> | <contract / consent> | <required> | <backend DB, region> | <TLS / at rest> | <account lifetime + n days> | <in-app delete → backend job> | <auth provider> | <yes: region → region, mechanism> | <Contact Info> | <Personal info> | <CM-00n> | <test / config link> |

Categories to consider: identifiers, contact info, account credentials (never stored in plain
text), user content, usage data, diagnostics, device identifiers, precise or coarse location,
photos and media, audio, contacts, health, financial, children's data, inferred data.

## Third-party SDKs

| SDK | Version | Data it collects | Purpose | iOS privacy manifest present | Declared in Data safety | Initialised only after consent? | Allowed for children? | Matrix rows |
|---|---|---|---|---|---|---|---|---|
| <firebase_messaging> | <x.y.z> | <push token, …> | <notifications> | <yes / n/a> | <yes> | <n/a — essential> | <check> | <CM-00n> |

## Permissions

| Permission (Android / iOS) | Feature that needs it | When requested | Rationale shown | Denied behaviour | Store declaration needed |
|---|---|---|---|---|---|
| <POST_NOTIFICATIONS / notifications> | <reminders> | <first reminder enabled> | <yes> | <reminders off, banner to settings> | <no> |

## Verification

| Check | Method | Last done | Result |
|---|---|---|---|
| Disclosures match behaviour | Compare network traffic, SDK list, and this inventory | <date> | <result> |
| Deletion removes all user data | Integration test + backend evidence | <date> | <result> |
