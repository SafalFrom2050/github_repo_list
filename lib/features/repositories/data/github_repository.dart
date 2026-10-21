import 'package:github_repo_list/features/repositories/data/github_api_client.dart';
import 'package:github_repo_list/features/repositories/models/repository_search_page.dart';
import 'package:github_repo_list/features/repositories/models/repository_summary.dart';

class GithubRepository {
  final GithubApiClient _apiClient;

  static const pageSize = 10;

  GithubRepository({required GithubApiClient apiClient})
    : _apiClient = apiClient;

  Future<RepositorySearchPage> searchRepositories({
    required String query,
    int page = 1,
  }) async {
    final jsonResponse = await _apiClient.searchRepositories(
      query: query,
      page: page,
      perPage: pageSize,
    );

    final items = (jsonResponse["items"] as List)
        .map((item) => RepositorySummary.fromJson(item as Map<String, dynamic>))
        .toList();

    return RepositorySearchPage(
      items: items,
      totalCount: jsonResponse["total_count"] as int,
      incompleteResults: jsonResponse["incomplete_results"] as bool,
    );
  }
}
