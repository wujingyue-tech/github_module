# learn_flutter

Flutter GitHub client used as a feature-first architecture template.

- [ARCHITECTURE.md](ARCHITECTURE.md): layout, dependency rules, and startup
- [ADD_FEATURE.md](ADD_FEATURE.md): how to add a feature, including MQTT and Bluetooth

HTTP environment (full restart, not hot reload):

```text
flutter run --dart-define=APP_ENV=sandbox
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/
flutter run --dart-define=SENTRY_DSN=https://key@sentry.example/1
```

