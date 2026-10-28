# Agent coordination

## Who coordinates

The main session is the coordinator. Questions and approval gates stay with it — subagents
cannot ask the user anything. To run a whole session in the coordinator role, start Claude Code
with `claude --agent flutter-mobile-kit:project-coordinator`.

The coordinator owns: the task plan, cross-feature decisions, shared files, shared docs,
integration review, and final verification. Specialists never redefine shared architecture.

## Roster

| Agent | Owns | Typical paths |
|---|---|---|
| `product-requirements-specialist` | Requirements, user stories, journeys, metrics, acceptance criteria | `docs/product/` drafts |
| `mobile-architecture-specialist` | Boundaries, dependency direction, technical design, decision records | `docs/architecture/` drafts |
| `architecture-graph-specialist` | Graph builds and queries, cycles, coupling, change impact | read-only; graph output |
| `mobile-ui-specialist` | Design system, shared components, screens, states, accessibility | `lib/design_system/`, `lib/widgets/`, feature `presentation/` |
| `authentication-security-specialist` | Auth, sessions, tokens, secure storage, access control | auth feature, session and storage code |
| `api-data-specialist` | API clients, repositories, models, persistence, sync, error mapping | `lib/data/`, repository interfaces |
| `navigation-specialist` | Routes, guards, redirects, deep links | router files, route definitions |
| `testing-quality-specialist` | Unit, widget, integration tests; analysis; review findings | `test/`, `integration_test/` |
| `android-platform-specialist` | Manifest, Gradle, lifecycle, permissions, background work, Play readiness | `android/` |
| `ios-ipad-specialist` | `Info.plist`, entitlements, signing, iPad behaviour, App Store readiness | `ios/` |
| `release-compliance-specialist` | Release config, privacy declarations, store submission readiness | read-only; `docs/compliance/` drafts |

Feature agents (for example `task-management-specialist`) are created per project by
`/new-project` from its `feature-agent.md` template, after the user approves the feature list.

## Shared files — coordinator only

The app entrypoints and bootstrap, the router root, the DI / provider root, theme and design
tokens, `pubspec.yaml`, `analysis_options.yaml`, `AndroidManifest.xml`, Gradle files,
`Info.plist`, entitlements, CI workflows, `CLAUDE.md`, and shared docs. A specialist that needs a
change there returns a proposed diff; the coordinator applies it.

## Feature ownership contract

Every meaningful feature records (template: new-project `feature-ownership.md`):

feature name and scope · responsible agent or workstream · screens and app-flow nodes · state
owners · repository and API dependencies · models and persistence · security and authorisation
rules · acceptance criteria · tests · documentation and graph impact.

## Delegation brief

Every hand-off states:

```
Goal: <one sentence>
Owned paths (may edit): <list>
Read-only paths: <list>
Interfaces to honour: <signatures / contracts agreed before work starts>
Acceptance criteria: <testable list>
Tests to add or update: <list>
Do not: <shared files, other features, new dependencies without approval>
Return: files changed · evidence · commands run with results · open questions
```

## Parallel work

- Assign non-overlapping paths. Two agents never edit the same file.
- Agree and write down interfaces before concurrent implementation.
- Shared changes go through the coordinator.
- Do not merge one agent's unreviewed assumptions into another's work.
- After specialists return: review each diff, run the project's gate, review cross-feature
  integration, and run the relevant integration tests.

## When subagents are unavailable

Run the same named roles as sequential workstreams in the main session, keep the same ownership
rules, and say so in the report. Never claim agents ran in parallel when they did not.

## Specialist reply format

```
Summary: <what was done or found>
Files changed: <path — why> (or "none — read-only")
Evidence: <labelled findings>
Commands: <command → exit status, key output>
Open questions / risks: <list>
```
