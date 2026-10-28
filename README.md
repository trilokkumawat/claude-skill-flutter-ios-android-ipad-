# flutter-mobile-kit

A Claude Code plugin for building and maintaining Flutter apps on Android phones, iPhones, and
iPads: staged product discovery, country-by-country compliance, premium mobile UI, report-first
quality checks, architecture analysis with Graphify and a Dart import analyser, and named
specialist subagents.

It prefers each project's existing conventions over its own defaults, never jumps straight to
code, and never commits, pushes, or installs anything without your approval.

## What is inside

| Skill | Command | Purpose |
|---|---|---|
| [new-project](skills/new-project/SKILL.md) | `/new-project` | Staged planning with three approval gates: identity and target markets → requirements → compliance → technical decisions → app flow → architecture → graph baseline → implementation plan and feature agents |
| [global-compliance](skills/global-compliance/SKILL.md) | `/global-compliance` | Target countries, privacy, children, payments, AI, accessibility, cross-border data, Apple and Google policies — verified against official sources, recorded in `docs/compliance/`, with a release gate. Invoked automatically by `/new-project` |
| [mobile-ui](skills/mobile-ui/SKILL.md) | `/mobile-ui` | Design system, components, and screens with every state, adaptive layouts, accessibility, dark mode, platform conventions |
| [quality-check](skills/quality-check/SKILL.md) | `/quality-check` | Report-first audit across fifteen categories; approved fixes classified as fix, refinement, or refactor |
| [mobile-standards](skills/mobile-standards/SKILL.md) | (hidden) | Shared rules every skill and agent loads: repository safety, secrets, evidence labels, graph analysis, agent coordination, definition of done |

| Agent | Role |
|---|---|
| [project-coordinator](agents/project-coordinator.md) | Plans, assigns bounded tasks, owns shared files, integrates, verifies |
| [product-requirements-specialist](agents/product-requirements-specialist.md) | Requirements, stories, metrics, acceptance criteria (read-only) |
| [mobile-architecture-specialist](agents/mobile-architecture-specialist.md) | Boundaries, dependency direction, decision records (read-only) |
| [architecture-graph-specialist](agents/architecture-graph-specialist.md) | Graph queries, cycles, coupling, change impact (read-only on source) |
| [mobile-ui-specialist](agents/mobile-ui-specialist.md) | Design system, components, screens |
| [authentication-security-specialist](agents/authentication-security-specialist.md) | Auth, sessions, tokens, secure storage, access control |
| [api-data-specialist](agents/api-data-specialist.md) | API clients, repositories, models, persistence, sync |
| [navigation-specialist](agents/navigation-specialist.md) | Routes, guards, redirects, deep links |
| [testing-quality-specialist](agents/testing-quality-specialist.md) | Unit, widget, integration tests; analysis |
| [android-platform-specialist](agents/android-platform-specialist.md) | Manifest, Gradle, permissions, background work, Play readiness |
| [ios-ipad-specialist](agents/ios-ipad-specialist.md) | Info.plist, entitlements, iPad behaviour, App Store readiness |
| [release-compliance-specialist](agents/release-compliance-specialist.md) | Release configuration, declarations vs behaviour, release gate (read-only) |

Feature-specific agents (for example `task-management-specialist`) are not shipped: `/new-project`
generates them into each project's `.claude/agents/` from a template once you approve the
feature list.

## Install

The repository is both the plugin and its marketplace (`trilok-mobile`).

**From GitHub**, inside a Claude Code session:

```text
/plugin marketplace add trilokkumawat/claude-skill-flutter-ios-android-ipad-
/plugin install flutter-mobile-kit@trilok-mobile
```

Or from a terminal with the Claude Code CLI:

```bash
claude plugin marketplace add trilokkumawat/claude-skill-flutter-ios-android-ipad-
```

```bash
claude plugin install flutter-mobile-kit@trilok-mobile
```

- **Every project on this machine** — the default user scope.
- **One project, shared with the team** — add `--scope project`; it records the plugin in that
  project's `.claude/settings.json`, and each teammate runs the same install command.
- **Try a local checkout without installing** — `claude --plugin-dir <path-to-this-repo>`, then
  `/reload-plugins` after edits. A `--plugin-dir` plugin replaces an installed one with the same
  name for that session.

Manage, update, or remove it from `/plugin` (Installed tab). Plugins installed on your machine
do not load in cloud sessions.

## Use

Commands work by their short name unless another command already uses it; the namespaced form
always works (for example `/flutter-mobile-kit:new-project`).

```text
/new-project                          start planning; the first question is the target market
/new-project "Habit Coach" --prototype
/new-project --existing               take over an app that already exists
/global-compliance "India, European Union"
/global-compliance --reassess         after markets, SDKs, data, or features change
/global-compliance --release-gate     before a store submission
/mobile-ui screen S-21                build a screen from its app-flow entry
/mobile-ui design-system              create or extend tokens and the theme
/mobile-ui review lib/features/tasks  UI review only, no edits
/quality-check                        full report, then asks which findings to fix
/quality-check lib/features/auth --report-only
/quality-check full --categories 6,7,8
```

Agents: ask in plain language ("use the architecture-graph-specialist to find cycles"),
mention one (`@agent-flutter-mobile-kit:architecture-graph-specialist`), or run a whole session
as the coordinator: `claude --agent flutter-mobile-kit:project-coordinator`.

