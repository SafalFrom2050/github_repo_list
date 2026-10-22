class GithubRateLimitException implements Exception{
  const GithubRateLimitException();

  String get message => 'Github rate limit exceeded. Please wait before trying again.';

  @override
  String toString() => message;
}