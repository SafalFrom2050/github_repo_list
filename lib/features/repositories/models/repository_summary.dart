class RepositorySummary {
  final int id;
  final String fullName;
  final String avatarUrl;

  const RepositorySummary({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
  });

  factory RepositorySummary.fromJson(Map<String, dynamic> json) {
    final owner = json["owner"] as Map<String, dynamic>;

    return RepositorySummary(
      id: json["id"] as int,
      fullName: json["fullName"] as String,
      avatarUrl: owner["avatarUrl"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "owner": {"avatar_url": avatarUrl},
    };
  }
}
