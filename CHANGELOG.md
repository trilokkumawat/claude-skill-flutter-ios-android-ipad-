# Changelog

All notable changes to this kit are recorded here. The plugin manifest carries no
`version`, so installs track the default branch; tag a release here when you want to
pin users to one.

## Unreleased

### Added

- `/new-project` — staged product discovery (identity, requirements, target markets,
  technical choices, app flow, architecture, graph baseline, approval and setup) with three
  approval gates and per-project feature-agent generation.
- `/global-compliance` — country and platform compliance assessment, invoked automatically
  by `/new-project`; six `docs/compliance/` templates and a release gate.
- `/mobile-ui` — design-system, component, and screen work for Android phones, iPhones,
  and iPads, with every screen state, responsive layout, and accessibility.
- `/quality-check` — report-first audit across fifteen categories, with a separate,
  approved remediation phase that classifies each fix as a refactor or a refinement.
- `mobile-standards` — shared rules loaded by every skill and agent: repository safety,
  secrets and configuration, evidence labels, graph analysis, agent coordination, and the
  definition of done.
- Twelve subagents: a project coordinator and eleven specialists.
- `dart_import_graph.dart` — a read-only Dart import-graph analyser (cycles, cross-feature
  imports, forbidden directions, hubs, unresolved imports, change impact), because Graphify
  does not parse Dart.
- `scripts/check_kit.dart` — structural self-check for the kit, plus a fixture test of the
  import-graph analyser.
