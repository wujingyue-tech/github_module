import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/app/log_console_host.dart';
import 'package:learn_flutter/app/router.dart';
import 'package:learn_flutter/core/theme/app_themes.dart';
import 'package:learn_flutter/features/session/presentation/settings_provider.dart';
import 'package:learn_flutter/l10n/app_localizations.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final settings = ref.watch(settingsProvider);
    final seed = settings.theme >= 0 && settings.theme < appThemes.length
        ? appThemes[settings.theme]
        : appThemes.first;
    final locale = switch (settings.locale) {
      'zh' => const Locale('zh'),
      'en' => const Locale('en'),
      _ => null,
    };
    final themeMode = switch (settings.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: (context, child) {
        return LogConsoleHost(
          router: router,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
