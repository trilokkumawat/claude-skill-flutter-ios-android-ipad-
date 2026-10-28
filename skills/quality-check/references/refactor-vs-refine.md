# Refactoring versus refining

Both improve existing code. They differ in what they promise about behaviour, how far they
reach, how they are verified, and how they are reviewed. Classifying each remediation correctly
keeps changes small, reviewable, and safe.

## Definitions

- **Refactoring** — changing the internal structure of code **without changing its observable
  behaviour**: same UI output, same state transitions, same API calls, same errors. Its purpose
  is to make future change cheaper: lower coupling, clearer boundaries, removed duplication,
  testability.
- **Refining** — improving the quality of what already exists **within its current
  structure**, accepting small, intended, documented changes in observable detail: clearer
  naming and copy, missing states, edge-case handling, accessibility, consistency with the
  design system, local performance.

Two neighbours complete the picture:

- **Fix** — corrects a defect: behaviour was wrong and becomes right.
- **Feature** — adds new capability. Out of scope for a quality remediation.

A *local refactor* (sometimes called tidying) is a refactor confined to one file or function —
extract a private widget, rename a local, inline a helper. It keeps the refactor's no-behaviour
promise with a small blast radius.

## Comparison

| Dimension | Refactoring | Refining |
|---|---|---|
| Promise about behaviour | Identical observable behaviour | Small, intended, documented improvement |
| Primary goal | Changeability: structure, coupling, boundaries | Quality: clarity, completeness, polish, consistency |
| Typical scope | Across files, modules, layers, or public interfaces | Inside one file, widget, or function; interfaces unchanged |
| Effect on the dependency graph | Edges move (imports, ownership, direction) | No edge changes — if edges move, it is a refactor |
| Risk and blast radius | Medium to high; callers you did not touch can break | Low to medium; mostly local |
| Test precondition | Characterization tests on the affected set, green before starting | Existing tests green, plus a test for the intended change |
| Execution | A sequence of small mechanical steps, each compiling and green | One focused change |
| Verification | Same tests green before and after; graph diff shows the intended structure; no behaviour diff | New or updated test proves the improvement; existing tests unchanged |
| Review | Architecture review; coordinator approval when shared or public interfaces move | Normal code review |
| Commit type | `refactor:` — never mixed with behaviour changes | `refine:` or `style:` / `perf:` / `docs:` as fits |
| When to schedule | Before a feature that the current structure blocks, or when coupling has a measured cost | Continuously, as part of normal work |
| Typical triggers | Cycles, god nodes, cross-feature imports, layer violations, duplicated business logic, untestable code, a widget calling an API | Unclear names, hardcoded styles, missing loading / empty / error / offline states, vague error copy, missing semantics, needless rebuilds |

## Decision rule

1. Does observable behaviour change (UI output, navigation, state transitions, network calls,
   stored data, errors shown)?
   - **Yes, because it was wrong** → **Fix**.
   - **Yes, as a small intended improvement** → **Refine**.
   - **Yes, new capability** → **Feature** (out of scope for remediation).
2. **No** behaviour change:
   - Structure moves across files, modules, layers, public interfaces, or graph edges →
     **Refactor**.
   - Confined to one file or function → **Local refactor**.

If one change needs both, split it: refactor first (behaviour preserved, tests green), then
refine or fix on the new structure.

## Flutter examples

| Change | Class |
|---|---|
| Move HTTP calls from a widget into a repository behind an interface | Refactor |
| Break a cycle between two features by moving a shared model into the domain layer | Refactor |
| Split a god provider into two state owners with the same public behaviour | Refactor |
| Replace a service locator lookup with constructor or provider injection | Refactor |
| Extract a private widget inside the same file to shorten `build()` | Local refactor |
| Replace literal colours and paddings with design tokens (same rendering) | Local refactor |
| Add an empty state and an offline banner to a list screen | Refine |
| Add semantics labels and enlarge a 32 dp tap target to 48 dp | Refine |
| Narrow rebuilds with `ref.watch(provider.select(...))` and `const` constructors | Refine (local performance) |
| Rewrite a vague error message to say what happened and what to do | Refine |
| The list showed deleted items after sync | Fix |

## Required tests by class

| Class | Before | After |
|---|---|---|
| Refactor | Characterization tests covering the `--impact` set (unit for logic, widget for screens) | Same tests unchanged and green; import-graph report shows the intended change |
| Local refactor | Existing tests for the file green | Same tests green |
| Refine | Existing tests green | A new or updated test for the improvement (state, label, message, rebuild count where practical) |
| Fix | A failing test that reproduces the defect | The test passes; surrounding tests green |

## Anti-patterns

- A "refactor" that also changes behaviour — reviewers cannot tell an intended change from a
  regression.
- Refining by moving files across layers — that is a refactor without its safeguards.
- Refactoring without characterization tests on the affected set.
- Large structural rewrites in one step; prefer extract → move → redirect callers → delete.
- Refactoring code no planned work touches, just to match a textbook layout.
