# Graphify workflow — setup and baseline

How to query and interpret graphs is in mobile-standards `graph-analysis.md`. This file covers
installation, registration, and when to build.

## Check before anything

```bash
command -v graphify || ls ~/.local/bin/graphify 2>/dev/null
graphify --version 2>/dev/null || ~/.local/bin/graphify --version
```

If Graphify is missing, report it and use the Dart import analyser alone. Do not install it
without the user's approval.

## Install (only with approval)

Official source: https://github.com/Graphify-Labs/graphify (PyPI package `graphifyy`, command
`graphify`). Re-read the current README before installing — the project releases often.

```bash
brew install uv                       # or the official uv installer, if the user prefers
uv tool install graphifyy==<version>  # pin the version you verified
~/.local/bin/graphify --version
```

- uv provides its own Python, so an older system Python is not a blocker.
- `uv tool update-shell` adds `~/.local/bin` to `PATH` by editing shell startup files — run it
  only with approval; otherwise call Graphify by its full path.
- Record the installed version in the project's docs.

## Assistant registration — optional, per project

`graphify install` registers a Graphify skill and **PreToolUse hooks that steer file reads
toward the graph**. Its default scope is the user's whole account, which changes behaviour in
every project. Prefer:

```bash
graphify install --project --platform claude
```

…and only when the user wants the hooks in that repository. The kit's agents work without it by
calling the CLI directly. Remove with `graphify uninstall` (check the current flags first).

## Safe defaults on every run

```bash
export GRAPHIFY_BACKEND=none GRAPHIFY_QUERY_LOG_DISABLE=1
graphify extract . --code-only
```

- Copy `.graphifyignore` from the mobile-standards `templates/graphifyignore` before the first
  build and adjust it to the project.
- Add `graphify-out/` to `.gitignore` unless the team decides to commit reviewed output.
- For a repository that must not change, set `GRAPHIFY_OUT` to a scratch directory.

## When to build

| Situation | Action |
|---|---|
| New project, Stage F | Define `--forbid` rules and feature folders; no graph yet |
| New project, after scaffolding (Gate 3) | Baseline: Dart import analyser (+ Graphify for native code); record zero cycles |
| Existing project, Stage A/F | With authorisation: analyser + Graphify; findings feed the architecture doc |
| After each increment that changes structure | Re-run the analyser; `graphify update .` |
| Before a refactor | `--impact` on the files to move; characterization tests on that set |

## Dart coverage

Graphify's code-only mode does not parse Dart (checked at 0.9.97). For Flutter, its graph covers
the Android and iOS hosts and configuration; the Dart import analyser covers `lib/`. After any
Graphify upgrade, run it on a small sample with one `.dart` file and check whether Dart nodes
appear before changing this guidance.
