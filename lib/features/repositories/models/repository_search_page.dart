import 'package:github_repo_list/features/repositories/models/repository_summary.dart';

class RepositorySearchPage {
  final List<RepositorySummary> items;
  final int totalCount;
  final bool incompleteResults;

  RepositorySearchPage({
    required List<RepositorySummary> items,
    required this.totalCount,
    required this.incompleteResults,
  }) : items = List.unmodifiable(items);
}
