# Architecture — <Project name>

Status: Draft · Approved (Gate 2, <YYYY-MM-DD>)

## Overview

<Two or three sentences: the shape of the app, the main layers, and why this level of
structure fits the product.>

## Technical decisions

| Area | Decision | Alternatives considered | Rationale | ADR |
|---|---|---|---|---|
| State management | <choice> | <options> | <why> | <ADR-000n> |
| Navigation | | | | |
| Networking | | | | |
| Persistence | | | | |
| Dependency injection | | | | |
| Models / codegen | | | | |
| Error model | | | | |
| Authentication | | | | |
| Observability | | | | |
| Environments and flavours | | | | |
| Testing and CI | | | | |

## Folder structure

```
lib/
  <tree>
test/
integration_test/
```

| Folder | Responsibility | May import | Must not import |
|---|---|---|---|
| `lib/app/` | <bootstrap, router, DI roots> | everything below | — |
| `lib/domain/` | <entities, repository interfaces> | `core/` | `data/`, `features/`, Flutter |
| `lib/data/` | <API clients, DTOs, repository impls> | `domain/`, `core/` | `features/` |
| `lib/features/<name>/` | <screens, widgets, state owners> | shared layers | other features |

## Dependency direction

presentation → state owners → (use cases) → repository interfaces ← implementations → data
sources → backend.

Enforced by the import analyser:

```bash
dart run <kit>/skills/mobile-standards/scripts/dart_import_graph.dart --root . \
  --features-dir lib/features --forbid lib/domain:lib/data --forbid lib/domain:lib/features \
  --forbid lib/data:lib/features --fail-on-cycles
```

## Ownership

| Concern | Owner | Notes |
|---|---|---|
| Navigation and guards | `lib/app/router*` | Controllers expose state; the router reacts |
| State | One owner per piece of state, inside its feature or `app/` for shared state | |
| Repositories and APIs | `lib/data/` behind `lib/domain/` interfaces | Return `Result<T>`; map failures at the boundary |
| Design system and shared UI | `lib/design_system/`, `lib/widgets/` | No literals outside the design system |
| Configuration | `lib/core/environment/` | Resolved once at startup |
| Platform integrations | `lib/infrastructure/platform/` | No platform checks scattered in UI |

## Testing locations

| Level | Location | Covers |
|---|---|---|
| Unit | `test/` mirroring `lib/` | Repositories, state owners, validators, mappers |
| Widget | `test/features/`, `test/widgets/` | Screen states, components, sizes, text scale, themes |
| Integration | `integration_test/` | Whole flows on device or emulator |

## Security model

<Summary of authentication, session lifecycle, token storage, server-side authorisation, and
links to `docs/compliance/security-requirements.md`.>

## Graph baseline

| Date | Files | Cycles | Cross-feature imports | Forbidden-direction imports | Tool versions |
|---|---|---|---|---|---|
| <YYYY-MM-DD> | <n> | 0 | 0 | 0 | <Dart analyser, Graphify version or "not installed"> |
