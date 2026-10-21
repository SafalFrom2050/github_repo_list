import 'package:github_repo_list/features/repositories/models/repository_summary.dart';

class RepositoryDetail {
  final RepositorySummary summary;
  final int subscribersCount;

  const RepositoryDetail({
    required this.summary,
    required this.subscribersCount,
  });

  factory RepositoryDetail.fromJson(Map<String, dynamic> json) {
    return RepositoryDetail(
      summary: RepositorySummary.fromJson(json),
      subscribersCount: json["subscribers_count"] as int,
    );
  }
}
