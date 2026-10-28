---
name: new-project
description: Plan and set up a new Flutter app, or take over an existing one, in approved stages — project identity, target countries and platforms, product requirements, global compliance, technical decisions, app flow and screen inventory, architecture and folder structure, an architecture-graph baseline, and an implementation plan with specialist agents. Never jumps straight to code. Use when starting a new mobile app, adding an app to a monorepo, or onboarding an existing app for planned work.
argument-hint: "[project name] [--prototype] [--existing]"
disable-model-invocation: true
---

# New project

Load the `mobile-standards` skill first (in the plugin: `flutter-mobile-kit:mobile-standards`).
References for this skill are in `${CLAUDE_SKILL_DIR}/references/`, templates in
`${CLAUDE_SKILL_DIR}/templates/`.

Arguments: `$ARGUMENTS` — an optional project name (reuse it; never ask again), `--prototype`
for quick-prototype mode, `--existing` to force existing-project mode.

**This workflow never jumps into code.** Nothing in the project is created or modified before
Gate 1, and no code is written before Gate 3. Each gate needs the user's explicit approval.

| Stage | Produces | Gate |
|---|---|---|
| A. Identity, market, shape | Name, target countries, platforms, project shape, users | — |
| B. Product requirements | PRD draft | — |
| B2. Global compliance (automatic) | Compliance matrix and open issues draft | **Gate 1** — writes `docs/product/prd.md` and `docs/compliance/*` |
| C. Technical requirements | Decisions with trade-offs | — |
| D. App flow and screens | Flow diagram and screen inventory | — |
| E. Architecture and folders | Architecture doc and decision records | — |
| F. Architecture graph | Boundary rules; baseline or findings | **Gate 2** — writes flow and architecture docs |
| G. Plan and setup | Implementation order, ownership, agents, setup steps | **Gate 3** — repository setup and code |

## Stage A — Identity, market, and shape

Infer what the request and the repository already show and state it; ask only what is missing,
in one grouped round (use the question tool when available — up to four questions per round).
**Ask the target market first:**

1. **Target market** (multi-select): India only · United States only · specific countries (list)
   · multiple countries or worldwide · not decided yet. Never assume a market from the developer's
   location, the device locale, or the conversation's language.
2. **Platforms** (multi-select): Android · iPhone · iPad · web · desktop.
3. **Shape**: one mobile app · several separate apps · a monorepo with apps and packages; new
   project or an existing app.
4. **Intended users**: adults · children (which ages) · businesses · mixed.

Then, only if still unknown: project name (optional — offer to skip and use a working name),
purpose and core requirements, features touching sensitive areas (authentication, payments,
subscriptions, location, camera, contacts, health, financial data, AI, advertising, user
content), and any decided backend, authentication, or stack.

**Existing app** (`pubspec.yaml` present, or `--existing`): run the read-only inventory in
[technical-architecture.md](references/technical-architecture.md) and the Stage F graph
analysis first; reconstruct requirements marked *inferred*; ask only about gaps.

**Monorepo**: propose Dart pub workspaces or Melos only when several apps or packages genuinely
need to share code — and never where the project's rules forbid it.

## Stage B — Product requirements

Follow [product-discovery.md](references/product-discovery.md) and fill
[prd.md](templates/prd.md): product overview · goals and objectives · functional requirements ·
non-functional requirements · user experience · success metrics · constraints and acceptance
criteria.

- Short grouped question rounds, never a giant questionnaire.
- Success metrics: baseline is "unknown" unless the user gives one; every target is marked
  *Proposed — needs approval*. Never present a hypothetical target as a commitment.
- Every important feature gets testable acceptance criteria.

## Stage B2 — Global compliance (always runs)

As soon as markets and platforms are confirmed — or the user says the market is not decided —
invoke the `global-compliance` skill (in the plugin: `flutter-mobile-kit:global-compliance`) with
the markets, users, features, business model, and processors gathered so far. Do not skip it and
do not assume a default country. Add the requirements it produces (account deletion, consent,
age gate, disclosures, …) to the PRD's functional requirements with their matrix row IDs.

