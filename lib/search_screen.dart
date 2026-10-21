import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_repo_list/features/repositories/presentation/search/search_controller.dart';
import 'package:github_repo_list/features/repositories/presentation/search/search_state.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchControllerProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (query) =>
                ref.read(searchControllerProvider.notifier).search(query),
            onChanged: (value) {
              if (value.trim().isEmpty) {
                ref.read(searchControllerProvider.notifier).search('');
              }
            },
          ),
        ),
        Expanded(child: _buildBody(searchState, ref)),
      ],
    );
  }

  Widget _buildBody(SearchState state, WidgetRef ref) {
    if (state.query.isEmpty) {
      return const Center(child: Text('Search for Repositories on Github'));
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorMessage = state.errorMessage;

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(searchControllerProvider.notifier).search(state.query);
              },
              child: Text("Retry"),
            ),
          ],
        ),
      );
    }

    final items = state.result?.items;

    if (items == null || items.isEmpty) {
      return const Center(child: Text('No Results'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final repository = items[index];
        return ListTile(
          leading: CircleAvatar(
            foregroundImage: NetworkImage(repository.avatarUrl),
            onForegroundImageError: (_, _) {},
            child: const Icon(Icons.person),
          ),
          title: Text(repository.fullName),
        );
      },
    );
  }
}
