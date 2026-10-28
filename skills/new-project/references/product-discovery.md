# Product discovery

Infer first, ask second. Read the request, any briefs or links the user gave, and (for an
existing app) the repository. Each question round has a handful of grouped questions with
suggested answers the user can accept.

## 1. Product overview

Capture: name and one-line description · the problem · target audience · context of use (where,
when, on which device, how often) · value proposition.

Ask only if unclear: "Who has this problem most acutely, and what do they do today instead?"

## 2. Goals and objectives

Capture: business or product goals · user outcomes · scope and boundaries (in scope / out of
scope) · MVP objectives · long-term objectives when relevant.

Write scope as two explicit lists. Anything not in "in scope" is out for the MVP.

## 3. Functional requirements

| Capture | Format |
|---|---|
| Features | Grouped by area, each with a priority (Must / Should / Could) |
| User stories | "As a <role>, I want <capability> so that <outcome>" |
| Roles and permissions | Matrix of role × action, enforced on the server |
| Core workflows | Numbered steps from trigger to outcome |
| Authentication and accounts | Sign-up, sign-in methods, recovery, sign-out, account deletion |
| Integrations | Each external system, direction, data, failure behaviour |
| Notifications | Trigger, channel (push, local, email), opt-in point |
| Offline and background | What works offline, what queues, what runs in background and why |
| Edge cases | Empty data, conflicts, duplicates, limits, time zones, interrupted flows |

Compliance-driven requirements from the global-compliance skill are added here with their
matrix row IDs.

## 4. Non-functional requirements

Performance (startup, frame rate, list sizes) · reliability (crash-free target, retry and
recovery) · security and privacy · accessibility (WCAG 2.2 AA as the default target) ·
maintainability · scalability · supported devices and OS versions (minimum Android API level and
iOS version — decide with the user; check the current Flutter support table) · offline behaviour
and recovery.

## 5. User experience

Target journeys · navigation model (tabs, stack, drawer, rail on large screens) · screen
inventory (Stage D) · screen states and transitions · onboarding and error recovery ·
accessibility needs · platform-specific patterns (iOS, Android, iPad).

## 6. Success metrics

| Metric | What is measured | Baseline | Target | Method | Time horizon |
|---|---|---|---|---|---|
| Activation rate | New users completing <first key action> within 24 h | Unknown | *Proposed — needs approval* | Analytics event (declared in the data inventory) | First 90 days |
| Task completion rate | % of started <core workflow> completed | Unknown | *Proposed* | Funnel events | Per release |
| Crash-free sessions | Sessions without a crash | Unknown | *Proposed* | Crash reporting (declared) | Rolling 28 days |
| D7 / D30 retention | Users active 7 / 30 days after install | Unknown | *Proposed* | Analytics cohorts | Per cohort |

Rules: never invent a baseline; mark every target as proposed until the user approves it; every
metric that needs analytics or crash reporting adds an SDK and data-collection item to the
compliance inventory.

## 7. Constraints and acceptance criteria

Capture: budget and timeline when given · existing systems · technical constraints · regulatory
constraints (from the compliance matrix) · definition of done (mobile-standards
`definition-of-done.md`, adapted).

Acceptance criteria per important feature, testable:

```
Feature: <name>
  Given <context>
  When <action>
  Then <observable outcome>
  And <edge case or failure outcome>
```

## Question round template

```
To shape the requirements I need a few answers (suggested defaults in brackets):
1. <question> [<default>]
2. <question> [<default>]
3. <question> [<default>]
Anything you skip, I'll treat as the default and list under Assumptions.
```