## Gate 1 — Requirements and compliance

Present the PRD summary, assumptions, proposed metrics, the compliance matrix summary, and the
open legal and policy questions. Ask for approval to write `docs/product/prd.md` and the six
`docs/compliance/` files. Write nothing else. Loop on requested changes.

## Stage C — Technical requirements

Follow [technical-architecture.md](references/technical-architecture.md). For each decision —
language and framework, app and backend architecture, state management, navigation, API and
networking, persistence, dependency injection, authentication and authorisation, validation,
error handling and observability, environments, flavours, testing and CI, version control and
release — give the recommendation, the alternatives, and the trade-off. Inspect the pinned
Flutter and Dart versions (FVM, `.fvmrc`) and existing conventions. Propose a package only when a
requirement justifies it.

## Stage D — App flow and screen inventory

Follow [app-flow.md](references/app-flow.md) and fill [app-flow.md](templates/app-flow.md): entry
point → authentication or onboarding → main navigation → feature screens → actions → success
and error states, with a Mermaid diagram and one inventory row per screen (ID, purpose, entry,
exits, actions, state, data dependencies, states, auth, accessibility). Do not build UI to fill
the inventory.

## Stage E — Architecture and folder structure

Fill [architecture.md](templates/architecture.md): the folder tree, responsibilities, dependency
direction, navigation ownership, state ownership, repository and API boundaries, shared UI and
design-system boundaries, feature dependency rules, testing locations, and configuration
ownership. Match complexity to the product — do not force clean architecture onto a prototype;
explain the trade-off. Record consequential choices as decision records ([adr.md](templates/adr.md)).

## Stage F — Architecture graph

Follow [graphify-workflow.md](references/graphify-workflow.md) and mobile-standards
`graph-analysis.md`. New project: express the feature dependency rules as `--forbid` rules for
the Dart import analyser and plan a baseline right after scaffolding. Existing project: with
authorisation, run the analyser (and Graphify for native code) now; feed cycles, hubs, and
boundary breaches into Stage E.

## Gate 2 — Technical plan

Present Stages C–F. Where alternatives have material consequences, ask the user to choose.
On approval, write `docs/product/app-flow.md`, `docs/architecture/architecture.md`, and
`docs/architecture/decisions/`.

## Stage G — Implementation plan and setup

Summarise: approved requirements · technical decisions · app flow and screens · architecture ·
security model (compliance `security-requirements.md` plus the auth design) · test plan · feature
implementation order · subagents and task boundaries.

- Fill [feature-ownership.md](templates/feature-ownership.md) for every meaningful feature.
- Propose feature agents by stable kebab-case name (for example `task-management-specialist`);
  on approval, generate each into the project's `.claude/agents/` from
  [feature-agent.md](templates/feature-agent.md). Do not create an agent per widget.
- List each setup step from [project-setup.md](references/project-setup.md) (create, FVM pin,
  flavours, CI, packages) for approval; nothing is installed or initialised without it.

## Gate 3 — Implementation

On approval, implement in small, verifiable increments — scaffold → design-system base →
navigation shell → authentication → features in the approved order. After each increment: tests,
the project's gate, the import-graph check, a compliance reassessment when data, permissions,
SDKs, or markets changed, and a short report. Coordinate with mobile-standards
`agent-coordination.md`.

## Quick-prototype mode

With `--prototype` or when the user asks for a quick prototype: use explicit assumptions for
non-critical choices (record them in an Assumptions table), keep the market question and a light
compliance screening, and still wait for Gate 1 before writing files. Never assume consequential
security, privacy, financial, or architectural decisions.

## Later changes

When requirements, target countries, SDKs, data collection, or major features change, run
`global-compliance --reassess` and update the affected docs before implementing.
