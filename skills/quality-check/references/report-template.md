# Quality report template

```markdown
# Quality check — <project> (<scope>) — <YYYY-MM-DD>

## Summary
- Scope: <full | path | feature>; categories: <list>
- Working tree: <clean | n uncommitted files — audited as is>
- Counts: Critical <n> · High <n> · Medium <n> · Low <n>
- Release blockers: <none | finding IDs>

## Commands run
| Command | Exit | Result |
|---|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 0 | no changes needed |
| `flutter analyze` | 1 | 3 warnings (listed in Q-004) |
| `flutter test test/features` | 0 | 214 passed, 0 failed |

## Verified defects
### Q-001 [CRITICAL] <title>  — Fix
- Evidence (Verified, High): `lib/...:42` — <what the code does>
- Impact: <who / what / how bad>
- Recommended fix: <smallest correct change>
- Required tests: <tests>
- Verification: <steps / commands>
- Limitations: <what was not checked>

## Recommendations
### Q-0xx [MEDIUM] <title>  — Refactor | Refine
...

## Suspected issues (hypotheses)
### Q-0xx [HIGH?] <title>
- Evidence (Hypothesis, Low): <why it is suspected>
- To confirm: <what to check>

## Architecture and graph
- Cycles: <n> (<cross-feature n, cross-layer n, local n>) — details in Q-0xx
- Hubs: <top files with fan-in / fan-out>
- Tools: Dart import graph <ran / not run>; Graphify <version, ran / not installed / not authorised>

## Not checked
| Category / check | Reason |
|---|---|
| Profile-mode performance | needs a device run |
| iOS release build | not authorised to build |

## Remediation plan (awaiting approval)
| Order | Findings | Class | Owner / agent | Tests first |
|---|---|---|---|---|
| 1 | Q-001 | Fix | authentication-security-specialist | reproduce with failing test |
| 2 | Q-007, Q-009 | Refine | mobile-ui-specialist | widget tests for states |
| 3 | Q-012 | Refactor | coordinator + api-data-specialist | characterization tests on impact set |
```

After remediation, append an **Outcome** column to every finding: fixed · skipped (why) · no
change needed, with the verifying command.
