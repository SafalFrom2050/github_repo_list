import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_list/app/dependencies.dart';
import 'package:github_repo_list/features/repositories/data/github_repository.dart';
import 'package:github_repo_list/features/repositories/presentation/search/search_state.dart';

class SearchController extends Notifier<SearchState> {
  late GithubRepository _repository;

  int _requestId = 0;

  @override
  SearchState build() {
    _repository = ref.watch(githubRepositoryProvider);

    ref.onDispose(() {
      _requestId++;
    });

    return const SearchState();
  }

  Future search(String input) async {
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

      state = SearchState(query: query, result: result);
    } catch (_) {
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      state = SearchState(
        query: query,
        errorMessage: "Something went wrong while loading the repositories.",
      );
    }
  }
}

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);