## How `/new-project` works

| Stage | Output | Gate |
|---|---|---|
| A. Identity, market, shape | Target countries (asked first), platforms, project shape, users | |
| B. Requirements | PRD draft | |
| B2. Global compliance | Compliance matrix and open issues | **1** — writes `docs/product/prd.md`, `docs/compliance/*` |
| C–F. Technical, flow, architecture, graph | Decisions, screen inventory, folder structure, boundary rules | **2** — writes flow and architecture docs |
| G. Plan and setup | Implementation order, ownership, feature agents, setup steps | **3** — repository setup and code |

Nothing is written before Gate 1 and no code before Gate 3. It never assumes a market from your
location, never invents metric baselines, and marks every proposed target as needing approval.

## Global compliance

Builds a per-country matrix from the app's features, users, business model, and data — applying
only what is relevant — and verifies each significant requirement against an official source
with its URL and the date checked. Each row is typed (legal obligation, platform policy, security
practice, open interpretation) and given a status (Confirmed, Conditional, Needs Review, Not
Applicable). It writes six documents: `country-matrix.md`, `privacy-data-inventory.md`,
`security-requirements.md`, `app-store-checklist.md`, `release-gate.md`, `open-issues.md`.

It is not legal advice: material legal questions are escalated for qualified counsel, and it
never states that an app is compliant or will be approved.

## Refactoring versus refining

| | Refactoring | Refining |
|---|---|---|
| Behaviour | Identical | Small, intended, documented improvement |
| Scope | Across files, layers, or interfaces | Inside one file or widget |
| Dependency graph | Edges move | No edge changes |
| Tests | Characterization tests first, green before and after | A test for the improvement |
| Review | Architecture review | Normal review |

`/quality-check` classifies every remediation this way and never mixes the two in one change.
Full comparison, decision rule, and Flutter examples:
[refactor-vs-refine.md](skills/quality-check/references/refactor-vs-refine.md).

## Architecture analysis

**Dart import analyser** (ships with the kit; read-only; needs only a Dart 3 SDK):

```bash
dart run skills/mobile-standards/scripts/dart_import_graph.dart --root <project> \
  --features-dir lib/features --forbid lib/domain:lib/data --impact lib/core/session.dart
```

It reports cycles with every edge's `file:line`, cross-feature and forbidden-direction imports,
fan-in and fan-out hubs, unresolved imports, external package use, and the tests affected by a
change. `--format json` and `--fail-on-cycles` suit CI.

**Graphify** ([official repository](https://github.com/Graphify-Labs/graphify)) adds the native
Android and iOS side. Its code-only parser does not read Dart (checked at 0.9.97), so the Dart
analyser carries the Flutter analysis. Install it only if you want it, pinned:

```bash
uv tool install graphifyy==0.9.97
```

uv itself comes from Homebrew (`brew install uv`) or Astral's official installer; on some Intel
Macs Homebrew has no prebuilt uv. The kit runs Graphify locally with
`GRAPHIFY_BACKEND=none GRAPHIFY_QUERY_LOG_DISABLE=1` and `--code-only`, keeps `graphify-out/` out
of git, and does not run `graphify install` at user level, because that registers hooks in every
project. Details: [graph-analysis.md](skills/mobile-standards/references/graph-analysis.md) and
[graphify-workflow.md](skills/new-project/references/graphify-workflow.md).

## Safety model

- Report first; edits only inside the approved scope; unrelated work preserved.
- No git writes unless you ask; never force-push or rewrite history.
- No installs, dependency additions, or configuration changes without approval.
- Secrets are never read or printed; values compiled into an app are treated as public.
- Every finding is labelled Verified, Graph-derived, or Hypothesis; unrun checks are reported as
  not run.
- The kit ships no hooks, MCP servers, or pre-approved tools. Review-only agents have no edit
  tools; agents with shell access still go through your permission prompts.

## Develop and validate

```bash
dart run scripts/check_kit.dart
```

The self-check validates both manifests, skill and agent frontmatter (keys, names, YAML-safe
values, preloaded skills), links, `${CLAUDE_SKILL_DIR}` paths, `SKILL.md` length, and scans for
secrets, emails, local paths, and project-specific names; then it runs the Dart analyser on
[the fixture app](tests/fixtures/sample_app) and compares the result with `expected.json`.
With the Claude Code CLI available, also run `claude plugin validate . --strict`.

## Layout

```text
.claude-plugin/        plugin.json, marketplace.json
skills/
  new-project/         SKILL.md, references/, templates/
  global-compliance/   SKILL.md, references/, templates/
  mobile-ui/           SKILL.md, references/
  quality-check/       SKILL.md, references/
  mobile-standards/    SKILL.md, references/, scripts/, templates/
agents/                12 subagents
scripts/check_kit.dart
tests/fixtures/sample_app/
```

## Limitations

- Delegating from a skill to a named plugin agent, and preloading plugin skills into plugin
  agents, are not documented by Claude Code; agents fall back to invoking the skill themselves.
- Plugin agents ignore `permissionMode`, so read-only roles are enforced by their tool lists and
  your permission prompts, not by a plan mode.
- Store policies and laws change: the skills fetch and date-stamp them at review time rather than
  embedding values.

## License

[MIT](LICENSE)
