# Technical architecture

## Contents

1. Existing-project inventory
2. Flutter and Dart versions
3. Decisions to make
4. Architecture by complexity
5. Dependency rules
6. Package justification

## 1. Existing-project inventory (read-only)

```bash
git status
cat .fvmrc 2>/dev/null; fvm list 2>/dev/null | head; flutter --version
sed -n '1,80p' pubspec.yaml
cat analysis_options.yaml 2>/dev/null
find lib -maxdepth 3 -type d | sort
find test integration_test -maxdepth 2 -type d 2>/dev/null | sort
ls android ios web macos linux windows 2>/dev/null
ls .github/workflows 2>/dev/null; ls docs 2>/dev/null
```

Record: SDK constraints, state management, routing, networking, persistence, DI, codegen,
flavours and entrypoints, test layout, CI, and the project's own rules (`CLAUDE.md`,
`.claude/rules/`). These are the conventions to keep.

## 2. Flutter and Dart versions

- Use the version the project pins (`.fvmrc`, `.fvm/fvm_config.json`, CI). For a new project,
  propose the current stable release and pin it with FVM (`fvm use <version>`), with approval.
- `environment: sdk:` in `pubspec.yaml` must match the pinned Dart version's range.
- Check the minimum Android API level and iOS deployment target the chosen Flutter release
  supports before promising device support.

## 3. Decisions to make

Give a recommendation, alternatives, and the trade-off for each. Prefer what the project already
uses.

| Decision | Common options | Choose by |
|---|---|---|
| State management | Riverpod · Bloc / Cubit · Provider · built-in (`ValueNotifier`, `setState`) | Team familiarity, testability, app size; one approach per app |
| Navigation | GoRouter · auto_route · Navigator 2 directly | Deep links, guards, nested navigation needs |
| Networking | `http` · Dio (interceptors) · generated clients from OpenAPI · Retrofit | Interceptor needs (auth refresh, retries), API contract tooling |
| Persistence | `shared_preferences` (prefs) · `flutter_secure_storage` (secrets) · drift / sqflite (relational) · other embedded databases (check maintenance status first) | Data shape, queries, migrations, encryption, offline needs |
| Dependency injection | Riverpod providers · get_it · constructor injection | Usually follows state management; avoid global service locators in features |
| Models and codegen | Hand-written immutable classes and sealed types · freezed + json_serializable | Model count, team tolerance for `build_runner` |
| Error model | `Result<T>` with a sealed `Failure` hierarchy mapped at the data boundary | Always: exceptions never escape the data layer; raw text never reaches users |
| Authentication | Backend sessions with access + refresh tokens · Firebase Auth · OAuth/OIDC provider · Sign in with Apple / Google | Backend, markets, store login-services rules |
| Authorisation | Server-enforced roles and permissions; client mirrors for UX | Always server-side |
| Validation | Client validators for UX; server validation authoritative | Always both |
| Observability | Gated debug logging · crash reporting · analytics (each declared in the data inventory) | Privacy requirements, metrics in the PRD |
| Environments | dev / staging / prod with separate backends and app IDs | Always for production apps |
| Flavours | Android `productFlavors` + iOS schemes / xcconfig; entrypoint per flavour or `--dart-define-from-file` | Team workflow, CI |
| Testing | Unit, widget, integration (`integration_test`), golden tests where design stability matters | Risk of each layer |
| CI | Format → analyze → test (+ coverage floor) → Android and iOS builds; secret scan | Hosting (GitHub Actions, Codemagic, Bitrise, …) |
| Version control and release | Trunk-based or short-lived branches; Conventional Commits; semantic versions; build numbers never reused | Team size and release cadence |
| Backend | Existing API · BaaS (Firebase, Supabase) · custom | Data residency, compliance, cost, team |

## 4. Architecture by complexity

**Small app or prototype** — feature-first with two layers:

```
lib/
  app/            app.dart, router.dart, theme/
  features/<name>/   <name>_screen.dart, <name>_controller.dart, <name>_repository.dart
  shared/         widgets/, utils/
```

**Medium to large app** — feature-first presentation, shared domain and data:

```
lib/
  app/            bootstrap, router, DI roots, environment
  core/           error/, result/, utils/, environment/
  design_system/  tokens/, theme/
  widgets/        shared stateless UI
  domain/         entities/, repositories/ (abstract), usecases/ (only where logic spans repositories)
  data/           remote/ (API clients), local/ (database, storage), dto/, repositories/ (impl)
  infrastructure/ platform/, notifications/, permissions/
  features/<name>/ presentation/ (screens, widgets, controllers / state)
test/             mirrors lib/
integration_test/ whole flows
```

Explain the trade-off: more layers buy isolation and testability at the cost of indirection.
Add a use-case layer only where logic genuinely spans repositories.

## 5. Dependency rules

- Direction: presentation → state owners → (use cases) → repository interfaces ← implementations
  → data sources. `domain/` imports nothing from `data/`, `features/`, or Flutter.
- Features never import another feature; shared needs move down to a shared layer.
- Navigation is owned by the router; state owners expose state, the routing layer reacts.
- Express the rules as import-analyser checks, for example:
  `--features-dir lib/features --forbid lib/domain:lib/data --forbid lib/domain:lib/features --forbid lib/data:lib/features`.

## 6. Package justification

For each proposed package record: the requirement it serves · why the SDK or existing code is not
enough · maintenance and publisher · licence · platforms · permissions and native SDKs it brings
(a compliance item) · alternatives considered. Add it with `flutter pub add` only in the change
that first uses it.
