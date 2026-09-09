# learn_flutter

Flutter GitHub client used as a feature-first architecture template. Ships iOS and Android only. SDK version is `.fvmrc` (currently 3.47.2); CI reads the same file.

- [ARCHITECTURE.md](ARCHITECTURE.md): layout, dependency rules, and startup
- [ADD_FEATURE.md](ADD_FEATURE.md): how to add a feature, including MQTT and Bluetooth

Native splash (light/dark) is generated from `flutter_native_splash.yaml`. After changing colors or `assets/splash/logo.png` / `logo_dark.png`, run `dart run flutter_native_splash:create` and `dart run flutter_launcher_icons`. It stays up until session restore finishes. The launcher icon uses the same Invertocat so iOS/Android do not zoom from Flutter's default mark first. Uninstall/reinstall is not enough: iOS keeps the old home-screen icon in SpringBoard and Xcode may reuse DerivedData — `fvm flutter clean` then a full `fvm flutter run` (not hot restart).

Copy `.dart_defines.json.example` to `.dart_defines.json` (gitignored) for Sentry DSN and PostHog. Empty keys disable those sinks. Needs a full restart, not hot reload.

```text
flutter run --dart-define=APP_ENV=sandbox
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/
flutter run --dart-define=SENTRY_DSN=https://key@sentry.example/1
flutter run --dart-define=POSTHOG_API_KEY=phc_...
```

