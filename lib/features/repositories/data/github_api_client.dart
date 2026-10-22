import 'dart:convert';

import 'package:github_repo_list/features/repositories/data/github_rate_limit_exception.dart';
import 'package:http/http.dart';


/// A client for interacting with the GitHub API. (Repository search and details endpoints)
class GithubApiClient {
  final Client _client;

  GithubApiClient({required Client client}) : _client = client;


  /// Fetches one page of repository search results matching [query].
  ///
  /// Throws [GithubRateLimitException] when GitHub limits requests.
  Future<Map<String, dynamic>> searchRepositories({
    required String query,
    int page = 1,
    int perPage = 30,
  }) {
    final uri = Uri.https('api.github.com', '/search/repositories', {
      'q': query,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });

    return _getJson(uri);
  }

  Future<Map<String, dynamic>> getRepositoryDetails({
    required String fullName,
  }) {
    final uri = Uri.https('api.github.com', '/repos/$fullName');

    return _getJson(uri);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _client
        .get(
          uri,
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2026-03-10',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (_isRateLimited(response)) {
      throw const GithubRateLimitException();
    }

    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode} : Failed to load repositories.',
      );
    }

    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON response.');
    }

    return jsonResponse;
  }

  bool _isRateLimited(Response response) {
    if (response.statusCode == 429) return true;
    if (response.statusCode != 403) return false;

    if (response.headers['x-ratelimit-remaining'] == '0' ||
        response.headers.containsKey('retry-after')) {
      return true;
    }

    try {
      final body = jsonDecode(response.body);
      final message = body is Map<String, dynamic>
          ? body['message']
          : null;

      return message is String &&
          message.toLowerCase().contains('rate limit');
    } on FormatException {
      return false;
    }
  }
}
