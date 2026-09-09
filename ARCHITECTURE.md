# Architecture

This project is a Flutter template using **feature-first** layout and thin domain ports. It does not use a UseCase class per action.

## Layout

```text
lib/
  app/           bootstrap, router, composition root (DI + store_providers), debug preview
  core/          shared kernel — must not import features
    logging/     AppLog, Talker, dump
    crash_reporting/  CrashPolicy + CrashReporter; sentry/ is the vendor adapter
    analytics/        AnalyticsPolicy + AppAnalytics; posthog/ is the vendor adapter
  features/      one folder per business capability
    */domain/    entities and repository interfaces
    */data/      remotes, DTOs, stores, repository implementations
    */presentation/  pages and Riverpod notifiers
  l10n/          generated localizations (Flutter codegen)
tool/
  brand/         Go CLI: Dart package name, visible app name, bundle id, splash, launcher icon
```

`tool/brand` is a Go CLI at the repo root. It is not a Flutter feature: it must not import `lib/`, and Pages must not call it. Its Go module path is `brand`, not the Dart package name. `name` reads the current name from `pubspec.yaml` and rewrites `package:<that>/` imports, the README H1 (`# <pub>`), this file's seed phrase (`one seed name (...)`), and `.vscode/launch.json` `"name"` when it equals the Dart package. `display` writes the home-screen name per locale: Android `res/values/strings.xml` and `res/values-zh/strings.xml` (`app_name`); iOS `en.lproj/InfoPlist.strings` and `zh.lproj/InfoPlist.strings`. `--title` is required. `--title-zh` is optional; if omitted, Chinese uses the same string as `--title`, and the CLI says so. `AndroidManifest` `android:label` is `@string/app_name` in the template; `display` does not rewrite it. iOS `Info.plist` still holds the English `CFBundleDisplayName` / `CFBundleName` because that is the OS default when a locale has no `InfoPlist.strings`. This does not change the Dart package or in-app `appTitle` in `lib/l10n/*.arb`. Dart cannot drop `package:` imports — the template keeps one seed name (`github_module`) until you run `name`.

Persistence for auth and settings is a domain port (`AuthStore` / `SettingsStore`) with the I/O implementation in `features/session/data`. `core` stays free of feature types. Notifiers must not call `SharedPreferences` or Keychain directly.

## Dependency rules

1. A feature's **presentation** must not import another feature's **data**. Cross-feature access goes through domain types or providers in `app/di.dart`. The signed-in profile is `User`; nested GitHub identities (repo owner) are `UserRef` — both live in auth domain.
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
| `DebugLogView` | Talker UI for `/logs` | Pages importing `talker_flutter` |
| `CrashReporter` / `CrashPolicy` | What to upload (id only, no tokens) | Vendor option names |
| `sentry/` adapter | Map policy onto sentry_flutter | Pages importing `sentry_flutter` |
| `AppAnalytics` / `AnalyticsPolicy` | screen + named events (`login_*`, `logout`, `repo_load_more*`); GitHub login as user id | Autocapture, replay, HTTP events |
| `posthog/` adapter | Map policy onto posthog_flutter | Pages importing `posthog_flutter` |
| `LogDump` / `HttpLogDump` | Export + POST diagnostic dump | Using `dioProvider` (would log the dump) |
| `DioCacheInterceptor` | Browser-like GET cache from HTTP headers | Custom `refresh` / `noCache` flags or per-call `CacheOptions` |
| Native splash (`app/native_splash.dart`) | Keep the OS launch screen up through restore | Flutter splash Page; in-app theme colors; Pages importing `flutter_native_splash` |

## Startup

