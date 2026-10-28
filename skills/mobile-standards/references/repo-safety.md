# Repository safety

## Before any change

- `git status` and `git diff` (staged and unstaged). Note untracked files — they are someone's
  work. If the tree is shared with other sessions, re-read a file immediately before editing it.
- Read every file you will change in full, plus its direct callers and tests.
- Confirm the change is inside the requested scope. Unrelated improvements become a note in the
  report, not an edit.

## Editing

- Smallest reviewable change; one concern per change. Keep it reversible.
- Never hand-edit generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.mocks.dart`,
  `GeneratedPluginRegistrant.*`); regenerate them with the project's generator.
- Never modify read-only references (design exports, vendored code, licences) unless asked.
- On an unexpected conflict — the file changed since you read it, or the change collides with
  uncommitted work — stop and explain; do not overwrite.
- Format only the files you changed when other work is in flight in the same tree.

## Git

| Allowed without asking | Only when the user asks in this conversation | Never |
|---|---|---|
| `status`, `log`, `diff`, `show`, `blame`, `grep`, `ls-files`, `rev-parse`, `branch --list`, `remote -v`, `fetch` | `add`, `commit`, `push`, `merge`, `rebase`, `tag`, `branch -d`, `stash`, `checkout`/`switch`, `pull` | `push --force`, history rewrites (`filter-branch`, `reset --hard` on shared history, `rebase` of pushed commits), deleting remote branches, bypassing hooks (`--no-verify`) |

- When a commit, branch, or PR is the right next step and git writes are not authorised, print
  the exact commands for the user and continue.
- Conventions when the project has none: branches `feat/<scope>`, `fix/<scope>`,
  `refactor/<scope>`, `chore/<scope>`; Conventional Commits messages (`feat:`, `fix:`,
  `refactor:`, `docs:`, `test:`, `chore:`). Keep refactors and behaviour changes in separate
  commits.
- Significant changes merge only after review and a green gate.

## Dependencies

1. Check `pubspec.yaml` first — reuse what is there.
2. Justify a new package by the requirement it serves and why existing code or the SDK is not
   enough.
3. Review it: maintenance activity, verified publisher, licence compatibility, platform support,
   null safety, transitive dependencies, and the permissions or native SDKs it merges into the
   app (each is a privacy and store-declaration item).
4. Add it with `flutter pub add <pkg>` (or `fvm flutter pub add`) so the version resolves against
   the pinned SDK. Never hand-write a version from memory.
5. Never upgrade unrelated dependencies, the Flutter/Dart SDK, Gradle, AGP, Kotlin, `compileSdk`,
   `targetSdk`, CocoaPods, or the iOS deployment target unless the change requires it.

## Tools and scripts

- Do not install, upgrade, or initialise tools (Graphify, uv, CocoaPods, linters, scanners)
  without approval. When approved: pin the version, prefer user- or project-local installs, and
  record what was installed where.
- Do not run project scripts whose effects are unknown. Read them first.
- No destructive commands (`rm -rf`, `git clean -fdx`, `flutter clean` on a shared tree,
  `pod deintegrate`) without approval.
- A test run killed for memory exits silently and looks like a hang: run per directory or with
  a lower `--concurrency`, and report each chunk.

## Report-only requests

A request to inspect, audit, review, or report is read-only. Commands that only read (analyze,
`dart format --output=none --set-exit-if-changed`, `git diff`, graph queries) are fine. Running
tests writes build caches but not source — say so when you run them. Graph builds write
`graphify-out/` — run them only when authorised, and point `GRAPHIFY_OUT` outside a repository
that must stay unchanged.
