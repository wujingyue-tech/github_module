# github_module

Flutter GitHub client used as a feature-first architecture template. Ships iOS and Android only. SDK version is `.fvmrc` (currently 3.47.2); CI reads the same file.

- [ARCHITECTURE.md](ARCHITECTURE.md): layout, dependency rules, and startup
- [ADD_FEATURE.md](ADD_FEATURE.md): how to add a feature, including MQTT and Bluetooth

The launcher icon is GitHub's Invertocat (`assets/splash/logo.png`). The Launch Screen uses the GitHub **wordmark** (`assets/splash/splash.png` / `splash_dark.png`), not the same cat. After changing either, run `dart run flutter_native_splash:create` and `dart run flutter_launcher_icons`, then a full `fvm flutter run` (iOS caches the old launch snapshot if you only hot restart).

Copy `.dart_defines.json.example` to `.dart_defines.json` (gitignored) for Sentry DSN and PostHog. Empty keys disable those sinks. Needs a full restart, not hot reload.

Branding repeats (Dart package name, visible app name, bundle id, splash, icon) go through an **external** Go CLI ([`flutter_brand`](https://github.com/wujingyue-tech/flutter_brand)). It is not a Flutter feature and must not live under `lib/`. Put the command on `PATH`, then run it from this repo root (`fvm` if `.fvmrc` exists). `name` reads the current Dart package from `pubspec.yaml` and rewrites `package:<pub>/` imports, the README H1, the seed name in `ARCHITECTURE.md`, and `.vscode/launch.json` `"name"` when it matches that package. `display` writes the home-screen name per locale (Android `app_name` string resources, iOS `InfoPlist.strings`); omit `--title-zh` to use the same string for Chinese (the CLI reminds you). `AndroidManifest` `android:label` is `@string/app_name`. In-app `appTitle` stays in `lib/l10n/*.arb`. `package` sets Android `applicationId` / `namespace` and iOS `PRODUCT_BUNDLE_IDENTIFIER`. `splash` / `icon` copy images then run `flutter_native_splash:create` / `flutter_launcher_icons`, bump `+buildNumber`, and restore `GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES`. When cloning this template into a real app, run `name`, `display`, and `package` first:

```text
flutter_brand
flutter_brand name --pub my_app
flutter_brand display --title "My App" --title-zh "我的应用"
flutter_brand package --id com.example.myapp
flutter_brand splash --image path.png --image-dark path_dark.png
flutter_brand icon --image path.png
```

```text
flutter run --dart-define=APP_ENV=sandbox
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/
flutter run --dart-define=SENTRY_DSN=https://key@sentry.example/1
flutter run --dart-define=POSTHOG_API_KEY=phc_...
```

