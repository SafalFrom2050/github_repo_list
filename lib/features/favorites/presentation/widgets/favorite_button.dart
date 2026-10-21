import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_list/features/favorites/presentation/favorites_controller.dart';
import 'package:github_repo_list/features/repositories/models/repository_summary.dart';

class FavoriteButton extends ConsumerWidget {
  final RepositorySummary repository;

  const FavoriteButton({super.key, required this.repository});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesControllerProvider);

    if (favoritesState.hasError) {
      return IconButton(
        tooltip: 'Retry loading favorites',
        icon: const Icon(Icons.refresh),
        onPressed: () => ref.invalidate(favoritesControllerProvider),
      );
    }

    final favorites = favoritesState.asData?.value;
    final isFavorite = favorites?.containsKey(repository.id) ?? false;

    return IconButton(
      isSelected: isFavorite,
      icon: const Icon(Icons.star_border),
      selectedIcon: const Icon(Icons.star),
      tooltip: favorites == null
          ? 'Loading favorites'
          : isFavorite
          ? 'Remove from favorites'
          : 'Add to favorites',
      onPressed: favorites == null
          ? null
          : () async {
        final messenger = ScaffoldMessenger.of(context);

        try {
          await ref
              .read(favoritesControllerProvider.notifier)
              .toggle(repository);
        } catch (_) {
          if (!messenger.mounted) return;

          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Could not save favorites. Please try again.',
              ),
            ),
          );
        }
      },
    );
  }
}