# Graph analysis — Graphify and the Dart import graph

Graph output is derived data. Source code and maintained architecture docs stay authoritative.

## Contents

1. Which tool covers what
2. Preconditions and safe settings
3. Graphify commands
4. Dart import-graph analyser
5. Flutter architecture investigation
6. Cycles, coupling, and change impact
7. Refactoring recommendations
8. Artifacts and what to commit

## 1. Which tool covers what

| Source | Covers | Does not cover |
|---|---|---|
| `dart_import_graph.dart` (this skill) | Dart `import` / `export` / `part` edges in `lib/`, `test/`, `integration_test/`; cycles; cross-feature and forbidden-direction imports; fan-in / fan-out; change impact on tests | Calls, runtime wiring (DI, routing tables built at runtime), non-Dart code |
| Graphify, code-only mode | Kotlin, Swift, Objective-C, JSON, YAML structure (Android and iOS hosts, platform channels' native side, configs) | **Dart is not parsed** (checked at Graphify 0.9.97 — re-check each upgrade with a small sample) |
| `grep` / reading code | Call sites, provider wiring, route tables, platform-channel names | Whole-repo structure at a glance |

For a Flutter app the Dart analyser carries the main analysis; Graphify adds the native side.
If a Graphify upgrade starts emitting Dart nodes, verify a sample of its edges against source
before relying on them.

## 2. Preconditions and safe settings

- Building a graph processes the repository: do it only when the user has authorised it for
  this repository. Querying an existing graph is read-only.
- Check availability: `command -v graphify || ls ~/.local/bin/graphify`, then
  `graphify --version`. If missing, say so and continue with the Dart analyser and `grep`. Never
  install it without approval (install steps: the new-project skill's `graphify-workflow.md`).
- Always run Graphify local and code-only, with no model backend and no query log:

  ```bash
  export GRAPHIFY_BACKEND=none GRAPHIFY_QUERY_LOG_DISABLE=1
  ```

- Honour `.gitignore`; add a `.graphifyignore` from `${CLAUDE_SKILL_DIR}/templates/graphifyignore`
  so build output, generated code, and secrets never enter the graph.
- When the repository must stay unchanged (a report-only audit), write output elsewhere:
  `GRAPHIFY_OUT=<scratch-dir>/graphify-out`.
- Never connect Graphify Cloud, an LLM backend, or an MCP server without explicit approval —
  that sends source-derived content off the machine.

## 3. Graphify commands (shell)

| Purpose | Command |
|---|---|
| Build (code only) | `graphify extract . --code-only` |
| Update after changes | `graphify update .` |
| Ask a question | `graphify query "what connects the audio service to the activity?"` |
| Path between two nodes | `graphify path "MainActivity" "AudioServiceHandler"` (add `--undirected` to ignore direction) |
| Explain a node | `graphify explain "LiveActivityBridge"` |
| Most-connected nodes | `graphify god-nodes` |
| Dependents of a node | `graphify affected "<node>"` |
| Visualise | `graphify export html` (default 5,000-node limit; `--node-limit N`) |

Name lookups exit `0` (answer), `3` (ambiguous — candidates listed), `4` (no such node).
Every edge carries a provenance tag: `EXTRACTED` (explicit in source), `INFERRED` (resolved or
derived — read the evidence), `AMBIGUOUS` (no single clear relationship — check source). A path
shows relationships in the graph; it does not prove the path executes at runtime.

Use scoped queries, paths, and explanations. Do not paste whole graphs into a report.

## 4. Dart import-graph analyser

Read-only; writes only to `--out`. Needs any Dart 3 SDK (`dart` or `fvm dart`).

```bash
dart run ${CLAUDE_SKILL_DIR}/scripts/dart_import_graph.dart --root <project> \
  [--format md|json] [--out <file>] [--features-dir lib/features] [--top 10] \
  [--forbid lib/domain:lib/data]... [--impact lib/path/file.dart]... [--fail-on-cycles]
```

- `--features-dir` — where feature folders live; imports between two features are reported.
- `--forbid from:to` — a dependency-direction rule; any import from a path under `from` to a path
  under `to` is a violation (repeatable). Derive the rules from the project's architecture doc.
- `--impact` — files that depend on the given file, directly or transitively, and the tests
  among them (the tests to run for a change).
- `--fail-on-cycles` — exit 1 when a cycle exists (for CI).

Output sections: cycles (with each edge's `file:line`, classified `cross-feature`,
`cross-layer`, or `local`), cross-feature imports, forbidden-direction imports, highest fan-in
and fan-out, unresolved internal imports (often generated files not yet built), most-used
external packages, and impact. Every edge is **Verified** as an import directive.

Limits: dynamic imports, runtime DI registration, and route tables built from data are invisible
to it; a commented-out import is ignored; an import inside a multi-line string that happens to
start a line could be misread (rare).

## 5. Flutter architecture investigation

Adapt to the codebase; do not assume a conventional layer exists. Locate each concern, then trace
paths such as **Screen → state owner → (use case / controller) → repository → API client or data
source → backend**.

| Concern | Where to look (`grep -rn` patterns) |
|---|---|
| Routes and guards | `GoRouter(`, `GoRoute(`, `ShellRoute`, `redirect:`, `onGenerateRoute`, `AutoRoute`, `Navigator.push` |
| Screens and widgets | `extends StatelessWidget`, `extends ConsumerWidget`, `extends StatefulWidget`, `Scaffold(` |
| State owners | Riverpod `Notifier`, `AsyncNotifier`, `Provider(`, `@riverpod`; Bloc `extends Bloc<`, `extends Cubit<`; `ChangeNotifier`; `ValueNotifier` |
| Dependency injection | `ProviderScope`, `overrides:`, `GetIt.instance`, `registerSingleton`, `injectable` |
| Repositories | `abstract class .*Repository`, `implements .*Repository`, `RepositoryImpl` |
| API and data sources | `http.Client`, `Dio(`, `@RestApi`, `GraphQLClient`, `WebSocketChannel`, `FirebaseFirestore` |
| Models and DTOs | `fromJson`, `toJson`, `@freezed`, `@JsonSerializable` |
| Local storage | `SharedPreferences`, `FlutterSecureStorage`, `Hive`, `Isar`, `drift`, `sqflite`, `ObjectBox` |
| Auth | `signIn`, `refreshToken`, `Authorization`, `401`, `GoogleSignIn`, `SignInWithApple` |
| Background and platform | `MethodChannel(`, `EventChannel(`, `Workmanager`, `onBackgroundMessage`, `audio_service`, `flutter_local_notifications` |
| Tests ↔ production | `--impact` on the production file; `grep -rl "<ClassName>" test integration_test` |

Investigation checklist for an existing app:

1. Screen and widget relationships (which screens own which widgets; shared widget layer).
2. State-owner dependencies (which providers/blocs read which; cycles between notifiers).
3. Repository interfaces and implementations (one interface, where it is bound).
4. API service and data-source relationships (one client or many; error mapping location).
5. Navigation and route configuration (guards, redirects, deep links).
6. Dependency injection and shared utilities.
7. Cross-feature dependencies (`--features-dir`).
8. Circular dependencies (analyser cycles; Graphify paths for native code).
9. High-coupling components and god nodes (fan-in × fan-out; `graphify god-nodes`).
10. High-risk refactoring areas and the tests each change would affect (`--impact`).

## 6. Cycles, coupling, and change impact

- **Cycle** — give the full path with each edge's `file:line`. Note its class: a
  `cross-feature` or `cross-layer` cycle is a boundary problem; a `local` cycle inside one
  folder is usually Low. Dart allows import cycles, so they compile; the cost is coupling,
  testability, and build order.
- **High coupling / god node** — a file with high fan-in *and* high fan-out, or a class many
  features reach into. Explain the dependency direction, the responsibilities it mixes, its blast
  radius (`--impact` count of files and tests), and a plausible extraction boundary.
- **Change impact** — before refactoring, list the dependents and the tests among them; those
  tests must be green before and after each step.

## 7. Refactoring recommendations

Every recommendation carries: finding and severity · evidence and confidence (label from
`evidence-reporting.md`) · affected files or modules · risk and likely impact · a small-step
refactor · the tests that protect behaviour · verification criteria (for example "cycle gone in
the analyser output; `--impact` test set green").

A report-only architecture audit never edits source.

## 8. Artifacts and what to commit

- Graphify writes `graphify-out/` (`graph.json`, `GRAPH_REPORT.md`, `graph.html`,
  `manifest.json`, `cache/`). Default: add `graphify-out/` to `.gitignore`.
- Commit graph output only after a team decision and a review for secrets and sensitive labels;
  the graph carries source-derived context and needs the same access controls as the source.
- Commit `.graphifyignore` (it is configuration, not output).
- Rebuild with `graphify update .` after significant changes; regenerate the Dart analyser report
  rather than editing it.
