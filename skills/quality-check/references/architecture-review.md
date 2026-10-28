# Architecture review — categories 1 to 4

Judge against the project's documented architecture first, then against general principles. A
project that deliberately chose fewer layers is not defective for lacking more.

## 1. Architecture and dependency direction

- Identify the actual layers (presentation, state, domain or use cases, repositories, data
  sources, platform). Record them before judging.
- Dependency direction points inward: widgets → state owners → (use cases) → repository
  interfaces ← implementations → data sources. Check internal directions with the Dart
  analyser's `--forbid` rules (for example `--forbid lib/domain:lib/data`), and framework leaks
  into pure layers with grep (for example `grep -rn "package:flutter" lib/domain`).
- Red flags: a widget importing an API client, `http`, `Dio`, or a database; a repository
  importing a widget or `BuildContext`; navigation called from a state owner
  (`context.go` / `Navigator` inside a notifier or bloc); DTOs leaking into widgets.
- Severity: Medium by default; High when it blocks testing of a core flow or causes defects.

## 2. Graph paths, cycles, coupling, impact

Follow mobile-standards `graph-analysis.md`:

- Run the Dart import-graph analyser; add Graphify for the native side when installed and
  authorised.
- Report every cycle with its full path and `file:line` edges, classified cross-feature,
  cross-layer, or local.
- Report hubs: top fan-in × fan-out files. For each: dependency direction, mixed
  responsibilities, blast radius (`--impact` counts), candidate extraction boundary.
- For each refactoring recommendation: finding and severity, evidence and confidence, affected
  files, risk, small-step plan, protecting tests, verification criteria.

## 3. Feature boundaries and shared state

- Cross-feature imports (`--features-dir`): a feature importing another feature's widgets,
  state, or data is a boundary breach; shared needs move down to a shared layer.
- Shared state: one owner per piece of state; global singletons or mutable statics shared across
  features; providers or blocs that read each other in a loop.
- Grep: `static .* = ` mutable statics in `lib/`; `GetIt.instance` in features; providers defined
  in one feature and watched in another.

## 4. Code quality and maintainability

- Analyzer output: errors and warnings are findings; check `analysis_options.yaml` for
  suppressed rules and `// ignore:` without reasons (`grep -rn "// ignore" lib`).
- Size and complexity: files over ~400 lines, `build()` methods over ~100 lines, functions with
  deep nesting — Low unless they hide defects.
- Duplication of business logic (the same rule implemented in two places) — Medium.
- Dead code: unused files (zero fan-in in the import graph and not an entrypoint), unused public
  members, commented-out code, `TODO` without an owner.
- Naming and consistency with the project's conventions.
- Hardcoded styles where a design system exists: `Color(0x`, `Colors.` (except
  `Colors.transparent`), raw `fontSize:`, `EdgeInsets.all(<number>)` outside the design-system
  folder.
- Prints and debug code: `grep -rnE "\bprint\(|debugPrint\(" lib` — check each for gating and
  personal data.
