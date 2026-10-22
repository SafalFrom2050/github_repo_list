import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_list/features/repositories/presentation/search/search_controller.dart';
import 'package:github_repo_list/features/repositories/presentation/search/search_state.dart';
import 'package:github_repo_list/features/repositories/presentation/widgets/repository_tile.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchControllerProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBar(
            hintText: 'Flutter, dart, ai-agent...',
            leading: const Icon(Icons.search),
            elevation: WidgetStatePropertyAll(0),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
            onSubmitted: (query) =>
                ref.read(searchControllerProvider.notifier).search(query),
            onChanged: (value) {
              if (value.trim().isEmpty) {
                ref.read(searchControllerProvider.notifier).search('');
              }
            },
          ),
        ),
        Expanded(child: _buildBody(context, searchState, ref)),
      ],
    );
  }

  Widget _buildBody(BuildContext context, SearchState state, WidgetRef ref) {
    if (state.query.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.travel_explore,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Discover repositories',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Search GitHub by keyword, or open Favorites '
                    'below to revisit your saved repositories.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorMessage = state.errorMessage;

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(searchControllerProvider.notifier).search(state.query);
              },
              child: Text("Retry"),
            ),
          ],
        ),
      );
    }

    final items = state.result?.items;

    if (items == null || items.isEmpty) {
      return const Center(child: Text('No Results'));
    }

    final showFooter =
        state.isLoadingMore || state.loadingMoreErrorMessage != null;

    void maybeLoadMore(ScrollMetrics metrics) {
      if (metrics.axis != Axis.vertical || metrics.extentAfter > 200) {
        return;
      }

      Future<void>.microtask(() {
        if (!context.mounted) return;

        final latest = ref.read(searchControllerProvider);

        if (latest.loadingMoreErrorMessage != null) return;

        ref.read(searchControllerProvider.notifier).loadNextPage();
      });
    }

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) {
        if (notification.depth == 0) {
          maybeLoadMore(notification.metrics);
        }
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 0) {
            maybeLoadMore(notification.metrics);
          }
          return false;
        },
        child: ListView.builder(
          itemCount: items.length + (showFooter ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == items.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: state.isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.loadingMoreErrorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(searchControllerProvider.notifier)
                                  .loadNextPage();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
              );
            }

            final repository = items[index];

            return RepositoryTile(repository: repository);
          },
        ),
      ),
    );
  }
}
