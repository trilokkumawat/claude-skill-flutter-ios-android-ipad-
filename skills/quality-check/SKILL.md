---
name: quality-check
description: Report-first quality audit of a Flutter app across fifteen categories — architecture and dependency direction, graph cycles and coupling, feature boundaries, code quality, validation and errors, authentication and authorisation, secrets and logging, API security, dependencies, tests, performance and lifecycle, accessibility and responsive UI, Android/iOS/iPad behaviour, privacy and permissions, and release and store policy. Produces prioritised, evidence-labelled findings, then applies only approved fixes, each classified as a fix, a refinement, or a refactor. Use when asked to audit, review, check quality or release readiness, or to decide between refactoring and refining.
argument-hint: "[full | <path> | <feature>] [--report-only] [--categories 1,6,13]"
---

# Quality check

Load the `mobile-standards` skill first (in the plugin: `flutter-mobile-kit:mobile-standards`)
and follow its evidence labels, severity scale, and report rules. References for this skill
are in `${CLAUDE_SKILL_DIR}/references/`.

Arguments: `$ARGUMENTS` — scope (`full` by default, a path, or a feature name), `--report-only`
(stop after the report even if fixes are obvious), and an optional category list.

**Phases 1–3 are read-only. Nothing is fixed until the user approves specific findings.**

## Phase 1 — Scope and inventory (read-only)

1. Read the project's `CLAUDE.md`, `.claude/rules/`, project skills, `analysis_options.yaml`,
   CI workflows, and `docs/` (architecture, decisions, compliance). Note any documented
   "known gaps" — judge them as planned work, not as defects.
2. `git status` — note uncommitted work; the audit covers the working tree as it is.
3. Inventory: `pubspec.yaml` (SDK constraints, dependencies, overrides), `.fvmrc`, the `lib/` and
   `test/` trees (three levels), `android/` and `ios/` presence, flavours and entrypoints.
4. Determine the project's own gate commands (format, analyze, test, build). Prefix with `fvm`
   when the project pins its SDK with FVM.

## Phase 2 — Collect evidence (read-only)

Run what the environment supports and record each command's exact outcome:

| Check | Command |
|---|---|
| Formatting (no writes) | `dart format --output=none --set-exit-if-changed lib test` |
| Static analysis | `flutter analyze` |
| Tests in scope | `flutter test <dirs>` (per directory when large; writes build caches only) |
| Dependency freshness | `flutter pub outdated` |
| Dart import graph | `dart run <mobile-standards>/scripts/dart_import_graph.dart --root . --features-dir <dir> --forbid <rules>` |
| Graphify (if installed and authorised) | code-only, `GRAPHIFY_OUT` outside the repo — see mobile-standards `graph-analysis.md` |
| Scanners already installed (never install) | e.g. `osv-scanner`, `gitleaks` |

Then walk the categories in scope with their checklists:

| # | Category | Checklist |
|---|---|---|
| 1 | Architecture and dependency direction | [architecture-review.md](references/architecture-review.md) |
| 2 | Graph paths, cycles, coupling, impact | [architecture-review.md](references/architecture-review.md) |
| 3 | Feature boundaries and shared state | [architecture-review.md](references/architecture-review.md) |
| 4 | Code quality and maintainability | [architecture-review.md](references/architecture-review.md) |
| 5 | Input validation and error handling | [security-checklist.md](references/security-checklist.md) |
| 6 | Authentication and authorisation | [security-checklist.md](references/security-checklist.md) |
| 7 | Secrets, credentials, tokens, storage, logging | [security-checklist.md](references/security-checklist.md) |
| 8 | API and network security | [security-checklist.md](references/security-checklist.md) |
| 9 | Dependency risks and vulnerable packages | [security-checklist.md](references/security-checklist.md) |
| 10 | Unit, widget, integration, regression tests | [testing-checklist.md](references/testing-checklist.md) |
| 11 | Performance, lifecycle, memory | [ui-runtime-checklist.md](references/ui-runtime-checklist.md) |
| 12 | Accessibility and responsive UI | [ui-runtime-checklist.md](references/ui-runtime-checklist.md) |
| 13 | Android, iOS, and iPad behaviour | [platform-compliance.md](references/platform-compliance.md) |
| 14 | Privacy, permissions, data collection | [platform-compliance.md](references/platform-compliance.md) |
| 15 | Build, signing, release, store policies | [platform-compliance.md](references/platform-compliance.md) |

For categories 14–15: if `docs/compliance/` exists, use it and the `global-compliance` skill's
`--release-gate` mode; if it does not, report that no compliance assessment exists and recommend
running `/global-compliance`.

Use the `architecture-graph-specialist`, `testing-quality-specialist`, and
`release-compliance-specialist` subagents for large audits when available, with read-only
briefs (mobile-standards `agent-coordination.md`).

## Phase 3 — Report, then stop

Write the report with [report-template.md](references/report-template.md):

- Findings ranked Critical → High → Medium → Low, each with severity, evidence and `file:line`,
  impact, recommended fix, required tests, verification steps, confidence, and limitations.
- Separate sections for verified defects, recommendations, and suspected issues.
- Each finding classified for remediation as **Fix**, **Refine**, or **Refactor**
  ([refactor-vs-refine.md](references/refactor-vs-refine.md)).
- A "not checked" list naming every category or command that did not run, and why.

Then **stop** and ask which findings to remediate. With `--report-only`, stop without asking.

## Phase 4 — Remediate approved findings only

1. Order: Critical fixes → other fixes → refinements → refactors.
2. One concern per change. Never mix a refactor with a behaviour change in one change.
3. Refactors: characterization tests first on the `--impact` set, then small steps, each green;
   compare the import graph before and after.
4. Large remediations follow ownership rules (one owner per file; shared files coordinator-only).
5. Inspect each file and the current diff before editing; never overwrite unrelated work.

## Phase 5 — Verify and re-report

Re-run the project's gate and the checks that produced each finding. Update each finding's
outcome — **fixed**, **skipped** (why), or **no change needed** — and list every command run with
its result. Anything not re-verified is reported as unverified.

## Refactoring versus refining

When the user asks how refactoring differs from refining, or which one a change is, answer from
[refactor-vs-refine.md](references/refactor-vs-refine.md) and apply its decision rule to their
case.
