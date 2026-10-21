import 'package:github_repo_list/features/repositories/models/repository_search_page.dart';

class SearchState {
  final String query;
  final bool isLoading;
  final RepositorySearchPage? result;
  final String? errorMessage;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });
}
