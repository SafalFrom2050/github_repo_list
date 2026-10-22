import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_repo_list/app/dependencies.dart';
import 'package:github_repo_list/features/favorites/data/favorites_repository.dart';
import 'package:github_repo_list/features/favorites/presentation/favorites_screen.dart';
import 'package:github_repo_list/features/repositories/models/repository_summary.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  var loadResult = Completer<List<RepositorySummary>>();

  final saveResult = Completer<void>();

  @override
  Future<List<RepositorySummary>> loadFavorites() => loadResult.future;

  @override
  Future<void> saveFavorites(Iterable<RepositorySummary> favorites) =>
      saveResult.future;
}

void main() {
  testWidgets('shows loading, then an empty favorites message', (tester) async {
    final repository = FakeFavoritesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [favoritesRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: FavoritesScreen())),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No favorites yet'), findsNothing);

    repository.loadResult.complete([]);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets("shows a load error and retries after error", (tester) async {
    final repository = FakeFavoritesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [favoritesRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: FavoritesScreen())),
      ),
    );
    repository.loadResult.completeError(Exception('Storage error'));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No favorites yet'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Could not load favorites.'), findsOneWidget);

    repository.loadResult = Completer<List<RepositorySummary>>();

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No favorites yet'), findsNothing);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('Could not load favorites.'), findsNothing);

    repository.loadResult.complete([]);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No favorites yet'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('Could not load favorites.'), findsNothing);
  });

  testWidgets("restores a favorite and shows an error when saving fails", (
    tester,
  ) async {
    final repository = FakeFavoritesRepository();
    const favorite = RepositorySummary(
      id: 123,
      fullName: 'safal sh',
      avatarUrl: 'https://www.xyz.com/avatar.png',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [favoritesRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: FavoritesScreen())),
      ),
    );

    repository.loadResult.complete([favorite]);

    await tester.pumpAndSettle();

    expect(find.text('safal sh'), findsOneWidget);

    // simulate removing the favorites
    await tester.tap(find.byTooltip('Remove from favorites'));
    await tester.pump();

    expect(find.text('safal sh'), findsNothing);
    expect(find.text('No favorites yet'), findsOneWidget);

    // simulate a failed save
    repository.saveResult.completeError(Exception("Storage error"));
    await tester.pumpAndSettle();

    expect(find.text('safal sh'), findsOneWidget);
    expect(find.text('No favorites yet'), findsNothing);

    expect(find.text('Could not save favorites. Please try again.'), findsOneWidget);

  });
}
