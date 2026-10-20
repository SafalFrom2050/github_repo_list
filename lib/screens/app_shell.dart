import 'package:flutter/material.dart';
import 'package:github_repo_list/favorites_screen.dart';
import 'package:github_repo_list/search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_selectedIndex == 0 ? "Search" : "Favorites")),

      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [SearchScreen(), FavoritesScreen()],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            label: "Search",
          ),
          NavigationDestination(
            icon: Icon(Icons.stars),
            label: "Favorites",
          ),
        ],
      ),
    );
  }
}
