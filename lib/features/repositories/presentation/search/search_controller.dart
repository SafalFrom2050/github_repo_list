import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_list/app/dependencies.dart';
import 'package:github_repo_list/features/repositories/data/github_rate_limit_exception.dart';
import 'package:github_repo_list/features/repositories/data/github_repository.dart';
import 'package:github_repo_list/features/repositories/models/repository_search_page.dart';
import 'package:github_repo_list/features/repositories/presentation/search/search_state.dart';


/// Search and pagination state with protection against outdated responses.
class SearchController extends Notifier<SearchState> {
  late GithubRepository _repository;

  int _requestId =
      0; // identifies current search request. since we are only interested in the current request, older ones can be ignored.

  @override
  SearchState build() {
    _repository = ref.watch(githubRepositoryProvider);

    ref.onDispose(() {
      _requestId++;
    });

    return const SearchState();
  }

  Future<void> search(String input) async {
    final requestId = ++_requestId;
    final query = input.trim();

    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = SearchState(query: query, isLoading: true);

    try {
      final result = await _repository.searchRepositories(query: query);

      if (!ref.mounted || requestId != _requestId) {
        return;
      }

      state = SearchState(
        query: query,
        result: result,
        page: 1,
        hasMore: _hasMorePages(result, 1),
      );
    } catch (error) {
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      state = SearchState(
        query: query,
        errorMessage: error is GithubRateLimitException
            ? error.message
            : 'Could not load repositories.',
      );
    }
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    final currentResult = currentState.result;

    if (currentState.isLoadingMore ||
        currentState.isLoading ||
        !currentState.hasMore ||
        currentResult == null) {
      return;
    }

    final requestId = _requestId;
    final nextPageNumber = currentState.page + 1;

    state = SearchState(
      query: currentState.query,
      result: currentResult,
      page: currentState.page,
      hasMore: currentState.hasMore,
      isLoadingMore: true,
    );

    try {
      final nextPage = await _repository.searchRepositories(
        query: currentState.query,
        page: nextPageNumber,
      );

      if (!ref.mounted || requestId != _requestId) {
        return;
      }

      final seenIds = currentResult.items.map((item) => item.id).toSet();

      final combinedResult = RepositorySearchPage(
        items: [
          ...currentResult.items,
          ...nextPage.items.where((item) => seenIds.add(item.id)),
        ],
        totalCount: nextPage.totalCount,
        incompleteResults:
            currentResult.incompleteResults || nextPage.incompleteResults,
      );

      state = SearchState(
        query: currentState.query,
        result: combinedResult,
        page: nextPageNumber,
        hasMore: _hasMorePages(nextPage, nextPageNumber),
      );
    } catch (error) {
      if (!ref.mounted || requestId != _requestId) {
        return;
      }

      state = SearchState(
        query: currentState.query,
        result: currentResult,
        page: currentState.page,
        hasMore: currentState.hasMore,
        loadingMoreErrorMessage: error is GithubRateLimitException
            ? error.message
            : 'Could not load more. Please retry.',
      );
    }
  }

  bool _hasMorePages(RepositorySearchPage response, int page) {
    final fetchedCount = page * GithubRepository.pageSize;

    // 1000 limit is the Github enforced limit
    return response.items.isNotEmpty &&
        fetchedCount < response.totalCount &&
        fetchedCount < 1000;
  }
}

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);
