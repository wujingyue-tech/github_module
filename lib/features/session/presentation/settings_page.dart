import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter/core/l10n/l10n_ext.dart';
import 'package:learn_flutter/core/theme/app_themes.dart';
import 'package:learn_flutter/features/session/presentation/settings_provider.dart';
import 'package:learn_flutter/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioGroup<String?>(
            groupValue: settings.locale,
            onChanged: notifier.setLocale,
            child: Column(
              children: [
                RadioListTile<String?>(
                  value: null,
                  title: Text(l10n.languageSystem),
                ),
                RadioListTile<String?>(
                  value: 'zh',
                  title: Text(l10n.languageChinese),
                ),
                RadioListTile<String?>(
                  value: 'en',
                  title: Text(l10n.languageEnglish),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.appearance,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioGroup<String?>(
            groupValue: settings.themeMode,
            onChanged: notifier.setThemeMode,
            child: Column(
              children: [
                RadioListTile<String?>(
                  value: null,
                  title: Text(l10n.appearanceSystem),
                ),
                RadioListTile<String?>(
                  value: 'light',
                  title: Text(l10n.appearanceLight),
                ),
                RadioListTile<String?>(
                  value: 'dark',
                  title: Text(l10n.appearanceDark),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.themeColor,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < appThemes.length; i++)
                  FilterChip(
                    selected: settings.theme == i,
                    onSelected: (_) => notifier.setColorIndex(i),
                    avatar: CircleAvatar(backgroundColor: appThemes[i]),
                    label: Text(colorLabel(l10n, i)),
                    showCheckmark: false,
                    selectedColor: appThemes[i].withValues(alpha: 0.24),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