`bootstrap()` keeps the **OS launch splash** up (`FlutterNativeSplash.preserve`) while it creates a `ProviderContainer` and restores auth and settings, then `runApp` with `UncontrolledProviderScope` and `remove()` after the first frame. The container lives for the process. The Launch Screen uses GitHub's **wordmark** (`assets/splash/splash.png` / `splash_dark.png`), not the Invertocat. The **launcher icon** is the Invertocat (`dart run flutter_launcher_icons`, `assets/splash/logo.png`). Light/dark splash colors are OS appearances only (white / `#121212`), not the in-app theme seed. After changing either mark, `dart run flutter_native_splash:create` rewrites `LaunchScreen.storyboard`; bump `+buildNumber` and do a full `flutter run` so iOS does not keep a cached launch snapshot. Uninstalling the app does not clear Xcode DerivedData or the Simulator SpringBoard icon cache — after changing icons, `flutter clean` and a full `flutter run` are required. `flutter_launcher_icons` rewrites every `ASSETCATALOG_*` line in `project.pbxproj` to `AppIcon`; `ios/Flutter/Debug.xcconfig` and `Release.xcconfig` keep `GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES` so the catalog still compiles. There is no Flutter `/splash` route. Resources are generated by `dart run flutter_native_splash:create` (`flutter_native_splash.yaml`). `preserve` / `remove` live in `app/native_splash.dart`; Pages must not import `flutter_native_splash`. Restore failures are reported through `AppLog` and ignored so the app still starts logged-out with default settings. `FlutterError.onError` and `PlatformDispatcher.instance.onError` also go to `AppLog`. If `SENTRY_DSN` is set, `AppLog.report` also sends through `CrashReporter` (Sentry adapter). Empty DSN is a no-op; `bootstrap` warns once (`crash reporting: disabled`). What may be sent is defined in `CrashPolicy` (exception, stack, `source` tag, release, environment, GitHub login as user id — not PATs, request bodies, screenshots, or debug logs). Vendor flags live only under `lib/core/crash_reporting/sentry/`. If `POSTHOG_API_KEY` is set, `AppAnalytics` uses the PostHog adapter; empty key is a no-op and `bootstrap` warns once (`analytics: disabled`). Screens come from the GoRouter path (`/login`, `/settings`, `/repos`, `/profile` — not `/logs`). Login success/failure/logout are captured in `AuthNotifier`; repo load-more success/failure in `RepoListNotifier`. Identify uses GitHub login only. Autocapture, session replay, surveys, feature flags, lifecycle events, and exception tracking stay off (`AnalyticsPolicy`); crashes stay on Sentry. Debug flushes each event; release batches 20 / 30s and flushes when the app backgrounds (`AnalyticsLifecycle`). Vendor flags live only under `lib/core/analytics/posthog/`. App version comes only from `pubspec.yaml` (`YYYY.MINOR.PATCH+build`, Android Studio style) and is injected via `PackageInfo` at startup; do not duplicate it in Dart, Gradle, or Info.plist. Debug builds show a floating button that opens the full `/logs` page; release builds unlock the same page by double-tapping the version on Settings, holding 10 seconds, then double-tapping again. Upload goes through `LogDump` (not the GitHub Dio) to `LOG_DUMP_URL`. Targets are iOS and Android; there is no `web/` folder.

## Configuration

`AppConfig` in `core/network` holds the HTTP preset (base URL, timeouts) plus compile-time secrets (`LOG_DUMP_URL`, `SENTRY_DSN`, `POSTHOG_API_KEY` / `POSTHOG_HOST`). Empty secrets disable those sinks. `appConfigProvider` uses `AppConfig.resolve()` (`APP_ENV`, optional `API_BASE_URL`). Override the provider in tests; do not edit the `github` preset to point at a fake backend. Do not put keys in the `github` / `sandbox` constants.

```text
flutter run --dart-define=APP_ENV=sandbox
flutter run --dart-define=APP_ENV=sandbox --dart-define=API_BASE_URL=http://10.0.2.2:8080/
flutter run --dart-define=SENTRY_DSN=https://key@sentry.example/1
flutter run --dart-define=POSTHOG_API_KEY=phc_... --dart-define=POSTHOG_HOST=https://us.i.posthog.com
```

Needs a full restart (not hot reload). `MqttConfig` / `BleConfig` stay separate when those channels appear.

Debug snapshot preview lives in `app/preview.dart`. It overrides domain ports (never Dio or notifiers) so one UI state can be inspected. How to add a case: [ADD_FEATURE.md](ADD_FEATURE.md).

How to add a feature (HTTP, MQTT, or Bluetooth): [ADD_FEATURE.md](ADD_FEATURE.md).
