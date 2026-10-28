---
name: mobile-standards
description: Shared engineering rules for the flutter-mobile-kit skills and agents — repository safety, secrets and configuration, evidence labels, Graphify and Dart import-graph analysis, multi-agent ownership, and the definition of done. Load before running new-project, mobile-ui, quality-check, or global-compliance, and when a specialist agent starts work.
user-invocable: false
---

# Mobile engineering standards

These rules apply to every skill and agent in this kit. **The target project's own rules win
where they are stricter or more specific.** Before acting, read the project's `CLAUDE.md`,
`.claude/rules/`, project skills, `analysis_options.yaml`, and CI workflow, and use their
commands and conventions instead of the defaults here.

Reference files are in `${CLAUDE_SKILL_DIR}/references/`. Read only the one a task needs.

| Need | Read |
|---|---|
| Touching files, git, dependencies, or tooling | [repo-safety.md](references/repo-safety.md) |
| Config, environments, env files, keys, tokens, logs | [secrets-config.md](references/secrets-config.md) |
| Writing any finding, review, or report | [evidence-reporting.md](references/evidence-reporting.md) |
| Architecture, dependency paths, cycles, coupling, change impact | [graph-analysis.md](references/graph-analysis.md) |
| Splitting work across agents or workstreams | [agent-coordination.md](references/agent-coordination.md) |
| Deciding whether a task is finished | [definition-of-done.md](references/definition-of-done.md) |

Tools that ship with this skill:

- `${CLAUDE_SKILL_DIR}/scripts/dart_import_graph.dart` — read-only Dart import-graph analyser
  (cycles, cross-feature imports, forbidden directions, hubs, change impact). Usage is in
  [graph-analysis.md](references/graph-analysis.md).
- `${CLAUDE_SKILL_DIR}/templates/graphifyignore` — a starting `.graphifyignore`.

## Non-negotiables

1. **Inspect before changing.** Read the exact files and their tests, and run `git status` and
   `git diff` first. Preserve uncommitted and untracked work; never overwrite unrelated files.
   Explain a conflict instead of resolving it silently.
2. **Report first when asked.** A report-only request produces a report and stops. No edits,
   no fixes, no "while I was there".
3. **Git writes only on request.** No commit, push, merge, rebase, reset, tag, or branch
   deletion unless the user asked for it in this conversation. Never force-push or rewrite
   history. Where a project forbids git writes, print the exact commands for the user.
4. **Secrets stay unseen.** Never open, print, or copy `.env*` (except `.env.example`),
   keystores, `key.properties`, `*.p8`, `*.p12`, `*.pem`, provisioning profiles, or service
   account files. Anything compiled into a mobile binary is public.
5. **No installs without approval.** Never install, upgrade, initialise, or reconfigure tools
   or dependencies without the user's approval. Add a package only in the change that first
   uses it, with the requirement it serves.
6. **Never weaken a control to get green.** No disabled lints, skipped tests, `// ignore:`
   without a reason, relaxed TLS, or removed security checks.
7. **Evidence on every claim.** Label findings Verified, Graph-derived, or Hypothesis. Never
   claim a check, build, audit, or policy review passed when it did not run.
8. **Ask only what changes the work.** Infer the rest from the request and the repository,
   state the inference, and group questions (at most one round of a few per stage).

## Order of work for any change

1. Read the project's instructions and conventions (above).
2. Inspect the files to change, their callers, and their tests (`graph-analysis.md` for impact).
3. State the plan. Wait for approval where the invoking skill or the user requires it.
4. Make the smallest change that meets the requirement; follow existing patterns.
5. Add or update tests in the same change.
6. Run the project's gate: format → analyze → relevant tests (→ platform build for native changes).
7. Review the diff for unintended edits, secrets, debug output, and dead code.
8. Report: files changed, commands run with outcomes, and what was not verified.

If `.fvmrc` or `.fvm/` exists, prefix Flutter and Dart commands with `fvm`.
