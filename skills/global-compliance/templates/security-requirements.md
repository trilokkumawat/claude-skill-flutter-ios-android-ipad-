# Security requirements — <Project name>

Baseline controls apply to every app; market-specific rows come from the country matrix.
Reference standard for mobile controls: OWASP MASVS (a security practice, not law).

| ID | Requirement | Source (matrix row / MASVS / platform) | Control | Implementation task | Verification method | Evidence | Status |
|---|---|---|---|---|---|---|---|
| SR-001 | Secure authentication and session management | Baseline | Short-lived access token, rotating refresh token, serialized refresh, sign-out clears tokens | <TASK> | Unit tests for refresh and expiry; integration test for sign-out | <link> | <status> |
| SR-002 | Server-side authorisation | Baseline | Every endpoint checks the caller's rights; hidden UI is not a control | <TASK> | Backend tests per role; attempt forbidden calls | <link> | <status> |
| SR-003 | Input validation and safe errors | Baseline | Validate on client for UX and on server for safety; no raw exception text to users | <TASK> | Validator unit tests; error-state widget tests | <link> | <status> |
| SR-004 | Secure token and secret storage | Baseline | Platform secure storage for tokens; no secrets in the binary or repository | <TASK> | Code review; secret scan in CI | <link> | <status> |
| SR-005 | Transport security | Baseline | HTTPS only; no cleartext exceptions outside local development | <TASK> | Manifest / Info.plist review; network test | <link> | <status> |
| SR-006 | Least-privilege permissions | Baseline | Request only what a feature uses, when it is used | <TASK> | Permission audit; denied-path tests | <link> | <status> |
| SR-007 | Data minimisation and retention | Matrix | Collect only listed data; retention jobs | <TASK> | Data inventory review | <link> | <status> |
| SR-008 | Account and data deletion | Matrix / platform | In-app deletion, backend erasure, local wipe, web deletion link where required | <TASK> | End-to-end deletion test | <link> | <status> |
| SR-009 | Consent and privacy settings | Matrix | Purpose-specific consent; optional SDKs gated on consent | <TASK> | Widget + integration tests | <link> | <status> |
| SR-010 | Logs, analytics, crash reports | Baseline | No tokens or personal data in logs; PII-free events | <TASK> | Log review; CI grep for token prints | <link> | <status> |
| SR-011 | Third-party SDK review | Baseline | Each SDK's data, permissions, and privacy manifest reviewed before adding | <TASK> | SDK table in data inventory | <link> | <status> |
| SR-012 | Environment separation | Baseline | Separate dev / staging / prod backends and IDs; release refuses non-prod config | <TASK> | Build-config test; release artefact check | <link> | <status> |
