import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_list/app/dependencies.dart';
import 'package:github_repo_list/features/repositories/models/repository_detail.dart';

final repositoryDetailProvider = FutureProvider.autoDispose
    .family<RepositoryDetail, String>((ref, fullName) {
      final repository = ref.watch(githubRepositoryProvider);
      return repository.getRepositoryDetails(fullName: fullName);
    }, retry: (retryCount, error) => null);
