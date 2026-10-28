# Evidence and reporting

## Evidence labels — on every finding

| Label | Meaning | Example |
|---|---|---|
| **Verified** | Confirmed directly: read at `file:line`, shown by command output, or observed in a test or on a device | `lib/app/router.dart:42` has no auth redirect for `/settings` |
| **Graph-derived** | Supported by a graph relationship, with its provenance: Graphify `EXTRACTED`, `INFERRED`, or `AMBIGUOUS`, or `import-graph` for the Dart import analyser | Graphify path `MainActivity → AudioService` (`EXTRACTED`) |
| **Hypothesis** | A plausible issue that needs investigation; say what would confirm it | The token refresh may race when two requests return 401 together |

- An import or a graph edge shows a static relationship, not runtime behaviour. "A imports B" is
  Verified as an import; "A calls B at runtime" needs the call site or a test.
- Promote a graph-derived finding to Verified only after reading the source location.

## Severity

| Severity | Use for |
|---|---|
| **Critical** | Exploitable security flaw, leaked secret, data loss or corruption, crash on a core path, or a confirmed mandatory legal or store requirement unmet — blocks release |
| **High** | Broken core workflow, missing authorisation check, privacy disclosure that contradicts behaviour, accessibility barrier on a core flow, cycle or coupling that blocks planned work |
| **Medium** | Degraded behaviour, missing non-core state, maintainability risk with a clear cost |
| **Low** | Polish, consistency, minor cleanup |

## Finding format

```
### [SEVERITY] Short title
- Evidence (label, confidence High/Medium/Low): file:line, command output, or graph path
- Impact: who or what is affected, and how badly
- Recommended fix: the smallest correct change (refactor or refinement — see quality-check)
- Required tests: what proves the fix and prevents regression
- Verification: the exact steps or commands that show it is fixed
- Limitations: what was not checked and why
```

Separate **verified defects**, **recommendations** (improvements, no defect), and **suspected
issues** (hypotheses) into different sections.

## Reporting commands and checks

- Give the exact command, its exit status, and the relevant lines of output.
- A step that did not run is named with the reason (tool missing, not authorised, no tests yet).
- A partial run is reported as partial: "ran `test/features`: 214 passed, 0 failed; full suite
  left to CI". Never "all tests pass" after a partial run.
- Never claim a build, test, scan, audit, or policy check passed unless it ran and passed in this
  session.

## Facts that age

Store policies, laws, regulator guidance, SDK requirements, and target-API deadlines change.
Cite the official source URL and the date you checked it. Never invent a regulation, deadline,
or requirement; mark anything unconfirmed as **Needs Review**.

## Never promise outcomes

Never promise App Store or Google Play approval, legal compliance, or security. Say which
criteria were checked, what passed, and what remains uncertain.
