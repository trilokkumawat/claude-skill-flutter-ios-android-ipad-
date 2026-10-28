# Regional behaviour in one app

Implement a difference between markets only when a matrix row (an applicable requirement) or a
recorded product decision justifies it. Every regional branch names that row ID.

## Market context — where the jurisdiction comes from

| Signal | Use |
|---|---|
| Account country chosen or confirmed at sign-up, stored on the backend | Primary source |
| Store country from purchase receipts, billing country | Corroboration for payments rules |
| Server-side configuration per account | Authoritative switch for restrictions |
| Device region or locale | A hint for defaults only — never the legal jurisdiction |
| Device language | Only for the UI language |
| IP geolocation | A hint; it is personal data itself and unreliable with VPNs — avoid unless justified |

The backend enforces restrictions; the app mirrors them in the UI. A hidden button is never the
boundary.

## Flutter shape

```
lib/domain/market/
  market_context.dart        // market code, applicable regime IDs, resolved once per session
  market_policy.dart         // abstract: consent purposes, minimum age, allowed features, disclosures
lib/data/market/
  market_repository_impl.dart // reads the account's market from the backend, caches it
lib/<policies>/
  eu_market_policy.dart, in_market_policy.dart, us_market_policy.dart, default_market_policy.dart
```

- Features ask the injected `MarketPolicy` ("is AI chat allowed?", "which consents are
  needed?"). No `if (country == 'XX')` scattered through widgets.
- Unknown or unresolved market → the most protective policy, not the most permissive.
- Policies are pure Dart and unit-tested; each method's doc comment cites its matrix row ID.

## Consent

- Purpose-specific and unbundled; never pre-ticked; as easy to withdraw as to give.
- Initialise analytics, advertising, and other optional SDKs only after the consent their purpose
  requires; test that they stay uninitialised before it.
- Record consent server-side with the policy version, purposes, and timestamp when the backend
  needs proof.
- Show a privacy-settings screen where the user can review and change choices.

## Disclosures and language

- Legal texts (privacy policy, terms, subscription terms) are versioned per market and language
  and reviewed by a person; do not machine-translate legal text without review.
- UI strings go through the project's localisation setup (`flutter gen-l10n` / `intl`).
- Show market-specific disclosures (e.g. auto-renewal terms) exactly where the applicable rule
  requires — next to the action, not only in a policy page.

## Payments, age, and data residency

- Digital goods use store billing; any alternative billing exists only where a store programme
  and the matrix allow it.
- Age gates are neutral (no default birth year that passes the gate) and the threshold comes from
  the market policy.
- Hosting region and processor locations are backend configuration, recorded in the data
  inventory.

## Tests

- Unit: each `MarketPolicy` method, including the unknown-market fallback.
- Widget: consent screens per market (default state, accept, decline, withdraw), age gate,
  disclosures present next to the purchase action.
- Integration: account deletion end-to-end; permission denied and revoked paths; optional SDKs
  not initialised before consent; switching the market context in a test build changes behaviour
  as the matrix says.
- Each test name references the matrix row it proves, and the row's evidence column links back.
