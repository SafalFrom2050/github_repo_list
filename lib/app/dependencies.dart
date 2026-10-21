import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_list/features/favorites/data/favorites_repository.dart';
import 'package:github_repo_list/features/repositories/data/github_api_client.dart';
import 'package:github_repo_list/features/repositories/data/github_repository.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

final httpClientProvider = Provider<Client>((ref) {
  final client = Client();

  ref.onDispose(client.close);

  return client;
});

final githubApiClientProvider = Provider<GithubApiClient>((ref) {
  final client = ref.watch(httpClientProvider);

  return GithubApiClient(client: client);
});

final githubRepositoryProvider = Provider<GithubRepository>((ref) {
  final apiClient = ref.watch(githubApiClientProvider);
  return GithubRepository(apiClient: apiClient);
});

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return FavoritesRepository(preferences: preferences);
});
