# Product requirements — <Project name>

| Field | Value |
|---|---|
| Status | Draft · Approved (Gate 1, <YYYY-MM-DD>) |
| Target markets | <from the compliance matrix> |
| Platforms | <Android · iPhone · iPad · …> |
| Owner | <name> |

## 1. Product overview

- **Description:** <one line>
- **Problem:** <what hurts, for whom>
- **Audience:** <primary and secondary users>
- **Context of use:** <where, when, device, frequency>
- **Value proposition:** <why this over the alternative>

## 2. Goals and objectives

- **Product / business goals:** <list>
- **User outcomes:** <list>
- **MVP objectives:** <list>
- **Long-term objectives:** <list, if relevant>

| In scope (MVP) | Out of scope |
|---|---|
| <item> | <item> |

## 3. Functional requirements

| ID | Feature | Priority | User story | Compliance rows |
|---|---|---|---|---|
| FR-01 | <feature> | Must | As a <role>, I want <capability> so that <outcome> | <CM-00n or —> |

**Roles and permissions** (enforced on the server):

| Action | <Role A> | <Role B> |
|---|---|---|
| <action> | ✓ | — |

**Core workflows:** <numbered steps per workflow>

**Authentication and accounts:** <sign-up, sign-in methods, recovery, sign-out, deletion>

**Integrations:** <system — direction — data — failure behaviour>

**Notifications:** <trigger — channel — opt-in point>

**Offline and background:** <what works offline, what queues, background work and why>

**Edge cases:** <list>

## 4. Non-functional requirements

| Area | Requirement |
|---|---|
| Performance | <startup, scrolling, list sizes> |
| Reliability | <crash-free target (proposed), recovery> |
| Security and privacy | <link to docs/compliance/security-requirements.md> |
| Accessibility | <WCAG 2.2 AA; 200% text; screen readers> |
| Maintainability | <architecture doc, tests, CI> |
| Scalability | <expected users, data growth> |
| Supported devices | <min Android API, min iOS, iPad support> |
| Offline | <behaviour and recovery> |

## 5. User experience

- **Journeys:** <list>
- **Navigation model:** <tabs / stack / rail on large screens>
- **Screens:** see `docs/product/app-flow.md`
- **Onboarding and recovery:** <summary>
- **Platform patterns:** <iOS / Android / iPad notes>

## 6. Success metrics

| Metric | What is measured | Baseline | Target | Method | Horizon |
|---|---|---|---|---|---|
| <metric> | <definition> | Unknown | *Proposed — needs approval* | <how> | <period> |

## 7. Constraints and acceptance criteria

- **Budget / timeline:** <if provided>
- **Existing systems:** <list>
- **Technical constraints:** <list>
- **Regulatory constraints:** <link to the country matrix>
- **Definition of done:** <adapted from the kit's definition of done>

### Acceptance criteria

```
FR-01 <feature>
  Given <context>
  When <action>
  Then <outcome>
  And <edge or failure outcome>
```

## Assumptions

| ID | Assumption | Impact if wrong | Confirm by |
|---|---|---|---|
| A-01 | <assumption> | <impact> | <who / when> |
