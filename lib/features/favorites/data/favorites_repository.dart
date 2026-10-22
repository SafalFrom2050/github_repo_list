import 'dart:convert';

import 'package:github_repo_list/features/repositories/models/repository_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Local persistence for favorite repository summaries.
class FavoritesRepository {
  final SharedPreferencesAsync _preferences;

  static const _storageKey = 'favorite_repositories_v1';

  FavoritesRepository({required SharedPreferencesAsync preferences})
    : _preferences = preferences;

  Future<List<RepositorySummary>> loadFavorites() async {
    final stored = await _preferences.getString(_storageKey);

    if (stored == null) {
      return [];
    }

    final decoded = jsonDecode(stored);

    if (decoded is! List) {
      throw const FormatException('Invalid favorites data.');
    }

    return List<RepositorySummary>.unmodifiable(
      decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid favorites data.');
        }

        return RepositorySummary.fromJson(item);
      }),
    );
  }

  Future<void> saveFavorites(Iterable<RepositorySummary> favorites) async {
    final items = favorites.map((repository) => repository.toJson()).toList();

    await _preferences.setString(_storageKey, jsonEncode(items));
  }
}
