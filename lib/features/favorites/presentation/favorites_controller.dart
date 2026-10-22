import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_list/app/dependencies.dart';
import 'package:github_repo_list/features/favorites/data/favorites_repository.dart';
import 'package:github_repo_list/features/repositories/models/repository_summary.dart';


/// Responsible for syncing favorites across screens and the shared preferences.
class FavoritesController
    extends AsyncNotifier<Map<int, RepositorySummary>> {
  late FavoritesRepository _repository;

  Future<void> _saveQueue = Future<void>.value();
  Map<int, RepositorySummary> _lastSaved = const {};
  int _changeId = 0;

  @override
  Future<Map<int, RepositorySummary>> build() async {
    final buildId = ++_changeId;
    final repository = ref.watch(favoritesRepositoryProvider);
    _repository = repository;

    await _saveQueue;
    final favorites = await repository.loadFavorites();

    final byId = Map<int, RepositorySummary>.unmodifiable({
      for (final repository in favorites) repository.id: repository,
    });

    if (ref.mounted && buildId == _changeId) {
      _lastSaved = byId;
    }

    return byId;
  }

  Future<void> toggle(RepositorySummary repository) async {
    final current = state.asData?.value;

    if (current == null) {
      throw StateError('Favorites are not loaded yet.');
    }

    final updated = Map<int, RepositorySummary>.of(current);

    if (updated.containsKey(repository.id)) {
      updated.remove(repository.id);
    } else {
      updated[repository.id] = repository;
    }

    final next = Map<int, RepositorySummary>.unmodifiable(updated);
    final changeId = ++_changeId;
    final storage = _repository;

    // Update all listening screens immediately.
    state = AsyncData(next);

    // Save snapshots in the order the user tapped.
    final save = _saveQueue.then((_) async {
      await storage.saveFavorites(next.values);
      _lastSaved = next;
    });

    // Allow later saves to continue after a failure.
    _saveQueue = save.catchError(
          (Object error, StackTrace stackTrace) {},
    );

    try {
      await save;
    } catch (_) {
      // makes sure that the failed save is the latest change before updating the state. if no longer the latest one, ignore the error.
      if (ref.mounted && changeId == _changeId) {
        state = AsyncData(_lastSaved);
      }

      rethrow;
    }
  }
}

final favoritesControllerProvider =
AsyncNotifierProvider<FavoritesController, Map<int, RepositorySummary>>(
  FavoritesController.new,
  retry: (retryCount, error) => null,
);