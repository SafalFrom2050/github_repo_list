import 'package:flutter_test/flutter_test.dart';
import 'package:github_repo_list/features/favorites/data/favorites_repository.dart';
import 'package:github_repo_list/features/repositories/models/repository_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePreferences extends Fake implements SharedPreferencesAsync {
  final Map<String, String> _storage;

  FakePreferences(this._storage);

  @override
  Future<String?> getString(String key) async => _storage[key];

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }
}

void main() {
  test('restores saved favorites through a new repository instance', () async {
    final storage = <String, String>{};

    const favorite = RepositorySummary(
      id: 123,
      fullName: 'safal sh',
      avatarUrl: 'https://www.xyz.com/avatar.png',
    );

    final repository = FavoritesRepository(
      preferences: FakePreferences(storage),
    );

    await repository.saveFavorites([favorite]);

    final reopenedRepository = FavoritesRepository(
      preferences: FakePreferences(storage),
    );

    final restored = await reopenedRepository.loadFavorites();

    expect(restored, hasLength(1));
    expect(restored.single.id, favorite.id);
    expect(restored.single.fullName, favorite.fullName);
    expect(restored.single.avatarUrl, favorite.avatarUrl);
  });
}