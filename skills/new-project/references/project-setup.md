# Project setup

Every step below needs the user's approval at Gate 3. List them with the exact commands first.
Inspect before each step; never overwrite existing files.

## New Flutter app

1. **Pin the SDK** (when FVM is used): `fvm use <stable-version>` — writes `.fvmrc`.
2. **Create the project**:

   ```bash
   fvm flutter create --org <reverse.domain> --project-name <snake_name> \
     --platforms android,ios --description "<one line>" <directory>
   ```

   Add `web`, `macos`, `windows`, or `linux` only when the PRD targets them. The bundle and
   application IDs derived from `--org` are hard to change after release — confirm them.
3. **Analysis**: keep `flutter_lints` (or the project's chosen lint set) in
   `analysis_options.yaml`; enable stricter rules the team agrees on.
4. **Environments and flavours**: dev / staging / prod — Android `productFlavors` with
   `applicationIdSuffix`, iOS schemes and `.xcconfig` per configuration, one entrypoint per flavour
   (`lib/main_dev.dart`, …) or `--dart-define-from-file=config/<env>.json` with public values only.
   A `config/*.example.json` or `.env.example` holds placeholders; real files are git-ignored.
5. **Folder structure** from the approved architecture doc; empty folders are not committed — create
   them with their first file.
6. **Base packages** — only those approved at Gate 2, each added with `flutter pub add` in the
   change that first uses it.
7. **Git hygiene** — extend `.gitignore` for env files, signing material, `graphify-out/`, and
   coverage output.
8. **CI** — a workflow running format check, analyze, tests (with a coverage floor if agreed),
   a secret scan, and Android and iOS debug builds.
9. **Project instructions** — a `CLAUDE.md` that records the stack, the gate commands, the
   architecture rules (pointing to `docs/architecture/architecture.md`), the git policy, and that
   the `flutter-mobile-kit` skills are used. Never overwrite an existing `CLAUDE.md`; propose a diff.
10. **Docs** — `README.md` (setup and run per flavour), `docs/product/`, `docs/architecture/`,
    `docs/compliance/` from the earlier gates.
11. **Feature agents** — generated into `.claude/agents/` from the approved feature list.
12. **Baseline checks** — format, analyze, the generated tests, the import-graph analyser with the
    agreed `--forbid` rules, and a debug build per platform. Report each result.

## Existing app

No scaffolding. Gate 3 covers only: the approved docs, any agreed `.gitignore` and CI additions,
feature agents, and the first increment of planned work. Never restructure folders without an
approved refactor plan (quality-check `refactor-vs-refine.md`).

## Monorepo (only when approved)

- Dart pub workspaces (a root `pubspec.yaml` with `workspace:` and `resolution: workspace` in each
  member) for shared packages; Melos only if its scripting is needed.
- Layout: `apps/<app>/`, `packages/<package>/`; each package has one owner and its own tests.
- A package is extracted only when a second consumer exists.

## Git

Inspect `git status` first. Do not commit, push, or create branches unless the user asks. When a
commit is the natural next step, print the commands, for example:

```bash
git add -A
git commit -m "chore: scaffold <app> with approved architecture"
git push -u origin <branch>
```
