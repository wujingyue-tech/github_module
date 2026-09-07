# Architecture

This project is a Flutter template using **feature-first** layout and thin domain ports. It does not use a UseCase class per action.

## Layout

```text
lib/
  app/           bootstrap, router, composition root (DI)
  core/          shared kernel — must not import features
  features/      one folder per business capability
    */domain/    entities and repository interfaces
    */data/      remotes, DTOs, stores, repository implementations
    */presentation/  pages and Riverpod notifiers
  l10n/          generated localizations (Flutter codegen)
```

Persistence for auth and settings lives in `features/session/data`. `core` stays free of feature types.

## Dependency rules

1. A feature's **presentation** must not import another feature's **data**. Cross-feature access goes through domain types or providers in `app/di.dart`.
2. **data** must not import presentation or Riverpod notifiers. Tokens are callbacks on interceptors or method arguments.
3. JSON **DTOs** must not leak into pages. Pages consume domain entities only.

```text
presentation → domain
data         → domain
data         → core
presentation → core
app          → features + core
core         → (nothing in features)
```

## Responsibilities

| Type | Does | Does not |
| --- | --- | --- |
| `GitHubAuthRemote` / `GitHubRepoRemote` | HTTP, DTO parse, `mapDioException` | Write session |
| `AuthRepository` / `RepoRepository` | DTO → entity | Hold Riverpod state |
| `AuthNotifier` | Login flow; persist via `SessionNotifier` | Call Dio |
| `SessionNotifier` / `SettingsNotifier` | Auth vs settings state + restore | Call GitHub |
| `dioProvider` | Assemble Dio + interceptors | `ref.watch` session inside interceptors |
| `DioCacheInterceptor` | Browser-like GET cache from HTTP headers | Custom `refresh` / `noCache` flags or per-call `CacheOptions` |

## Startup

`bootstrap()` creates a `ProviderContainer`, restores auth and settings, then calls `runApp` with `UncontrolledProviderScope`. The container lives for the process. It is disposed only if restore throws before `runApp`.

## Configuration

`AppConfig` in `core/network` holds base URL and timeouts. Swap it through `appConfigProvider` for flavors later.

How to add a feature (HTTP, MQTT, or Bluetooth): [ADD_FEATURE.md](ADD_FEATURE.md).
