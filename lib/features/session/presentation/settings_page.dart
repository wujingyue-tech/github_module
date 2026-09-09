import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:github_module/app/di.dart';
import 'package:github_module/app/hidden_log_unlock.dart';
import 'package:github_module/app/log_console_provider.dart';
import 'package:github_module/core/l10n/l10n_ext.dart';
import 'package:github_module/core/theme/app_themes.dart';
import 'package:github_module/features/session/presentation/settings_provider.dart';
import 'package:github_module/l10n/app_localizations.dart';

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
          const Divider(),
          const _UploadLogsTile(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Center(
              child: HiddenLogUnlock(
                holdDuration: ref.watch(hiddenLogHoldProvider),
                onUnlocked: () {
                  ref.read(logConsoleProvider.notifier).unlock();
                  context.push('/logs');
                },
                child: Text(
                  l10n.appVersion(ref.watch(appInfoProvider).label),
                  key: const Key('appVersion'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadLogsTile extends ConsumerStatefulWidget {
  const _UploadLogsTile();

  @override
  ConsumerState<_UploadLogsTile> createState() => _UploadLogsTileState();
}

class _UploadLogsTileState extends ConsumerState<_UploadLogsTile> {
  var _uploading = false;

  Future<void> _upload() async {
    if (_uploading) return;
    setState(() => _uploading = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final report = await ref.read(logDumpProvider).upload();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.uploadLogsSuccess(report.id))),
      );
    } catch (error, stackTrace) {
      ref.read(appLogProvider).report(error, stackTrace, 'log dump upload');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(authErrorText(l10n, error))),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.cloud_upload_outlined),
      title: Text(l10n.uploadLogs),
      enabled: !_uploading,
      trailing: _uploading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: _uploading ? null : _upload,
    );
  }
}
