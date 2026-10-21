import 'package:flutter_test/flutter_test.dart';
import 'package:github_repo_list/features/repositories/models/repository_summary.dart';

void main() {
  test('parses GitHub repository JSON', () {
    final json = <String, dynamic>{
      'id': 123,
      'full_name': 'safal sh',
      'owner': {
        'avatar_url': 'https://www.xyz.com/avatar.png',
      },
    };

    final repository = RepositorySummary.fromJson(json);

    expect(repository.id, 123);
    expect(repository.fullName, 'safal sh');
    expect(
      repository.avatarUrl,
      'https://www.xyz.com/avatar.png',
    );
  });
}