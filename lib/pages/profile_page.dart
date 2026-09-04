import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_ext.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          TextButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            child: Text(l10n.signOut),
          ),
        ],
      ),
      body: auth.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(authErrorText(l10n, error), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(authProvider.notifier).refreshProfile(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.savedToken));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(authProvider.notifier).refreshProfile(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                _Header(user: user),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(user.bio!, style: Theme.of(context).textTheme.bodyLarge),
                ],
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatChip(
                      icon: Icons.folder_outlined,
                      label: l10n.publicRepos,
                      value: '${user.publicRepos}',
                    ),
                    _StatChip(
                      icon: Icons.lock_outlined,
                      label: l10n.privateRepos,
                      value: '${user.totalPrivateRepos}',
                    ),
                    _StatChip(
                      icon: Icons.people_outlined,
                      label: l10n.followers,
                      value: '${user.followers}',
                    ),
                    _StatChip(
                      icon: Icons.person_add_alt_outlined,
                      label: l10n.following,
                      value: '${user.following}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_hasText(user.company))
                  _InfoTile(
                    icon: Icons.business_outlined,
                    text: user.company!,
                  ),
                if (_hasText(user.location))
                  _InfoTile(
                    icon: Icons.location_on_outlined,
                    text: user.location!,
                  ),
                if (_hasText(user.blog))
                  _InfoTile(icon: Icons.link, text: user.blog!),
                if (_hasText(user.email))
                  _InfoTile(icon: Icons.mail_outlined, text: user.email!),
                if (user.createdAt.isNotEmpty)
                  _InfoTile(
                    icon: Icons.calendar_month_outlined,
                    text: l10n.joinedAt(_shortDate(user.createdAt)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String _shortDate(String iso) =>
    iso.length >= 10 ? iso.substring(0, 10) : iso;

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name?.isNotEmpty == true ? user.name! : user.login,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '@${user.login}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label $value'),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text),
    );
  }
}
