import 'package:flutter/material.dart';
import 'package:github_repo_list/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:github_repo_list/features/repositories/models/repository_summary.dart';
import 'package:github_repo_list/features/repositories/presentation/detail/repository_detail_screen.dart';

class RepositoryTile extends StatelessWidget {
  final RepositorySummary repository;

  const RepositoryTile({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        foregroundImage: NetworkImage(repository.avatarUrl),
        onForegroundImageError: (_, _) {},
        child: const Icon(Icons.person),
      ),
      title: Text(repository.fullName),
      trailing: FavoriteButton(repository: repository),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RepositoryDetailScreen(
              fullName: repository.fullName,
            ),
          ),
        );
      },
    );
  }
}