import 'package:github_repo_list/features/repositories/models/repository_search_page.dart';

class SearchState {
  final String query;
  final bool isLoading;
  final RepositorySearchPage? result;
  final String? errorMessage;

  // pagination
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadingMoreErrorMessage;
  //

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.result,
    this.errorMessage,
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadingMoreErrorMessage,
  });
}
