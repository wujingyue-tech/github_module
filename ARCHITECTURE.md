# Architecture

This project is a Flutter template using **feature-first** layout and thin domain ports. It does not use a UseCase class per action.

## Layout

```text
lib/
  app/           bootstrap, router, composition root (DI), debug preview
  core/          shared kernel — must not import features
  features/      one folder per business capability
    */domain/    entities and repository interfaces
    */data/      remotes, DTOs, stores, repository implementations
    */presentation/  pages and Riverpod notifiers
  l10n/          generated localizations (Flutter codegen)
```

Persistence for auth and settings is a domain port (`AuthStore` / `SettingsStore`) with the I/O implementation in `features/session/data`. `core` stays free of feature types. Notifiers must not call `SharedPreferences` or Keychain directly.

## Dependency rules

1. A feature's **presentation** must not import another feature's **data**. Cross-feature access goes through domain types or providers in `app/di.dart`.
2. **data** must not import presentation or Riverpod notifiers. Tokens are callbacks on interceptors or method arguments.
3. JSON **DTOs** must not leak into pages. Pages consume domain entities only.

```text
presentation → domain
data         → domain
domain       → core   (shared kernel only, e.g. RequestCancel)
data         → core
presentation → core
app          → features + core
core         → (nothing in features)
```

## Responsibilities

| Type | Does | Does not |
| --- | --- | --- |
| `GitHubAuthRemote` / `GitHubRepoRemote` | HTTP, DTO parse, `mapDioException`, map Dio cancel | Write session |
| `AuthRepository` / `RepoRepository` | DTO → entity | Hold Riverpod state |
| `AuthNotifier` | Login flow; persist via `SessionNotifier` | Call Dio |
| `SessionNotifier` / `SettingsNotifier` | Auth vs settings state + restore | Open prefs / Keychain |
| `dioProvider` | Assemble Dio + interceptors | `ref.watch` session inside interceptors |
| `AppLog` / `TalkerAppLog` | Console + in-app log history | Pages calling Talker / `print` |
| `DioCacheInterceptor` | Browser-like GET cache from HTTP headers | Custom `refresh` / `noCache` flags or per-call `CacheOptions` |

## Startup

`bootstrap()` creates a `ProviderContainer`, restores auth and settings, then calls `runApp` with `UncontrolledProviderScope`. The container lives for the process. Restore failures are reported through `AppLog` and ignored so the app still starts logged-out with default settings. `FlutterError.onError` and `PlatformDispatcher.instance.onError` also go to `AppLog`. Debug builds can open Talker's log screen at `/logs` (Settings).

## Configuration

`AppConfig` in `core/network` holds base URL and timeouts. `appConfigProvider` uses `AppConfig.resolve()` (`APP_ENV`, optional `API_BASE_URL`). Override the provider in tests; do not edit the `github` preset to point at a fake backend.

```text
flutter run --dart-define=APP_ENV=sandbox
flutter run --dart-define=APP_ENV=sandbox --dart-define=API_BASE_URL=http://10.0.2.2:8080/
```

Needs a full restart (not hot reload). `MqttConfig` / `BleConfig` stay separate when those channels appear.

Debug snapshot preview lives in `app/preview.dart`. It overrides domain ports (never Dio or notifiers) so one UI state can be inspected. How to add a case: [ADD_FEATURE.md](ADD_FEATURE.md).

How to add a feature (HTTP, MQTT, or Bluetooth): [ADD_FEATURE.md](ADD_FEATURE.md).
