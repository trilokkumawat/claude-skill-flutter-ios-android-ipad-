---
name: global-compliance
description: Country-by-country compliance assessment for a mobile app — target markets, privacy and data protection, children, consumer and subscription rules, payments, location, accessibility, AI disclosures, sector rules, cross-border data, and Apple App Store and Google Play policies — verified against official sources and recorded in docs/compliance/. Use when a new mobile app is being planned (new-project invokes it), when target countries, features, SDKs, or data collection change, or before a store release.
argument-hint: "[countries] [--reassess | --release-gate]"
---

# Global compliance

This skill organises compliance research and engineering work. **It is not legal advice.**
Material legal questions are escalated for review by qualified counsel, never answered by
assumption.

Before starting, load the `mobile-standards` skill (in the plugin:
`flutter-mobile-kit:mobile-standards`) and follow its evidence and reporting rules. References
for this skill are in `${CLAUDE_SKILL_DIR}/references/`, templates in
`${CLAUDE_SKILL_DIR}/templates/`.

Arguments: `$ARGUMENTS` — optional target countries, `--reassess`, or `--release-gate`.

## First action: target markets

If the target market is not already confirmed in this conversation or in
`docs/compliance/country-matrix.md`, ask for it first (multi-select allowed):

- India only
- United States only
- Specific other countries (list them)
- Multiple countries / worldwide (list the priority markets)
- Not decided yet

**Never assume a market from the developer's location, the device locale, or the language of
the conversation.** If the answer is "Not decided yet", continue gathering requirements, keep
every status at most **Needs Review**, and record the open market decision in
`open-issues.md` as blocking for release.

## Inputs (ask only what is missing, grouped in one round)

1. Target countries or regions (required) and platforms (Android, iOS, both).
2. Intended users: adults, children (which ages), businesses, or mixed.
3. Features touching regulated areas: accounts, payments, subscriptions, advertising, location
   (foreground / background), camera or photos, microphone, contacts, health data, financial
   data, AI features, user-generated content or messaging, analytics or crash reporting,
   notifications, biometrics.
4. Business model: free, paid, subscription, in-app purchases, ads, B2B.
5. Backend, auth provider, hosting region, and third-party SDKs, if decided.
6. Sector: health, finance, education, e-commerce, or another regulated area.

Infer what the request and repository already show (`pubspec.yaml` packages, manifests,
`Info.plist`, existing privacy docs) and state each inference.

## Workflow

1. **Screen applicability** — map features, users, model, data, and markets to requirement
   areas with [applicability-screening.md](references/applicability-screening.md). Do not apply
   every regulation to every app.
2. **Verify current rules** — follow [official-sources.md](references/official-sources.md). For
   each significant requirement record: country or region · law, regulation, or policy · official
   source URL and date checked · whether it applies and why · effective date or transition (as
   stated by the source) · required app changes · required backend changes · tests and evidence ·
   status · type.
3. **Inventory personal data** — every data element, purpose, basis or consent, storage,
   processors and SDKs, retention, deletion path, transfers, and store-disclosure mapping.
4. **Derive security requirements** — map each applicable requirement and the baseline controls
   to an implementation task and a verification method.
5. **Platform checklist** — Apple App Store and Google Play items that apply to these features.
6. **Regional behaviour** — where markets differ, design it with
   [regional-behavior.md](references/regional-behavior.md): a reliable market context, policy
   objects, consent-gated SDKs, and tests per market.
7. **Present** the matrix summary, required changes mapped to tasks, and unresolved questions.
   **Wait for approval before writing files.** When invoked from `/new-project`, its Gate 1
   approval covers writing the compliance docs.
8. **Write or update** the six documents from the templates:

| File | Template |
|---|---|
| `docs/compliance/country-matrix.md` | [country-matrix.md](templates/country-matrix.md) |
| `docs/compliance/privacy-data-inventory.md` | [privacy-data-inventory.md](templates/privacy-data-inventory.md) |
| `docs/compliance/security-requirements.md` | [security-requirements.md](templates/security-requirements.md) |
| `docs/compliance/app-store-checklist.md` | [app-store-checklist.md](templates/app-store-checklist.md) |
| `docs/compliance/release-gate.md` | [release-gate.md](templates/release-gate.md) |
| `docs/compliance/open-issues.md` | [open-issues.md](templates/open-issues.md) |

Never overwrite existing compliance documents or project instructions wholesale: update rows,
keep history in the change log section, and show the diff in the report.

## Classification

**Status** — `Confirmed` (applies, verified against an official source) · `Conditional`
(applies only if a stated condition holds, e.g. "if users under 13 are admitted") ·
`Needs Review` (unverified, ambiguous, or awaiting counsel or a product decision) ·
`Not Applicable` (with the reason).

**Type** — `Legal obligation` · `Platform policy` · `Security practice` (a standard such as
OWASP MASVS, not law) · `Open interpretation` (legal meaning unsettled — escalate).

## Rules

- Never invent a regulation, deadline, threshold, or requirement. No effective date without a
  source. Unknown is recorded as Needs Review.
- Distinguish legal obligations from platform policies, security practices, and unresolved
  interpretations in every table.
- Country-specific behaviour only where an applicable requirement or a product decision justifies
  it; never an artificial regional restriction without a documented reason (a matrix row ID).
- Collect only data a user-facing feature needs; request only permissions a feature uses.
- A requirement is complete only with verification evidence (a test, a screenshot, a config
  diff, a store-console record).

## Modes

- **Initial assessment** (default) — the workflow above.
- **`--reassess`** — run when requirements, target countries, SDKs, data collection, or major
  features change: diff the change against the existing docs, update statuses, add open issues,
  and list which tasks and tests the change triggers.
- **`--release-gate`** — evaluate `docs/compliance/release-gate.md` with evidence:
  1. Run the project's format, analyze, and relevant tests (unit, widget, integration, end-to-end).
  2. Confirm tests exist and pass for consent, permissions, data deletion, authorisation, and
     regional behaviour where applicable.
  3. Verify privacy disclosures (privacy policy, Apple privacy labels and privacy manifest, Google
     Data safety) against actual app, backend, and SDK behaviour.
  4. Re-check current Apple and Google requirements for this release (date-stamped).
  5. Record unresolved legal, privacy, security, and policy issues.

  Verdict: **Blocked** when a Critical security issue or a Confirmed mandatory requirement is
  unresolved · **Ready with open items** (non-blocking items listed with owners) · **Ready**.
  Never state that the app is compliant or will be approved; state what was checked.
