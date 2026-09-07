import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_flutter/core/l10n/l10n_ext.dart';
import 'package:learn_flutter/features/repos/domain/repo.dart';
import 'package:learn_flutter/features/repos/presentation/repo_list_provider.dart';
import 'package:learn_flutter/l10n/app_localizations.dart';

class RepoListPage extends ConsumerWidget {
  const RepoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repos = ref.watch(repoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reposTitle),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: repos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: authErrorText(l10n, error),
          onRetry: () => ref.read(repoListProvider.notifier).refresh(),
          retryLabel: l10n.retry,
        ),
        data: (data) {
          if (data.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.read(repoListProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: Center(child: Text(l10n.reposEmpty)),
                  ),
                ],
              ),
            );
          }
          final showFooter = data.hasMore || data.loadMoreError != null;
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (data.loadMoreError == null &&
                  notification.metrics.extentAfter < 240) {
                ref.read(repoListProvider.notifier).loadMore();
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () => ref.read(repoListProvider.notifier).refresh(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: data.items.length + (showFooter ? 1 : 0),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index >= data.items.length) {
                    return _LoadMoreFooter(
                      error: data.loadMoreError,
                      onRetry: () =>
                          ref.read(repoListProvider.notifier).retryLoadMore(),
                    );
                  }
                  return _RepoTile(repo: data.items[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RepoTile extends StatelessWidget {
  const _RepoTile({required this.repo});

  final Repo repo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final description = repo.description?.trim();

    return ListTile(
      isThreeLine: true,
      title: Row(
        children: [
          Expanded(
            child: Text(
              repo.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (repo.private)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                l10n.repoPrivate,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            (description == null || description.isEmpty)
                ? l10n.repoNoDescription
                : description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            [
              if (repo.language != null) repo.language!,
              l10n.starCount(repo.stargazersCount),
              l10n.forkCount(repo.forksCount),
            ].join(' · '),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (error == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(authErrorText(l10n, error!), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
