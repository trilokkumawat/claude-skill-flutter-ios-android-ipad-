# Definition of done

A feature or change is done only when every applicable line holds. Name each line that does not
apply and why.

## Requirements and design

- [ ] Requirements and acceptance criteria are documented.
- [ ] Screen and app-flow behaviour is agreed (entry, exit, actions, states).
- [ ] State ownership and interfaces are defined; no business logic, API calls, or storage
      access inside widgets.

## Implementation

- [ ] Input is validated on the client for usability and on the server for safety.
- [ ] Loading, empty, error, offline, and success states are handled; failures are mapped to
      friendly messages, never raw exception text.
- [ ] No secrets, test credentials, debug output, commented-out code, or dead code.
- [ ] New dependencies are justified, reviewed, and declared (permissions, privacy, licences).

## Verification

- [ ] Unit tests for logic, widget tests for UI states, integration tests for whole flows where
      the change crosses screens or platforms.
- [ ] Format, analyze (zero errors, zero warnings), and the relevant tests ran and passed — or
      the failure is reported with its output.
- [ ] Platform build ran for native changes (Android and/or iOS).
- [ ] Accessibility checked where UI changed: labels, 48 dp / 44 pt targets, 200% text scale,
      contrast, reduced motion.
- [ ] Responsive layout checked on a small phone, a large phone, and an iPad where targeted.
- [ ] Security reviewed where sensitive functionality changed (auth, tokens, storage, payments,
      personal data, permissions).
- [ ] Compliance docs updated where data collection, permissions, SDKs, target markets, or store
      declarations changed (`docs/compliance/`).

## Documentation and architecture

- [ ] README and `docs/` reflect the change (setup, architecture, API, decisions).
- [ ] Graph impact checked when architecture changed: no new cycles, no new cross-feature or
      forbidden-direction imports (`dart_import_graph.dart`).
- [ ] The final diff was reviewed for unintended changes.

## Reporting

- [ ] Exact commands and outcomes are listed; skipped and partial checks are named.
- [ ] Nothing is described as verified, passing, compliant, or approved without evidence.
