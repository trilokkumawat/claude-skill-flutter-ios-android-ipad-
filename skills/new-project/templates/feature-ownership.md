# Feature ownership — <Project name>

One block per meaningful feature. Shared files stay with the coordinator (mobile-standards
`agent-coordination.md`).

## <Feature name>

| Field | Value |
|---|---|
| Scope | <what the feature does and does not do> |
| Owner | `<feature>-specialist` agent · or workstream <name> |
| Screens and flow nodes | <S-20, S-21 …> |
| State owners | <providers / blocs / notifiers and what each owns> |
| Repository and API dependencies | <interfaces, methods, endpoints> |
| Models and persistence | <entities, DTOs, local tables or keys, retention> |
| Security and authorisation | <who may do what; server enforcement; data sensitivity> |
| Compliance rows | <CM-…, SR-…> |
| Acceptance criteria | <FR-… criteria IDs> |
| Tests | <unit, widget, integration files to add> |
| Owned paths (may edit) | <lib/features/<name>/…, test/features/<name>/…> |
| Read-only paths | <shared layers> |
| Interfaces agreed before work | <signatures / contracts> |
| Docs and graph impact | <docs to update; expected new edges; forbidden edges> |
| Depends on features | <none, or which and through which shared interface> |
