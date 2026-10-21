import 'dart:convert';

import 'package:http/http.dart';

class GithubApiClient {
  final Client _client;

  GithubApiClient({required Client client}) : _client = client;

  Future<Map<String, dynamic>> searchRepositories({
    required String query,
    int page = 1,
    int perPage = 10,
  }) async {
    final uri = Uri.https('api.github.com', '/search/repositories', {
      'q': query,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });

    final response = await _client
        .get(
          uri,
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2026-03-10',
          },
        )
        .timeout(const Duration(seconds: 15));

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
}
