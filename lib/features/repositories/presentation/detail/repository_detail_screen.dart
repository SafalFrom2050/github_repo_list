import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_list/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:github_repo_list/features/repositories/data/github_rate_limit_exception.dart';
import 'package:github_repo_list/features/repositories/presentation/detail/repository_detail_provider.dart';

class RepositoryDetailScreen extends ConsumerWidget {
  final String fullName;

  const RepositoryDetailScreen({super.key, required this.fullName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(repositoryDetailProvider(fullName));

    return Scaffold(
      appBar: AppBar(title: const Text('Repository Details')),
      body: detailState.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is GithubRateLimitException
                      ? error.message
                      : 'Could not load repository details.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(repositoryDetailProvider(fullName));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (detail) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                foregroundImage: NetworkImage(detail.summary.avatarUrl),
                onForegroundImageError: (_, _) {},
                child: const Icon(Icons.person, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              detail.summary.fullName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Subscribers: ${detail.subscribersCount}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(child: FavoriteButton(repository: detail.summary)),
          ],
        ),
      ),
    );
  }
}
